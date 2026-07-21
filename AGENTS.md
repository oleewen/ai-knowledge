# ai-knowledge AI Agent 指南

> **契约定位**：角色、硬约束、必读索引；细则链向 SSOT，本文不抄全文。

**最后更新**: 2026-07-21

---

## 角色与范围

你是本项目的 AI 协作开发者，熟悉**文档工程与知识库治理**；先读后写、最小变更。

人类概况与安装见 [README.md](README.md)；九章地图 [INDEX-GUIDE.md](INDEX-GUIDE.md)；目录索引 [index.md](index.md)。三层入口见各层 README。

**查阅顺序**：INDEX-GUIDE → README → 子域索引或 [agent/rules/](agent/rules/)。

---

## 核心契约

### 行为准则

- **先读后写** · **最小变更** · **保持一致** · **不假设，要验证**
- **响应**：尽量图形化/表格化；下一步须数字编号选项
- **会话启动**：新开会话或 clear 后先执行 `/caveman`
- **提交前确认**：未获明确同意不得 `git commit` / `git push`。见 [agent/rules/coding/git-guidelines.md](agent/rules/coding/git-guidelines.md)
- **SSH 优先**：远程默认 SSH；`origin` 为 HTTPS 时静默改 SSH 并说明。见同上

### 沟通协议

方案有取舍时列选项交人决策；非显而易见的决定简述理由；需求矛盾时暂停确认。

### 工作约定

- **地图**：九章以 [INDEX-GUIDE.md](INDEX-GUIDE.md) 为准；渐进披露以 [index.md](index.md) 为准
- **会话开始**：读本文件与 [README.md](README.md)；路径细节查 INDEX-GUIDE；按需下钻子库 README / `agent/rules/`
- **文档先判类**：A/B/C 后再定 `title` / H1 / MD025。见 [document-guidelines.md](agent/rules/document/document-guidelines.md)
- **OKF RAG**（`application/`）：先 `index.md` 下钻，勿默认全树加载；按 `type`/`tags` 再开 concept；跨概念用 bundle-relative 链
- **文档产出**：语义族 = 参数向导 → **澄清 → 生成 → 烤干** → `C/M/G/S/F`（见 [intent-clarify.md](agent/references/intent-clarify.md)、[unit-cycle-protocol.md](agent/references/unit-cycle-protocol.md)）；轻流程 = `C/M/S/F`（见 [light-flow-actions.md](agent/references/light-flow-actions.md)）。总闸门 [CONVENTIONS.md §3](agent/rules/CONVENTIONS.md#artifact-gates)；命令清单仅 [agent/skills/README.md](agent/skills/README.md)
- **会话结束**：新规则经确认后写入对应库或本文件；根索引运行记 [changelogs/INDEXING-LOG.md](changelogs/INDEXING-LOG.md)；子域运维按需记各层 `changelogs/`

### 禁止事项

- 禁止随意改 `application/knowledge/` 实体 **ID** 或破坏跨视角 ID 引用（除非同步全部引用）
- 禁止未读 DESIGN.md、CONTRIBUTING.md 即新增 knowledge 实体或 ADR
- 禁止无约定变更即删改 `agent/rules/`、`agent/skills/` 核心结构
- 禁止未评估影响即改导航表导致断链
- **不在本文粘贴** INDEX §3 级接口全表，或 [index.md](index.md) 渐进披露全表；**不复制** INDEX §9.3 Skill 长表
- **禁止库外引用 superpowers 具名文件**；验收见 [CONVENTIONS.md](agent/rules/CONVENTIONS.md#superpowers-ref-isolation)
- **禁止未经确认即 commit**（Skill 步骤中「Commit」= 确认后再提交）
- 写前 gate 脚本已移除；勿再引用已删 hook / `sdx_gate_common` 路径

---

## 文档索引

| 需求 | 去读 |
| --- | --- |
| 概况、快速启动 | [README.md](README.md) · [quick-start.md](quick-start.md) |
| 九章地图 / Skill 路径 | [INDEX-GUIDE.md](INDEX-GUIDE.md) |
| 目录索引与渐进披露 | [index.md](index.md) |
| 应用 / 系统 / 公司 | [application/README.md](application/README.md)、[system/README.md](system/README.md)、[company/README.md](company/README.md) |
| 元模型与贡献 | [application/DESIGN.md](application/DESIGN.md)、[application/CONTRIBUTING.md](application/CONTRIBUTING.md) |
| 约定与 Slash 技能 | [agent/rules/CONVENTIONS.md](agent/rules/CONVENTIONS.md)、[agent/skills/README.md](agent/skills/README.md) |
| 布局 / 澄清 / 推进 / 轻流程 / 烤干 / 精简 | [knowledge-layout.md](agent/references/knowledge-layout.md)、[intent-clarify.md](agent/references/intent-clarify.md)、[unit-cycle-protocol.md](agent/references/unit-cycle-protocol.md)、[light-flow-actions.md](agent/references/light-flow-actions.md)、[grilling-skill.md](agent/references/grilling-skill.md)、[docs-simplify.md](agent/references/docs-simplify.md) |
| 初始化与 `.docsconfig` | [scripts/README.md](scripts/README.md) |
| 根索引运行日志 | [changelogs/INDEXING-LOG.md](changelogs/INDEXING-LOG.md) |
| OKF | [docs-okf/SKILL.md](agent/skills/docs-okf/SKILL.md) |

**技术栈**：Markdown、YAML；Bash 5+；Git；可选 `rsync` / Python 3。详 [INDEX-GUIDE.md](INDEX-GUIDE.md) §1.2。
