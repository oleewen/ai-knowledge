# docs-change 采集规则

歧义是否停顿见 [gates.md](gates.md)。

## 输出目录

**前置**：须已通过 [gates.md](gates.md) `.docsconfig` 硬门禁。

1. 用户 `--output`（相对 `REPO_ROOT` 或绝对路径）
2. `${DOC_ROOT}/changelogs/`（`.docsconfig` 解析之文档根下 changelogs）

已移除：`./changelogs/` 仓库根默认、最短路径 `**/changelogs/`、无配置时新建 `./changelogs/`。

## Git

**条件**：`commit_time > baseline_time`

```bash
git log --since="$BASELINE_TIME" \
    --pretty=format:"%H|%aI|%aN|%s" --name-only
```

字段：`commit_hash`、`time`、`author`、`message`、`files[]`

## CHANGELOG

**条件**：`entry_time > cutoff_time`

| 格式 | 示例 |
|------|------|
| Keep a Changelog | `## [1.0.0] - 2026-03-23` |
| Semantic Release JSON | `{"version":"1.0.0","date":"2026-03-23T10:00:00Z"}` |
| 自定义 | 日期 `\d{4}-\d{2}-\d{2}` |

正则：

```
\[(\d{4}-\d{2}-\d{2})\]|(\d{4}-\d{2}-\d{2})|(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})
```

条目解析失败：`[WARN]` 跳过该条，继续同文件其余条目。

## 本地文件

**条件**：`mtime > cutoff_time`

| 排除 | 原因 |
|------|------|
| `.git` | 版本控制 |
| `node_modules` | 依赖 |
| `.venv`、`__pycache__` | Python |
| `target`、`build` | 构建产物 |
| `.cursor`、`.idea`、`.vscode` | IDE |
| `{output_dir}` | 防自引用循环 |

## 错误处理

| 场景 | 处理 |
|------|------|
| Git 不可用 | `[WARN]` 跳过 git |
| CHANGELOG 单条无效 | `[WARN]` 跳过该条 |
| 输出目录不可写 | 创建或报错终止 |
| JSON 异常 | 清临时文件，`[ERROR]` |
| 时间无效 | 默认或跳过 |

```
[ERROR] [yyyy-MM-dd HH:mm:ss] …
[WARN]  [yyyy-MM-dd HH:mm:ss] …
[INFO]  [yyyy-MM-dd HH:mm:ss] …
```
