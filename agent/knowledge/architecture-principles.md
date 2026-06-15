---
id: architecture-principles
title: 架构原则
version: "2.0"
last_reviewed: null
next_review: null
approved_by: Architecture Board
tags: ["architecture", "principles", "governance"]
---

# 架构原则

与 [agent/rules](../rules/CONVENTIONS.md) 治理配套；细则以 ADR / 评审为准。

## 元原则

| ID | 名称 | 陈述 |
| --- | --- | --- |
| MP-01 | 原则数量克制 | 核心原则可执行、数量克制，避免口号化。 |
| MP-02 | 原则可验证 | 每条原则应有可操作的验证或评审方式。 |

## 架构原则

| ID | 名称 | 分类 | 陈述 |
| --- | --- | --- | --- |
| AP-01 | 业务能力驱动 | business-alignment | 系统边界与业务能力边界对齐，而非仅按技术层次划分。 |
| AP-02 | 演进式架构 | business-alignment | 架构支持增量变更，重大变更需渐进路径与回滚预案。 |
| AP-03 | 数据所有权明确 | data-governance | 每个数据实体有唯一权威来源服务。 |
| AP-04 | 事件作为一等公民 | data-governance | 跨服务状态传播优先领域事件，配合幂等与契约版本。 |
| AP-05 | API 优先 | technical-excellence | 服务能力通过定义良好的 API 暴露，契约先于实现。 |
| AP-06 | 故障隔离 | technical-excellence | 单组件故障不导致全站不可用；限流、熔断、降级内建。 |
| AP-07 | 可观测性内建 | technical-excellence | 服务内建日志、指标、链路追踪等可观测性。 |
| AP-08 | 零信任安全 | security | 服务间默认不信任，认证授权与最小权限。 |
| AP-09 | 团队自治与对齐 | organization | 团队在服务边界内自治，跨团队接口与标准对齐。 |
| AP-10 | 文档即代码 | organization | 架构文档与代码同仓、版本化，关键一致性可 CI 校验。 |

## 知识库原则

| ID | 名称 | 分类 | 陈述 |
| --- | --- | --- | --- |
| KP-01 | 单一事实源 | knowledge-management | 知识实体单点定义，他处仅 ID 引用；映射写在源侧 meta 或 JSON。 |
