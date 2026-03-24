import { Router, Response } from 'express';
import { Queue } from 'bullmq';
import multer from 'multer';
import prisma from '../config/prisma';
import { authMiddleware, AuthRequest } from '../middleware/auth';
import { generateDraftPlan } from '../services/llm';
import { redisConnectionOptions } from '../config/redis';
import { LimitService } from '../services/limitService';

const router = Router();
router.use(authMiddleware);

const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB max
    fileFilter: (_req, file, cb) => {
        const allowed = [
            'application/pdf',
            'image/jpeg',
            'image/png',
            'image/jpg',
            'image/webp',
            'image/heic',
            'image/heif'
        ];
        if (allowed.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb(new Error('Sadece PDF, Görsel (JPG/PNG/HEIC/WEBP) dosyalar kabul edilir.'));
        }
    },
});

export const examQueue = new Queue('exam-generation', { connection: redisConnectionOptions });

// POST /exam/draft — Fast AI plan suggestion (with optional file attachment)
router.post('/draft', upload.single('attachment'), async (req: AuthRequest, res: Response) => {
    try {
        const { prompt } = req.body;
        if (!prompt) return res.status(400).json({ error: 'prompt zorunlu' });

        const fileBuffer = req.file?.buffer;
        const fileMime = req.file?.mimetype;

        const plan = await generateDraftPlan(prompt, fileBuffer, fileMime);
        // We return the plan object which now contains isValid and error
        // Also return file info so frontend can pass it to confirm
        const result: any = { suggested: plan };
        if (req.file) {
            result.fileBase64 = req.file.buffer.toString('base64');
            result.fileMime = req.file.mimetype;
        }
        return res.json(result);
    } catch (err) {
        console.error('[Draft]', err);
        return res.status(500).json({ error: 'Plan oluşturulamadı' });
    }
});

// POST /exam — Confirm & queue exam generation
router.post('/', async (req: AuthRequest, res: Response) => {
    try {
        const { prompt, title, questionCount, durationMin, difficulty, outline, needsAscii, allowedTypes, fileBase64, fileMime, isAuto } = req.body;
        if (!prompt || !title) return res.status(400).json({ error: 'prompt ve title zorunlu' });

        const { allowed, remaining } = await LimitService.checkExamLimit(req.userId!);
        if (!allowed) {
            return res.status(403).json({ 
                error: 'Günlük sınav oluşturma limitine ulaştınız. Lütfen yarın tekrar deneyin veya planınızı yükseltin. ✨',
                limitReached: true 
            });
        }

        const exam = await prisma.exam.create({
            data: {
                userId: req.userId!,
                title,
                prompt,
                status: 'QUEUED',
                durationMin: durationMin || 30,
                questionCount: questionCount || 10,
                difficulty: difficulty || 'mixed',
                isAuto: isAuto || false,
            },
        });
        await examQueue.add('generate', {
            examId: exam.id,
            prompt,
            plan: { title, questionCount, durationMin, difficulty, outline, needsAscii: needsAscii ?? false, allowedTypes: allowedTypes ?? ['MULTIPLE_CHOICE'] },
            fileBase64: fileBase64 || undefined,
            fileMime: fileMime || undefined,
        }, {
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
                isAuto: true,
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
                        id: true, type: true, orderIndex: true, text: true, options: true,
                        difficulty: true, topicTag: true, asciiArt: true,
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

import { gradeOpenEndedQuestions } from '../services/llm';

// ... (existing code)

// POST /exams/:id/attempts — Submit answers
router.post('/:id/attempts', async (req: AuthRequest, res: Response) => {
    try {
        const { answers, startedAt } = req.body;
        console.log(`[Attempt] Submitting for exam ${req.params.id}. Answers: ${JSON.stringify(answers)}`);
        // answers: [{ questionId, selectedOption: number | string | null }]
        const questions = await prisma.question.findMany({
            where: { examId: req.params.id as string },
            orderBy: { orderIndex: 'asc' }
        });
        if (questions.length === 0) return res.status(400).json({ error: 'Sınav soruları bulunamadı' });

        let totalWeight = questions.length;
        let earnedPoints = 0;
        let correctCount = 0, wrongCount = 0, emptyCount = 0;

        const openEndedData: { questionId: string; questionText: string; studentAnswer: string; correctAnswerCriteria: string }[] = [];

        for (const q of questions) {
            const answer = (answers as { questionId: string; selectedOption: any }[])
                .find(a => a.questionId == q.id); // Use loose equality in case of string/number mismatch

            if (!answer || answer.selectedOption === null || answer.selectedOption === undefined || answer.selectedOption === '') {
                emptyCount++;
                console.log(`[Attempt] Question ${q.id} (index ${q.orderIndex}) is EMPTY. Answer: ${JSON.stringify(answer)}`);
                continue;
            }

            if (q.type === 'MULTIPLE_CHOICE' || q.type === 'TRUE_FALSE') {
                if (answer.selectedOption === q.correctOption) {
                    earnedPoints += 1;
                    correctCount++;
                } else {
                    wrongCount++;
                }
            } else if (q.type === 'OPEN_ENDED') {
                // Normalize curly quotes and trim for better AI matching
                const normalizedAnswer = answer.selectedOption.toString()
                    .replace(/[‘’]/g, "'")
                    .replace(/[“”]/g, '"')
                    .trim();

                openEndedData.push({
                    questionId: q.id,
                    questionText: q.text,
                    studentAnswer: normalizedAnswer,
                    correctAnswerCriteria: q.correctAnswer || '',
                });
            }
        }

        console.log(`[Attempt] Open-ended questions found to grade: ${openEndedData.length}`);

        // Call AI for open-ended questions
        const enrichedAnswers = [...(answers as any[])];

        if (openEndedData.length > 0) {
            const aiResults = await gradeOpenEndedQuestions(openEndedData);
            console.log('[Attempt] AI Grading results received:', JSON.stringify(aiResults));
            for (const qId in aiResults) {
                const result = aiResults[qId];
                earnedPoints += (result.score || 0) / 100;

                // Merge AI results back into the answer objects
                const targetIdx = enrichedAnswers.findIndex(a => a.questionId === qId);
                if (targetIdx !== -1) {
                    enrichedAnswers[targetIdx].aiScore = result.score;
                    enrichedAnswers[targetIdx].aiFeedback = result.feedback;
                }

                if ((result.score || 0) >= 50) correctCount++;
                else wrongCount++;
            }
        }

        const score = Math.round((earnedPoints / totalWeight) * 100 * 10) / 10;

        const attempt = await prisma.attempt.create({
            data: {
                examId: req.params.id as string,
                userId: req.userId!,
                answers: enrichedAnswers,
                score,
                correctCount,
                wrongCount,
                emptyCount,
                startedAt: startedAt ? new Date(startedAt) : new Date(),
                finishedAt: new Date(),
            },
        });
        return res.status(201).json({ attemptId: attempt.id, score, correctCount, wrongCount, emptyCount });
    } catch (err) {
        console.error('[Attempt Submission Error]:', err);
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
