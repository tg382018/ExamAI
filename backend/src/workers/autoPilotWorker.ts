import { Worker, Job, Queue } from 'bullmq';
import { redisConnectionOptions } from '../config/redis';
import prisma from '../config/prisma';
import { examQueue } from '../routes/exam';

const NOTIFICATION_DELAY_MS = 2 * 60 * 1000; // 2 minutes

export const notificationQueue = new Queue('auto-pilot-notifications', {
    connection: redisConnectionOptions,
    defaultJobOptions: {
        removeOnComplete: true,
        removeOnFail: 1000,
    }
});

export const startAutoPilotWorker = () => {
    const worker = new Worker('auto-pilot-trigger', async (job: Job) => {
        const { userId, autoPilotConfigId } = job.data;
        console.log(`[AutoPilot Worker] Triggered for user ${userId}, config ${autoPilotConfigId}`);

        const config = await prisma.autoPilotConfig.findUnique({
            where: { id: autoPilotConfigId },
        });

        if (!config || !config.isActive) {
            console.log(`[AutoPilot Worker] Config ${autoPilotConfigId} inactive or missing. Skipping.`);
            return;
        }

        // 1. Create the exam (Stage: QUEUED)
        let prompt = config.isPromptTab ? config.prompt : '';
        if (!config.isPromptTab) {
            prompt = `Automated ${config.type} exam for ${config.level} about ${config.topic}. Subtopic: ${config.subtopic}. Question count: ${config.questionCount}.`;
        }

        const title = config.title || `Auto ${config.topic || 'Sınav'} - ${new Date().toLocaleDateString()}`;

        const exam = await prisma.exam.create({
            data: {
                userId,
                autoPilotConfigId,
                title,
                prompt: prompt || 'Auto Pilot Exam',
                status: 'QUEUED',
                durationMin: 30, // Default for auto
                questionCount: config.questionCount,
                isAuto: true,
                language: config.language || 'tr',
            },
        });

        // 2. Queue for generation (The 2-minute early start)
        await examQueue.add('generate', {
            examId: exam.id,
            prompt,
            plan: {
                title,
                questionCount: config.questionCount,
                durationMin: 30,
                outline: [], // LLM will decide
                needsAscii: false,
                allowedTypes: [config.type === 'mixed' ? 'MULTIPLE_CHOICE' : config.type.toUpperCase()]
            },
            language: config.language || 'tr'
        });

        // 3. Schedule a notification job (The target time: now + 2 mins)
        await notificationQueue.add(
            'send-notification',
            { userId, examId: exam.id },
            { delay: NOTIFICATION_DELAY_MS }
        );

        console.log(`[AutoPilot Worker] Exam ${exam.id} queued and notification scheduled.`);
    }, {
        connection: redisConnectionOptions,
        concurrency: 5,
    });

    worker.on('failed', (job, err) => {
        console.error(`[AutoPilot Worker] Job failed: ${job?.id}`, err);
    });

    console.log('[Worker] Auto-Pilot trigger worker started');
};
