# DS-ORDER-MYSQL-PRIMARY — 订单主库

对应数据架构中的 **order_db**，存储订单核心业务数据。归属应用见 [_meta.yaml](./_meta.yaml)。

## 元信息

| 属性 | 值 |
|------|-----|
| 存储标识 | DS-ORDER-MYSQL-PRIMARY（order_db） |
| 类型 | MySQL 8.0 |
| 所属服务 | svc-order |
| 数据量级 | ~2000万行/年 |
| 关联文档 | [数据架构总览](../DATA-ARCHITECTURE.md)、[业务聚合 AGG-ORDER](../../business/BD-ORDER/BSD-FULFILLMENT/BC-ORDER-MGMT/aggregates/AGG-ORDER.yaml) |

## 核心表结构

### orders 表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 订单ID |
| order_no | VARCHAR(32) | UNIQUE, NOT NULL | 订单编号 |
| user_id | BIGINT | NOT NULL | 用户ID |
| status | VARCHAR(20) | NOT NULL | 订单状态(见INV-002) |
| total_amount | BIGINT | NOT NULL | 订单总额(分) |
| discount_amount | BIGINT | NOT NULL, DEFAULT 0 | 优惠金额(分) |
| shipping_amount | BIGINT | NOT NULL, DEFAULT 0 | 运费(分) |
| pay_amount | BIGINT | NOT NULL | 应付金额(分) |
| paid_at | DATETIME | | 支付时间 |
| shipping_address | JSON | NOT NULL | 收货地址快照 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |
| deleted_at | DATETIME | | 软删除标记 |

**索引**:
- `uk_order_no` UNIQUE (order_no)
- `idx_user_id_created_at` (user_id, created_at)
- `idx_status` (status)

### order_items 表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 订单项ID |
| order_id | BIGINT | NOT NULL | 订单ID |
| product_id | BIGINT | NOT NULL | 商品ID |
| sku_code | VARCHAR(50) | NOT NULL | SKU编码 |
| product_name | VARCHAR(200) | NOT NULL | 商品名称(快照) |
| unit_price | BIGINT | NOT NULL | 单价(分)(快照) |
| quantity | INT | NOT NULL | 数量 |
| subtotal | BIGINT | NOT NULL | 小计(分) |

**索引**:
- `idx_order_id` (order_id)

## 数据实体映射

| 物理表 | 实体定义 | 聚合根 |
|--------|----------|--------|
| orders | [ENT-T_ORDER](./schema/ENT-T_ORDER.yaml) | AGG-ORDER |
| order_items | [ENT-T_ORDER_ITEMS](./schema/ENT-T_ORDER_ITEMS.yaml) | 订单项（从属订单） |

## 数据分片策略

| 表 | 分片方式 | 分片键 | 分片数 | 触发条件 |
|----|----------|--------|--------|----------|
| orders | 按用户ID哈希 | user_id | 16 | 单表超过5000万行(PC-004) |
| order_items | 跟随 orders | order_id 关联 | 16 | 与 orders 同步分片 |
