import { Router, Response } from 'express';
import prisma from '../config/prisma';
import { authMiddleware, AuthRequest } from '../middleware/auth';
import { updateAutoPilotSchedule } from '../services/scheduler';
import { LimitService } from '../services/limitService';

const router = Router();
router.use(authMiddleware);

// GET /auto-pilot — Get all user configs
router.get('/', async (req: AuthRequest, res: Response) => {
    try {
        const configs = await prisma.autoPilotConfig.findMany({
            where: { userId: req.userId! },
            orderBy: { updatedAt: 'desc' }
        });
        return res.json(configs);
    } catch (err) {
        console.error('[AutoPilot Get]', err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

// POST /auto-pilot — Create/Update config
router.post('/', async (req: AuthRequest, res: Response) => {
    try {
        const { id, isActive, frequency, time, dayOfWeek, topic, subtopic, level, questionCount, type, prompt, isPromptTab, title, language } = req.body;

        // Check Auto Pilot Limits
        if (isActive) {
            const { allowed, count } = await LimitService.checkAutoPilotLimit(req.userId!);
            if (!allowed) {
                return res.status(403).json({ 
                    error: count === 0 
                        ? 'Otomatik sınav özelliği için Üyelik planına geçmeniz gerekmektedir. ✨' 
                        : 'Maksimum 20 aktif otomatik sınav talimatı limitine ulaştınız. ✨',
                    limitReached: true 
                });
            }
        }

        let config;
        if (id) {
            // Update existing
            config = await prisma.autoPilotConfig.update({
                where: { id: id as string, userId: req.userId as string },
                data: {
                    isActive, frequency, time, dayOfWeek, topic, subtopic, level,
                    questionCount, type, prompt, isPromptTab, title, language
                },
            });
        } else {
            // Create new
            config = await prisma.autoPilotConfig.create({
                data: {
                    userId: req.userId as string,
                    isActive, frequency, time, dayOfWeek, topic, subtopic, level,
                    questionCount, type, prompt, isPromptTab, title, language
                },
            });
        }

        // Update BullMQ schedule
        await updateAutoPilotSchedule(config);

        return res.json(config);
    } catch (err) {
        console.error('[AutoPilot Save]', err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

// DELETE /auto-pilot/:id — Delete a specific config
router.delete('/:id', async (req: AuthRequest, res: Response) => {
    try {
        const id = req.params.id as string;
        const config = await prisma.autoPilotConfig.findFirst({
            where: { id, userId: req.userId as string }
        });

        if (!config) {
            return res.status(404).json({ error: 'Konfigürasyon bulunamadı' });
        }

        await prisma.autoPilotConfig.delete({ where: { id: req.params.id as string } });

        // Remove from BullMQ
        await updateAutoPilotSchedule({ ...config, isActive: false });

        return res.json({ success: true });
    } catch (err) {
        console.error('[AutoPilot Delete]', err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

export default router;
