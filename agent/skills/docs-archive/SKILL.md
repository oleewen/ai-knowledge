---
name: docs-archive
description: >
  将四层 knowledge overview 的已确认内容归档到其行内副标题指向的视角章节，
  再按策略回写 overview。适用于 /docs-archive、overview 行归档、冲突核对和索引壳回写。
  不适用于第三列提炼（docs-extract）、联邦槽位上行（docs-distill）、实体/索引维护（docs-build）
  或术语链式修订（docs-revise）。
---

# docs-archive

按 overview 第三列的 delta 更新行内副标题链接指向的章节，再按确认书回写该行。

## 硬约束

- 当前单元只有一个目标章节及其 overview 行块。
- **确认书就是写前意图澄清**。收口并取得写前 `C` 前，不写目标，也不回写 overview。
- 主线固定为：`澄清 → 目标章节 → overview 回写 → 烤干 → 停等动作`。
- 目标章节先写，成功且自检通过后才回写 overview；失败时不回写。
- 每次写入与失败恢复前核对文件版本；发现并发编辑按 [门禁](references/gates.md) 保留现场，禁止旧快照覆盖。
- 原始材料只读；作为归档入口的 overview 仅可回写确认书允许的行。归档写入范围限于确认书、目标章节和这些 overview 行。
- 保留行内副标题链接。索引壳只保留导航，不承载业务事实。
- 第三列 `[A]`/`[U]` 归档后回写 `—` 或索引壳；`[D]` 必须先落实目标章节删除，再回写 `—`。
- 写入 `*/knowledge/**` 时遵守 [knowledge-governance.md](../../knowledge/knowledge-governance.md) 的引用边界。
- 当前单元默认必须烤干；收敛后停下，等待 `C/M/G/S/F`，不得自动推进下一单元。

## 执行

1. 读 overview、目标章节和同级体例；从表格行内副标题链接解析目标。
2. 填 [确认书模板](assets/archive-template.md)：公共六项、来源/目标/映射、冲突策略、overview 回写策略、方案推荐。
3. 逐项核对缺链、断链、冲突和 `[D]`；把未决项留在确认书，不猜路径、ID 或裁决。
4. 写前 `C` 后，只处理当前单元：先写目标章节，再按确认书回写 overview。
5. 按 [quality-checklist.md](references/quality-checklist.md) 烤干，覆盖结构、链接、delta、索引壳、冲突和受众 A/B/C/E。
6. 输出改动文件、每文件一句、待用户动作；停在当前单元。

## 分流

- 来源提炼到 overview 第三列：`docs-extract`
- 槽位内容全量上行：`docs-distill`
- 实体 ID、知识实体或 INDEX-GUIDE 第四章：`docs-build`
- 术语/事实/链接定向修订：`docs-revise`
- 整篇结构精简或 SSOT 去重：`docs-simplify`

## 按需参考

- 共享协议：[intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../references/grilling-skill.md)
- 流程与字段：[references/workflow.md](references/workflow.md)
- 写入门禁：[references/gates.md](references/gates.md)
- overview、锚点、delta：[references/core-concepts.md](references/core-concepts.md)
- 链接与 Git：[references/links-and-index.md](references/links-and-index.md)
- 原则/反模式：[references/design-principles.md](references/design-principles.md)、[references/anti-patterns.md](references/anti-patterns.md)
- 验收/受众/陷阱：[references/quality-checklist.md](references/quality-checklist.md)、[references/audience-and-language.md](references/audience-and-language.md)、[gotchas.md](gotchas.md)
- 评测维护：[evals/evals.json](evals/evals.json)、[agents/grader.md](agents/grader.md)
- 运行评测时读：[references/evaluation.md](references/evaluation.md)（CLI、适配器与结果契约）。
