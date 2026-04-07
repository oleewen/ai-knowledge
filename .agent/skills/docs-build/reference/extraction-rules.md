# 四视角提取规则详解

docs-build 的核心提取规则。按固定顺序执行：技术 → 数据 → 业务 → 产品。每个视角独立提取，后续视角可引用前序视角已提取的 ID。

输出文件统一使用 `{perspective}_knowledge.json`（schema_version 2.1）。完整 JSON 结构见 [../assets/knowledge-schema-template.json](../assets/knowledge-schema-template.json)。

---

## 1. 技术视角（Technical）

### 输入源

- 主 Index Guide
- AGENTS.md（模块定义，可选）
- 源代码（@GatewayApi、Controller、Dubbo 接口、MQ、Job 等）

### 提取规则

#### SYS（系统层级）

- 提取自 README.md 项目结构描述（若存在）
- 一个仓库通常对应一个 SYS-ID
- **必须字段**：`full_id`（目录风格，如 `SYS-BILLING-APPEAL`）、`description`、`architecture`（含 apps/external_dependencies/ddd_layers）

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
| `…Api` | 宿主类 SimpleName（如 `BillingAppealApi` → `BillingAppeal`） |
| `…ApiImpl` | 宿主类 SimpleName（如 `AppealService` → `Appeal`） |
| `…Controller` | 宿主类 SimpleName（如 `FeeAppealTaskController` → `FeeAppealTask`） |

- **同名合并**：相同宿主类或同义宿主类二选一（如 BillingAppeal、Appeal，选择 BillingAppeal）
- **必须字段**：`host_class`、`host_module`、`protocol`（HTTP/Dubbo/HTTP+Dubbo）
- **可选字段**：`merge_note`（合并说明）
- **禁止**：使用 Maven 模块名作为 MS-ID、单模块对应多个 MS-ID、使用包名尾段作为显示名

#### API（接口层级）

API 层级统一抽取四类入口：**Dubbo 接口、HTTP 接口、MQ 消息监听、定时任务（Job）**。

**通用必须字段**：`service_id`（所属 MS-ID）、`host_class`、`host_module`、`method_signature`、`api_type`（`DUBBO` | `HTTP` | `MQ_CONSUMER` | `JOB`）

**别名命名**：必须以所属 MS 别名为前缀，格式 `{MS别名}.{apiMethodAlias}`

##### Dubbo 接口

- **识别标准**：
  - 类标注 `@DubboService` / `@Service`（`org.apache.dubbo.config.annotation`）
  - 或 XML 配置 `<dubbo:service interface="...">`
  - 实现了以 `Api` / `Facade` / `Service` 后缀结尾的 RPC 接口
- **额外字段**：`dubbo_interface`（完整 FQCN）、`protocol`（固定 `Dubbo`）
- **注意**：仅提取 **Provider 端**，不提取 Consumer 端

##### HTTP 接口

- **识别标准**：
  - 类标注 `@Controller` / `@RestController`
  - 方法标注 `@RequestMapping` / `@GetMapping` / `@PostMapping` / `@PutMapping` / `@DeleteMapping`
  - 或 Gateway 路由配置中暴露的端点
- **额外字段**：`http_method`（GET/POST/PUT/DELETE）、`http_path`、`protocol`（固定 `HTTP`）

##### MQ 消息监听

- **识别标准**：
  - 类标注 `@RocketMQMessageListener` / `@KafkaListener` / `@RabbitListener` 等
  - 或实现 `MessageListenerConcurrently` / `MessageListenerOrderly` 等接口
  - 或在配置文件中注册为 Consumer
- **额外字段**：`topic`、`consumer_group`、`tag`（如有）、`protocol`（固定 `MQ`）
- **别名命名**：`{MS别名}.on{Topic简写}`（如 `BillingAppeal.onDealResult`）
- **注意**：仅提取 Consumer，不提取 Producer；多 Tag 时按 Tag 拆分为多条 API

##### 定时任务（Job）

- **识别标准**：
  - 方法标注 `@XxlJob("handlerName")` 或 `@Scheduled`
  - 或实现 `IJobHandler` / `Job`（Quartz）等接口
  - 或在调度平台配置中注册的任务处理器
- **额外字段**：`job_handler`（处理器名称）、`cron_expression`（如可获取）、`protocol`（固定 `JOB`）
- **别名命名**：`{MS别名}.job{HandlerAlias}`（如 `BillingAppeal.jobExpireCheck`）

### 输出结构

技术视角使用**分类结构**（非扁平数组），`entities` 下按 `systems`、`applications`、`services`、`apis` 分组。完整示例见 [../assets/knowledge-schema-template.json](../assets/knowledge-schema-template.json)。

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
- **必须字段**：`full_id`（如 `DS-BILLING-APPEAL-TIDB`）、`description`、`type`（如 `TiDB / MySQL 8.0+`）、`config_key`、`owned_by_app_id`
- **可选字段**：`notes`（如事务注解说明）

#### ENT（实体层级）

