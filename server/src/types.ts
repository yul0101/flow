// 这些类型与客户端 domain 模型保持一致
// 对齐的目的：让 API 返回能直接被客户端 freezed 模型解析

export interface User {
  id: string;
  username: string;
  avatar: string;
  bio: string | null;
  createdAt: string;
}

export interface Post {
  id: string;
  content: string;
  imageUrl: string | null;
  author: User;
  likes: number;
  comments: number;
  liked: boolean;
  createdAt: string;
}

export interface Comment {
  id: string;
  postId: string;
  content: string;
  author: User;
  createdAt: string;
}

export interface AuthTokens {
  token: string;
  user: User;
}
