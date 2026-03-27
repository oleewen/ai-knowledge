# 四视角提取规则详解

knowledge-extract 技能的核心提取规则。按固定顺序执行：技术 → 数据 → 业务 → 产品。每个视角独立提取，后续视角可引用前序视角已提取的 ID。

输出文件统一使用 `{perspective}_knowledge.json`（schema_version 2.1）。

---

## 1. 技术视角（Technical）

### 输入源

- 主 Index Guide
- AGENTS.md（模块定义，可选，若存在则参考）
- 源代码（@GatewayApi、Controller、Dubbo 接口、MQ、Job 等）

### 提取规则

#### SYS（系统层级）

- 提取自 README.md 项目结构描述（若存在）
- 一个仓库通常对应一个 SYS-ID
- **必须字段**：`full_id`（目录风格，如 `SYS-POLICY-APPEAL`）、`description`、`architecture`（含 apps/external_dependencies/ddd_layers）

#### APP（应用层级）

- 提取自启动类所在 Maven 模块
- 识别标准：
  - 包含 `main(String[] args)` 方法
  - 调用 `Main.run()` 或 `SpringApplication.run()`
  - 配置 `spring-boot-maven-plugin`
- **必须字段**：`full_id`、`parent_sys_id`、`startup_class`、`maven_module`、`service_ids`
- **可选字段**：`mq_consumers`、`jobs`、`jobs_count`、`repo_url`、`docs_manifest_path`

#### MS（微服务层级）

- 必须有宿主类
- 命名规则：SimpleName 去后缀
- 聚类方式：按 APIs 宿主类

**MS 生成规则**：

| 宿主类模式 | 别名生成方式 |
|-----------|-------------|
| `…Api` | 宿主类 SimpleName（如 `PolicyAppealApi` → `PolicyAppeal`） |
| `…ApiImpl` | 宿主类 SimpleName（如 `AppealService` → `Appeal`） |
| `…Controller` | 宿主类 SimpleName（如 `FeeAppealTaskController` → `FeeAppealTask`） |

- **同名合并**：相同宿主类或同义宿主类二选一（如 PolicyAppeal、Appeal，选择 PolicyAppeal）
- **必须字段**：`host_class`、`host_module`、`protocol`（HTTP/Dubbo/HTTP+Dubbo）
- **可选字段**：`merge_note`（合并说明）
- **禁止**：使用 Maven 模块名作为 MS-ID、单模块对应多个 MS-ID、使用包名尾段作为显示名

#### API（接口层级）

- **必须字段**：`service_id`（所属 MS-ID）、`host_class`、`host_module`、`method_signature`
- **别名命名**：必须以所属 MS 别名为前缀，格式 `{MS别名}.{apiMethodAlias}`
  - 示例：MS 别名=PolicyAppeal，API 方法=create → `PolicyAppeal.create`

### 输出结构

技术视角使用**分类结构**（非扁平数组），`entities` 下按 `systems`、`applications`、`services`、`apis` 分组：

```json
{
  "schema_version": "2.1",
  "perspective": "technical",
  "generated_at": "ISO-8601",
  "entities": {
    "systems": [
      {
        "hierarchy": "SYS", "id": "001",
        "full_id": "SYS-POLICY-APPEAL",
        "alias": "PolicyAppealSystem", "name": "政策申诉系统",
        "description": "系统定位与架构描述",
        "architecture": {
          "apps": [{ "id": "APP-...", "name": "...", "startup_class": "...", "role": "..." }],
          "external_dependencies": [{ "system": "...", "integration": "...", "purpose": "..." }],
          "ddd_layers": ["Gateway", "Application", "Domain", "Infrastructure"]
        },
        "evidence_chain": [...],
        "cross_references": { "business": ["BD-001"], "product": ["PL-001"] }
      }
    ],
    "applications": [
      {
        "hierarchy": "APP", "id": "001",
        "full_id": "APP-POLICY-APPEAL-SERVICE",
        "parent_sys_id": "SYS-POLICY-APPEAL",
        "alias": "AppealServiceApp", "name": "申诉业务服务应用",
        "description": "...",
        "startup_class": "AppealServiceApp",
        "maven_module": "policy-appeal-service",
        "service_ids": ["MS-001", "MS-002", ...],
        "mq_consumers": ["PolicyAppealDealConsumer", ...],
        "evidence_chain": [...],
        "cross_references": { ... }
      }
    ],
    "services": [
      {
        "hierarchy": "MS", "id": "001",
        "alias": "PolicyAppeal", "name": "政策申诉服务",
        "host_class": "PolicyAppealApiImpl, AppealServiceImpl",
        "host_module": "policy-appeal-service",
        "protocol": "HTTP+Dubbo",
        "merge_note": "same_name_merge: ...",
        "evidence_chain": [...],
        "cross_references": { "business": [...], "product": [...], "apis": [...] }
      }
    ],
    "apis": [
      {
        "hierarchy": "API", "id": "001",
        "alias": "PolicyAppeal.listPolicyAppeal", "name": "政策申诉列表查询",
        "service_id": "MS-001",
        "host_class": "PolicyAppealApiImpl",
        "host_module": "policy-appeal-service",
        "method_signature": "listPolicyAppeal(PolicyAppealReq req)",
        "evidence_chain": [{ "source": "PolicyAppealApiImpl#listPolicyAppeal:73", "confidence": "high", "type": "code_location" }]
      }
    ]
  },
  "metadata": { "total_systems": 1, "total_applications": 2, "total_services": 12, "total_apis": 72, "total_entities": 87 }
}
```

