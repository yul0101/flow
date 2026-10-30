# Flow - 中文 Flutter 社区 App 架构模板

> 一套**真正能 Fork 即跑**的 Flutter 内容社区架构参考。
>
> **不是又一个社区 App**——是让新人 30 分钟内看到 Feed、7 天内拉起自己社区的**起手式**。
>
> 目标平台：iOS / Android / Web / macOS

## 它是什么

一个完整闭环：

```
Fork 仓库
  ↓
cd server && npm install && npm run dev   # 后端跑起来
  ↓
cd .. && flutter pub get && flutter run   # 客户端连上去
  ↓
alice@flow.com / 123456 登录 → 发帖 → Feed 刷新看到自己的贴 → 点赞 → 评论
```

## 快速开始（全栈）

### 1. 后端（Express + SQLite + JWT）

```bash
cd server
npm install
npm run init-db   # seed demo 用户 + 示例帖子
npm run dev       # 跑在 http://localhost:3000
```

首次启动自动建表，SQLite 单文件数据库在 `server/data/flow.db`。想清空数据删掉这个文件即可。

### 2. 客户端

```bash
flutter pub get
dart run build_runner build   # 生成 freezed / json_serializable
flutter run -d chrome        # Web
flutter run -d macos         # macOS
flutter run -d <iPhone模拟器>  # iOS
```

demo 账号：`alice@flow.com` / `123456`（后端 seed 的）。

### 3. 生产部署

后端切换生产 baseUrl：

```bash
flutter build web --release --dart-define=API_BASE_URL=https://your-api.com
```

## 功能闭环（已实现）

| 模块 | 状态 | 说明 |
|------|------|------|
| 登录 / Token 持久化 / 路由守卫 | ✅ | JWT 自动挂 Authorization 头 |
| Feed 分页 + 下拉刷新 | ✅ | AsyncNotifierProvider，乐观更新 |
| 点赞（乐观更新 + 回滚） | ✅ | 先改 UI，后端返回后以实际为准 |
| 帖子详情 + 评论列表 | ✅ | family provider 按 postId 缓存 |
| 发帖（文本 + 可选图片 URL） | ✅ | 写完顶到 Feed 首位 |
| 主题模式（亮 / 暗 / 系统） | ✅ | FlexColorScheme gold，持久化 |
| 国际化（zh-CN / en-US） | ✅ | easy_localization |
| 真实后端对接 | ✅ | `server/` 提供完整样例 |
| 错误统一处理 | ✅ | AppException sealed class + 拦截器链 |
| 单测 | ✅ | 1 smoke test + 4 集成测试（skip，需后端） |

## 三端构建状态

| 端 | 状态 | 说明 |
|----|------|------|
| iOS 27.1 模拟器 | ✅ 已实跑 | 启动无崩溃，路由守卫正确 |
| macOS arm64 | ✅ 已实跑 | Release 46.5MB |
| Chrome Web | ✅ 已实跑 | Release 28.9s，tree-shaking 99%+ |
| Android | ⏳ 构建链就绪，待真机 | `flutter run -d <device>` 即可 |

## 技术栈

### 客户端

| 领域 | 包 | 选型理由 |
|---|---|---|
| 状态管理 | flutter_riverpod 3.x | 日下载 85k+；**显式 Provider** 而非 `@riverpod` 注解，意图一眼可见 |
| 路由 | go_router 18.x | StatefulShellRoute 原生嵌套导航 + redirect 守卫 |
| 网络 | dio 5.x | 拦截器链、错误统一转换、`ApiConfig.baseUrl` 一处切换环境 |
| 模型 | freezed 4.x + json_serializable | **必须** `abstract class User with _$User`（freezed 4 要求） |
| 主题 | flex_color_scheme 8.x | Material 3；9.0.0 有破坏性变更，故锁 8.x |
| 存储 | shared_preferences | token / 主题模式持久化 |
| 日志 | logger | PrettyPrinter |
| i18n | easy_localization | **必须**放在最外层包裹 `ProviderScope` |

### 后端（server/）

| 技术 | 版本 | 理由 |
|------|------|------|
| Express | 5.x | 轻量、生态成熟 |
| TypeScript | 5.x | 与 Dart 风格接近，新人容易上手 |
| better-sqlite3 | 11.x | 单文件数据库，无额外进程依赖 |
| bcryptjs | 3.x | 纯 JS 实现，无原生依赖 |
| jsonwebtoken | 9.x | JWT 签发 + 验证 |

## 项目结构

```
flow/
├── lib/
│   ├── main.dart                     # EasyLocalization → ProviderScope → FlowApp
│   ├── core/                         # ⚠️ 不能 import features/
│   │   ├── errors/app_exception.dart # sealed class AppException + 6 子类型
│   │   ├── network/                  # dioProvider + auth + error 拦截器
│   │   ├── storage/app_storage.dart
│   │   ├── router/app_router.dart    # go_router + StatefulShellRoute + redirect
│   │   ├── theme/app_theme.dart
│   │   ├── i18n/app_localization.dart
│   │   ├── widgets/
│   │   └── utils/constants.dart
│   └── features/                     # ⚠️ 之间不能互相 import
│       ├── auth/  (domain / data / providers / presentation)
│       ├── feed/  (domain: Post, Comment / data / providers / presentation)
│       └── profile/(presentation + widgets)
├── server/
│   ├── src/
│   │   ├── index.ts                  # Express 入口
│   │   ├── auth.ts                   # JWT 中间件
│   │   ├── db.ts                     # SQLite 连接 + schema
│   │   ├── mappers.ts                # DB row → API response
│   │   ├── seed.ts                   # demo 用户 + 帖子
│   │   └── routes/(auth.ts, feed.ts)
│   ├── package.json
│   ├── tsconfig.json
│   └── README.md                     # API 文档
├── assets/translations/
├── .github/workflows/ci.yml
└── pubspec.yaml
```

## 开发约束

1. **core/** 不能 import features/——违反即分层死亡
2. **features/** 之间不能互相 import——跨模块通信走 `ref.watch` 或 core 抽象
3. Repository 层只暴露 `Future` 方法，状态变化由 Provider 负责
4. 新模型 `@freezed` + `abstract class`
5. `AsyncValue` 三态统一走 `AsyncValueBuilder`

## 换后端

Repository 方法签名已锁死，换任何后端（NestJS / Go / Deno / Flask）只要返回相同 JSON 结构，**客户端零改动**。

换后端两步：

1. 实现 `server/README.md` 里列的 API 端点
2. 更新 `ApiConfig.baseUrl`（`--dart-define` 或直接改值）

## 测试

```bash
# smoke test 始终绿
flutter test

# 集成测试（需要后端启动）
cd server && npm run dev  # 在另一个终端
flutter test --plain-name "集成"  # 或直接 flutter test 去掉 skip
```

## Roadmap

- [ ] 搜索（用户 / 帖子 / 话题）
- [ ] 多账号支持
- [ ] 通知中心（回复 / @ / 点赞）
- [ ] FCM / APNs 推送
- [ ] Docker Compose 一键部署
- [ ] ActivityPub 与 Lemmy / Mastodon 互通（远期）

## License

MIT
