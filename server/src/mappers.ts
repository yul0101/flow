import type { User, Post, Comment } from './types.js';

// 数据库行 → API 返回对象，字段对齐客户端 Domain 模型

function rowToUser(row: any): User {
  return {
    id: row.id,
    username: row.username,
    avatar: row.avatar ?? '',
    bio: row.bio ?? null,
    createdAt: row.created_at,
  };
}

function rowToPost(row: any, liked: boolean): Post {
  return {
    id: row.id,
    content: row.content,
    imageUrl: row.image_url ?? null,
    author: rowToUser({
      id: row.user_id,
      username: row.author_username,
      avatar: row.author_avatar,
      bio: row.author_bio,
      created_at: row.author_created_at,
    }),
    likes: row.likes,
    comments: row.comments,
    liked,
    createdAt: row.created_at,
  };
}

function rowToComment(row: any): Comment {
  return {
    id: row.id,
    postId: row.post_id,
    content: row.content,
    author: rowToUser({
      id: row.user_id,
      username: row.author_username,
      avatar: row.author_avatar,
      bio: row.author_bio,
      created_at: row.author_created_at,
    }),
    createdAt: row.created_at,
  };
}

export { rowToUser, rowToPost, rowToComment };
