---
name: docs-indexing
description: >
  为代码库生成结构化文档索引（INDEX_GUIDE.md），支持全量/增量扫描与三级深度（拓扑/结构/精读）。
  执行前必须由用户显式确认扫描模式（全量/增量）与深度（1/2/3）；禁止在未获确认时代为选定参数。
  深度 3（精读）须在过滤规则内应读尽读、尽量遍历目录与读全文件，并在九章结构下尽可能多地建立索引条目。
  产出标准化九章文档索引，为 Agent 导航与 RAG 上下文提供权威文档地图。
  在用户执行 /docs-indexing、需要生成或更新项目索引文档、或进行项目 Onboarding 时使用。
---

# 文档索引生成器（docs-indexing）

将代码库解析为结构化、可检索的文档索引 INDEX_GUIDE.md，作为 Agent 与开发者的系统全景导航。

## 输入与输出

**输入**：用户已确认的扫描模式 + 用户已确认的扫描深度 + 代码库（**不得**由 Agent 默认定参）
**输出**：`{Doc Root}/INDEX_GUIDE.md`（九章结构）、`changelogs/indexing-log.jsonl`（操作日志）

| 类型 | 内容 |
|------|------|
| 硬输入 | 代码库根目录、**用户确认的**扫描模式（full/incremental）、**用户确认的**扫描深度（1/2/3） |
| 可选输入 | 输出路径、增量起始时间、`changes-index.json`（增量模式）；**凡影响索引行为的取值均须用户确认或显式提供，禁止 Agent 自行推断** |
| 固定输出 | `{Doc Root}/INDEX_GUIDE.md`、`changelogs/indexing-log.jsonl` |
| 不产出 | 不生成知识实体 ID、不修改 README/AGENTS、不产出 CHANGELOG |

## 用户确认门禁（强制）

在执行本技能的任何扫描、脚本调用或写文件步骤之前，**必须**同时满足：

1. **模式**：用户已明确选择 **全量（full）** 或 **增量（incremental）**。不得因「无历史日志」「省事」等理由由 Agent 代为选定；若增量前提不满足（例如无 `indexing-log.jsonl`），须向用户说明并**重新请用户确认**是否改走全量或中止。
2. **深度**：用户已明确选择 **1（拓扑）**、**2（结构）** 或 **3（精读）**。不得根据仓库大小、时间压力或 Agent 判断自动降级或升级深度。
3. **其他影响行为的参数**（如 `--output`、`--since`、是否使用某份 `changes-index.json`）：若脚本或流程会读取这些值，则须**用户确认**或**用户显式给出字面量**；禁止在未确认时从日志「自动取最近时间戳」等隐式行为作为执行依据。

**未完成上述确认前，禁止进入「步骤 3」及之后。**

快捷选项（供用户在对话中一次性回复，Agent 仅记录为已确认参数，不得替用户勾选）：

- 模式：`A` 全量（full） / `B` 增量（incremental）
- 深度：`1` / `2` / `3`

## 参数

| 参数 | 必需 | 说明 |
|------|------|------|
| `--mode` | 是 | **必须由用户确认**：`f`/`full`（全量）或 `i`/`incremental`（增量）；无默认、无 Agent 代选 |
| `--depth` | 是 | **必须由用户确认**：`1`（拓扑）、`2`（结构）、`3`（精读）；无默认、无 Agent 代选 |
| `--output` | 否 | 输出路径；若脚本有默认值，**仍须在执行前向用户展示并确认**，或用户显式给出路径 |
| `--since` | 增量时视流程而定 | 增量起始时间（epoch ms）；可从日志**读取候选值向用户展示**，但**以用户确认或显式输入为准**，禁止未确认即采用 |

深度级别与模式的详细定义见 [reference/scan-spec.md](reference/scan-spec.md)。

## 工作流（六步）

### 步骤 1：环境准备

