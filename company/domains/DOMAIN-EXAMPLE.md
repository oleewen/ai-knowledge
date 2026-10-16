---
type: Domain Architecture
id: DOMAIN-EXAMPLE
title: 示例业务域架构
---
# DOMAIN-EXAMPLE

对应 knowledge 实体 **BD-EXAMPLE**。不在此定义新 ID。

## 1. 支撑的价值链

- [VC-EXAMPLE](../knowledge/business/VC-EXAMPLE/VC-EXAMPLE.md)

## 2. BSD-L1 如何支撑

示例链，不新造 ID。BD-EXAMPLE 支撑 VC-EXAMPLE；其下 BSD-EXAMPLE 对标 CAP-EXAMPLE，CAP-EXAMPLE 实现该 VC。

| 角色 | ID | 关系 |
| --- | --- | --- |
| 业务域 | [BD-EXAMPLE](../knowledge/business/BD-EXAMPLE/BD-EXAMPLE.md) | `supports_to` VC-EXAMPLE；`children` BSD-EXAMPLE |
| 一级子域 | [BSD-EXAMPLE](../knowledge/business/BD-EXAMPLE/BSD-EXAMPLE.md) | `parent` BD-EXAMPLE；`maps_to` CAP-EXAMPLE |
| 能力 | [CAP-EXAMPLE](../knowledge/business/VC-EXAMPLE/CAP/CAP-EXAMPLE.md) | `implements_to` VC-EXAMPLE |

## 3. 范围 / 非范围

- 范围：该 BD 及其 BSD-L1 的公司级能力归属
- 非范围：方案正文、系统需求

## 4. 拆到哪条产品线 PL

- PL-EXAMPLE