---

## 2. 数据视角（Data）

### 输入源

- 主 Index Guide
- 多数据源配置文件
- @Table 注解的实体类
- MyBatis XML 映射文件

### 提取规则

#### DS（数据源层级）

- 提取自 `application.yml/properties` 多数据源配置
- **必须字段**：`full_id`（如 `DS-PANGU-APPEAL-TIDB`）、`description`、`type`（如 `TiDB / MySQL 8.0+`）、`config_key`、`owned_by_app_id`
- **可选字段**：`notes`（如事务注解说明）

#### ENT（实体层级）

- 提取自 @Table 注解的实体类
- **必须字段**：`full_id`（如 `ENT-001`）、`parent_id`（所属 DS 的 full_id）、`logical_name`（Java 类名）、`physical_table`（数据库表名）
- **同表合并**：相同表名对应的实体类合并为一个 ENT-ID
- **禁止**：使用包名作为 ENT-ID、单表对应多个 ENT-ID、使用 Mapper 类名作为显示名

### 输出结构

数据视角使用**扁平数组**：

```json
{
  "schema_version": "2.1",
  "perspective": "data",
  "generated_at": "ISO-8601",
  "entities": [
    {
      "hierarchy": "DS", "id": "001",
      "full_id": "DS-PANGU-APPEAL-TIDB",
      "alias": "PanguAppealTiDB", "name": "TiDB 主业务库",
      "description": "主业务数据库描述",
      "type": "TiDB / MySQL 8.0+",
      "config_key": "pangu_tidb",
      "owned_by_app_id": ["APP-POLICY-APPEAL-SERVICE"],
      "notes": ["@MultiTransactional(\"pangu\")"],
      "evidence_chain": [...],
      "cross_references": { "business": ["BD-001"] }
    },
    {
      "hierarchy": "ENT", "id": "001",
      "full_id": "ENT-001",
      "parent_id": "DS-PANGU-APPEAL-TIDB",
      "alias": "PolicyAppeal", "name": "申诉单表",
      "logical_name": "PolicyAppeal",
      "physical_table": "policy_appeal",
      "evidence_chain": [...],
      "cross_references": { "datasource": "DS-001", "business": ["AGG-001"], "technical": ["MS-001"] }
    }
  ],
  "metadata": { "total_datasources": 3, "total_entities": 21, "total_items": 24 }
}
```

---

## 3. 业务视角（Business）

### 输入源

- 主 Index Guide
- AGENTS.md（业务域定义，可选，若存在则参考）
- 源代码包结构（FQCN 分析）
- 技术视角已提取的 MS-* 服务

### 提取规则

#### BD（业务域层级）

- 提取自包路径域名首段、AGENTS.md 业务域定义
- **必须字段**：`full_id`（如 `BD-CHARGING-APPEAL`）、`description`、`strategic_classification`（core_domain/supporting/generic）、`children`（子域 full_id 列表）

#### BSD（业务子域层级）

- 提取自 BC 与 BD 间的包路径段
- **必须字段**：`full_id`、`parent_id`（所属 BD 的 full_id）、`description`、`bounded_contexts`（BC full_id 列表）
- **禁止**：将 BC 直接作为 BSD、跨业务域合并 BSD

#### BC（限界上下文层级）

- 提取自宿主类父包名、限界上下文包路径
- **必须字段**：`full_id`（如 `BC-POLICY-APPEAL-CORE`）、`parent_id`、`description`、`implemented_by_app_id`、`aggregates`（AGG full_id 列表）
- **可选字段**：`ubiquitous_language`（通用语言词汇表，key-value 对）
- **禁止**：使用 Maven 模块名作为 BC-ID、单包对应多个 BC-ID

