# docs-simplify 推进协议（binding）

## 定位

本技能绑定 [写前意图澄清](../../../references/intent-clarify.md)、[单元推进](../../../references/unit-cycle-protocol.md)、[写后烤干](../../../references/grilling-skill.md) 和 [精简原则](../../../references/simplify-principles.md)。协议正文只在共享文件维护；执行步骤见 [workflow.md](workflow.md)。

## 单元定义

一个文件、文件内已确认 hunk，或用户明确确认的多文件批次。批次作为一个单元，不拆成逐文件重复确认；批次外文件属于下一单元。

`S` 在本技能表示暂存并跳过当前改写或扩批，不落盘待写内容；不自动回滚已经写入的内容。

## 技能追加澄清字段 / 边界

六项清单采用 [范围模板](../assets/docs-simplify-scope-ack-template.md)。补充：hunk 边界、排除类是否点名纳入、扩批清单、疑似 SSOT 候选与处置、双目标顺序。

用户已明确的参数和本单元写前授权沿用；revise 写后确认不自动等于 simplify 写前授权。协议内 simplify 遍不另开确认环。

## 写后默认

唯一默认表见 [workflow.md](workflow.md#写后默认表)：每个当前单元必须烤干。

## 高风险场景

以下未决事项须给结论、推荐与数字选项，确认前不执行：扩围；疑似重复删段/改引用；非日期 C4 契约变更；双目标顺序；语义冲突及前文回改。

## 原子性 / 失败停顿

- 未获写前 `C` 不写当前单元；意图变更按共享协议重开。
- 无法核实真源或引用合法性，保留原文，停问该处置，不编造链接。
- 范围外命中可报告，不修改、不自动纳入下一批。
- 当前单元收敛后等待写后动作，不自动扩批；`F` 按共享协议先批确认剩余意图。

## 典型语义问题（烤干）

约束是否丢失；角色/承诺是否变化；重复是否同一事实；链接与锚点是否仍有效。终检见 [quality-checklist.md](quality-checklist.md)。
