# document-change 常见陷阱（Gotchas）

本文记录执行 `document-change` Skill 时高频踩坑点，供 Agent 与人类开发者参考。

---

## 1. 时间基准阶段

### 1.1 忽略已有 changes-index.json 中的 baseline_time
**陷阱**：增量执行时直接使用默认值 `2020-01-01`，未读取已有 `changes-index.json` 中的 `baseline_time`。  
**后果**：重复收录历史变更，产物膨胀，下游 `document-indexing` 重复处理。  
**正确做法**：严格按优先级：命令行 `--since` > 已有 JSON 的 `baseline_time` > 默认值。

### 1.2 混淆 baseline_time 与 cutoff_time
**陷阱**：把 `baseline_time` 和 `cutoff_time` 当同一个值使用，跳过 `max(baseline, latest_git_commit)` 计算。  
**后果**：CHANGELOG 和本地文件过滤阈值偏低，收录了 git 已覆盖时间段内的冗余条目。  
**正确做法**：Git 可用时，`cutoff_time = max(baseline_time, latest_git_commit_time)`；Git 不可用时，`cutoff_time = baseline_time`。

### 1.3 时间格式不统一
**陷阱**：不同来源的时间字符串格式混用（ISO 8601、Unix timestamp、自定义格式），未统一转换。  
**后果**：时间比较逻辑出错，过滤条件失效，漏收或多收变更。  
**正确做法**：所有时间统一转换为 `yyyy-MM-dd HH:mm:ss.SSS` 字符串 + 13 位毫秒戳双格式，比较时一律用 `*_ms` 字段。

---

## 2. 数据采集阶段

### 2.1 Git 不可用时终止流程
**陷阱**：`git --version` 失败后直接报错退出，未继续采集 CHANGELOG 和本地文件来源。  
**后果**：在无 Git 环境（如 CI 容器、只读挂载）下完全无产出。  
**正确做法**：Git 不可用时输出警告并跳过 git 来源，继续执行其余两个来源（优雅降级）。

### 2.2 CHANGELOG 日期解析失败时静默跳过整个文件
**陷阱**：CHANGELOG 文件中某一条目日期格式不匹配，导致整个文件被跳过，无任何提示。  
**后果**：有效的 CHANGELOG 条目丢失，产物不完整。  
**正确做法**：解析失败时只跳过该条目并输出 `[WARN]` 日志，继续解析同文件其余条目。

### 2.3 本地文件扫描未排除输出目录自身
**陷阱**：扫描 `mtime` 时将 `{output_dir}` 本身（如 `./changelogs/`）纳入扫描范围。  
**后果**：每次执行都把上次生成的 `changes-index.json` 和 `changes-index.md` 收录为变更，产生自引用循环。  
**正确做法**：扫描前将输出目录加入排除列表，与 `.git`、`node_modules` 等同等处理。

### 2.4 三源过滤规则不一致
**陷阱**：Git 来源用 `> baseline_time`，CHANGELOG 和本地文件也用 `> baseline_time`，忽略 `cutoff_time` 的区别。  
**后果**：CHANGELOG 和本地文件收录了 git 提交已覆盖的时间段，产生冗余条目。  
**正确做法**：Git 来源过滤用 `baseline_time`，CHANGELOG 和本地文件过滤用 `cutoff_time`（两者可能不同）。

---

## 3. 数据处理与输出阶段

### 3.1 JSON 与 Markdown 统计数不一致
**陷阱**：JSON 的 `statistics.total_changes` 与 Markdown 中「总变更数」字段分别计算，出现偏差。  
**后果**：验证清单检查失败；下游 Skill 消费 JSON 时数量与可读摘要对不上。  
**正确做法**：先生成 JSON，Markdown 的统计数直接从 JSON `statistics` 字段读取，保证单一来源。

### 3.2 未按时间倒序排列
**陷阱**：三源数据合并后未排序，或只对单源内部排序，跨源顺序混乱。  
**后果**：Markdown 摘要时间线混乱，下游 Skill 读取「最新变更」时取到错误条目。  
**正确做法**：合并后统一按 `time_ms` 倒序排列，再生成双格式产物。

### 3.3 增量执行覆盖而非追加
**陷阱**：增量执行时直接覆盖已有 `changes-index.json`，丢失历史变更记录。  
**后果**：`baseline_time` 丢失，下次执行无法正确计算时间基准；审计链断裂。  
**正确做法**：增量执行时将新变更合并追加到已有 JSON 的 `changes` 数组，更新 `metadata` 中的时间字段，不清空历史记录。

---

## 4. 验证阶段

### 4.1 跳过 JSON 格式有效性校验
**陷阱**：生成后未执行 `jq empty` 或等效校验，直接交付。  
**后果**：下游 `document-indexing` 解析 JSON 时报错，增量索引中断。  
**正确做法**：输出后必须验证 JSON 格式有效性，以及 `metadata`、`statistics`、`changes` 三个顶层字段存在。

### 4.2 时间一致性校验遗漏
**陷阱**：未校验 `changes` 数组中所有条目的 `time_ms > metadata.cutoff_time_ms`。  
**后果**：过期变更混入产物，下游 Skill 基于错误时间基准执行增量操作。  
**正确做法**：验证清单中时间一致性为必检项，发现不符条目时输出 `[WARN]` 并标记。

---

## 5. 与下游 Skill 的协作

### 5.1 输出目录路径与下游约定不一致
**陷阱**：用户未指定 `--output` 时输出到 `./system/changelogs/`，但下游 `document-indexing` 默认从 `./changelogs/` 读取。  
**后果**：下游 Skill 找不到 `changes-index.json`，增量模式降级为全量。  
**正确做法**：严格按优先级：用户指定 > `./changelogs/` > `./system/changelogs/`；与下游 Skill 约定保持一致。

### 5.2 `source` 字段缺失导致下游无法分流
**陷阱**：`changes` 数组中的条目未标注 `source` 字段（`git` / `changelog` / `local`）。  
**后果**：下游 `knowledge-extract` 无法按来源类型分流处理，只能全量消费。  
**正确做法**：每条变更记录必须包含 `source` 字段，三源数据合并时各自标记来源。

---

## 快速检查清单

执行完毕后，对照以下项目快速自查：

- [ ] 时间基准按优先级正确读取，未直接使用默认值
- [ ] `cutoff_time = max(baseline_time, latest_git_commit_time)` 计算正确
- [ ] 所有时间统一为双格式（字符串 + 13 位毫秒戳）
- [ ] Git/CHANGELOG 不可用时已优雅降级，未终止流程
- [ ] 输出目录自身已从本地文件扫描中排除
- [ ] JSON `statistics.total_changes` 与 Markdown 统计数一致
- [ ] `changes` 数组按 `time_ms` 倒序排列
- [ ] 增量执行未清空历史 `changes` 记录
- [ ] JSON 格式有效性已校验（`jq empty` 通过）
- [ ] 所有条目 `time_ms > cutoff_time_ms`
- [ ] 每条变更记录含 `source` 字段
