---
type: Architecture Chapter
tags: [architecture, chapter]
title: 中间件与基础组件
---
# 中间件与基础组件

[返回 · 技术架构](../README.md)

本系统共享平台能力选型与使用规范。

> **中间件 SSOT**：MW/CMP 定义在 application；本章为落地叙事与 TSD 边界。样例 [MW-EXAMPLE](../MW-EXAMPLE/MW-EXAMPLE.md) → `application/knowledge/technical/MW-EXAMPLE/`；公司框架见 [company/knowledge/technical/README.md](../../../../company/knowledge/technical/README.md)。

## 消息队列

写集群划分、主题/队列命名、保留策略与事件流对齐。

## 缓存

写部署模式、淘汰策略、穿透/击穿/雪崩防护与 TTL 约定。

## 搜索引擎

写集群角色、索引生命周期、分片副本与安全隔离。

## 配置注册

写配置分层、敏感处理、灰度回滚与服务发现。

## 任务调度

写批处理/定时平台、幂等、重试与告警。

## 对象存储

写桶命名、生命周期、预签名 URL 与权限策略。
