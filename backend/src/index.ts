import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
dotenv.config();

import { initFirebase } from './config/firebase';
import authRoutes from './routes/auth';
import examRoutes from './routes/exam';
import deviceTokenRoutes from './routes/deviceToken';
import { startWorker } from './workers/examWorker';
import { startAutoPilotWorker } from './workers/autoPilotWorker';
import { startNotificationWorker } from './workers/notificationWorker';
import autoPilotRoutes from './routes/autoPilot';

initFirebase();
startWorker();
startAutoPilotWorker();
startNotificationWorker();

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => res.json({ status: 'ok' }));
app.use('/auth', authRoutes);
app.use('/exam', examRoutes);
app.use('/exams', examRoutes);
app.use('/device-token', deviceTokenRoutes);
app.use('/auto-pilot', autoPilotRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`[Server] ExamAI backend running on port ${PORT}`);
});

export default app;
