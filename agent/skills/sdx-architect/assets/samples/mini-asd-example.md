# Mini ASD Example

## 1. 设计概述

- 目标：在订单域重构中建立清晰服务边界，降低跨服务耦合风险。
- 约束：保持现有对外 API 契约不变，不在本阶段下沉到 DSD 实现细节。

## 2. 架构设计

- 服务变更：`order-service` 拆分查询职责到 `order-query-service`。
- 交互方式：同步查询改为 API Gateway 聚合，写路径保持原链路。

## 3. 需求规约

- 规约文件：`./specs/spec-order-1-order.md`
- 规约摘要：定义查询能力边界、关键参数、异常返回约束。
