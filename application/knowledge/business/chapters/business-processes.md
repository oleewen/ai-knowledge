---
type: Architecture Chapter
tags: [architecture, chapter]
title: 业务流程
---
# 业务流程

[返回 · 业务架构](../README.md)

本应用主责业务流程及与能力的映射。

> **本章口径**：本应用实现落地（`docs-extract` / `docs-archive`）。本层首次定义仅 **API / TBL / MW / CMP**。上游公司 / 解决方案 / 系统实体用纯 ID 或 parent HTTP，不重复字段语义。

## 核心流程

列出业务流程组（`a.b`）与活动（`a.b.c`）编码、定义及关键输入输出。

## 分支流程

展开 L4 子活动（`a.b.c.d`）及与 L3 的从属关系。

## 异常流程

写清补偿、回滚、升级路径、触发条件与 SLA。

## 系统映射

对照流程活动与系统能力、接口及 SLA；链至 [应用架构](../../application/chapters/application-architecture.md)。
