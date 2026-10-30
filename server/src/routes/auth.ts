import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { db } from '../db.js';
import { rowToUser } from '../mappers.js';
import { issueToken, authenticate } from '../auth.js';

const router = Router();

function newId(prefix: string) {
  return `${prefix}_${Date.now().toString(36)}${Math.random().toString(36).slice(2, 8)}`;
}

router.post('/register', async (req, res) => {
  const { username, email, password } = req.body ?? {};
  if (!username || !email || !password) {
    res.status(400).json({ error: 'username / email / password are required' });
    return;
  }
  if (password.length < 6) {
    res.status(400).json({ error: 'Password must be at least 6 characters' });
    return;
  }

  const existing = db.prepare('SELECT id FROM users WHERE email = ? OR username = ?').get(email, username);
  if (existing) {
    res.status(409).json({ error: 'Email or username already taken' });
    return;
  }

  const hash = await bcrypt.hash(password, 10);
  const id = newId('u');
  const now = new Date().toISOString();
  db.prepare(
    `INSERT INTO users (id, username, email, password_hash, avatar, bio, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?)`
  ).run(id, username, email, hash, `https://picsum.photos/seed/${username}/200`, null, now);

  const user = db.prepare('SELECT * FROM users WHERE id = ?').get(id) as any;
  res.status(201).json({ token: issueToken(id), user: rowToUser(user) });
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body ?? {};
  if (!email || !password) {
    res.status(400).json({ error: 'email and password are required' });
    return;
  }

  const user = db.prepare('SELECT * FROM users WHERE email = ?').get(email) as any;
  if (!user) {
    res.status(401).json({ error: 'Invalid credentials' });
    return;
  }

  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) {
    res.status(401).json({ error: 'Invalid credentials' });
    return;
  }

  res.json({ token: issueToken(user.id), user: rowToUser(user) });
});

router.get('/me', authenticate, (req, res) => {
  const user = (req as any).user;
  res.json(rowToUser(user));
});

export const authRouter = router;
