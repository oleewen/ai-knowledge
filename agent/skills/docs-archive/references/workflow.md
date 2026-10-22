# 工作流

主线：探索 → 确认书 → 写目标 → 回写 overview → 烤干。

共享协议：[intent-clarify.md](../../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../../references/grilling-skill.md)。确认书承载写前意图澄清；烤干遵守共享受众和动作协议。

## 1. 探索

读取 overview 或指定锚点、目标章节、同级文件；路径不明时读取目标层 README/索引。写入 knowledge 时同时读取 [knowledge-layout.md](../../../references/knowledge-layout.md) 和 [knowledge-governance.md](../../../knowledge/knowledge-governance.md)。

标准路径中，目标只由 overview 表格的行内副标题链接决定。缺链、断链或手写目标与标准路径不一致时，列入冲突清单并停问。

## 2. 确认书

模板见 [archive-template.md](../assets/archive-template.md)。确认书标记“当前阶段：意图澄清”，承载[公共六项](../../../references/intent-clarify.md#公共六项清单)，追加来源、目标、映射、冲突策略、overview 回写策略和方案推荐。

批次确认书收口并取得写前 C 后，才进入单元落盘。

## 3. 写目标章节

提取业务含义，去掉来源噪声；正文服从目标章节体例。来源路径、审计信息和未决裁决留在确认书或冲突清单。

第三列语义由 [federation-spec.md](../../docs-distill/references/federation-spec.md) 定义；本技能只消费 delta 并完成回写闭环：

| delta | 目标章节 | overview 回写 |
| --- | --- | --- |
| A / U | 并入或更新对应章节 | — 或仅导航的索引壳 |
| D | 先落实删除说明 | — |
| — | 按确认书判断是否补档 | 保持原样 |

## 4. 回写 overview

仅回写确认书允许的 overview 行，保留行内副标题链接；原始材料保持只读。索引壳只写章节导航，不复制业务正文。目标章节未成功写入时禁止回写。

## 5. 烤干与收尾

当前单元默认必须烤干，按 [quality-checklist.md](quality-checklist.md) 验收；受众检查遵守[共享 A/B/C/E](../../../references/audience-and-language.md)及[本地差额](audience-and-language.md)。未获用户明确认可的待确认冲突仍按未收敛处理。任一步失败都保持当前单元未收敛；回写失败时恢复本轮 overview 改动或明确标记待修复。收敛后输出变更摘要和待用户动作，停下等待 C/M/G/S/F。

Git 变更只读；未经用户同意不 commit 或 push。