#### AGG（聚合层级）

- 提取自 MS-* 服务、聚合根实体
- **必须字段**：`full_id`（如 `AGG-POLICY-APPEAL`）、`parent_id`（所属 BC 的 full_id）、`description`、`root_entity`、`entities`（值对象列表）、`persisted_as_entity_ids`（对应 ENT-ID 列表）、`implemented_by_service_ids`（对应 MS-ID 列表）、`abilities`（对应 AB full_id 列表）
- **可选字段**：`invariants`（业务不变量/约束列表）
- **禁止**：无 MS-* 对应的 AGG-ID、单 MS-* 对应多个 AGG-ID

#### AB（聚合边界层级）

- 提取自入口 API、聚合边界定义
- **必须字段**：`full_id`（如 `AB-APPEAL-LIFECYCLE`）、`parent_id`（所属 AGG 的 full_id）、`description`、`capability`（能力概述）、`apis`（结构化接口列表）
- `apis` 数组每项含：`id`（API-ID）、`method`（MS别名.方法名）、`description`
- **禁止**：无 API 对应的 AB-ID、AB 缺少能力概述描述

### 输出结构

业务视角使用**扁平数组**，通过 `hierarchy` 区分层级，`parent_id` 表达层级关系：

```json
{
  "schema_version": "2.1",
  "perspective": "business",
  "generated_at": "ISO-8601",
  "confidence": "high",
  "entities": [
    {
      "hierarchy": "BD", "id": "001",
      "full_id": "BD-CHARGING-APPEAL",
      "alias": "ChargingAppealDomain", "name": "计费申诉域",
      "description": "...",
      "strategic_classification": "core_domain",
      "children": ["BSD-POLICY-APPEAL", "BSD-FEE-APPEAL"],
      "evidence_chain": [...],
      "cross_references": { "technical": ["SYS-001"], "product": ["PL-001"] }
    },
    {
      "hierarchy": "AGG", "id": "001",
      "full_id": "AGG-POLICY-APPEAL",
      "parent_id": "BC-POLICY-APPEAL-CORE",
      "alias": "PolicyAppealAgg", "name": "政策申诉聚合",
      "description": "...",
      "root_entity": "PolicyAppeal",
      "entities": ["PolicyAppealItem", "PolicyAppealItemDraft", "PolicyAppealItemHis"],
      "invariants": ["申诉主单提交后 24 小时未操作自动作废", ...],
      "persisted_as_entity_ids": ["ENT-001", "ENT-002", "ENT-003", "ENT-004"],
      "implemented_by_service_ids": ["MS-001", "MS-002", "MS-009"],
      "abilities": ["AB-APPEAL-LIFECYCLE"],
      "evidence_chain": [...],
      "cross_references": { "technical": [...], "business": [...], "data": [...] }
    },
    {
      "hierarchy": "AB", "id": "001",
      "full_id": "AB-APPEAL-LIFECYCLE",
      "parent_id": "AGG-POLICY-APPEAL",
      "alias": "AppealLifecycle", "name": "申诉生命周期能力",
      "description": "...",
      "capability": "提供政策申诉主单的创建、提交、取消、审核等完整生命周期能力",
      "apis": [
        { "id": "API-002", "method": "PolicyAppeal.create", "description": "创建申诉主单" },
        { "id": "API-005", "method": "PolicyAppeal.submit", "description": "提交申诉" }
      ],
      "evidence_chain": [...],
      "cross_references": { "technical": ["MS-001", "MS-002"], "business": ["AGG-001"] }
    }
  ],
  "metadata": { "total_business_domains": 1, "total_business_subdomains": 2, "total_bounded_contexts": 3, "total_aggregates": 3, "total_abilities": 3, "total_entities": 12 }
}
```

---

## 4. 产品视角（Product）

### 输入源

- 主 Index Guide
- 技术视角已提取的 SYS、MS、API，业务视角已提取的 BD、BSD、BC、AGG、AB
- README.md（如存在，参考产品概述、用户场景）
- PRD 文档（若有）、用户场景文档（若有）

### 提取规则

#### PL（产品线层级）

- 提取自 README.md 产品概述、SYS-* 系统定义
- 与 SYS-* 一一对应
- **必须字段**：`full_id`（如 `PL-POLICY-APPEAL`）、`description`、`target_users`（目标用户角色列表）

#### PM（产品模块层级）

