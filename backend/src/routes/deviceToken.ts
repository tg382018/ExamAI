import { Router, Request, Response } from 'express';
import prisma from '../config/prisma';
import { authMiddleware, AuthRequest } from '../middleware/auth';

const router = Router();
router.use(authMiddleware);

// POST /device-token
router.post('/', async (req: AuthRequest, res: Response) => {
    try {
        const { token, platform } = req.body;
        if (!token || !platform) return res.status(400).json({ error: 'token ve platform zorunlu' });
        await prisma.deviceToken.upsert({
            where: { token },
            update: { userId: req.userId!, platform },
            create: { userId: req.userId!, token, platform },
        });
        return res.json({ success: true });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

export default router;
