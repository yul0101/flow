# Flow Server

Flow 客户端的**最小后端样例**，用于演示客户端如何对接真实 API。

> 后端技术栈：Express + TypeScript + SQLite（better-sqlite3）
> 为什么选这些？依赖少、启动快、SQLite 单文件数据库不需要额外进程——Fork 下来 `npm install && npm start` 就能跑。
>
> 你可以把它换成 NestJS、Go（Gin）、Deno、Flask 等任何你熟悉的栈。客户端仓库里的 `Repository` 方法签名已经锁死，只要后端返回相同的 JSON 结构，**客户端零改动**。

## 快速启动

```bash
cd server
npm install
npm run dev          # 开发模式（tsx 热重载）
npm run build && npm start   # 生产模式
```

服务默认跑在 `http://localhost:3000`。首次启动会自动建表并写入 seed 数据（一个 demo 用户 + 6 条示例帖子）。

## 对接 Flutter 客户端

客户端通过 `ApiConfig.baseUrl` 指向你的后端地址。在客户端仓库里：

```bash
# 开发时直接跑后端默认端口即可
cd .. && flutter run -d chrome
```

## API 端点

所有返回值都是 JSON。错误返回统一为 `{ "error": "错误描述" }`。

### 认证

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/auth/register` | 注册 `{ username, email, password }` |
| POST | `/api/auth/login` | 登录 `{ email, password }` → 返回 `{ token, user }` |
| GET  | `/api/auth/me` | 获取当前用户（需 `Authorization: Bearer <token>`） |

### Feed

| 方法 | 路径 | 说明 |
|------|------|------|
| GET  | `/api/feed?page=1&size=20` | 分页 Feed |

### 帖子

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/posts` | 发帖（需登录）`{ content, imageUrl? }` |
| POST | `/api/posts/:id/like` | 切换点赞状态（需登录）→ 返回最新 Post |
| GET  | `/api/posts/:id/comments` | 评论列表 |
| POST | `/api/posts/:id/comments` | 发评论（需登录）`{ content }` |

## 数据模型（与客户端对齐）

```json
// User
{ "id": "u_1", "username": "alice", "avatar": "https://...", "bio": null, "createdAt": "2026-10-30T..." }

// Post
{ "id": "p_1", "content": "...", "imageUrl": "https://...", "author": {User}, "likes": 42, "comments": 3, "liked": false, "createdAt": "..." }

// Comment
{ "id": "c_1", "postId": "p_1", "content": "...", "author": {User}, "createdAt": "..." }
```

## 数据库

SQLite 文件在 `server/data/flow.db`。首次启动自动建表。想清空数据直接删这个文件。

表结构：

```sql
users(id TEXT PK, username TEXT UNIQUE, email TEXT UNIQUE, password_hash TEXT, avatar TEXT, bio TEXT, created_at TEXT)
posts(id TEXT PK, user_id TEXT → users.id, content TEXT, image_url TEXT, likes INT, comments INT, created_at TEXT)
post_likes(user_id TEXT → users.id, post_id TEXT → posts.id, PRIMARY KEY(user_id, post_id))
comments(id TEXT PK, post_id TEXT → posts.id, user_id TEXT → users.id, content TEXT, created_at TEXT)
```

## 换成你自己的后端

1. 保持以上 API 端点和 JSON 结构
2. 把客户端 `lib/core/network/api_config.dart` 里的 `baseUrl` 改成你的后端地址
3. 客户端 `Repository` 里的 mock 方法 → `_dio.get/post`（README 有完整示例）

License: MIT
