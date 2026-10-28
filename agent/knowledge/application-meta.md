---
type: Perspective Meta
title: 应用视角元数据
---
# 应用视角元数据

> **定位**：应用视角实体的字段必填性、属性与例外。首次定义层见 [治理规则](knowledge-governance.md#各层聚焦摘要)；关系目标和双向规则见 [关系模型](entity-relations.md)；ID 见 [命名规范](naming-conventions.md)；落点见 [知识布局](../references/knowledge-layout.md)；公共格式见 [OKF](okf-spec.md)。

## 1. 实体总表

实体类型统一见 [术语表](glossary.md#实体缩写登记)，层归属统一见 [治理规则](knowledge-governance.md#各层聚焦摘要)。本文件不重复总表、路径和跨视角边表。

## 2. 实体细则

下列“可选”仍受 [反向同步规则](entity-relations.md#动词与双向要求)及其例外约束。目标类型按关系模型；无值的可选属性不影响实体有效性。

### SLN

必填：`maps_to`、`implemented_by`；后者为 BP，不登记 SYS。无 `parent`。

### SYS

必填：`implements_to`、`implemented_by`。可选：`maps_to`。两条上游边固定纯 ID，见 [关系例外](entity-relations.md#例外与禁止)。不写 `uses_to` MDG/TS。

PD 消费本 SYS 的反向视图由 [消费声明](entity-relations.md#共享系统消费) 汇总；不新增必填的人工 `used_by`，不把消费方写成 `maps_to`。

### APP

必填：`implements_to`、`implemented_by`。可选：`supports_to`、`uses_to`。

### MS

必填：`implements_to`、`implemented_by`。可选：`maps_to`、`uses_to`。

`implements_to` 恰好一个 APP；`id` 在该 APP 内唯一，跨文件完整身份按 [命名规范](naming-conventions.md#身份范围与限定引用) 表达。

### API

必填：`implements_to`。可选：`supports_to`、`maps_to`。API 为叶子；别名、方法签名、入口类型写详细说明，缺省不判失败。

`implements_to` 恰好一个已核实 MS，并能确定其 APP；缺任一归属不落正式实体。局部 `id` 在该 MS 内唯一，文件名保持局部 ID；迁移归属按 [身份迁移](knowledge-governance.md#身份迁移与删除) 处理。

## 3. 跨视角出边

允许目标与反向关系见 [实体关系模型](entity-relations.md#允许边)；关系所在正文段见 [OKF](okf-spec.md)。字段是否必填以本文件 §2 为准。

## 4. 层入口

实体台账见各层 `knowledge/application/README.md`；目录导航见各层 `knowledge/index.md`。生成与维护职责见 [知识布局](../references/knowledge-layout.md)，不在 meta 固化实例路径或索引开关。
