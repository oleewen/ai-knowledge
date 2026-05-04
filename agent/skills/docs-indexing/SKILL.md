---
name: docs-indexing
description: >
  为代码库生成结构化文档索引（INDEX_GUIDE.md），产出标准化九章文档地图，
  作为 Agent 导航与 RAG 上下文的权威来源；索引运行记录写入 `changelogs/INDEXING-LOG.md` 主表（最新在上，见 `reference/indexing-log-spec.md`）。
  支持全量/增量扫描与三级深度（拓扑/结构/精读）。
  当用户执行 /docs-indexing、需要生成或更新项目索引、建立文档地图、做项目 Onboarding、
  或下游 docs-build/docs-agent 需要 INDEX_GUIDE.md 时，务必使用本技能。
  即使用户只说"帮我建个索引"、"生成一下项目文档"、"更新一下 INDEX"、
  "项目文档太乱了帮我整理一下"，也应触发本技能。
---

# 文档索引生成器（docs-indexing）

将代码库解析为结构化、可检索的 `INDEX_GUIDE.md`，作为 Agent 与开发者的系统全景导航。
这份索引是整个知识库体系的"地图"——它的质量直接决定后续 docs-build、docs-agent 等技能能否准确定位信息。

## 输入与输出

| 类型 | 内容 |
| ---- | ---- |
| 硬输入 | 代码库根目录、用户确认的扫描模式（full/incremental）、用户确认的扫描深度（1/2/3） |
| 可选输入 | 输出路径、增量起始时间；候选基线可从 `changelogs/INDEXING-LOG.md` **主表第一行** `indexing_finished_ms` 读取（仅作展示；迁移期可提及 HTML 回退，见 [reference/indexing-log-spec.md](reference/indexing-log-spec.md)） |
| 固定输出 | `DOC_ROOT/INDEX_GUIDE.md`（九章结构）、`changelogs/INDEXING-LOG.md`（主表插入一行，**最新在上**） |
| 不产出 | 不生成知识实体 ID、不修改 README/AGENTS、不产出 CHANGELOG |

## 参数

| 参数 | 必需 | 说明 |
| ---- | ---- | ---- |
| `--mode` | 是 | 用户确认：`f`/`full`（全量）或 `i`/`incremental`（增量） |
| `--depth` | 是 | 用户确认：`1`（拓扑）、`2`（结构）、`3`（精读） |
| `--output` | 否 | 输出路径；若使用默认值须向用户展示并确认 |
| `--since` | 增量时视情况 | 增量起始时间（epoch ms）；可从日志读取候选值展示，以用户确认为准 |

深度级别与模式的详细定义见 [reference/scan-spec.md](reference/scan-spec.md)。

---

## 工作流（六步）

### 步骤 1：环境准备

读取 `changelogs/INDEXING-LOG.md`（若存在）主表第一行，或回退为文内旧 HTML 注释，提取**候选** `indexing_finished_ms`——仅作展示，不能据此自动锁定模式。验证输出路径可写。

建议按 [reference/scan-config-onboarding.md](reference/scan-config-onboarding.md) 的「上下文探索」核对仓库事实（DOC_ROOT 位置、是否有有效基线），这样在步骤 2 提问时能给用户更准确的建议。

### 步骤 2：扫描配置（HARD-GATE：参数确认书）

**在进入步骤 3 之前，必须获得用户对以下参数的明确确认（Qclose-1）：**

- `mode`：`full` 或 `incremental`
- `depth`：`1`、`2` 或 `3`
- `--output`（若使用默认值，须展示路径请用户确认）
- `--since`（增量时，须展示候选值请用户确认，或用户显式给出）

这个门禁存在的原因：模式和深度直接决定扫描成本与覆盖范围，Agent 无法替用户做这个权衡。

**参数确认书格式**（会话内，无需落盘 spec 文件）：

```
即将执行 /docs-indexing，参数如下：
- mode: <full|incremental>
- depth: <1|2|3>
- output: <路径>
- since: <时间或 N/A>

C 确认执行 / M 修改参数 / S 跳过
```

收到 C/S 后方可进入步骤 3。**禁止**在未收到确认前写入 `INDEX_GUIDE.md` 或 `INDEXING-LOG.md`。

**推荐做法**：一条消息列出所有待确认项，并附便捷预设（如 full+1、incremental+2 等），降低来回成本。用户选定预设后，仍须复述完整参数再执行。具体话术见 [reference/scan-config-onboarding.md](reference/scan-config-onboarding.md)。

