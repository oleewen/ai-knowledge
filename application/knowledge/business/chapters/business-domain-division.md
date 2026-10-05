---
type: Architecture Chapter
tags: [architecture, chapter]
title: 业务域划分
---
# 业务域划分

[返回 · 业务架构](../README.md)

本应用承接的业务域切片（实现映射）。L1 ∈ 公司，L2 ∈ 解决方案，BC 链 ∈ 系统。

> **本章口径**：本应用实现落地（`docs-extract` / `docs-archive`）。本层首次定义仅 **API / TBL / MW / CMP**。上游公司 / 解决方案 / 系统实体用纯 ID 或 parent HTTP，不重复字段语义。

## 业务域清单

列出上游域 ID（纯 ID 或 parent HTTP）及本应用实现映射，不重复公司/解决方案/系统字段语义。

## 业务域职责

按域写目标、能力、关键实体与协作方式。

## 核心域 / 支撑域 / 通用域

标注战略分类、理由与资源投入原则。

## 业务域关系图

描述域间依赖与数据/事件流；附关键依赖说明。
