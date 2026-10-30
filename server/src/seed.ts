// 一次性 seed 脚本：写入 demo 用户 + 示例帖子
// 运行：npx tsx server/src/seed.ts
// 仅在 users 表为空时生效，不会覆盖已有数据

import bcrypt from 'bcryptjs';
import { initSchema, db } from './db.js';

function newId(prefix: string) {
  return `${prefix}_${Date.now().toString(36)}${Math.random().toString(36).slice(2, 8)}`;
}

async function main() {
  initSchema();

  const userCount = db.prepare('SELECT COUNT(*) AS c FROM users').get() as any;
  if (userCount.c > 0) {
    console.log(`[seed] users 表已有 ${userCount.c} 行数据，跳过 seed`);
    return;
  }

  const now = new Date().toISOString();
  const hash = await bcrypt.hash('123456', 10);

  const users = [
    { id: newId('u'), username: 'alice', email: 'alice@flow.com' },
    { id: newId('u'), username: 'bob',   email: 'bob@flow.com' },
    { id: newId('u'), username: 'carol', email: 'carol@flow.com' },
  ];

  for (const u of users) {
    db.prepare(
      `INSERT INTO users (id, username, email, password_hash, avatar, bio, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?)`
    ).run(u.id, u.username, u.email, hash, `https://picsum.photos/seed/${u.username}/200`, null, now);
  }

  const posts = [
    '今天天气真好 ☀️',
    '分享一段喜欢的文字',
    '有人一起去散步吗？',
    '刚看完一部电影，强推！',
    '早起打卡 🕐',
    '今天的咖啡 ☕️',
  ];

  const insertPost = db.prepare(
    `INSERT INTO posts (id, user_id, content, image_url, likes, comments, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?)`
  );

  for (let i = 0; i < posts.length; i++) {
    const user = users[i % users.length];
    insertPost.run(
      newId('p'),
      user.id,
      posts[i],
      i % 2 === 0 ? `https://picsum.photos/seed/seed${i}/600` : null,
      0,
      0,
      new Date(Date.now() - i * 5 * 60_000).toISOString(),
    );
  }

  console.log(`[seed] 写入 ${users.length} 个用户 + ${posts.length} 条帖子`);
  console.log(`[seed] demo 账号：alice@flow.com / 123456`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
