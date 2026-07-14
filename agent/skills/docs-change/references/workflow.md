# docs-change 工作流

时间语义见 [core-concepts.md](core-concepts.md)；采集见 [collection-rules.md](collection-rules.md)；验证见 [quality-checklist.md](quality-checklist.md)。

## 参数

| 参数 | 必需 | 默认 | 说明 |
| ---- | ---- | ---- | ---- |
| `--since` | 否 | 见时间基准 | `yyyy-MM-dd HH:mm:ss.SSS` 或 epoch ms |
| `--output` | 否 | `${DOC_ROOT}/changelogs/` | 用户指定 > `.docsconfig` 解析 |
| 来源范围 | 否 | 三源并行 | `git` / `changelog` / `local` 或其子集 |

硬输入：仓库根且存在有效 `.docsconfig`（`DOC_ROOT` / `REPO_ROOT` / `DOC_DIR`）。

## 参数向导

按以下顺序收口参数；用户已明确时可跳过对应项：

1. `--since` 或基线策略
2. `--output`
3. 来源范围（默认三源并行）

参数未收口前，不进入执行。

## 当前输出单元

一个当前输出单元就是单个 `CHANGE-LOG.md` 输出。

一次只处理一个当前输出单元，不并行推进多个输出目录。

## 执行循环

### 1 环境准备

1. **`.docsconfig` 硬门禁**（见 [gates.md](gates.md)）：`validate_bootstrap_docsconfig`；失败即中止
2. `DOC_ROOT="$(resolve_repo_doc_root)"`；`cd "$REPO_ROOT"`
3. 默认输出：`DEFAULT_OUTPUT="${DOC_ROOT}/changelogs"`；用户 `--output` 可覆盖
4. 输出目录可写；检测 Git；扫描 CHANGELOG 候选

### 2 时间基准

```text
baseline_time = --since | CHANGE-LOG 文末注释 | "2020-01-01 00:00:00.000"
cutoff_time   = max(baseline_time, latest_git_commit_time)   # 无 Git 时 = baseline_time
```

- **Git**：`baseline_time` 过滤
- **CHANGELOG / 本地文件**：`cutoff_time` 过滤

二者不可混用，见 [gotchas.md](../gotchas.md)。

### 3 采集

默认三源并行。可选脚本（路径按实际调整）：

```bash
agent/skills/docs-change/scripts/change-indexing.sh \
  --since "2026-03-20 00:00:00.000"
```

输出 `{output_dir}/.raw/`；Agent 解析后写 `CHANGE-LOG.md`。细则见 collection-rules。

### 4 处理与写入

1. 标记来源：`git` / `changelog` / `local`
2. 统一展示时间 `yyyy-MM-dd HH:mm:ss.SSS`；比较用毫秒戳
3. 按时间倒序
4. 写入 `CHANGE-LOG.md`（结构见 [../assets/changes-index-template.md](../assets/changes-index-template.md)）
5. **增量**：新条目插文件最前；更新文末 `<!-- docs-change:baseline_time_ms=... -->`

### 5 轻量校核与动作停顿

当前输出单元写入后，立即校核：

- `.docsconfig` 是否真实生效
- `baseline_time` 与 `cutoff_time` 是否按约定使用
- 是否出现重复条目或来源遗漏
- 输出路径是否仍是已确认目录

当前输出单元收敛后，停下等待 `C/M/S/F`：

- `C`：确认当前输出单元并结束或进入下一输出目录
- `M`：修改时间基准、输出目录或来源范围，再重新校核
- `S`：跳过当前输出单元，不写入
- `F`：按已确认参数补齐剩余输出目录
