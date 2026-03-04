import { Router, Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import prisma from '../config/prisma';

const router = Router();

// POST /auth/register
router.post('/register', async (req: Request, res: Response) => {
    try {
        const { email, password, name } = req.body;
        if (!email || !password || !name) {
            return res.status(400).json({ error: 'email, password ve name zorunlu' });
        }
        const existing = await prisma.user.findUnique({ where: { email } });
        if (existing) {
            return res.status(409).json({ error: 'Bu email zaten kayıtlı' });
        }
        const passwordHash = await bcrypt.hash(password, 10);
        const user = await prisma.user.create({
            data: { email, passwordHash, name },
            select: { id: true, email: true, name: true },
        });
        const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET || 'secret', { expiresIn: '30d' });
        return res.status(201).json({ user, token });
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
        const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET || 'secret', { expiresIn: '30d' });
        return res.json({ user: { id: user.id, email: user.email, name: user.name }, token });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Sunucu hatası' });
    }
});

export default router;
