---
type: Perspective Meta
title: 业务视角元数据（solution/knowledge/business）
---
# 业务视角元数据（solution/knowledge/business）

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SOLUTION-KNOWLEDGE-BUSINESS` |
| 视角 | business |
| 层级范围 | solution |
| 说明 | BSD(L2) 与 BS 本层 SSOT。BS 无 parent，`maps_to` BSD(L2) 1:1。BD/L1 = 公司 reference |

## 层级链

| 链序 | 层级 | 本层角色 |
| --- | --- | --- |
| 1–2 | BD / BSD(L1) | 公司 SSOT；本层 reference |
| 3 | BSD(L2) | 本层 SSOT；`mapped_by` BS |
| — | BS | 本层 SSOT；无 parent；`maps_to` BSD(L2) 1:1 |
