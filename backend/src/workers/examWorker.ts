import { Worker, Job } from 'bullmq';
import prisma from '../config/prisma';
import { redisConnectionOptions } from '../config/redis';
import { generateFullExam, DraftPlan } from '../services/llm';
import { sendPushNotification } from '../config/firebase';

interface GenerateExamJob {
    examId: string;
    prompt: string;
    plan: DraftPlan;
}

export function startWorker() {
    const worker = new Worker<GenerateExamJob>(
        'exam-generation',
        async (job: Job<GenerateExamJob>) => {
            const { examId, prompt, plan } = job.data;
            console.log(`[Worker] Starting exam generation: ${examId}`);

            try {
                // 1. Mark as GENERATING
                await prisma.exam.update({
                    where: { id: examId },
                    data: { status: 'GENERATING' },
                });

                // 2. Generate via LLM (multi-step)
                const { questions, summary } = await generateFullExam(prompt, plan);

                // Helper to remove null bytes that cause Postgres UTF8 errors
                const sanitizeString = (str: string | undefined | null) => {
                    if (!str) return str;
                    return str.replace(/\0/g, '');
                };

                // 3. Save questions to DB
                await prisma.question.createMany({
                    data: questions.map(q => {
                        // Find index of option containing " (DC)"
                        const correctIndex = q.options.findIndex(opt => opt.includes(' (DC)'));
                        // Clean all options of the " (DC)" tag and null bytes
                        const cleanedOptions = q.options.map(opt => sanitizeString(opt.replace(' (DC)', '').trim()) as string);

                        return {
                            examId,
                            orderIndex: q.orderIndex,
                            text: sanitizeString(q.text) as string,
                            options: cleanedOptions,
                            correctOption: correctIndex >= 0 ? correctIndex : 0,
                            explanation: sanitizeString(q.explanation) as string,
                            difficulty: sanitizeString(q.difficulty) as string,
                            topicTag: sanitizeString(q.topicTag) as string,
                            asciiArt: sanitizeString(q.asciiArt),
                        };
                    }),
                });

                // 4. Mark as READY + save summary + sync actual questionCount
                await prisma.exam.update({
                    where: { id: examId },
                    data: {
                        status: 'READY',
                        aiSummary: summary,
                        questionCount: questions.length, // Sync count in case LLM deviated
                    },
                });

                // 5. Send FCM push notification
                const exam = await prisma.exam.findUnique({
                    where: { id: examId },
                    select: { userId: true, title: true },
                });
                if (exam) {
                    const deviceTokens = await prisma.deviceToken.findMany({
                        where: { userId: exam.userId },
                        select: { token: true },
                    });
                    const tokens = deviceTokens.map((d: { token: string }) => d.token);
                    await sendPushNotification(
                        tokens,
                        'ExamAI ✅',
                        `"${exam.title}" sınavın hazır! Hadi başlayalım.`,
                        { examId, type: 'exam_ready' }
                    );
                }

                console.log(`[Worker] Exam generation complete: ${examId}`);
            } catch (err) {
                console.error(`[Worker] Error generating exam ${examId}:`, err);
                await prisma.exam.update({
                    where: { id: examId },
                    data: { status: 'FAILED' },
                });
                throw err; // BullMQ will retry
            }
        },
        {
            connection: redisConnectionOptions,
            concurrency: 3,
        }
    );

    worker.on('completed', job => {
        console.log(`[Worker] Job ${job.id} completed`);
    });

    worker.on('failed', (job, err) => {
        console.error(`[Worker] Job ${job?.id} failed:`, err.message);
    });

    console.log('[Worker] Exam generation worker started');
    return worker;
}
