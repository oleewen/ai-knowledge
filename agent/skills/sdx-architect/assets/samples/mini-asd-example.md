# ASD 片段示例

## 1. 设计概述

- 目标：订单域重构中明确服务边界、降低跨服务耦合。
- 约束：对外 API 契约不变；本阶段不下沉 DSD 细节。

## 2. 架构设计

- 服务变更：`order-service` 查询职责拆到 `order-query-service`。
- 交互：读走 API Gateway 聚合；写路径不变。

## 3. 需求规约

- 概设规约：`./specs/spec-asd-order-1-order.md`
- 摘要：查询能力边界、关键参数、异常返回约束。
