---
type: Architecture Chapter
tags: [architecture, chapter]
title: 业务能力
---
# 业务能力

[返回 · 业务架构](../README.md)

公司级能力框架与成熟度标准。

## 能力清单

公司级单层能力清单及与业务域对应。

## 成熟度评估

评估维度、等级、周期与责任人。

## 产品与方案映射

CAP 对标 PL / SLN 为**推导路径**（不新增 CAP 直连字段）：

1. `CAP.implements_to_vc` → VC  
2. `CAP.maps_to_bsd` → 一级 BSD  
3. 一级 BSD `maps_to_pl` → PL  
3. `SLN.maps_to_pl_id` → 同一 PL（一 PL 一 SLN）

公司只记原则与缺口；不落 PD/SYS。
