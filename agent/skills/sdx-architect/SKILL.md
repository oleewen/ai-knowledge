---
name: sdx-architect
description: >
  基于已共识 PRD 创建或修订 ASD 架构设计，明确系统/应用边界、服务变更和需求规约摘要。
  适用于 /sdx-architect、ASD 或 spec-asd 概设请求；实现级 API、DDL、DSD 使用 sdx-design。
---

# sdx-architect

将已确认需求转成可评审的三章 ASD：设计概述、架构设计、需求规约。ASD 说明边界与取舍；实现级接口、DDL 和错误码正文交由 `sdx-design`。

## 开始前

1. 读取 `.docsconfig`，按 [类型模式](references/knowledge-type-modes.md) 判断落点；只有系统/应用库可写 ASD，公司/解决方案库先分流。
2. 核实同链 `PRD-{IDEA-ID}-{N}.md` 和本轮范围。缺 PRD 先补输入或转 `sdx-prd`；已有参数与授权沿用，只问缺项。ANALYSIS 为可选追溯材料。
3. 读 [工作流](references/workflow.md) 与 [推进约束](references/gates.md)，再初始化或修改目标文件。已有 ASD 只改已授权段。

## 执行约束

- 默认一个当前段：写前澄清、生成、写后自动烤干；收敛后等待 `C/M/G/F`，无 `S`。
- 公共协议只在 [意图澄清](../../references/intent-clarify.md)、[单元推进](../../references/unit-cycle-protocol.md)、[烤干](../../references/grilling-skill.md) 维护。`F` 须先批确认剩余意图，不能覆盖已确认前文。
- 生成与修订遵循 [精简原则](../../references/simplify-principles.md)；烤干检查 [ASD 受众要求](references/audience-and-language.md)。

## 按需读取

| 时机 | 资源 |
| --- | --- |
| 新建 ASD | [三章模板](assets/asd-template.md)；需要示例时看 [片段](assets/samples/mini-asd-example.md) |
| 系统联邦概要 | [承接表片段](assets/asd-stub-sections-federated.md) |
| 用户需要独立概设规约 | [spec-asd 模板](assets/asd-spec-template.md) |
| 遇到模式、路径或内容混淆 | [操作陷阱](gotchas.md)、[概念反模式](references/anti-patterns.md) |
| 当前段/整篇收口 | [质量清单](references/quality-checklist.md) |
| 维护或评估本技能 | [评测说明](references/evaluation.md) |

## 产物与校验

产物路径与命令见 [工作流](references/workflow.md#产物路径)。校验需要 Bash 5+ 和随 Agent 树安装的 `scripts/lib/docsconfig.sh`。收尾使用 `validate-asd.sh --strict`；脚本只做结构检查，不证明架构正确、完整 YAML 合法或用户已确认。
