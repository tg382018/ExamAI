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

                // 3. Save questions to DB
                await prisma.question.createMany({
                    data: questions.map(q => ({
                        examId,
                        orderIndex: q.orderIndex,
                        text: q.text,
                        options: q.options,
                        correctOption: q.correctOption,
                        explanation: q.explanation,
                        difficulty: q.difficulty,
                        topicTag: q.topicTag,
                    })),
                });

                // 4. Mark as READY + save summary
                await prisma.exam.update({
                    where: { id: examId },
                    data: { status: 'READY', aiSummary: summary },
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
