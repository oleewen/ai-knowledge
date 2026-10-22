# ASD 片段示例

> 虚构示例，只演示内容粒度；不是可通过完整校验的 ASD。假定所在位置为 `docs/requirements/REQUIREMENT-ORDER/MVP-Phase-1/ASD-ORDER-1.md`。

## 1. 设计概述

- 目标：订单域重构，划清服务边界、降耦合
- 约束：对外契约不变；本轮不写 DSD 细则

## 2. 架构设计

- 变更：`order-service` 读查询迁到 `order-query-service`
- 交互：读经 Gateway 聚合；写路径照旧

## 3. 需求规约

### 3.1 需求规约摘要

| 应用 | 规约文件 | 规约描述 |
| --- | --- | --- |
| 订单应用 | 待建：`../../../specs/spec-asd-ORDER-1-order.md` | 查询边界、关键参数、异常口径 |

下游承接：订单应用 `DSD-ORDER-1.md`（待建）。
