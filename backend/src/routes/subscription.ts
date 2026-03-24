import { Router, Response } from 'express';
import { authMiddleware, AuthRequest } from '../middleware/auth';
import prisma from '../config/prisma';

const router = Router();

/**
 * POST /subscription/verify
 * Verifies an IAP receipt with the respective store (Apple/Google)
 * and upgrades the user to PRO upon success.
 */
router.post('/verify', authMiddleware, async (req: AuthRequest, res: Response) => {
    try {
        const { productId, verificationData, source } = req.body;
        const userId = req.userId;

        if (!productId || !verificationData || !source) {
            return res.status(400).json({ error: 'Eksik ödeme verisi' });
        }

        // TODO: Implement actual store verification logic here.
        // For production, you would use libraries like 'node-apple-receipt-verify' 
        // or official Google/Apple APIs to ensure the receipt is valid and not reused.
        
        console.log(`Verifying ${productId} for user ${userId} from ${source}`);

        // For now, we simulate a successful verification. 
        // In a real app, you MUST call the store APIs here.
        const isVerified = true; 

        if (isVerified) {
            const user = await prisma.user.update({
                where: { id: userId },
                data: { subscriptionTier: 'PRO' },
                select: { id: true, email: true, name: true, subscriptionTier: true }
            });
            return res.json({ message: 'Ödeme doğrulandı. PRO üyeliğiniz aktif!', user });
        } else {
            return res.status(402).json({ error: 'Ödeme doğrulanamadı' });
        }
    } catch (err) {
        console.error('Subscription verify error:', err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

export default router;
