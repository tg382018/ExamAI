import { Worker, Job } from 'bullmq';
import { redisConnectionOptions } from '../config/redis';
import prisma from '../config/prisma';
import { sendPushNotification } from '../config/firebase';

export const startNotificationWorker = () => {
    const worker = new Worker('auto-pilot-notifications', async (job: Job) => {
        const { userId, examId } = job.data;
        console.log(`[Notification Worker] Checking readiness for exam ${examId} (User ${userId})`);

        const exam = await prisma.exam.findUnique({
            where: { id: examId },
            select: { status: true, title: true }
        });

        if (!exam) {
            console.log(`[Notification Worker] Exam ${examId} not found. Skipping.`);
            return;
        }

        if (exam.status === 'READY') {
            // Fetch user's device tokens
            const tokens = await prisma.deviceToken.findMany({
                where: { userId },
                select: { token: true }
            });

            if (tokens.length === 0) {
                console.log(`[Notification Worker] No device tokens for user ${userId}.`);
                return;
            }

            const tokenList = tokens.map(t => t.token);
            console.log(`[Notification Worker] Sending notification to ${tokenList.length} devices.`);

            await sendPushNotification(
                tokenList,
                'Sınavın Hazır! 🎯',
                `"${exam.title}" sınavın planladığın saatte hazırlandı. Hemen çözmeye başla!`
            );
        } else {
            console.log(`[Notification Worker] Exam ${examId} status is ${exam.status}. Notification delayed or failed.`);
            // Optionally retry once in a minute?
        }
    }, {
        connection: redisConnectionOptions,
        concurrency: 5,
    });

    worker.on('failed', (job, err) => {
        console.error(`[Notification Worker] Job failed: ${job?.id}`, err);
    });

    console.log('[Worker] Notification delivery worker started');
};
