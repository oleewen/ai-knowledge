# 工作流

主线：探索 → 确认书 → 写目标 → 回写 overview → 烤干。

共享协议：[intent-clarify.md](../../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../../references/grilling-skill.md)。确认书承载写前意图澄清；烤干遵守共享受众和动作协议。

## 1. 探索

读取 overview 或指定锚点、目标章节、同级文件及其 [证据记录](../../../knowledge/knowledge-evidence.md)；路径不明时读取目标层 README/索引。按 [overview 增量语义](../../../knowledge/overview-spec.md#第三列增量语义) 核对候选与删除依据；依据未闭合时保留当前章节和 delta，列入确认书未决项。写入 knowledge 时同时读取 [knowledge-layout.md](../../../references/knowledge-layout.md) 和 [knowledge-governance.md](../../../knowledge/knowledge-governance.md)。

标准路径中，目标只由 overview 表格的行内副标题链接决定。缺链、断链或手写目标与标准路径不一致时，列入冲突清单并停问。

### 实体依赖与交接

按 [实体事实与章节摘要](../../../knowledge/knowledge-governance.md#实体事实与章节摘要) 核对相关实体及本次 delta：

| 情况 | 当前动作 |
| --- | --- |
| 仅解释或引用，ID/属性/关系与实体一致 | 继续当前归档单元，无需 build |
| 实体新增或结构化事实变化（含删除） | 停止当前单元章节与 overview 写入，保留整行 delta，交 docs-build |
| 实体尚未更新、校验失败或证据未确认 | 保留输入和交接状态，不以待确认章节替代实体，不清 delta |
| build 已成功且证据、归属及变更范围经核对 | 重读实体、章节和 overview，核对原授权与文件基线，再接续归档 |

发起方按 [TODO 协议](../../../references/todo-protocol.md) 登记交接；已有相关项则续写同一项。记录实体 ID/路径、变更依据、受影响章节与 overview 行、下一动作及依赖状态。交接不自动授权 build 写入；接手方核对已有授权，缺口按其技能门禁收口。TODO 与确认书中的流程定位不复制进 knowledge 正文。

build 交付实体、台账、导航及实体版本证据；archive 接续更新章节、派生摘要与章节版本证据，通过本单元检查后才回写 overview。实体已更新而章节未更新时，旧章节仍对应其此前核验版本，记录待复核；不得把实体新版本直接标为旧章节已采用。单环节成功只报告局部完成；全链同步核验并获用户确认后，按 TODO 协议勾销。

## 2. 确认书

模板见 [archive-template.md](../assets/archive-template.md)。确认书标记“当前阶段：意图澄清”，承载[公共六项](../../../references/intent-clarify.md#公共六项清单)，追加来源、目标、映射、证据编号与写入范围、冲突策略、overview 回写策略和方案推荐。确认书是流程材料，不替代纳入版本管理的证据登记。

批次确认书收口并取得写前 C 后，才进入单元落盘。

已有同范围确认书与有效授权时直接复用；仅补缺项或重新确认实际变化的范围。

## 3. 写目标章节

提取业务含义，去掉来源噪声；正文服从目标章节体例。来源版本及事实依赖按 [知识证据登记](../../../knowledge/knowledge-evidence.md) 持久保存；裁决过程留在确认书或冲突清单。章节可写本库证据编号纯文本，不写证据目录或库外来源链接。

先确认当前单元没有未解除的实体依赖；有则停在交接，不进入写目标步骤。保存来源、目标、证据与 overview 的读取版本。按 [写入与失败保护](gates.md) 先登记待落盘证据，再写当前目标章节；核对实际目标字节后补齐证据。检测到其他编辑先停下核对。

来源实体或章节计划删除时，先核对仍有效的事实依赖，完成替代依据迁移、独立复核或目标事实撤回；未知外库依赖不得报告通过。纯历史证据可保留，但仅标“待复核”不能解除当前依赖。

第三列语义见 [overview-spec.md](../../../knowledge/overview-spec.md#第三列增量语义)；本技能在依据及依赖已核实后消费 delta，完成回写闭环：

| delta | 目标章节 | overview 回写 |
| --- | --- | --- |
| A / U | 并入或更新对应章节 | — 或仅导航的索引壳 |
| D | 先落实删除说明 | — |
| — | 按确认书判断是否补档 | 保持原样 |

## 4. 回写 overview

仅回写确认书允许的 overview 行，保留行内副标题链接；原始材料保持只读。索引壳只写章节导航，不复制业务正文。目标章节未成功写入、证据未与实际版本一致或实体依赖未解除时禁止回写。

## 5. 烤干与收尾

当前单元默认必须烤干，按 [quality-checklist.md](quality-checklist.md) 验收；受众检查遵守[共享 A/B/C/E](../../../references/audience-and-language.md)及[本地差额](audience-and-language.md)。未获用户明确认可的待确认冲突仍按未收敛处理。任一步失败都保持当前单元未收敛；恢复遵守 [版本检查与本轮差异边界](gates.md)，不得用旧快照覆盖后续编辑。收敛后输出变更摘要和待用户动作，停下等待 C/M/G/S/F。

Git 变更只读；未经用户同意不 commit 或 push。