- 读取历史日志 `changelogs/indexing-log.jsonl`（若存在），仅用于**向用户展示信息**或**候选 `--since`**，不据此自动锁定模式或时间戳
- 无历史记录时：**不得**自动假定全量；须说明增量可能不可用，并请用户按「用户确认门禁」选择模式与深度
- 验证输出路径可写（路径若未由用户指定，须先确认再写入）

### 步骤 2：扫描配置

- **必须**完成用户确认：`mode` + `depth`（以及本流程需要的 `--output` / `--since` 等，规则见上文门禁）
- 增量模式下：可从 `indexing-log.jsonl` 解析建议的基线时间戳，**展示给用户并获确认后**再作为 `--since` 使用

### 步骤 3：变更分析

- 调用 `docs-change` 技能生成变更索引
- 解析变更文件列表，建立扫描路径集
- 全量模式下跳过变更过滤

### 步骤 4：执行扫描

按深度级别扫描代码库。扫描规则（文件过滤、深度控制、路径解析）见 [reference/scan-spec.md](reference/scan-spec.md)。

**当用户已确认深度为 3（精读）时**，执行须同时满足 [reference/scan-spec.md](reference/scan-spec.md) 中的「深度 3 应读尽读准则」：在排除规则允许的范围内遍历目录与可读文件，**尽量完整读取**文件内容；**尽可能多**地建立索引条目、路径与交叉引用；禁止以「仓库过大」「省 token」为由对同级目录或同类文件抽样跳读。未读或不可读路径须在产出 §八 中显式标注，不得写成已核实事实。

可使用辅助脚本：

```bash
scripts/indexing.sh --mode <用户已确认的 mode> --depth <用户已确认的 depth>
```

（`full`/`3` 仅为语法示意；**实际参数必须与用户确认值一致**，不得照抄示例。）

### 步骤 5：质量验证

按 [reference/quality-standards.md](reference/quality-standards.md) 执行验证：结构完整性、信息密度、准确度、交叉引用。

### 步骤 6：输出生成

- 按九章规范（详见 [reference/nine-chapter-spec.md](reference/nine-chapter-spec.md)）生成文档
- 输出模板骨架参见 [assets/index-guide-template.md](assets/index-guide-template.md)
- 追加日志到 `changelogs/indexing-log.jsonl`（日志格式见 [reference/scan-spec.md](reference/scan-spec.md)）
- 清理临时文件

## 核心约束

| 约束 | 说明 |
|------|------|
| 参数门禁 | 模式与深度必须经用户确认；禁止未经确认的自动选参（含默认全量、自动深度、未确认的 `--since`） |
| 精读（深度 3） | **应读尽读**：在过滤规则内遍历目录与可读文件，尽量读全内容；**索引最大化**：在九章结构与 MECE 前提下尽可能多建条目与引用；禁止抽样跳读同级文件；未读路径归 §八 |
| 零幻觉 | 只索引实际读取的内容，禁止臆测 |
| 路径精确 | 使用项目根相对路径 |
| 幂等性 | 相同输入产出一致结果 |
| 增量一致性 | 增量索引保持与全量索引结构一致 |
| MECE 原则 | 分类互斥穷尽，避免重复索引 |
| 版本追溯 | 每次索引记录完整元数据到日志 |

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 前置 | `docs-change` | 生成变更索引 `changes-index.json` |
| 下游 | `docs-build` | 以主 INDEX 作为提取证据来源 |
| 关联 | `agent-guide` | 维护 README.md / AGENTS.md 与 INDEX 交叉引用 |

## 参考

| 资源 | 路径 |
|------|------|
| 扫描执行规范（深度/模式/过滤/日志/错误处理） | [reference/scan-spec.md](reference/scan-spec.md) |
| 九章文档结构规范 | [reference/nine-chapter-spec.md](reference/nine-chapter-spec.md) |
| 质量验证清单 | [reference/quality-standards.md](reference/quality-standards.md) |
| INDEX_GUIDE 输出模板 | [assets/index-guide-template.md](assets/index-guide-template.md) |
| 常见陷阱与防错规则 | [gotchas.md](gotchas.md) |
| 辅助脚本 | [scripts/indexing.sh](scripts/indexing.sh) |
