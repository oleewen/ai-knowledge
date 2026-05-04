# docs-change 工作流（五步）

多源融合变更追踪的推荐执行顺序。时间语义见 [core-concepts.md](core-concepts.md)；采集与排除表见 [collection-rules.md](collection-rules.md)；验证见 [quality-checklist.md](quality-checklist.md)。

---

## 步骤 1：环境准备

1. 定位输出目录并确认可写（规则见 [collection-rules.md](collection-rules.md)「输出目录定位」）。
2. 检测 Git 可用性（不可用则跳过 git 来源，**不终止**流程）。
3. 扫描 `CHANGELOG*` / `CHANGE-LOG.md` / `changes*` 等候选文件。
4. 若存在歧义，按 [gates.md](gates.md)「前置确认与歧义处理」先与用户确认。

---

## 步骤 2：时间基准计算

```
baseline_time = --since 参数 | CHANGE-LOG.md 文末注释 | "2020-01-01 00:00:00.000"
cutoff_time   = max(baseline_time, latest_git_commit_time)   # Git 不可用时 = baseline_time
```

- **Git** 来源用 `baseline_time` 过滤。
- **CHANGELOG** 与**本地文件**用 `cutoff_time` 过滤。

二者不可混用，详见 [gotchas.md](../gotchas.md)。

---

## 步骤 3：数据采集

默认**三源并行**采集。可用辅助脚本收集原始数据：

```bash
agent/skills/docs-change/scripts/change-indexing.sh \
  --since "2026-03-20 00:00:00.000" \
  --output ./changelogs/
```

（于仓库根执行时路径按实际调整。）

脚本输出到 `{output_dir}/.raw/`（见脚本头注释），由 Agent 读取、解析、整理后写入 `CHANGE-LOG.md`。细则见 [collection-rules.md](collection-rules.md)。

---

## 步骤 4：数据处理与输出

1. 三源数据各自标记来源（`git` / `changelog` / `local`）。
2. 统一时间格式：字符串 `yyyy-MM-dd HH:mm:ss.SSS`（比较时用毫秒戳，见 gotchas）。
3. 按时间**倒序**排列。
4. 将本轮摘要与条目写入 `CHANGE-LOG.md`（结构参考 [../assets/changes-index-template.md](../assets/changes-index-template.md)）。
5. **增量模式**：新条目**插入文件最前**（最新在上），历史保留不删；更新文末 `<!-- docs-change:baseline_time_ms=... -->`。

---

## 步骤 5：验证

按 [quality-checklist.md](quality-checklist.md) 逐项核对后再收束本轮输出。
