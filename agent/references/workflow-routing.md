# 共享工作流路由（Agent SSOT）

> **定位**：技能族名单与共享能力分工的唯一真源；本地 workflow / gates 只补技能差额。

**最后更新**: 2026-10-23

## 技能族

| 族 | 技能 | 推进契约 |
| --- | --- | --- |
| 语义族 | 全部 `/sdx-*`；docs-agent / docs-extract / docs-merge / docs-distill / docs-archive / docs-revise / docs-simplify / docs-indexing / docs-build | [写前澄清](intent-clarify.md) + [单元推进](unit-cycle-protocol.md) |
| 轻流程 | docs-okf / docs-link / docs-tag / docs-install / agent-install / docs-upgrade / skill-upgrade | [轻流程动作](light-flow-actions.md)；docs-okf 自有 workflow，无当前单元循环，不强制动作字母 |

未绑定语义族协议的技能维持既有轻流程；同类参数确认型技能可按轻流程动作执行。

## 能力分工

| 问题 | 唯一真源 | 本地差额 |
| --- | --- | --- |
| 写前要确认什么 | [intent-clarify.md](intent-clarify.md) | 追加字段、路径、高风险 |
| 何时烤干、如何授权和推进 | [unit-cycle-protocol.md](unit-cycle-protocol.md) | 当前对象、写后默认表、原子性 |
| 如何发现问题与逐问深挖 | [grilling-skill.md](grilling-skill.md) | 业务检查问题 |
| 轻流程如何确认与完成 | [light-flow-actions.md](light-flow-actions.md) | 参数、执行步骤、单元名称 |
| 如何检查读者与信息边界 | [audience-and-language.md](audience-and-language.md) | 主读者、宜写/宜弱化、特殊允许区 |
| 如何组织、精简和引用正文 | [simplify-principles.md](simplify-principles.md) | 模板结构 |
| 未执行动作如何保存和勾销 | [todo-protocol.md](todo-protocol.md) | 具体动作、依赖 |

共享正文不复制到各 skill。
