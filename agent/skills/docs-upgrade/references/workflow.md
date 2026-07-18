# docs-upgrade 工作流

须与 [gates.md](gates.md) binding 一致。预检：[brainstorming-integration.md](brainstorming-integration.md)。

契约：

- 写前澄清：[intent-clarify.md](../../../references/intent-clarify.md)
- 单元推进 / `C/M/G/S/F`：[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)
- 写后烤干：[grilling-skill.md](../../../references/grilling-skill.md)

## 参数向导

按序收口；用户已明确时可跳过对应项：

1. 主目标文件或候选范围
2. 改动摘要或术语替换目标
3. 是否允许关联扩展
4. 当前轮起始单元（主文件 / 关联批次）

参数未收口前，不进入单元推进。

## 当前单元

主文件 / 已确认关联批次 / 回链修复批次；一次一个。定义见 [gates.md](gates.md)。

## 写后默认表

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 单个主文件或关联/回链批次 | **必须** | 未确认决策写入；术语边界或关联扩展范围变更；导航路径/相对链接/`#anchor` 变更；冲突消解或范围/目标口径变更 |

启发式只可升级为必须，不可把默认「必须」降为跳过。

## 技能步骤

推进环见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)；本技能只补改文特有步骤：

### 1. 锁定目标

解析路径；无时先搜候选，多候选**列选项**。意图糊 → brainstorming 预检。

### 2. 澄清

输出公共六项，标明「当前阶段：意图澄清」：

| 公共六项 | upgrade 落点示例 |
| --- | --- |
| 本段/单元目标 | 本轮要改清什么（术语统一 / 单点修复 / 链式同步） |
| 范围 / 非范围 | 主文件 + 关联范围或「仅本文件」 |
| 已知缺口 | 术语边界、命中规模等；无则写「无」 |
| 禁止臆测项 | 不得编造的数字、路径、全库承诺 |
| 写后烤干预判 | 按上表；当前单元默认必须烤干 |
| 写入路径/容器 | 主目标文件路径 + 本批次关联文件清单 |

可用 [docs-upgrade-scope-ack-template.md](../assets/docs-upgrade-scope-ack-template.md)。未获写前 `C` 不得写入。

### 3. 生成（主修改）

增/改/替（含注释、字符串里文档路径）。简写 [core-concepts.md](core-concepts.md)。

### 4. 烤干

检查术语是否越过既定语义边界；是否应扩展到引用链或关键词命中；用户是否已明确「只改本文件 / 不要关联 / 不要全库搜」；互链、相对路径、`#anchor`、反引号路径是否仍有效。

### 5. 关联与语义（下一单元）

仅在当前单元烤干收敛且用户写后 `C` 确认允许扩展时，才将下一关联批次定为新当前单元并重走澄清→生成→烤干：

- 引用链：[related-doc-discovery.md](related-doc-discovery.md)
- 关键词：[semantic-keyword-discovery.md](semantic-keyword-discovery.md)

大范围或概念边界存疑 → 先 **brainstorming「范围预检」** 再扩。

用户动作见 unit-cycle-protocol；本技能 `S` 补充语义见 [gates.md](gates.md)。

## 不确定

仓内无法核实 → **停**、编号选项 → 用户选后再动。可多轮单问。
