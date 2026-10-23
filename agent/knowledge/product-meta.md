---
type: Perspective Meta
title: 产品视角元数据
---
# 产品视角元数据

> **定位**：产品视角实体的字段必填性、属性与例外。首次定义层见 [治理规则](knowledge-governance.md#各层聚焦摘要)；关系目标和双向规则见 [关系模型](entity-relations.md)；ID 见 [命名规范](naming-conventions.md)；落点见 [知识布局](../references/knowledge-layout.md)；公共格式见 [OKF](okf-spec.md)。

## 1. 实体总表

实体类型统一见 [术语表](glossary.md#实体缩写登记)，层归属统一见 [治理规则](knowledge-governance.md#各层聚焦摘要)。本文件不重复总表、路径和跨视角边表。

## 2. 实体细则

下列“可选”仍受 [反向同步规则](entity-relations.md#动词与双向要求)约束：对端已声明关系时，反向字段必须填写。目标类型按关系模型；无值的可选属性不影响实体有效性。

### PL

必填：`maps_to`。可选：`implemented_by`、`mapped_by`。无 `parent`。

### PD

必填：`implements_to`、`maps_to`、`implemented_by`；后者包含 BSP、PM，跨层 PM 只写纯 ID。可选：`uses_to`。不写 `mapped_by` SYS。

### BP

必填：`implements_to`。可选：`children`。不挂入产品组成链。

### BSP

必填：`parent`、`implements_to`。`kind` 值为 `core` / `branch` / `exception`。

### PM

必填：`implements_to`、`implemented_by`。可选：`maps_to`、`depends_to`、`depended_by`。跨系统归属限制见 [关系例外](entity-relations.md#例外与禁止)。

### FT

必填：`implements_to`、`implemented_by`。可选：`supported_by`。

### FR

必填：`implements_to`、`implemented_by`。

### UC

必填：`implements_to`。可选：`maps_to`、`mapped_by`。

### BR

必填：`implements_to`。

## 3. 跨视角出边

允许目标与反向关系见 [实体关系模型](entity-relations.md#允许边)；关系所在正文段见 [OKF](okf-spec.md)。字段是否必填以本文件 §2 为准。

## 4. 层入口

实体台账见各层 `knowledge/product/README.md`；目录导航见各层 `knowledge/index.md`。生成与维护职责见 [知识布局](../references/knowledge-layout.md)，不在 meta 固化实例路径或索引开关。
