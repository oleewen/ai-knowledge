# sdx-domains 核心概念

## 产物与身份

`DOMAIN-MAP.md` 是 VC/BD/分域文档的导航总图。`DOMAIN-{BD-ID}.md` 解释一个已有业务域如何支撑价值链，不是新 knowledge 实体或交付包。

新建示例：已有 `BD-ORDER`，文件名与 `id` 为 `DOMAIN-BD-ORDER`。历史文档若已采用 `DOMAIN-EXAMPLE` 等命名，先核对其对应 BD 与总图引用，保留名称；不要自动迁移。

字段和章骨架以 [总图模板](../assets/domain-map-template.md)、[分域模板](../assets/domain-template.md) 为准。

## 关系核对

治理真源：[knowledge-governance.md](../../../knowledge/knowledge-governance.md)「公司层」与「核心映射」。本技能读取以下关系，不重新定义或写回它们：

| 要回答的问题 | 读取的已有关系 |
| --- | --- |
| 哪条 BD 支撑 VC | BD `supports_to` VC |
| 哪些一级子域承担能力 | BD `children` BSD-L1；BSD-L1 `parent` BD |
| 子域怎样支撑价值链 | BSD-L1 `maps_to` CAP；CAP `implements_to` VC |
| 对接哪条产品线 | 已有 BL/PL 映射或确认材料；PL 用纯 ID |

BSD 的层级以实体 `level` 与关系核实，不从名称猜测。PL 的定义属于解决方案层；公司域文档不复制其正文。未核实关系标缺口，不从目录邻接或名字相似推导。
