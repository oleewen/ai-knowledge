---
name: sdx-design
description: >
  技术方案设计：基于产品需求文档（PRD）进行系统架构设计，输出架构设计说明书（ADD）与规约文件（specs）。
  当用户执行 /sdx-design、需要编写 ADD 文档、进行系统架构设计、设计接口协议与领域模型、
  生成 API/数据/领域规约、需要技术蓝图供研发实现、或需要将 PRD 转化为可落地的技术方案时，务必使用本技能。
  即使用户只说"帮我写个技术方案"、"设计一下接口"、"出一份 ADD"、"把 PRD 转成技术设计"、
  "设计一下数据库表"、"画一下架构图"，也应触发本技能。
  输出至应用知识库 {DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ADD-{IDEA-ID}-{N}.md。
---

# 方案设计阶段（sdx-design）

**术语**：**应用知识库**指应用知识库目录 `DOC_DIR`（见 `.docsconfig`），对应路径前缀 `{DOC_DIR}/`。

基于产品需求文档，结合系统架构与领域模型，输出**架构设计说明书（ADD）**与**规约文件（specs）**，为测试设计与开发提供技术蓝图。

主要读者：**架构师与骨干开发**；业务验收口径仍以 PRD 为准，见 [reference/audience-and-language.md](reference/audience-and-language.md)。

---

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 产品需求文档（应用知识库 `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`） |
| 可选输入 | 需求分析文档、`knowledge/technical/`、`knowledge/business/`、`constitution/adr/`（按需加载，禁止通读全仓） |
| 固定输出 | `ADD-{IDEA-ID}-{N}.md`、`specs/{service-name}/{type}/*.yaml` |
| 不产出 | 测试设计、代码（使用下游 sdx-test / dev） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `IDEA-ID` | 与 PRD/需求分析一致 |
| `--prd` | 否 | — | 上游 PRD stem，自动定位对应文件 |
| `--mvp` | 否 | `1` | 目标 MVP 阶段编号（`MVP-Phase-{N}`） |
| `--depth` | 否 | `standard` | 设计深度：`quick`（架构+接口概要）/ `standard`（完整五维度）/ `deep`（增加性能建模与容量规划） |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 已有 PRD，需进行技术方案设计输出 ADD 与规约 | ✅ |
| 需设计系统架构、接口协议、领域模型、数据架构 | ✅ |
| 需生成 API/数据/领域规约文件 | ✅ |
| 已有解决方案，需进行需求分析与 MVP 拆分 | ❌ → sdx-analysis |
| 已有需求分析，需编写 PRD | ❌ → sdx-prd |
| 已有 PRD 与 ADD，需测试设计 | ❌ → sdx-test |

---

## 工作流（四步）

执行前先加载 PRD，提取业务流程、US-n、用例、功能模块、业务规则与 NFR；PRD 不存在时终止并提示先执行 `sdx-prd`。详细算法、`--depth` 差异与步间数据流见 [reference/workflow-spec.md](reference/workflow-spec.md)。

### 步骤 1：架构设计

以 `knowledge/technical/` 现有架构为基线，只描述变更部分；五维度设计：系统架构（服务变更与调用关系 Mermaid）、接口协议概要（API-n）、领域模型（聚合/实体/值对象/领域事件）、数据架构（ER/DDL 概要/迁移方案）、发布与回滚方案；关键决策记录为 DD-n（含决策点、结果、理由、备选方案）。产出对应文档 §1–§2。

### 步骤 2：详细设计

应用架构（容器级架构图、MQ/异步/定时任务）；API 详设（签名、参数、响应、错误码、幂等性、容错策略）；业务逻辑（核心类图、状态机、时序图、伪代码、一致性策略）；数据访问（DDL 含 `gmt_create`/`gmt_modified`、索引策略、分页、缓存）；非功能（安全设计、可观测设计）。产出对应文档 §3。

### 步骤 3：规约生成

从步骤 1–2 产出提取，按服务写入 `specs/{service-name}/{type}/`（`type` 为 `api/`、`domain/`、`data/`、`integration/`）；每个规约文件头部标注 `source`（ADD 章节）与 `requirement`（FR-n）。产出对应文档 §4 参考文档表。

### 步骤 4：文档输出与评审

套用 [assets/add-template.md](assets/add-template.md) 五章结构；填写文末元数据 YAML（**禁止**文件头 frontmatter）；按 [reference/quality-checklist.md](reference/quality-checklist.md) **逐项**自查；已通过项在 §5.2 中将 `- [ ]` 改为 `- [x]`，未通过项保持 `- [ ]` 先修复，**禁止虚假勾选**。

辅助校验：

```bash
.agent/skills/sdx-design/scripts/validate-design.sh
```

---

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 严格遵循 `add-template.md` 五章结构；无内容章节保留标题并标注「不适用」 |
| 证据优先 | 架构决策须引用 PRD、需求分析与 `knowledge/` 事实，禁止臆测 |
| MVP 聚焦 | 仅覆盖目标 MVP 范围，不引入不必要的抽象层或扩展点 |
| 歧义标注 | 不确定项标为待澄清，暂停确认，禁止自行假设 |
| 可追溯 | DD-n/API-n/TBL-n → US-n/FR-n；规约 → ADD 章节 |
| 自查勾选 | §5.2 已通过项须为 `- [x]`；未通过项保持 `- [ ]` 直至修复 |

完整原则、反模式与错误处理见 [reference/design-principles.md](reference/design-principles.md)。

---

## 命名约定

- ADD 路径（应用知识库）：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ADD-{IDEA-ID}-{N}.md`
- 规约路径：`.../specs/{service-name}/{type}/`（`type` 为 `api/`、`domain/`、`data/`、`integration/`）
- IDEA-ID 与上游 `PRD-{IDEA-ID}-{N}.md` 完全一致
- 元数据位置：文末「## 文档元数据」下的 fenced YAML；**禁止**在文件开头使用 `---` frontmatter

---

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（必需） | `sdx-prd` | 提供产品需求文档作为核心输入 |
| 上游（推荐） | `sdx-analysis` | 提供需求分析文档与 MVP 上下文 |
| 上游（可选） | `docs-build` | 提供 `knowledge/` 基线 |
| 下游 | `sdx-test` | 基于 PRD 与 ADD 进行测试设计 |

---

## 参考资源

| 资源 | 路径 | 何时读 |
|------|------|--------|
| 四步工作流（算法、depth、数据流） | [reference/workflow-spec.md](reference/workflow-spec.md) | 步骤执行时，规则不确定时 |
| 受众与文档语言 | [reference/audience-and-language.md](reference/audience-and-language.md) | 步骤 4 语言审查时 |
| 核心概念与 IDEA-ID 落盘示例 | [reference/core-concepts.md](reference/core-concepts.md) | 口径对齐、编号规则不确定时 |
| 设计原则、反模式、错误处理 | [reference/design-principles.md](reference/design-principles.md) | 遇到边界判断、错误场景时 |
| 质量验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 步骤 4 自查时 |
| ADD 文档模板 | [assets/add-template.md](assets/add-template.md) | 步骤 4 生成文档时 |
| 规约摘录模板 | [assets/spec-template.md](assets/spec-template.md) | 步骤 3 生成规约时 |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) | 遇到架构设计、API 设计、规约生成相关问题时 |
| 文档结构校验脚本 | [scripts/validate-design.sh](scripts/validate-design.sh) | 步骤 4 自动验证时 |
