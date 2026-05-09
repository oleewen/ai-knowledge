# docs-change 工作流（五步）

时间语义见 [core-concepts.md](core-concepts.md)；采集见 [collection-rules.md](collection-rules.md)；验证见 [quality-checklist.md](quality-checklist.md)。

## 步骤 1：环境准备

1. 输出目录可写（规则见 collection-rules「输出目录定位」）。
2. 检测 Git；不可用则跳过 git 来源，流程继续。
3. 扫描 `CHANGELOG*`、`CHANGE-LOG.md`、`changes*` 等候选。
4. 歧义按 [gates.md](gates.md) 先确认。

## 步骤 2：时间基准

```
baseline_time = --since | CHANGE-LOG 文末注释 | "2020-01-01 00:00:00.000"
cutoff_time   = max(baseline_time, latest_git_commit_time)   # 无 Git 时 = baseline_time
```

- **Git**：`baseline_time` 过滤。
- **CHANGELOG / 本地文件**：`cutoff_time` 过滤。

二者不可混用，见 [gotchas.md](../gotchas.md)。

## 步骤 3：采集

默认三源并行。可选脚本（路径按实际调整）：

```bash
agent/skills/docs-change/scripts/change-indexing.sh \
  --since "2026-03-20 00:00:00.000" \
  --output ./changelogs/
```

输出 `{output_dir}/.raw/`；Agent 解析后写 `CHANGE-LOG.md`。细则见 collection-rules。

## 步骤 4：处理与写入

1. 标记来源：`git` / `changelog` / `local`。
2. 统一展示时间 `yyyy-MM-dd HH:mm:ss.SSS`；比较用毫秒戳。
3. 按时间倒序。
4. 写入 `CHANGE-LOG.md`（结构见 [../assets/changes-index-template.md](../assets/changes-index-template.md)）。
5. **增量**：新条目插文件最前；更新文末 `<!-- docs-change:baseline_time_ms=... -->`。

## 步骤 5：验证

按 [quality-checklist.md](quality-checklist.md) 核对后收束。
