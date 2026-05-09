# docs-change 核心概念

流程见 [workflow.md](workflow.md)。

## 三源

| 标签 | 含义 |
|------|------|
| `git` | `git log` 中 `commit_time > baseline_time` |
| `changelog` | `CHANGELOG*` 解析条目，`entry_time > cutoff_time` |
| `local` | `mtime > cutoff_time`（排除见 [collection-rules.md](collection-rules.md)） |

## baseline_time 与 cutoff_time

- **baseline_time**：`--since` > 文末 `baseline_time_ms` > 默认 `2020-01-01`。
- **cutoff_time**：`max(baseline_time, latest_git_commit_time)`；无 Git 时 = `baseline_time`。

**Git** 用 **baseline**；**CHANGELOG / local** 用 **cutoff**。不可互换。

## 文末基线

`<!-- docs-change:baseline_time_ms=... -->` 供下次增量；丢失会退化为默认起点，见 gotchas。
