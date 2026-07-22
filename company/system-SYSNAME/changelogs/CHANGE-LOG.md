---
type: Change Log
title: CHANGE-LOG（system-SYSNAME 槽位）
---
<!-- markdownlint-disable-next-line MD025 -->
# CHANGE-LOG（system-SYSNAME 槽位）

单系统槽位同步留痕。

## 写入约定

- 新记录按时间倒序追加
- 记录 `system → company` 同步与校核事件
- 每条注明来源、时间与影响范围
