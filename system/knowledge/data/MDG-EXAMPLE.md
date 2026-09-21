---
type: Master Data Domain
title: 示例主数据域
description: 演示系统级 MDG 结构。
tags: [data, MDG]
timestamp: "2026-06-21T00:00:00Z"
id: MDG-EXAMPLE
perspective: data
hierarchy: MDG
parent_id: null
layer_scope: system
---
## 关系

- (none)

## 跨视角

- 被 SYS-EXAMPLE 经 uses_mdg_ids 引用
- DS-EXAMPLE.authoritative_mdg_id / parent → 本 MDG

## 详细说明

- governance_owner: 示例：数据治理委员会
- definition_scope: local

## 依据与证据

chapters/data-model.md（主数据节，示例）
