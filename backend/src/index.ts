import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
dotenv.config();

import { initFirebase } from './config/firebase';
import authRoutes from './routes/auth';
import examRoutes from './routes/exam';
import deviceTokenRoutes from './routes/deviceToken';
import { startWorker } from './workers/examWorker';

initFirebase();
startWorker();

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => res.json({ status: 'ok' }));
app.use('/auth', authRoutes);
app.use('/exam', examRoutes);
app.use('/exams', examRoutes);
app.use('/device-token', deviceTokenRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`[Server] ExamAI backend running on port ${PORT}`);
});

export default app;
