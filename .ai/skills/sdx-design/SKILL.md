---
name: sdx-design
description: >
  技术方案设计：基于产品需求与架构/领域文档进行技术方案设计，输出架构设计说明书（ADD）与规约摘录文档。
  当用户执行 /sdx-design、需要编写 ADD 文档、进行系统架构设计、设计接口协议与领域模型、
  生成规约文件、或需要技术蓝图供研发实现时，务必使用本技能。
  即使用户只说"帮我写个技术方案"、"设计一下接口"、"出一份 ADD"，也应触发本技能。
  输出至 system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ADD-{IDEA-ID}-{N}.md。
---

# 方案设计阶段（sdx-design）

基于产品需求文档，结合系统架构与领域模型，输出**架构设计说明书（ADD）**与**规约文件（specs）**，为测试设计与开发提供技术蓝图。产出结构以 [assets/add-template.md](assets/add-template.md) 为准：**五章附录**（含 **§5.2 质量自查**）。**§5.2** 内逐条 *通过标准* 为质量门禁权威正文，与 [reference/quality-checklist.md](reference/quality-checklist.md) 摘要配合使用。

主要读者为**架构师与骨干开发**；业务验收口径仍以 PRD 为准，见 [reference/audience-and-language.md](reference/audience-and-language.md)。

## 命名约定

- 落盘路径：`system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ADD-{IDEA-ID}-{N}.md`
- 规约路径：`.../specs/{service-name}/{type}/`（`type` 为 `api/`、`domain/`、`data/`、`integration/`）
- IDEA-ID 与上游 `PRD-{IDEA-ID}-{N}.md` 完全一致
- 元数据位置：文末「## 文档元数据」下的 fenced YAML；**禁止**在文件开头使用 `---` frontmatter

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 产品需求文档（`system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`） |
| 可选输入 | 需求分析文档、`knowledge/technical/`、`knowledge/business/`、`knowledge/constitution/adr/`、AGENTS.md |
| 固定输出 | `ADD-{IDEA-ID}-{N}.md`、`specs/{service-name}/{type}/*.yaml` |
| 不产出 | 测试设计、代码（使用下游 sdx-test / dev） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `IDEA-ID` | 与 PRD/需求分析一致 |
| `--doc-root` | 否 | `system` | 文档根目录 |
| `--prd` | 否 | — | 上游 PRD stem，自动定位对应文件 |
| `--mvp` | 否 | `1` | 目标 MVP 阶段编号（`MVP-Phase-{N}`） |
| `--depth` | 否 | `standard` | 设计深度（quick / standard / deep），影响步骤 1–2 粒度 |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 已有 PRD，需进行技术方案设计输出 ADD 与规约 | 是 |
| 需设计系统架构、接口协议、领域模型、数据架构 | 是 |
| 需生成规约摘录文档 | 是 |
| 已有解决方案，需进行需求分析与 MVP 拆分 | 否 → sdx-analysis |
| 已有需求分析，需编写 PRD | 否 → sdx-prd |
| 已有 PRD 与 ADD，需测试设计 | 否 → sdx-test |

## 工作流（四步）

按顺序执行；每步算法、角色、`--depth` 与产出落位见 [reference/workflow-spec.md](reference/workflow-spec.md)。

1. **架构设计** — 系统/服务变更与交互、接口协议概要、领域模型、数据架构、发布与回滚；DD-n 与 Mermaid；对照 `knowledge/` 与 INDEX_GUIDE 中的架构索引
2. **详细设计** — 应用架构、API 详设（签名/参数/错误码/幂等/容错）、业务逻辑与一致性、数据访问（DDL/索引/缓存）、非功能（安全、可观测）
3. **规约生成** — 按服务写入 `specs/{service-name}/{type}/`；每个规约文件标注 `source`（ADD 章节）与 `requirement`（FR-n）
4. **文档输出与评审** — 按 [assets/add-template.md](assets/add-template.md) 整合；按 [reference/quality-checklist.md](reference/quality-checklist.md) **逐项**自查；**凡已满足通过标准的条目**，在写入 `ADD-*.md` 时须将模板 **§5.2** 中该项由 `- [ ]` 改为 `- [x]`，未满足的保持 `- [ ]` 并先修复或说明，不得虚假勾选

辅助校验：

```bash
.ai/skills/sdx-design/scripts/validate-design.sh --doc-root system
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 add-template.md 五章结构；无内容章节保留标题并标注「不适用」 |
| 证据优先 | 架构决策与设计须引用 PRD、需求分析与 `knowledge/` 事实，禁止臆测 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标为待澄清，禁止自行假设 |
| 范围清晰 | 仅产出 ADD 与规约摘录文档，不涉及测试设计 / 代码 |
| MVP 聚焦 | 仅覆盖目标 MVP 范围内的功能需求，不超越 MVP 边界 |
| 可追溯 | API/数据变更可追溯到 PRD 需求；规约可追溯到 ADD 设计条目 |
| 自查勾选 | 质量门禁通过后，交付物 **§5.2** 中已通过项须为 `- [x]`；未通过项保持 `- [ ]` 直至修复（禁止未达标而全选） |

完整原则、反模式与错误处理见 [reference/design-principles.md](reference/design-principles.md)。

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（必需） | `sdx-prd` | 提供产品需求文档作为核心输入 |
| 上游（必需） | `sdx-analysis` | 提供需求分析文档与 MVP 上下文 |
| 上游（可选） | `docs-build` | 提供 `knowledge/` 基线 |
| 下游 | `sdx-test` | 基于 PRD 与 ADD 进行测试设计 |

## 参考

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
