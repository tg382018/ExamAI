import { Router, Response } from 'express';
import { Queue } from 'bullmq';
import prisma from '../config/prisma';
import { authMiddleware, AuthRequest } from '../middleware/auth';
import { generateDraftPlan } from '../services/llm';
import { redisConnectionOptions } from '../config/redis';

const router = Router();
router.use(authMiddleware);

export const examQueue = new Queue('exam-generation', { connection: redisConnectionOptions });

// POST /exam/draft — Fast AI plan suggestion
router.post('/draft', async (req: AuthRequest, res: Response) => {
    try {
        const { prompt } = req.body;
        if (!prompt) return res.status(400).json({ error: 'prompt zorunlu' });
        const plan = await generateDraftPlan(prompt);
        return res.json({ suggested: plan });
    } catch (err) {
        console.error('[Draft]', err);
        return res.status(500).json({ error: 'Plan oluşturulamadı' });
    }
});

// POST /exam — Confirm & queue exam generation
router.post('/', async (req: AuthRequest, res: Response) => {
    try {
        const { prompt, title, questionCount, durationMin, difficulty, outline } = req.body;
        if (!prompt || !title) return res.status(400).json({ error: 'prompt ve title zorunlu' });
        const exam = await prisma.exam.create({
            data: {
                userId: req.userId!,
                title,
                prompt,
                status: 'QUEUED',
                durationMin: durationMin || 30,
                questionCount: questionCount || 10,
                difficulty: difficulty || 'mixed',
            },
        });
        await examQueue.add('generate', { examId: exam.id, prompt, plan: { title, questionCount, durationMin, difficulty, outline } }, {
            attempts: 3,
            backoff: { type: 'exponential', delay: 10000 },
        });
        return res.status(201).json({ examId: exam.id, status: 'QUEUED' });
    } catch (err) {
        console.error('[Exam Create]', err);
        return res.status(500).json({ error: 'Sınav oluşturulamadı' });
    }
});

// GET /exams — List user's exams
router.get('/', async (req: AuthRequest, res: Response) => {
    try {
        const exams = await prisma.exam.findMany({
            where: { userId: req.userId! },
            orderBy: { createdAt: 'desc' },
            select: {
                id: true, title: true, status: true, durationMin: true,
                questionCount: true, difficulty: true, createdAt: true,
                attempts: { select: { score: true }, orderBy: { finishedAt: 'desc' }, take: 1 },
            },
        });
        const result = exams.map((e: any) => ({
            ...e,
            lastScore: e.attempts[0]?.score ?? null,
        }));
        return res.json(result);
    } catch (err) {
        console.error('[Exam List]', err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

// GET /exams/:id — Exam detail
router.get('/:id', async (req: AuthRequest, res: Response) => {
    try {
        const exam = await prisma.exam.findFirst({
            where: { id: req.params.id as string, userId: req.userId! },
            include: {
                questions: {
                    orderBy: { orderIndex: 'asc' },
                    select: {
                        id: true, orderIndex: true, text: true, options: true,
                        difficulty: true, topicTag: true,
                        // correctOption & explanation hidden until attempt submitted
                    },
                },
            },
        });
        if (!exam) return res.status(404).json({ error: 'Sınav bulunamadı' });
        return res.json(exam);
    } catch (err) {
        console.error('[Exam Detail]', err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

// GET /exams/:id/solutions — Answer key + explanations (after attempt)
router.get('/:id/solutions', async (req: AuthRequest, res: Response) => {
    try {
        const attempt = await prisma.attempt.findFirst({
            where: { examId: req.params.id as string, userId: req.userId!, finishedAt: { not: null } },
        });
        if (!attempt) return res.status(403).json({ error: 'Sınavı tamamlamadan çözümleri göremezsiniz' });
        const questions = await prisma.question.findMany({
            where: { examId: req.params.id as string },
            orderBy: { orderIndex: 'asc' },
        });
        return res.json(questions);
    } catch (err) {
        console.error('[Solutions]', err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

// GET /exams/:id/summary — AI summary
router.get('/:id/summary', async (req: AuthRequest, res: Response) => {
    try {
        const exam = await prisma.exam.findFirst({
            where: { id: req.params.id as string, userId: req.userId! },
            select: { aiSummary: true, status: true },
        });
        if (!exam) return res.status(404).json({ error: 'Sınav bulunamadı' });
        if (exam.status !== 'READY') return res.status(400).json({ error: 'Sınav henüz hazır değil' });
        return res.json({ summary: exam.aiSummary });
    } catch (err) {
        console.error('[Summary]', err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

// POST /exams/:id/attempts — Submit answers
router.post('/:id/attempts', async (req: AuthRequest, res: Response) => {
    try {
        const { answers, startedAt } = req.body;
        // answers: [{ questionId, selectedOption }]
        const questions = await prisma.question.findMany({ where: { examId: req.params.id as string } });
        if (questions.length === 0) return res.status(400).json({ error: 'Sınav soruları bulunamadı' });

        let correct = 0, wrong = 0, empty = 0;
        for (const q of questions) {
            const answer = (answers as { questionId: string; selectedOption: number | null }[])
                .find(a => a.questionId === q.id);
            if (!answer || answer.selectedOption === null || answer.selectedOption === undefined) {
                empty++;
            } else if (answer.selectedOption === q.correctOption) {
                correct++;
            } else {
                wrong++;
            }
        }
        const score = Math.round((correct / questions.length) * 100 * 10) / 10;

        const attempt = await prisma.attempt.create({
            data: {
                examId: req.params.id as string,
                userId: req.userId!,
                answers,
                score,
                correctCount: correct,
                wrongCount: wrong,
                emptyCount: empty,
                startedAt: startedAt ? new Date(startedAt) : new Date(),
                finishedAt: new Date(),
            },
        });
        return res.status(201).json({ attemptId: attempt.id, score, correctCount: correct, wrongCount: wrong, emptyCount: empty });
    } catch (err) {
        console.error('[Attempt]', err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

// GET /attempts/:attemptId — Attempt detail
router.get('/attempts/:attemptId', async (req: AuthRequest, res: Response) => {
    try {
        const attempt = await prisma.attempt.findFirst({
            where: { id: req.params.attemptId as string, userId: req.userId! },
            include: { exam: { select: { title: true, questionCount: true } } },
        });
        if (!attempt) return res.status(404).json({ error: 'Sonuç bulunamadı' });
        return res.json(attempt);
    } catch (err) {
        console.error('[Attempt Detail]', err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

export default router;
