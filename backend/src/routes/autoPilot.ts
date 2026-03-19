import { Router, Response } from 'express';
import prisma from '../config/prisma';
import { authMiddleware, AuthRequest } from '../middleware/auth';
import { updateAutoPilotSchedule } from '../services/scheduler';

const router = Router();
router.use(authMiddleware);

// GET /auto-pilot — Get user config
router.get('/', async (req: AuthRequest, res: Response) => {
    try {
        const config = await prisma.autoPilotConfig.findUnique({
            where: { userId: req.userId! },
        });
        return res.json(config || { isActive: false });
    } catch (err) {
        console.error('[AutoPilot Get]', err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

// POST /auto-pilot — Save/Update config
router.post('/', async (req: AuthRequest, res: Response) => {
    try {
        const { isActive, frequency, time, topic, subtopic, level, difficulty, questionCount, type, prompt, isPromptTab } = req.body;

        const config = await prisma.autoPilotConfig.upsert({
            where: { userId: req.userId! },
            update: {
                isActive, frequency, time, topic, subtopic, level,
                difficulty, questionCount, type, prompt, isPromptTab
            },
            create: {
                userId: req.userId!,
                isActive, frequency, time, topic, subtopic, level,
                difficulty, questionCount, type, prompt, isPromptTab
            },
        });

        // Update BullMQ schedule
        await updateAutoPilotSchedule(config);

        return res.json(config);
    } catch (err) {
        console.error('[AutoPilot Save]', err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

export default router;