- 提取自技术视角 MS-* 服务列表，与 MS-* 一一对应
- **必须字段**：`full_id`（如 `PM-POLICY-APPEAL-CORE`）、`parent_id`（所属 PL 的 full_id）
- **禁止**：无 MS-* 对应的 PM-ID、单 MS-* 对应多个 PM-ID

#### FT（功能特性层级）

- 提取自用户操作提炼、API-* 接口分析
- **必须字段**：`full_id`、`parent_id`（所属 PM 的 full_id）、`description`、`invokes_api_ids`（调用的 API-ID 列表）、`acceptance_criteria`（验收标准列表）、`realizes_use_case_ids`（实现的 UC-ID 列表）
- **禁止**：无 API 绑定的 FT-ID、技术实现细节作为功能特性

#### UC（用例层级）

- 提取自 PRD 文档、用户场景文档、README.md 核心业务
- **禁止**：无 API 绑定的 UC-ID、单一技术操作作为用例

### 输出结构

产品视角使用**扁平数组**：

```json
{
  "schema_version": "2.1",
  "perspective": "product",
  "generated_at": "ISO-8601",
  "confidence": "high",
  "entities": [
    {
      "hierarchy": "PL", "id": "001",
      "full_id": "PL-POLICY-APPEAL",
      "alias": "PolicyAppealProduct", "name": "政策申诉产品",
      "description": "...",
      "target_users": ["快递网点操作员", "计费中心审核员", "财经中心"],
      "evidence_chain": [...],
      "cross_references": { "technical": ["SYS-001"], "business": ["BD-001"] }
    },
    {
      "hierarchy": "FT", "id": "001",
      "full_id": "FT-POLICY-APPEAL-LIFECYCLE",
      "parent_id": "PM-POLICY-APPEAL-CORE",
      "alias": "PolicyAppealLifecycle", "name": "申诉单生命周期",
      "description": "...",
      "invokes_api_ids": ["API-001", "API-002", "API-003", ...],
      "acceptance_criteria": ["申诉单创建后返回唯一申诉单号", "审核结果同步神州系统"],
      "realizes_use_case_ids": ["UC-001", "UC-002", "UC-003"],
      "evidence_chain": [...],
      "cross_references": { "product": ["PM-001", "PM-002"], "business": ["AB-001"] }
    },
    {
      "hierarchy": "UC", "id": "001",
      "alias": "CreatePolicyAppeal", "name": "发起政策申诉主单",
      "evidence_chain": [{ "source": "API-002 PolicyAppeal.create", "confidence": "high", "type": "api_reference" }],
      "cross_references": { "technical": ["API-002"], "product": ["PM-001"], "business": ["AB-001"] }
    }
  ],
  "metadata": { "total_products": 1, "total_modules": 9, "total_features": 3, "total_use_cases": 13, "total_entities": 26 }
}
```

---

## 跨视角依赖

```
技术视角 ─────────────────────────────────┐
  SYS → APP → MS → API                   │
                                          ▼
数据视角                              业务视角
  DS → ENT                     BD → BSD → BC → AGG → AB
                                   引用 MS-*    引用 API-*
                                          │
                                          ▼
                                    产品视角
                               PL → PM → FT → UC
                            引用 SYS-*  引用 MS-*  引用 API-*
```

---

## 通用字段说明

所有实体共享以下基础字段：

| 字段 | 必需 | 说明 |
|------|------|------|
| `hierarchy` | 是 | 层级标识（SYS/APP/MS/API/DS/ENT/BD/BSD/BC/AGG/AB/PL/PM/FT/UC） |
| `id` | 是 | 数字编码（001、002...），同层级唯一 |
| `alias` | 是 | 英文编码，机器可读标识 |
| `name` | 是 | 中文名称，面向业务阅读 |
| `evidence_chain` | 是 | 证据链数组，每项含 `source`、`confidence`、`type` |
| `cross_references` | 是 | 跨视角引用 |
| `full_id` | 推荐 | 目录风格规范 ID（如 `SYS-POLICY-APPEAL`） |
| `description` | 推荐 | 实体描述 |
| `parent_id` | 视情况 | 指向父层 full_id，表达层级归属 |

### metadata 节

每个 `*_knowledge.json` 尾部须包含 `metadata` 对象：

| 字段 | 说明 |
|------|------|
| `total_*` | 各层级实体数量统计 |
| `total_entities` | 全部实体总数 |
| `extraction_basis` | 提取依据说明 |
| `schema_notes` | Schema 格式备注 |
| `changes_from_previous` | 与前版差异说明（增量更新时填写） |