- 提取自 @Table 注解的实体类
- **必须字段**：`full_id`（如 `ENT-001`）、`parent_id`（所属 DS 的 full_id）、`logical_name`（Java 类名）、`physical_table`（数据库表名）
- **同表合并**：相同表名对应的实体类合并为一个 ENT-ID
- **禁止**：使用包名作为 ENT-ID、单表对应多个 ENT-ID、使用 Mapper 类名作为显示名

### 输出结构

数据视角使用**扁平数组**，DS 和 ENT 通过 `parent_id` 关联。完整示例见 [../assets/knowledge-schema-template.json](../assets/knowledge-schema-template.json)。

---

## 3. 业务视角（Business）

### 输入源

- 主 Index Guide
- AGENTS.md（业务域定义，可选）
- 源代码包结构（FQCN 分析）
- 技术视角已提取的 MS-* 服务

### 提取规则

#### BD（业务域层级）

- 提取自包路径域名首段、AGENTS.md 业务域定义
- **必须字段**：`full_id`（如 `BD-CHARGING-APPEAL`）、`description`、`strategic_classification`（core_domain/supporting/generic）、`children`（子域 full_id 列表）

#### BSD（业务子域层级）

- 提取自 BC 与 BD 间的包路径段
- **必须字段**：`full_id`、`parent_id`（所属 BD）、`description`、`bounded_contexts`（BC full_id 列表）
- **禁止**：将 BC 直接作为 BSD、跨业务域合并 BSD

#### BC（限界上下文层级）

- 提取自宿主类父包名、限界上下文包路径
- **必须字段**：`full_id`（如 `BC-BILLING-APPEAL-CORE`）、`parent_id`、`description`、`implemented_by_app_id`、`aggregates`（AGG full_id 列表）
- **可选字段**：`ubiquitous_language`（通用语言词汇表）
- **禁止**：使用 Maven 模块名作为 BC-ID、单包对应多个 BC-ID

#### AGG（聚合层级）

- 提取自 MS-* 服务、聚合根实体
- **必须字段**：`full_id`（如 `AGG-BILLING-APPEAL`）、`parent_id`（所属 BC）、`description`、`root_entity`、`entities`（值对象列表）、`persisted_as_entity_ids`（对应 ENT-ID）、`implemented_by_service_ids`（对应 MS-ID）、`abilities`（对应 AB full_id 列表）
- **可选字段**：`invariants`（业务不变量/约束列表）
- **禁止**：无 MS-* 对应的 AGG-ID、单 MS-* 对应多个 AGG-ID

#### AB（聚合边界层级）

- 提取自入口 API、聚合边界定义
- **必须字段**：`full_id`（如 `AB-APPEAL-LIFECYCLE`）、`parent_id`（所属 AGG）、`description`、`capability`（能力概述）、`apis`（结构化接口列表，每项含 `id`、`method`、`description`）
- **禁止**：无 API 对应的 AB-ID、AB 缺少能力概述

### 输出结构

业务视角使用**扁平数组**，通过 `hierarchy` 区分层级，`parent_id`/`children` 表达层级关系。完整示例见 [../assets/knowledge-schema-template.json](../assets/knowledge-schema-template.json)。

---

## 4. 产品视角（Product）

### 输入源

- 主 Index Guide
- 技术视角已提取的 SYS、MS、API，业务视角已提取的 BD、BSD、BC、AGG、AB
- README.md（产品概述、用户场景）
- PRD 文档（若有）

### 提取规则

#### PL（产品线层级）

- 提取自 README.md 产品概述、SYS-* 系统定义，与 SYS-* 一一对应
- **必须字段**：`full_id`（如 `PL-BILLING-APPEAL`）、`description`、`target_users`（目标用户角色列表）

#### PM（产品模块层级）

- 提取自技术视角 MS-* 服务列表，与 MS-* 一一对应
- **必须字段**：`full_id`（如 `PM-BILLING-APPEAL-CORE`）、`parent_id`（所属 PL）
- **禁止**：无 MS-* 对应的 PM-ID、单 MS-* 对应多个 PM-ID

#### FT（功能特性层级）

- 提取自用户操作提炼、API-* 接口分析
- **必须字段**：`full_id`、`parent_id`（所属 PM）、`description`、`invokes_api_ids`（调用的 API-ID）、`acceptance_criteria`（验收标准）、`realizes_use_case_ids`（实现的 UC-ID）
- **禁止**：无 API 绑定的 FT-ID、技术实现细节作为功能特性

#### UC（用例层级）

- 提取自 PRD 文档、用户场景文档、README.md 核心业务
- **禁止**：无 API 绑定的 UC-ID、单一技术操作作为用例

### 输出结构

产品视角使用**扁平数组**，PL→PM→FT→UC 通过 `parent_id` 关联。完整示例见 [../assets/knowledge-schema-template.json](../assets/knowledge-schema-template.json)。

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
| `full_id` | 推荐 | 目录风格规范 ID（如 `SYS-BILLING-APPEAL`） |
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
