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
    const [hours, minutes] = timeStr.split(':').map(Number);
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
 * Updates or removes the repeatable job for a user's Auto-Pilot.
 */
export async function updateAutoPilotSchedule(config: any) {
    const jobId = `auto-pilot-${config.userId}`;

    // 1. Remove existing repeatable jobs for this user
    const repeatableJobs = await autoPilotQueue.getRepeatableJobs();
    for (const job of repeatableJobs) {
        // Correctly match the jobId in the repeatable job options
        if (job.id === jobId || job.key.includes(jobId)) {
            await autoPilotQueue.removeRepeatableByKey(job.key);
        }
    }

    // 2. If active, add the new schedule
    if (config.isActive && config.time) {
        const cron = getCronExpression(config.time, config.frequency, config.dayOfWeek);
        console.log(`[Scheduler] Scheduling Auto-Pilot for ${config.userId} at ${config.time} (${config.frequency}) (Cron: ${cron})`);

        await autoPilotQueue.add(
            'trigger',
            { userId: config.userId },
            {
                repeat: { pattern: cron },
                jobId: jobId
            }
        );
    } else {
        console.log(`[Scheduler] Auto-Pilot disabled/removed for ${config.userId}`);
    }
}
