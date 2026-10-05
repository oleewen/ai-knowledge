---
type: Architecture Chapter
tags: [architecture, chapter]
title: 接口管理
---
# 接口管理

[返回 · 应用架构](../README.md)

本应用内外接口的发现、规范与演进。

> **本章口径**：本应用实现落地（`docs-extract` / `docs-archive`）。本层首次定义仅 **API / TBL / MW / CMP**。上游公司 / 解决方案 / 系统实体用纯 ID 或 parent HTTP，不重复字段语义。

## 内部 API

写目录结构、命名、认证、错误约定与契约存放位置。本层 **API** 为 SSOT。

## 开放 API

列出对外 API、用途、SLA 与 DTO/脱敏差异。

## 版本策略

写兼容窗口、弃用公告与破坏性变更审批。

## 变更日志

按服务/API 聚合变更记录与消费者行动项。
