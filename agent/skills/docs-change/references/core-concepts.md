# docs-change 核心概念

术语与时间线；**流程**见 [workflow.md](workflow.md)。

---

## 三源

| 标签 | 含义 |
|------|------|
| `git` | `git log` 在 `baseline_time` 之后的提交 |
| `changelog` | `CHANGELOG*` 等文件中解析出的版本条目，用 `cutoff_time` 过滤 |
| `local` | 工作区文件 `mtime > cutoff_time`（排除列表见 [collection-rules.md](collection-rules.md)） |

---

## baseline_time 与 cutoff_time

- **`baseline_time`**：本轮增量起点。取自 `--since` > 已有 `CHANGE-LOG.md` 文末 `baseline_time_ms` > 默认 `2020-01-01`。
- **`cutoff_time`**：`max(baseline_time, latest_git_commit_time)`；Git 不可用时等于 `baseline_time`。

**Git** 提交过滤使用 **`baseline_time`**。**CHANGELOG** 与**本地 mtime** 使用 **`cutoff_time`**。二者不可互换。

---

## 文末基线注释

`CHANGE-LOG.md` 文末 HTML 注释形态：`<!-- docs-change:baseline_time_ms=... -->`

供下次增量采集读取；丢失会导致下次退化为从默认起点重扫，见 gotchas。
