---
name: docs-indexing
description: >
  为代码库生成结构化文档索引（INDEX_GUIDE.md），支持全量/增量扫描与三级深度（拓扑/结构/精读）。
  产出标准化九章文档索引，为 Agent 导航与 RAG 上下文提供权威文档地图。
  当用户执行 /docs-indexing、需要生成或更新项目索引、建立文档地图、做项目 Onboarding、
  或下游 docs-build/agent-guide 需要 INDEX_GUIDE.md 时，务必使用本技能。
  即使用户只说"帮我建个索引"、"生成一下项目文档"、"更新一下 INDEX"，也应触发本技能。
---

# 文档索引生成器（docs-indexing）

将代码库解析为结构化、可检索的 `INDEX_GUIDE.md`，作为 Agent 与开发者的系统全景导航。

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 代码库根目录、**用户确认的**扫描模式（full/incremental）、**用户确认的**扫描深度（1/2/3） |
| 可选输入 | 输出路径、增量起始时间、`changes-index.json`（增量模式）；凡影响索引行为的取值均须用户确认 |
| 固定输出 | `{Doc Root}/INDEX_GUIDE.md`（九章结构）、`changelogs/indexing-log.jsonl`（操作日志） |
| 不产出 | 不生成知识实体 ID、不修改 README/AGENTS、不产出 CHANGELOG |

## 用户确认门禁（强制）

**在进入步骤 3 之前，必须同时获得用户对以下参数的明确确认：**

- **模式**：`full`（全量）或 `incremental`（增量）——不得因「无历史日志」等理由由 Agent 代选
- **深度**：`1`（拓扑）、`2`（结构）或 `3`（精读）——不得根据仓库大小或 Agent 判断自动升降级
- **`--since` / `--output`**：若流程需要读取这些值，须用户确认或显式给出字面量；禁止从日志「自动取最近时间戳」等隐式行为

增量前提不满足（如无 `indexing-log.jsonl`）时，须向用户说明并**重新请用户确认**是否改走全量或中止，不得自动降级。

## 参数

| 参数 | 必需 | 说明 |
|------|------|------|
| `--mode` | 是 | 必须由用户确认：`f`/`full` 或 `i`/`incremental`；无默认、无 Agent 代选 |
| `--depth` | 是 | 必须由用户确认：`1`、`2`、`3`；无默认、无 Agent 代选 |
| `--output` | 否 | 输出路径；若使用默认值，须向用户展示并确认 |
| `--since` | 增量时视流程而定 | 增量起始时间（epoch ms）；可从日志读取候选值展示给用户，但以用户确认为准 |

深度级别与模式的详细定义见 [reference/scan-spec.md](reference/scan-spec.md)。

## 工作流（六步）

### 步骤 1：环境准备

读取历史日志 `changelogs/indexing-log.jsonl`（若存在），仅用于向用户展示信息或提供候选 `--since`，不据此自动锁定模式或时间戳。验证输出路径可写。

### 步骤 2：扫描配置（门禁）

完成用户确认：`mode` + `depth`（以及本流程需要的 `--output` / `--since`）。**未完成确认前禁止进入步骤 3。**

### 步骤 3：变更分析

调用 `docs-change` 技能生成变更索引；解析变更文件列表，建立扫描路径集。全量模式跳过变更过滤。

### 步骤 4：执行扫描

按深度级别扫描代码库。扫描规则（文件过滤、深度控制、路径解析）见 [reference/scan-spec.md](reference/scan-spec.md)。

深度 3（精读）须遵守「应读尽读准则」：在排除规则内系统遍历目录与可读文件，尽量读全内容；在九章结构与 MECE 前提下尽可能多建索引条目；禁止以「仓库过大」「省 token」为由抽样跳读；未读路径归 §八。

可使用辅助脚本（参数必须与用户确认值一致，不得照抄示例）：

```bash
scripts/indexing.sh --mode <用户已确认的 mode> --depth <用户已确认的 depth>
```

### 步骤 5：质量验证

按 [reference/quality-standards.md](reference/quality-standards.md) 执行验证：结构完整性、信息密度、准确度、交叉引用。

### 步骤 6：输出生成

按九章规范（见 [reference/nine-chapter-spec.md](reference/nine-chapter-spec.md)）生成文档；输出模板见 [assets/index-guide-template.md](assets/index-guide-template.md)；追加日志到 `changelogs/indexing-log.jsonl`。

## 核心约束

| 约束 | 说明 |
|------|------|
| 参数门禁 | 模式与深度必须经用户确认；禁止未经确认的自动选参（含自动降级、未确认的 `--since`） |
| 精读（深度 3） | 应读尽读：在过滤规则内遍历目录与可读文件，尽量读全；索引最大化：在九章与 MECE 前提下尽可能多建条目；未读路径归 §八 |
| 零幻觉 | 只索引实际读取的内容，禁止臆测 |
| 路径精确 | 使用项目根相对路径 |
| 幂等性 | 相同输入产出一致结果 |
| 增量一致性 | 增量索引保持与全量索引结构一致 |
| MECE 原则 | 分类互斥穷尽，避免重复索引 |

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 前置 | `docs-change` | 生成变更索引 `changes-index.json` |
| 下游 | `docs-build` | 以主 INDEX 作为提取证据来源 |
| 关联 | `agent-guide` | 维护 README.md / AGENTS.md 与 INDEX 交叉引用 |

## 参考

| 资源 | 路径 | 何时读 |
|------|------|--------|
| 扫描执行规范（深度/模式/过滤/日志/错误处理） | [reference/scan-spec.md](reference/scan-spec.md) | 步骤 4 扫描时，深度/模式规则不确定时 |
| 九章文档结构规范 | [reference/nine-chapter-spec.md](reference/nine-chapter-spec.md) | 步骤 6 生成文档时 |
| 质量验证清单 | [reference/quality-standards.md](reference/quality-standards.md) | 步骤 5 验证时 |
| INDEX_GUIDE 输出模板 | [assets/index-guide-template.md](assets/index-guide-template.md) | 步骤 6 生成文档时 |
| 常见陷阱与防错规则 | [gotchas.md](gotchas.md) | 遇到门禁/扫描/输出相关问题时 |
| 辅助脚本 | [scripts/indexing.sh](scripts/indexing.sh) | 步骤 4 执行扫描时 |
