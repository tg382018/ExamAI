import { Queue } from 'bullmq';
import { redisConnectionOptions } from '../config/redis';

// Use a dedicated queue for Auto-Pilot triggers
export const autoPilotQueue = new Queue('auto-pilot-trigger', {
    connection: redisConnectionOptions,
    defaultJobOptions: {
        removeOnComplete: true,
        removeOnFail: 1000,
    }
});

/**
 * Converts "HH:mm" time and frequency to a cron expression.
 * Returns a cron that triggers 2 minutes BEFORE the target time.
 */
function getCronExpression(timeStr: string, frequency: string, dayOfWeek?: number): string {
    let hours: number, minutes: number;

    const timeLower = timeStr.toLowerCase();
    if (timeLower.includes('am') || timeLower.includes('pm')) {
        const isPm = timeLower.includes('pm');
        const cleanTime = timeLower.replace('am', '').replace('pm', '').trim();
        const parts = cleanTime.split(':').map(Number);
        hours = parts[0];
        minutes = parts[1] || 0;

        if (isPm && hours < 12) hours += 12;
        if (!isPm && hours === 12) hours = 0;
    } else {
        const parts = timeStr.split(':').map(Number);
        hours = parts[0];
        minutes = parts[1] || 0;
    }

    // Safety fallback
    if (isNaN(hours) || isNaN(minutes)) {
        console.error(`[Scheduler] Invalid time format: "${timeStr}". Defaulting to 09:00.`);
        hours = 9;
        minutes = 0;
    }

    let targetMinutes = minutes - 2;
    let targetHours = hours;
    let targetDayOfWeek = dayOfWeek; // 1-7 (Mon-Sun)

    if (targetMinutes < 0) {
        targetMinutes += 60;
        targetHours -= 1;
        if (targetHours < 0) {
            targetHours = 23;
            if (targetDayOfWeek !== undefined) {
                targetDayOfWeek -= 1;
                if (targetDayOfWeek < 1) targetDayOfWeek = 7;
            }
        }
    }

    if (frequency === 'weekly' && targetDayOfWeek !== undefined) {
        // Weekly cron: "minutes hours * * dayOfWeek"
        return `${targetMinutes} ${targetHours} * * ${targetDayOfWeek}`;
    }

    // Daily cron: "minutes hours * * *"
    return `${targetMinutes} ${targetHours} * * *`;
}

/**
 * Updates or removes the repeatable job for a specific Auto-Pilot configuration.
 */
export async function updateAutoPilotSchedule(config: any) {
    // Each config has its own job, identified by its unique ID
    const jobId = `auto-pilot-config-${config.id}`;

    // 1. Remove existing repeatable jobs for this specific config
    const repeatableJobs = await autoPilotQueue.getRepeatableJobs();
    for (const job of repeatableJobs) {
        if (job.id === jobId || job.key.includes(jobId)) {
            await autoPilotQueue.removeRepeatableByKey(job.key);
        }
    }

    // 2. If active, add the new schedule
    if (config.isActive && config.time) {
        const cron = getCronExpression(config.time, config.frequency, config.dayOfWeek);
        console.log(`[Scheduler] Scheduling Auto-Pilot Config ${config.id} (User: ${config.userId}) at ${config.time} (${config.frequency}) (Cron: ${cron})`);

        await autoPilotQueue.add(
            'trigger',
            {
                userId: config.userId,
                autoPilotConfigId: config.id // Pass the specific config ID to the worker
            },
            {
                repeat: { pattern: cron },
                jobId: jobId
            }
        );
    } else {
        console.log(`[Scheduler] Auto-Pilot Config ${config.id} disabled/removed`);
    }
}
