---
type: Perspective Meta
title: 技术视角元数据
---
# 技术视角元数据

> **定位**：技术视角实体的字段必填性、属性与例外。首次定义层见 [治理规则](knowledge-governance.md#各层聚焦摘要)；关系目标和双向规则见 [关系模型](entity-relations.md)；ID 见 [命名规范](naming-conventions.md)；落点见 [知识布局](../references/knowledge-layout.md)；公共格式见 [OKF](okf-spec.md)。

## 1. 实体总表

实体类型统一见 [术语表](glossary.md#实体缩写登记)，层归属统一见 [治理规则](knowledge-governance.md#各层聚焦摘要)。本文件不重复总表、路径和跨视角边表。

## 2. 实体细则

下列“可选”仍受 [反向同步规则](entity-relations.md#动词与双向要求)约束：对端已声明关系时，反向字段必须填写。目标类型按关系模型；无值的可选属性不影响实体有效性。

### TPL

必填：`implemented_by`。无 `parent`。`domain` 能力域：云基础设施 / DevOps / 安全 / 开发环境 / 可观测 / 地图 / 人工智能。

### TS

必填：`implements_to`、`implemented_by`。可选：`used_by`，目标为 PD。

### MW

必填：`implements_to`。可选：`implemented_by`、`used_by`、`uses_to`。绑定类型、配置键写详细说明，缺省不判失败。

### CMP

必填：`implements_to`。可选属性 `maven_coordinates` 为 `groupId:artifactId:version`，写详细说明。

## 3. 跨视角出边

允许目标与反向关系见 [实体关系模型](entity-relations.md#允许边)；关系所在正文段见 [OKF](okf-spec.md)。字段是否必填以本文件 §2 为准。

## 4. 层入口

实体台账见各层 `knowledge/technical/README.md`；目录导航见各层 `knowledge/index.md`。生成与维护职责见 [知识布局](../references/knowledge-layout.md)，不在 meta 固化实例路径或索引开关。
