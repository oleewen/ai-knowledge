---
type: Architecture Chapter
tags: [architecture, chapter]
title: 集成架构
---
# 集成架构

[返回 · 应用架构](../README.md)

本应用第三方与遗留集成：协议、数据流与防腐边界。

> **本章口径**：本应用实现落地（`docs-extract` / `docs-archive`）。本层首次定义仅 **API / TBL / MW / CMP**。上游公司 / 解决方案 / 系统实体用纯 ID 或 parent HTTP，不重复字段语义。

## 集成清单

列出外部系统、用途、对接团队与数据敏感度。

## 集成协议

写 HTTP/消息/文件等选型、认证模式与禁止项。

## 集成数据流

写数据流向、频率、批/实时属性与权威源。

## 防腐层

写 ACL/Adapter 位置、映射规则、错误隔离与重试。