**增量前提不满足时**（`INDEXING-LOG.md` 主表/回退均无法得到有效 `indexing_finished_ms` 且用户未给 `--since`）：向用户说明，请其确认改走全量或中止，**不得**静默自动全量；`scripts/indexing.sh` 在 incremental 且无基线时**非 0 退出**。

### 步骤 3：变更分析

调用 `docs-change` 技能生成变更索引；解析变更文件列表，建立扫描路径集。全量模式跳过变更过滤。

### 步骤 4：执行扫描

按用户确认的深度级别扫描代码库。扫描规则（文件过滤、深度控制、路径解析）见 [reference/scan-spec.md](reference/scan-spec.md)。

**深度 3（精读）的核心原则**：在排除规则内系统遍历目录与可读文件，尽量读全内容；在九章结构与 MECE 前提下尽可能多建索引条目。未读路径归 §八并说明原因。不能以"仓库过大"或"省 token"为由抽样跳读——用户选择深度 3 就是要最大化覆盖。

可使用辅助脚本（参数必须与用户确认值一致）：

```bash
scripts/indexing.sh --mode <用户已确认的 mode> --depth <用户已确认的 depth>
```

### 步骤 5：质量验证

按 [reference/quality-standards.md](reference/quality-standards.md) 执行验证：结构完整性、信息密度、准确度、交叉引用。

重点检查：每条目是否有实质内容（15-30 字，含功能描述或关键属性）；路径是否为项目根相对路径；版本号/配置值是否来自实际读取的文件。

### 步骤 6：输出生成

按九章规范（见 [reference/nine-chapter-spec.md](reference/nine-chapter-spec.md)）生成文档；输出模板见 [assets/index-guide-template.md](assets/index-guide-template.md)；在 `INDEX_GUIDE` 成功落盘后，向 `changelogs/INDEXING-LOG.md` 主表**插入**一行（**最新在上**；见 `scripts/indexing_log.py` 与 [reference/indexing-log-spec.md](reference/indexing-log-spec.md)）。

---

## 核心约束

这些约束保证索引的可信度和可用性：

| 约束 | 原因 |
| ---- | ---- |
| 参数门禁 | 模式与深度决定扫描成本与覆盖范围，Agent 无法替用户权衡 |
| 零幻觉 | 只索引实际读取的内容；未读路径标注 `[未索引]` 归 §八 |
| 路径精确 | 使用项目根相对路径，确保链接可点击 |
| 幂等性 | 相同输入产出一致结果，支持重复执行 |
| 增量一致性 | 增量索引保持与全量索引结构一致；只合并变更条目，不清空未变更部分 |
| MECE 原则 | 每个文件只归入一个最匹配的章节，交叉引用以超链接体现 |

---

## 依赖关系

| 类型 | 技能/组件 | 说明 |
| ---- | --------- | ---- |
| 前置 | `docs-change` | 维护变更聚合 `CHANGE-LOG.md`，增量模式依赖其变更文件列表 |
| 下游 | `docs-build` | 以主 INDEX 作为提取证据来源 |
| 关联 | `docs-agent` | 维护 README.md / AGENTS.md 与 INDEX 交叉引用 |

---

## 参考资源

| 资源 | 路径 | 何时读 |
| ---- | ---- | ------ |
| 扫描配置引导与便捷预设 | [reference/scan-config-onboarding.md](reference/scan-config-onboarding.md) | 步骤 1～2，需对齐上下文或一次性确认参数时 |
| 扫描执行规范（深度/模式/过滤/日志/错误处理） | [reference/scan-spec.md](reference/scan-spec.md) | 步骤 4 扫描时 |
| 九章文档结构规范 | [reference/nine-chapter-spec.md](reference/nine-chapter-spec.md) | 步骤 6 生成文档时 |
| 质量验证清单 | [reference/quality-standards.md](reference/quality-standards.md) | 步骤 5 验证时 |
| INDEX_GUIDE 输出模板 | [assets/index-guide-template.md](assets/index-guide-template.md) | 步骤 6 生成文档时 |
| 常见陷阱与防错规则 | [gotchas.md](gotchas.md) | 遇到门禁/扫描/输出相关问题时 |
| 索引运行日志（表、锚、增量、dry-run）与 DISTILL-LOG 对位 | [reference/indexing-log-spec.md](reference/indexing-log-spec.md) | 读/写 `INDEXING-LOG.md` 或对齐脚本行为时 |
| 辅助脚本 | [scripts/indexing.sh](scripts/indexing.sh) | 步骤 4 执行扫描时 |
