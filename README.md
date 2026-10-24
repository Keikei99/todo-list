# Todo List

一个用 Flutter 实现的待办清单 App，配合 json-server 作为本地 mock 后端。本项目是一次分层架构练习：数据访问（服务层）、界面状态（状态层）、布局（页面/组件层）各自独立，依赖方向只能向下——**pages/widgets → state → services → models**。以后把 mock 后端换成真实服务器，理论上只需要改 `TodoServices` 一个文件。

## 功能

- 待办列表：按创建时间倒序展示，带优先级徽标（高/中/低）和创建日期
- 新增：输入标题、选择优先级后添加
- 完成与撤销：点复选框切换，完成后标题划线
- 删除：点 × 或左滑条目
- 筛选：全部 / 未完成 / 已完成
- 下拉刷新、手动重载；首次加载失败时显示错误页和重试按钮
- 统计行：未完成数量 / 总数

## 技术栈

| 依赖 | 用途 |
| --- | --- |
| Flutter / Dart | UI 框架 |
| `http` | 与 json-server 通信 |
| `provider` | `ChangeNotifier` 状态管理 |
| json-server | 本地 mock 后端（`../mock-server`） |

## 目录结构

```text
lib/
├── main.dart                    # 入口：只做 runApp
├── app.dart                     # TodoApp：主题 + 注入 TodoServices / TodoList
├── models/
│   └── todo.dart                # Todo 模型 + Priority 枚举，JSON 手动解析
├── services/
│   └── todo_services.dart       # 服务层：json-server 增删改查，HTTP 细节止步于此
├── state/
│   └── todo_list.dart           # 状态层：列表数据、筛选、加载/出错状态
├── pages/
│   └── todo_list_page.dart      # 页面：输入区 + 筛选区 + 列表区
└── widgets/
    └── todo_tile.dart           # 复用组件：单条待办卡片
```

## 快速开始

1. 启动 mock 服务（默认监听 `http://localhost:3000`）：

   ```bash
   cd ../mock-server
   npx json-server db.json
   ```

2. 另开一个终端，启动 App：

   ```bash
   flutter run
   ```

网络地址说明：iOS 模拟器可直接访问 `localhost`；Android 模拟器需把 `TodoServices` 的 `baseUrl` 改为 `http://10.0.2.2:3000`；真机使用电脑的局域网 IP 并保证同一 Wi-Fi。

## Mock API

json-server 基于 `db.json` 的 `todos` 资源提供 REST 接口：

| 操作 | 请求 |
| --- | --- |
| 全量列表 | `GET /todos` |
| 单条 | `GET /todos/:id` |
| 新增 | `POST /todos` |
| 更新 | `PATCH /todos/:id` |
| 删除 | `DELETE /todos/:id` |

数据字段：`id`、`title`、`completed`（bool）、`priority`（`low` / `medium` / `high`）、`createdAt`（ISO 8601）。通过接口做的增删改会写回 `db.json`。

## 测试

```bash
flutter test
```

`test/` 下按层各有一份测试：

| 文件 | 覆盖内容 |
| --- | --- |
| `todo_test.dart` | 模型 JSON 解析 |
| `todo_services_test.dart` | 服务层请求 |
| `todo_list_test.dart` | 状态层逻辑 |
| `todo_list_page_test.dart` | 页面交互 |
