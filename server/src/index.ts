import express from 'express';
import cors from 'cors';
import { initSchema, db } from './db.js';
import { authRouter } from './routes/auth.js';
import { feedRouter } from './routes/feed.js';

const PORT = Number(process.env.FLOW_PORT ?? 3000);

initSchema();

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.use('/api/auth', authRouter);
app.use('/api/feed', feedRouter);

app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', uptime: process.uptime() });
});

app.listen(PORT, () => {
  console.log(`[flow-server] listening on http://localhost:${PORT}`);
});
