---
type: Architecture Chapter
tags: [architecture, chapter]
title: 基础设施架构
---
# 基础设施架构

[返回 · 技术架构](../README.md)

本应用计算、网络与边缘交付落地。

> **本章口径**：本应用实现落地（`docs-extract` / `docs-archive`）。本层首次定义仅 **API / TBL / MW / CMP**。上游公司 / 解决方案 / 系统实体用纯 ID 或 parent HTTP，不重复字段语义。

## 部署架构

写机房/区域/可用区拓扑与跨区策略。

## 网络拓扑

写 VPC、子网、防火墙与安全域分层。

## 云资源规划

写网段、NAT、安全组、标签与成本分摊。

## 容器编排

写 K8s 集群划分、命名空间、配额与升级策略。

## 流量接入

写 CDN、LB、DNS、证书与 HTTPS 终止。
