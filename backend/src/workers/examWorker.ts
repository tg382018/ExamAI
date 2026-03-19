import { Worker, Job } from 'bullmq';
import prisma from '../config/prisma';
import { redisConnectionOptions } from '../config/redis';
import { generateFullExam, DraftPlan } from '../services/llm';
import { sendPushNotification } from '../config/firebase';

interface GenerateExamJob {
    examId: string;
    prompt: string;
    plan: DraftPlan;
    fileBase64?: string;
    fileMime?: string;
}

export function startWorker() {
    const worker = new Worker<GenerateExamJob>(
        'exam-generation',
        async (job: Job<GenerateExamJob>) => {
            const { examId, prompt, plan, fileBase64, fileMime } = job.data;
            console.log(`[Worker] Starting exam generation: ${examId}`);

            try {
                // 1. Mark as GENERATING
                await prisma.exam.update({
                    where: { id: examId },
                    data: { status: 'GENERATING' },
                });

                // 2. Generate via LLM (multi-step)
                const { questions: rawQuestions, summary } = await generateFullExam(prompt, plan, fileBase64, fileMime);

                // Enforce requested count (slice if LLM generated more)
                const requestedCount = plan.questionCount || 10;
                const questions = rawQuestions.slice(0, requestedCount);

                // Helper to remove null bytes that cause Postgres UTF8 errors
                const sanitizeString = (str: string | undefined | null) => {
                    if (!str) return str;
                    return str.replace(/\0/g, '');
                };

                // 3. Save questions to DB
                await prisma.question.deleteMany({ where: { examId } }); // Ensure idempotency if job retries
                await prisma.question.createMany({
                    data: questions.map(q => {
                        let correctIndex: number | null = null;
                        let correctAnswer: string | null = null;
                        let cleanedOptions = q.options.map(opt => sanitizeString(opt) as string);

                        if (q.type === 'MULTIPLE_CHOICE') {
                            const foundIndex = q.options.findIndex(opt => opt.includes(' (DC)'));
                            correctIndex = foundIndex >= 0 ? foundIndex : 0;
                            // Clean the " (DC)" tag and also stripping "A) ", "1- ", etc. labels if LLM included them
                            cleanedOptions = q.options.map(opt => {
                                let s = opt.replace(' (DC)', '').trim();
                                // Remove leading labels like "A) ", "B- ", "1. "
                                s = s.replace(/^[A-Ea-e1-5][\)\-\.\s]+\s*/, '');
                                return sanitizeString(s) as string;
                            });
                        } else if (q.type === 'TRUE_FALSE') {
                            correctIndex = q.correctOption ?? 0;
                            correctAnswer = q.correctAnswer ?? 'Doğru';
                        } else if (q.type === 'OPEN_ENDED') {
                            correctAnswer = sanitizeString(q.correctAnswer) || '';
                            cleanedOptions = []; // No options for open-ended
                        }

                        return {
                            examId,
                            type: q.type,
                            orderIndex: q.orderIndex,
                            text: sanitizeString(q.text) as string,
                            options: cleanedOptions,
                            correctOption: correctIndex,
                            correctAnswer: correctAnswer,
                            explanation: sanitizeString(q.explanation) as string,
                            difficulty: sanitizeString(q.difficulty) as string,
                            topicTag: sanitizeString(q.topicTag) as string,
                            asciiArt: sanitizeString(q.asciiArt),
                        };
                    }) as any,
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
