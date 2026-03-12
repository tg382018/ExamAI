import { Router, Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import prisma from '../config/prisma';
import { emailService } from '../services/email.service';
import { authMiddleware, AuthRequest } from '../middleware/auth';

const router = Router();

// Helper to generate 6-digit OTP
const generateOTP = () => Math.floor(100000 + Math.random() * 900000).toString();

// POST /auth/register
router.post('/register', async (req: Request, res: Response) => {
    try {
        const { email, password, name } = req.body;
        if (!email || !password || !name) {
            return res.status(400).json({ error: 'email, password ve name zorunlu' });
        }
        const existing = await prisma.user.findUnique({ where: { email } });
        if (existing && existing.isVerified) {
            return res.status(409).json({ error: 'Bu email zaten kayıtlı' });
        }

        const verificationCode = generateOTP();
        const passwordHash = await bcrypt.hash(password, 10);

        let user;
        if (existing) {
            // Update unverified user
            user = await prisma.user.update({
                where: { email },
                data: {
                    passwordHash,
                    name,
                    verificationCode,
                    isVerified: false
                },
                select: { id: true, email: true, name: true },
            });
        } else {
            // Create brand new user
            user = await prisma.user.create({
                data: {
                    email,
                    passwordHash,
                    name,
                    verificationCode,
                    isVerified: false
                },
                select: { id: true, email: true, name: true },
            });
        }

        // Send email in background
        emailService.sendVerificationCode(email, verificationCode);

        return res.status(201).json({
            message: 'Kayıt başarılı. Lütfen e-postanıza gönderilen doğrulama kodunu girin.',
            user: { id: user.id, email: user.email, name: user.name }
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

// POST /auth/verify
router.post('/verify', async (req: Request, res: Response) => {
    try {
        const { email, code } = req.body;
        if (!email || !code) {
            return res.status(400).json({ error: 'email ve kod zorunlu' });
        }

        const user = await prisma.user.findUnique({ where: { email } });
        if (!user) {
            return res.status(404).json({ error: 'Kullanıcı bulunamadı' });
        }

        if (user.verificationCode !== code) {
            return res.status(400).json({ error: 'Geçersiz doğrulama kodu' });
        }

        await prisma.user.update({
            where: { id: user.id },
            data: { isVerified: true, verificationCode: null }
        });

        const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET || 'secret', { expiresIn: '30d' });

        return res.json({
            message: 'E-posta başarıyla doğrulandı',
            user: { id: user.id, email: user.email, name: user.name },
            token
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

// POST /auth/resend-verification
router.post('/resend-verification', async (req: Request, res: Response) => {
    try {
        const { email } = req.body;
        if (!email) {
            return res.status(400).json({ error: 'email zorunlu' });
        }

        const user = await prisma.user.findUnique({ where: { email } });
        if (!user) {
            return res.status(404).json({ error: 'Kullanıcı bulunamadı' });
        }

        if (user.isVerified) {
            return res.status(400).json({ error: 'Bu hesap zaten doğrulanmış' });
        }

        const newCode = generateOTP();
        await prisma.user.update({
            where: { id: user.id },
            data: { verificationCode: newCode }
        });

        await emailService.sendVerificationCode(email, newCode);

        return res.json({ message: 'Yeni doğrulama kodu gönderildi' });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

// POST /auth/login
router.post('/login', async (req: Request, res: Response) => {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(400).json({ error: 'email ve password zorunlu' });
        }
        const user = await prisma.user.findUnique({ where: { email } });
        if (!user) {
            return res.status(401).json({ error: 'Geçersiz email veya şifre' });
        }
        const valid = await bcrypt.compare(password, user.passwordHash);
        if (!valid) {
            return res.status(401).json({ error: 'Geçersiz email veya şifre' });
        }

        if (!user.isVerified) {
            return res.status(403).json({
                error: 'E-posta doğrulanmamış',
                unverified: true
            });
        }

        const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET || 'secret', { expiresIn: '30d' });
        return res.json({ user: { id: user.id, email: user.email, name: user.name }, token });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

// POST /auth/change-password
router.post('/change-password', authMiddleware, async (req: AuthRequest, res: Response) => {
    try {
        const { oldPassword, newPassword } = req.body;
        const userId = req.userId;

        if (!oldPassword || !newPassword) {
            return res.status(400).json({ error: 'Mevcut şifre ve yeni şifre zorunlu' });
        }

        if (newPassword.length < 6) {
            return res.status(400).json({ error: 'Yeni şifre en az 6 haneli olmalıdır' });
        }

        const user = await prisma.user.findUnique({ where: { id: userId } });
        if (!user) {
            return res.status(404).json({ error: 'Kullanıcı bulunamadı' });
        }

        const valid = await bcrypt.compare(oldPassword, user.passwordHash);
        if (!valid) {
            return res.status(401).json({ error: 'Mevcut şifre yanlış' });
        }

        const newPasswordHash = await bcrypt.hash(newPassword, 10);
        await prisma.user.update({
            where: { id: userId },
            data: { passwordHash: newPasswordHash }
        });

        return res.json({ message: 'Şifre başarıyla güncellendi' });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

export default router;
