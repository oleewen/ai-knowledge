# {架构设计说明书（ASD）标题}


## 1. 设计概述

### 1.1 设计目标

- 关联需求分析：`{DOC_DIR}/analysis/ANALYSIS-{IDEA-ID}.md`
- 关联产品需求：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`
- MVP阶段：MVP-Phase-{N}

### 1.2 设计约束
<!-- 技术约束、架构约束、兼容性约束等 -->

### 1.3 关键设计决策

| 决策编号 | 决策点 | 决策结果 | 决策理由 | 备选方案 |
| --------- | ------- | --------- | --------- | --------- |
| DD-001 | | | | |

## 2. 架构设计

### 2.1 系统架构设计

#### 系统架构图

```mermaid
graph TD
    subgraph 本次变更范围
        A[系统A]
        B[系统B]
    end
    C[外部系统C] --> A
    A --> B
```

#### 服务变更

| 服务名称  | 所属应用   | 变更类型 | 变更说明    |
| ----------- | ------------ | ---------- | ------------- |
| service-a | xx-service | 变更     | 新增xxx功能 |
| service-b | yy-service | 新增     | 新服务      |

#### 服务交互

```mermaid
sequenceDiagram
    participant Client
    participant ServiceA
    participant ServiceB
    participant DB
    
    Client->>ServiceA: POST /api/xxx
    ServiceA->>ServiceB: gRPC call
    ServiceB->>DB: Query
    DB-->>ServiceB: Result
    ServiceB-->>ServiceA: Response
    ServiceA-->>Client: 200 OK
```

### 2.2 接口协议设计

| 接口名称 | 所属服务 | 能力说明 | 输入输出 |
| --------------- | -------- | -------- | ------ |
| XX接口 | serivice-a | 提供XX能力 | 输入：XX <br/> 输出：YY |

### 2.3 领域模型设计

#### 领域模型图

```mermaid
classDiagram
    class AggregateRoot {
        +ID id
        +method1()
        +method2()
    }
    class Entity {
        +ID id
        +field1
    }
    class ValueObject {
        +field1
        +field2
    }
    AggregateRoot "1" --> "*" Entity
    Entity --> ValueObject
```

#### 领域事件

| 事件名称        | 触发条件 | 携带数据 | 消费者 |
| --------------- | -------- | -------- | ------ |
| XxxCreatedEvent |          |          |        |

### 2.4 数据架构设计

#### 数据存储选型

```mermaid
flowchart LR
    Start(["🚀 存储选型开始"]) --> Q1{"数据是否结构化<br/>且需要复杂事务？"}

    Q1 -->|"是"| Q3{"<b>数据量大吗？</b>"}
		Q3-->|"累计不超5千万，单表存储"|SQL["🗄️ <b>RDB</b><br/>MySQL<br/>PostgreSQL"]
		Q3-->|"累计超5千万，分表存储"|SQL
		Q3-->|"累计超5千万，不分表"|OB["🗄️ <b>RDB</b><br/>OceanBase<br/>TiDB"]

    Q1 -->|"否"| Q2{"核心访问模式是什么？"}

    Q2 -->|"高并发KV读写"| A_KV["⚡ <b>缓存/KV 存储</b><br/>KVRocks<br/>Redis<br/>Memcached"]
    Q2 -->|"文档型灵活Schema"| A_DOC["📄 <b>文档数据库</b><br/>MongoDB"]
    Q2 -->|"海量日志/全文检索"| A_LOG["🔍 <b>搜索引擎</b><br/>Elasticsearch"]
    Q2 -->|"时序数据"| A_TS["⏱️ <b>时序数据库</b><br/>InfluxDB<br/>TDengine<br/>TimescaleDB"]
    Q2 -->|"海量列式分析"| A_COL["📊 <b>列式存储/分析</b><br/>Doris<br/>ClickHouse<br/>HBase"]
    Q2 -->|"图关系查询"| A_GRAPH["🕸️ <b>图数据库</b><br/>Neo4j<br/>JanusGraph"]
    Q2 -->|"对象/文件存储"| A_OBJ["📦 <b>对象/文件存储</b><br/>MinIO<br/>S3<br/>HDFS"]
    Q2 -->|"消息/事件流"| A_MSG["📨 <b>消息/事件流</b><br/>Kafka<br/>RockitMQ<br/>RabbitMQ"]
```

#### 数据库表设计

```mermaid
erDiagram
    table_name1（U） {
        BIGINT id PK "主键ID"
        VARCHAR name "名称"
        VARCHAR code UK "编码（A）"
        TIMESTAMP created_at "创建时间"
        TIMESTAMP updated_at "更新时间"
    }

    table_name2（A） {
        BIGINT id PK "主键ID"
        VARCHAR name "名称"
        VARCHAR code FK "表1编码" 
        TIMESTAMP created_at "创建时间"
        TIMESTAMP updated_at "更新时间"
    }

    table_name1（U）||--o{ table_name2（A）: 被引用
```

#### 数据分片设计

#### 数据迁移方案

### 2.5 发布方案设计

#### 发布步骤

<!-- 明确本次变更涉及的部署与环境变更，按顺序列出操作项（例如：容器/服务升级、数据库迁移、配置/环境变量调整、接口切换等） -->

#### 发布检查

- 变更窗口与影响面通知到位
- 相关服务和依赖是否已完成升级/发布准备
- 回滚/兜底策略是否有预案
- 数据迁移是否有验证脚本
- 三方验证、全链路验证是否已准备好

#### 回滚方案

- 回滚前需备份相关数据库与配置
- 回滚步骤：逐步逆向操作（如数据库还原、容器回滚等），确保服务健康
- 回滚注意事项：做好监控收敛，通知相关人员

## 文档元数据

<!-- 唯一元数据位置：须为 fenced yaml，且位于全文末尾；禁止在文件开头使用 --- YAML frontmatter -->

```yaml
id: "ASD-{IDEA-ID}"
title: "{架构设计说明书标题}"
version: "1.0.0"
status: "draft"
created: "{YYYY-MM-DD}"
updated: "{YYYY-MM-DD}"
author: "architect"
reviewers: []
parent: "PRD-{IDEA-ID}"
mvp_phase: "MVP-Phase-{N}"
tags: ["ASD"]
```
