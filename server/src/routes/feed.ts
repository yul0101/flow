import { Router, Request, Response } from 'express';
import { db } from '../db.js';
import { rowToPost, rowToComment } from '../mappers.js';
import { authenticate } from '../auth.js';

const router = Router();

function newId(prefix: string) {
  return `${prefix}_${Date.now().toString(36)}${Math.random().toString(36).slice(2, 8)}`;
}

router.get('/', (req: Request, res: Response) => {
  const page = Math.max(1, parseInt(req.query.page as string) || 1);
  const size = Math.min(100, Math.max(1, parseInt(req.query.size as string) || 20));
  const offset = (page - 1) * size;
  const meId = (req as any).user?.id;

  const rows = db.prepare(`
    SELECT p.*,
      u.username AS author_username,
      u.avatar   AS author_avatar,
      u.bio      AS author_bio,
      u.created_at AS author_created_at,
      pl.post_id IS NOT NULL AS liked_flag
    FROM posts p
    JOIN users u ON u.id = p.user_id
    LEFT JOIN post_likes pl ON pl.post_id = p.id AND pl.user_id = ?
    ORDER BY p.created_at DESC
    LIMIT ? OFFSET ?
  `).all(meId ?? '', size, offset) as any[];

  const posts = rows.map((r) => rowToPost(r, r.liked_flag === 1));
  res.json(posts);
});

router.post('/posts', authenticate, (req, res) => {
  const userId = (req as any).user.id;
  const { content, imageUrl } = req.body ?? {};
  if (!content || typeof content !== 'string' || content.trim().length === 0) {
    res.status(400).json({ error: 'content is required' });
    return;
  }
  if (content.trim().length > 500) {
    res.status(400).json({ error: 'content must be <= 500 characters' });
    return;
  }

  const id = newId('p');
  const now = new Date().toISOString();
  db.prepare(
    `INSERT INTO posts (id, user_id, content, image_url, likes, comments, created_at)
     VALUES (?, ?, ?, ?, 0, 0, ?)`
  ).run(id, userId, content.trim(), imageUrl ?? null, now);

  const row = db.prepare(`
    SELECT p.*,
      u.username AS author_username,
      u.avatar   AS author_avatar,
      u.bio      AS author_bio,
      u.created_at AS author_created_at,
      0 AS liked_flag
    FROM posts p JOIN users u ON u.id = p.user_id WHERE p.id = ?
  `).get(id) as any;
  res.status(201).json(rowToPost(row, false));
});

router.post('/posts/:id/like', authenticate, (req, res) => {
  const userId = (req as any).user.id;
  const postId = req.params.id;

  const post = db.prepare('SELECT id, likes FROM posts WHERE id = ?').get(postId) as any;
  if (!post) {
    res.status(404).json({ error: 'Post not found' });
    return;
  }

  const existing = db.prepare('SELECT post_id FROM post_likes WHERE user_id = ? AND post_id = ?')
    .get(userId, postId);

  let liked: boolean;
  if (existing) {
    db.prepare('DELETE FROM post_likes WHERE user_id = ? AND post_id = ?').run(userId, postId);
    db.prepare('UPDATE posts SET likes = MAX(0, likes - 1) WHERE id = ?').run(postId);
    liked = false;
  } else {
    db.prepare('INSERT INTO post_likes (user_id, post_id) VALUES (?, ?)').run(userId, postId);
    db.prepare('UPDATE posts SET likes = likes + 1 WHERE id = ?').run(postId);
    liked = true;
  }

  const row = db.prepare(`
    SELECT p.*,
      u.username AS author_username,
      u.avatar   AS author_avatar,
      u.bio      AS author_bio,
      u.created_at AS author_created_at,
      ? AS liked_flag
    FROM posts p JOIN users u ON u.id = p.user_id WHERE p.id = ?
  `).get(liked ? 1 : 0, postId) as any;
  res.json(rowToPost(row, liked));
});

router.get('/posts/:id/comments', (req, res) => {
  const postId = req.params.id;
  const rows = db.prepare(`
    SELECT c.*,
      u.username AS author_username,
      u.avatar   AS author_avatar,
      u.bio      AS author_bio,
      u.created_at AS author_created_at
    FROM comments c JOIN users u ON u.id = c.user_id
    WHERE c.post_id = ?
    ORDER BY c.created_at ASC
  `).all(postId) as any[];
  res.json(rows.map(rowToComment));
});

router.post('/posts/:id/comments', authenticate, (req, res) => {
  const userId = (req as any).user.id;
  const postId = req.params.id;
  const { content } = req.body ?? {};
  if (!content || typeof content !== 'string' || content.trim().length === 0) {
    res.status(400).json({ error: 'content is required' });
    return;
  }

  const post = db.prepare('SELECT id FROM posts WHERE id = ?').get(postId);
  if (!post) {
    res.status(404).json({ error: 'Post not found' });
    return;
  }

  const id = newId('c');
  const now = new Date().toISOString();
  const tx = db.transaction(() => {
    db.prepare(
      `INSERT INTO comments (id, post_id, user_id, content, created_at) VALUES (?, ?, ?, ?, ?)`
    ).run(id, postId, userId, content.trim(), now);
    db.prepare('UPDATE posts SET comments = comments + 1 WHERE id = ?').run(postId);
  });
  tx();

  const row = db.prepare(`
    SELECT c.*,
      u.username AS author_username,
      u.avatar   AS author_avatar,
      u.bio      AS author_bio,
      u.created_at AS author_created_at
    FROM comments c JOIN users u ON u.id = c.user_id WHERE c.id = ?
  `).get(id) as any;
  res.status(201).json(rowToComment(row));
});

export const feedRouter = router;
