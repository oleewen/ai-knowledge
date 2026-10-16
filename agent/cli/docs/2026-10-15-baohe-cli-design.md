# 宝盒lite 会话抽取 CLI — 设计

日期：2026-10-15  
仓库：`ai-knowledge`  
实现路径：`agent/cli/`（包名建议 `baohe`）  
状态：待用户审阅后进入实现计划

## 背景

宝盒lite（Electron，`zbox-lite`）本机数据在  
`~/Library/Application Support/zbox-lite/`。消息不以官方全量导出形式提供，主要来源：

- `Partitions/baohe_<uid>/IndexedDB/file__0.indexeddb.leveldb`（近期会话缓存）
- `localCache.json`：`search_history`（会话名/ID）、`forwardMsgId_*`（转发消息 base64）

已有一次性产物：`~/Documents/grok-exports/log-governance-*.{json,md}`（「日志采集治理」群）。

## 目标

做只读 Python CLI，支持：

1. **点名导出**：指定单聊/群 → 关键信息报告骨架（消息摘录，不含 LLM 总结）
2. **最近批量**：按时间扫最近会话 → 多份简报 + 索引

输出同时提供 **JSON（机器可读）** 与 **Markdown（可读稿骨架）**。  
覆盖范围：**本地缓存尽力而为**，报告头标明局限。

非目标：远端登录、改写宝盒数据、内置 LLM 总结、UI 自动化、全量历史保证。

## 命令面

入口：`python -m baohe` 或 `pip install -e agent/cli` 后的 `baohe`。

| 命令 | 作用 |
| --- | --- |
| `baohe list [--days N]` | 列出本机能识别的单聊/群 |
| `baohe export <名称或ID> [--days N] [-o 目录]` | 点名导一份 |
| `baohe recent [--days N] [--limit K]` | 最近会话批量简报 |

全局可选：`--data-dir`（覆盖 zbox-lite 根目录）、`-v`/`--verbose`。

## 布局

```
agent/cli/
  README.md
  pyproject.toml
  baohe/
    __init__.py
    __main__.py
    cli.py          # argparse 入口
    discover.py     # 定位数据目录 / uid partition
    sessions.py     # search_history + ID 合并
    messages.py     # LevelDB / forward 缓存解析与过滤
    export.py       # 写 JSON + MD
    models.py       # Session / Message 规范化结构
```

默认输出根：`~/Documents/grok-exports/baohe/<slug>-<timestamp>/`  
`recent` 另写 `index.md` 串联各会话目录。

## 数据流

1. **发现**：默认 `~/Library/Application Support/zbox-lite`；解析 `Partitions/baohe_*`；`--data-dir` / 环境变量 `BAOHE_DATA_DIR` 可覆盖。
2. **会话**：`localCache.json` → `search_history`（`name`/`groupName`/`id`/`chatType`）为主；与 IndexedDB 可解析会话 ID 合并去重。
3. **消息**：只读；若 LevelDB 被占用，先拷贝到临时目录再解析。解析可读 UTF-8/JSON 片段 + 解码 `forwardMsgId_*`；按 `groupId` / `conversationId` / 名称过滤；按 `sendTime` 排序；去掉明显噪声。图片/语音等非文本记占位（如 `[图片]`）。
4. **导出**：
   - `messages.json`：规范化字段（至少 `msgId`, `sender`, `senderId`, `body`, `sendTime`, `chatType`, `sessionId`, `sessionName`, `source`）
   - `report.md`：元信息、覆盖说明、时间线摘录、空的「关键结论」区（人工或外接 AI 填写）
5. **失败**：锁/缺库 → 明确错误与建议；零命中 → 非零退出码 + 已扫范围说明。

## 依赖与实现约束

- Python 3.9+（与本机一致）
- LevelDB：优先**无需编译扩展**的方案（拷贝后扫 `.log`/`.ldb` 字符串并抽 JSON；若后续稳定性不足再评估 `plyvel`）
- 不依赖宝盒进程内 API；不写回任何应用数据文件

## 验收

1. `baohe export 日志采集治理`（或对应 ID）得到非空 `messages.json` + `report.md`
2. `baohe recent --days 2` 列表/产物中能出现该群（在缓存仍有数据的前提下）
3. 宝盒开着时：拷贝路径可读，或失败信息可读且可操作
4. `agent/cli/README.md` 含安装与三条命令示例

## 风险与局限

- IndexedDB 仅为近期缓存，历史会缺失；必须在报告中声明
- Chromium LevelDB 格式可能随宝盒版本变化；解析器需可演进
- 并发写导致拷贝瞬时不一致：接受 best-effort，必要时提示关闭客户端后重试

## 后续（本设计不做）

- 可选接入 LLM 生成「关键结论」
- 近全量方案（若官方/私有 API 可用再开新 spec）
