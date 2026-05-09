# ASD 片段示例

## 1. 设计概述

- 目标：订单域重构，划清服务边界、降耦合
- 约束：对外契约不变；本轮不写 DSD 细则

## 2. 架构设计

- 变更：`order-service` 读查询迁到 `order-query-service`
- 交互：读经 Gateway 聚合；写路径照旧

## 3. 需求规约

- 概设：`./specs/spec-asd-order-1-order.md`
- 摘要：查询边界、关键参数、异常口径
