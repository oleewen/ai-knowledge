# docs-archive Skill 重构设计（应用知识库归档到系统知识库）

**日期**: 2026-04-07  
**类型**: Skill 重构设计  
**范围**: `.agent/skills/docs-archive/`（`SKILL.md + reference/* + scripts/`*）及归档相关命名统一

---

## 1. 背景与目标

当前 `docs-archive` 已具备“应用知识上行系统知识库”的基本描述，但存在以下问题：

- 关键命名不统一（`ARCHITECTURE` 拼写、`CHANGE-LOG/ARCHIVE-LOG` 命名混杂）
- 增量锚点职责和系统变更日志职责边界不清晰
- `--dry-run` 行为粒度不足，难以做人工确认
- 旧脚本职责交叉且命名与语义不一致

本次重构目标：

1. 将应用知识库 `system/application-{name}/` 中已核实内容归档到 `system/architecture/`；
2. 严格按 `architecture/` 模板要求填充；
3. 支持增量锚点、`--dry-run`、`--full`；
4. 归档后记录系统变更日志并更新应用归档锚点日志；
5. 强化技能触发语义，确保用户口语指令也会触发。

---

## 2. 信息架构与文件职责

### 2.1 日志职责（三日志）

- **应用变更日志（源日志）**
  - 路径：`system/application-{name}/changelogs/CHANGE-LOG.md`
  - 语义：记录应用知识库自身变更事实（来源变更），不作为归档锚点日志。
- **应用归档日志（锚点真源）**
  - 路径：`system/application-{name}/changelogs/ARCHIVE-LOG.md`
  - 语义：记录该应用每次归档批次与 last marker。
  - 用途：默认增量起点依据此文件。
- **系统变更日志（系统侧批次）**
  - 路径：`system/changelogs/CHANGE-LOG.md`
  - 语义：系统知识库变更批次日志。
  - 粒度：每次归档 1 条（按 app 聚合）。

### 2.2 归档目标目录

- 归档目标：`system/architecture/`
- 目标文件统一命名：
  - `system/architecture/BUSINESS-ARCHITECTURE.md`
  - `system/architecture/TECHNICAL-ARCHITECTURE.md`
  - `system/architecture/DATA-ARCHITECTURE.md`
  - `system/architecture/PRODUCT-ARCHITECTURE.md`

---

## 3. 流程与参数语义

### 3.1 归档主流程（四步）

#### Step 0：解析范围

- 默认增量：读取 `ARCHIVE-LOG.md` 的 last marker。
- 指定 `--since`：覆盖默认锚点。
- 指定 `--full`：忽略锚点，执行全量扫描。

#### Step 1：提取候选

- 从 `system/application-{name}/` 提取已核实且可归档内容。
- 仅提取与四视角架构模板对应的结构化片段。

#### Step 2：写入架构文档

- 仅写入模板定义的“受管区块”。
- 非受管区块严格不变。
- 多文件写入需保持批次一致性。

#### Step 3：记录与锚点（原子顺序）

1. 先写 `system/changelogs/CHANGE-LOG.md` 批次记录；
2. 再更新应用 `ARCHIVE-LOG.md`；
3. 若任一失败，不推进锚点。

### 3.2 参数行为

- `--app`：仅处理指定应用；未指定则遍历全部 `system/application-`*
- `--since`：人工指定起点，覆盖锚点
- `--full`：全量扫描，但仍遵守“仅覆盖受管区块”
- `--dry-run`：输出
  - 处理范围（app、模式、区间）
  - 目标文件拟变更摘要
  - 拟写入片段预览（不落盘）

---

## 4. 重构方案（已确认）

采用“规范与脚本同步重构”：

- 同步重构 `SKILL.md + reference/* + scripts/*`
- 一次性统一命名、流程、参数、示例命令
- 删除旧脚本，避免双轨语义长期并存

不采用“仅文档最小改动”或“引入复杂中间 plan 层”的原因：

- 前者无法完整满足 `--dry-run` 预览与日志职责重塑；
- 后者复杂度超出本次目标。

---

## 5. 脚本重构设计

### 5.1 新脚本职责（建议）

- `scripts/update-application-archive-log.sh`
  - 更新 `system/application-{name}/changelogs/ARCHIVE-LOG.md`
  - 参数示例：`--app --changelog-id --changelog-time [--archived-at]`
- `scripts/append-system-change-log.sh`
  - 追加 `system/changelogs/CHANGE-LOG.md` 批次记录（按 app 聚合）
  - 参数示例：`--app --changelog-id --changelog-time [--archived-at] [--summary]`

### 5.2 删除旧脚本

- 删除：
  - `.agent/skills/docs-archive/scripts/update-fetch-log.sh`
  - `.agent/skills/docs-archive/scripts/update-archive-log.sh`

要求：删除后全仓不得残留对旧脚本的调用或文档引用。

---

## 6. Skill 触发策略（强触发）

`docs-archive` 需在以下场景强触发：

- 用户执行 `/docs-archive`
- 用户表达：
  - 「归档」
  - 「同步应用知识到系统」
  - 「同步一下」
  - 「把应用侧内容推上去」
  - 「更新主库」
  - 「应用更新后刷新主库索引与契约」

触发后默认进入归档流程，除非用户显式拒绝执行该技能。

---

## 7. 迁移清单（执行顺序）

1. 统一 `system/architecture/*-ARCHITECTURE.md` 命名并全仓替换引用。
2. 迁移系统日志到 `system/changelogs/CHANGE-LOG.md`。
3. 为每个 `system/application-{name}` 建立并统一：
  - `changelogs/CHANGE-LOG.md`
  - `changelogs/ARCHIVE-LOG.md`
4. 重写 `.agent/skills/docs-archive/SKILL.md` 与 `reference/*`。
5. 替换并重构脚本；删除旧脚本。
6. 执行全仓引用自检（旧命名零命中）。
7. 以单应用执行一次 `--dry-run` 与一次真实归档回归。

---

## 8. 验收标准（DoD）

- `docs-archive` 文档、参考与脚本对三日志职责描述一致。
- 默认增量、`--since`、`--full`、`--dry-run` 行为一致且可验证。
- `system/architecture/` 目标文件名全部为 `*-ARCHITECTURE.md`。
- 旧脚本删除后，仓库内无残留引用。
- 归档批次成功后：
  - `system/changelogs/CHANGE-LOG.md` 新增一条批次记录；
  - `system/application-{name}/changelogs/ARCHIVE-LOG.md` 更新锚点。

---

## 9. 风险与控制

- 风险：重命名与删脚本导致历史调用断裂。  
  - 控制：迁移后执行全仓检索与一次端到端 dry-run + 实跑。
- 风险：受管区块边界定义不清导致误改人工内容。  
  - 控制：在模板中标注受管区块标记并在脚本中强校验。
- 风险：`--full` 模式误判为全文件覆盖。  
  - 控制：文档与脚本同时声明“仅覆盖受管区块”。

---

## 10. 非目标

- 本次不引入额外归档中间 DSL（如 `archive-plan.json`）作为执行主路径。
- 本次不扩展到 `company/` 层归档流程，仅覆盖 `system/`。