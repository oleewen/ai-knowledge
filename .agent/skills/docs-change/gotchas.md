# docs-change 常见陷阱

---

## 时间基准

**baseline vs cutoff 混淆**：这是最高频的错误。`baseline_time` 和 `cutoff_time` 是两个不同的值——Git 来源用 `baseline_time` 过滤，CHANGELOG 和本地文件用 `cutoff_time`（= `max(baseline, latest_git_commit)`）。用错会导致冗余条目或漏收。

**增量时忘读已有 JSON**：增量执行时必须先读 `changes-index.json` 的 `metadata.baseline_time`，否则会用默认值 `2020-01-01` 重复收录全量历史。

**时间格式不统一**：不同来源的时间格式各异，比较时一律用 `*_ms`（13 位毫秒戳）字段，不要用字符串比较。

---

## 数据采集

**输出目录自引用**：扫描本地文件 mtime 时，必须将 `{output_dir}` 加入排除列表，否则每次执行都会把上次生成的 `changes-index.json` 收录为变更，形成循环。

**Git 不可用时终止**：Git 检测失败应优雅降级（输出 `[WARN]`，跳过 git 来源），不应终止整个流程。CHANGELOG 和本地文件来源仍需继续采集。

**CHANGELOG 解析失败静默丢弃整个文件**：某条目日期格式不匹配时，只跳过该条目并输出 `[WARN]`，不要跳过整个文件。

---

## 输出处理

**增量执行覆盖历史**：增量模式必须将新变更**追加**到已有 `changes` 数组，更新 `metadata` 时间字段，不能清空历史记录——否则 `baseline_time` 丢失，审计链断裂。

**JSON 与 MD 统计数分别计算**：先生成 JSON，MD 的统计数直接从 JSON `statistics` 字段读取，保证单一来源，避免两边数字对不上。

**合并后未排序**：三源数据合并后必须统一按 `time_ms` 倒序排列，再生成双格式产物。

**`source` 字段缺失**：每条变更记录必须包含 `source` 字段（`git` / `changelog` / `local`），下游 `docs-build` 依赖此字段分流处理。

---

## 与下游协作

**输出路径与下游约定不一致**：未指定 `--output` 时默认输出到 `./changelogs/`，下游 `docs-indexing` 也从此路径读取。若输出到应用知识库下 `./{DOC_DIR}/changelogs/` 而下游期望 `./changelogs/`，增量模式会降级为全量。

---

## 快速自查清单

- [ ] 时间基准按优先级正确读取（`--since` > 已有 JSON > 默认值）
- [ ] `cutoff_time = max(baseline_time, latest_git_commit_time)` 计算正确
- [ ] 所有时间比较使用 `*_ms` 字段
- [ ] 输出目录已从本地文件扫描中排除
- [ ] Git/CHANGELOG 不可用时已优雅降级
- [ ] 增量执行未清空历史 `changes` 记录
- [ ] JSON `statistics.total_changes` 与 MD 统计数一致
- [ ] `changes` 数组按 `time_ms` 倒序排列
- [ ] 每条变更记录含 `source` 字段
- [ ] `jq empty` 校验通过
