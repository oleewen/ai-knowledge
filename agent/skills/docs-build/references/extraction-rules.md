# 五视角提取规则

顺序：应用 → 数据 → 业务 → 产品 → 技术。各视角独立产出；后序只**引用**前序 ID。

输出：各实体 per-entity `{ID}.md`（OKF concept + YAML frontmatter；schema 2.1 字段语义）。结构参考 [knowledge-schema-template.json](../assets/knowledge-schema-template.json) 与 [consolidation-spec.md](consolidation-spec.md)「concept 文件形状」。

## 目录

- [1. 应用视角（Application）](#1-应用视角application)
  - [SLN（解决方案层级）](#sln解决方案层级)
  - [SYS（系统层级）](#sys系统层级)
  - [APP（应用层级）](#app应用层级)
  - [MS（微服务层级）](#ms微服务层级)
  - [API（接口层级）](#api接口层级)
- [2. 数据视角（Data）](#2-数据视角data)
  - [MDG（主数据域层级）](#mdg主数据域层级)
  - [DS（数据源层级）](#ds数据源层级)
  - [ENT（实体层级）](#ent实体层级)
  - [TBL（数据表层级）](#tbl数据表层级)
- [3. 业务视角（Business）](#3-业务视角business)
  - [VC（价值链层级）](#vc价值链层级)
  - [CAP（业务能力层级）](#cap业务能力层级)
  - [BD（业务域层级）](#bd业务域层级)
  - [BSD（业务子域层级）](#bsd业务子域层级)
  - [BL（业务线层级）](#bl业务线层级)
  - [BS（业务服务层级）](#bs业务服务层级)
  - [BC（限界上下文层级）](#bc限界上下文层级)
  - [AGG（聚合层级）](#agg聚合层级)
  - [AB（聚合边界层级）](#ab聚合边界层级)
- [4. 产品视角（Product）](#4-产品视角product)
  - [PL（产品线层级）](#pl产品线层级)
  - [PD（产品服务层级）](#pd产品服务层级)
  - [BP（业务流程层级）](#bp业务流程层级)
  - [BSP（业务子流程层级）](#bsp业务子流程层级)
  - [PM（产品模块层级）](#pm产品模块层级)
  - [FT（功能特性层级）](#ft功能特性层级)
  - [FR（功能需求层级）](#fr功能需求层级)
  - [BR（业务规则层级）](#br业务规则层级)
  - [UC（用例层级）](#uc用例层级)
- [5. 技术视角（Technical）](#5-技术视角technical)
  - [TPL（技术平台层级）](#tpl技术平台层级)
  - [TSD（技术域层级）](#tsd技术域层级)
  - [MW（中间件绑定）](#mw中间件绑定)
  - [CMP（组件）](#cmp组件)
- [跨视角依赖](#跨视角依赖)
- [通用字段说明](#通用字段说明)

---

## 1. 应用视角（Application）

### 输入源

- 主 Index Guide
- 解决方案边界（SLN）
- AGENTS.md（模块定义，可选）
- 源代码（@GatewayApi、Controller、Dubbo 接口、MQ、Job 等）

### 提取规则

#### SLN（解决方案层级）

- 提取自解决方案边界；解决方案层首次定义；一仓一条
- **必须字段**：`id`、`description`、`maps_to`（PL，一对一）
- **可选关系**：`implemented_by`（BP）

#### SYS（系统层级）

- 提取自 README.md 项目结构描述（若存在）
- 一个仓库通常对应一个 SYS-ID
- **必须字段**：`id`（目录风格，如 `SYS-BILLING-APPEAL`）、`description`、`implements_to`（所属 SLN）、`implemented_by`（APP）
- **可选关系**：`maps_to`（PD）、`uses_to`（MDG\|TSD）
- **详细说明可选**：架构（应用、外部依赖、分层）。缺了不算提取失败

#### APP（应用层级）

- 提取自启动类所在 Maven 模块
- 识别标准：
  - 包含 `main(String[] args)` 方法
  - 调用 `Main.run()` 或 `SpringApplication.run()`
  - 配置 `spring-boot-maven-plugin`
- **必须字段**：`id`、`description`、`implements_to`（所属 SYS）、`implemented_by`（MS）
- **可选关系**：`supports_to`（BC）、`uses_to`（DS）
- **详细说明可选**：启动类、Maven 模块、MQ 消费者、定时任务、仓库地址。缺了不算提取失败

#### MS（微服务层级）

- 识别标准：须能定位宿主类
- 命名规则：SimpleName 去后缀
- 聚类方式：按 APIs 宿主类

**MS 生成规则**：

| 宿主类模式 | 别名生成方式 |
|-----------|-------------|
| `…Api` | 宿主类 SimpleName（如 `BillingAppealApi` → `BillingAppeal`） |
| `…ApiImpl` | 宿主类 SimpleName（如 `AppealService` → `Appeal`） |
| `…Controller` | 宿主类 SimpleName（如 `FeeAppealTaskController` → `FeeAppealTask`） |

- **同名合并**：相同宿主类或同义宿主类二选一（如 BillingAppeal、Appeal，选择 BillingAppeal）
- **必须字段**：`id`、`description`、`implements_to`（所属 APP）
- **可选关系**：`maps_to`（AGG）、`uses_to`（ENT）
- **详细说明可选**：宿主类、宿主模块、协议、合并说明。缺了不算提取失败
- **禁止**：使用 Maven 模块名作为 MS-ID、单模块对应多个 MS-ID、使用包名尾段作为显示名

#### API（接口层级）

API 层级统一抽取四类入口：**Dubbo 接口、HTTP 接口、MQ 消息监听、定时任务（Job）**。

**通用必须字段**：`id`、`description`、`implements_to`（所属 MS）

**可选关系**：`supports_to`（FT）、`maps_to`（UC）

**详细说明可选**：宿主类、宿主模块、方法签名、入口类型，以及协议、路径、Topic、Cron。缺了不算提取失败

**别名命名**：必须以所属 MS 别名为前缀，格式 `{MS别名}.{apiMethodAlias}`

##### Dubbo 接口

- **识别标准**：
  - 类标注 `@DubboService` / `@Service`（`org.apache.dubbo.config.annotation`）
  - 或 XML 配置 `<dubbo:service interface="...">`
  - 实现了以 `Api` / `Facade` / `Service` 后缀结尾的 RPC 接口
- **可写入详细说明**：接口全名、协议。缺了不算提取失败
- **注意**：仅提取 **Provider 端**，不提取 Consumer 端

##### HTTP 接口

- **识别标准**：
  - 类标注 `@Controller` / `@RestController`
  - 方法标注 `@RequestMapping` / `@GetMapping` / `@PostMapping` / `@PutMapping` / `@DeleteMapping`
  - 或 Gateway 路由配置中暴露的端点
- **可写入详细说明**：HTTP 方法、路径、协议。缺了不算提取失败

##### MQ 消息监听

- **识别标准**：
  - 类标注 `@RocketMQMessageListener` / `@KafkaListener` / `@RabbitListener` 等
  - 或实现 `MessageListenerConcurrently` / `MessageListenerOrderly` 等接口
  - 或在配置文件中注册为 Consumer
- **可写入详细说明**：Topic、消费组、Tag、协议。缺了不算提取失败
- **别名命名**：`{MS别名}.on{Topic简写}`（如 `BillingAppeal.onDealResult`）
- **注意**：仅提取 Consumer，不提取 Producer；多 Tag 时仍是一条 API，Tag 写入详细说明

##### 定时任务（Job）

- **识别标准**：
  - 方法标注 `@XxlJob("handlerName")` 或 `@Scheduled`
  - 或实现 `IJobHandler` / `Job`（Quartz）等接口
  - 或在调度平台配置中注册的任务处理器
- **可写入详细说明**：处理器名、Cron、协议。缺了不算提取失败
- **别名命名**：`{MS别名}.job{HandlerAlias}`（如 `BillingAppeal.jobExpireCheck`）

### 输出结构

应用视角：解决方案层 SLN 落 `application/{id}.md`；系统层每个 SYS/APP/MS 各一 `{ID}.md`；应用层每个 API 落 `application/{MS}/{id}.md`（缺 MS 父级不落盘）。frontmatter 用 okf-spec 的 9 个字段。宿主类、协议等分类说明写入详细说明。详见 [knowledge-schema-template.json](../assets/knowledge-schema-template.json) 与 [consolidation-spec.md](consolidation-spec.md)。

---

## 2. 数据视角（Data）

### 输入源

- 主 Index Guide
- 主数据划分（MDG）
- 多数据源配置文件
- @Table 注解的实体类
- DDL（TBL）
- MyBatis XML 映射文件

### 提取规则

#### MDG（主数据域层级）

- 提取自解决方案主数据划分；解决方案层首次定义；一个 SLN 可有多条
- **必须字段**：`id`、`description`
- **禁止**：用 MDG 代替 DS 或 ENT

#### DS（数据源层级）

- 提取自 `application.yml/properties` 多数据源配置
- **必须字段**：`id`（如 `DS-BILLING-APPEAL-TIDB`）、`description`、`implements_to`（所属 MDG）
- **可选关系**：`implemented_by`（ENT）、`used_by`（APP）
- **详细说明可选**：存储类型、配置键、事务注解。缺了不算提取失败

#### ENT（实体层级）

- 提取自 @Table 注解的实体类
- **必须字段**：`id`、`description`、`implements_to`（所属 DS）
- **可选关系**：`maps_to`（AGG）
- **详细说明可选**：类名、物理表名。缺了不算提取失败
- **同表合并**：相同表名对应的实体类合并为一个 ENT-ID
- **禁止**：使用包名作为 ENT-ID、单表对应多个 ENT-ID、使用 Mapper 类名作为显示名

#### TBL（数据表层级）

- 提取自 @Table / DDL 的物理表
- **必须字段**：`id`、`description`、`implements_to`（所属 ENT）
- **禁止**：缺 ENT 父级仍落盘；一张物理表拆成多条 TBL

### 输出结构

数据视角：解决方案层 MDG 落 `data/{id}.md`；系统层每个 DS/ENT 各一 `{ID}.md`；应用层每个 TBL 落 `data/{ENT}/{id}.md`（缺 ENT 父级不落盘）。详见 [knowledge-schema-template.json](../assets/knowledge-schema-template.json) 与 [consolidation-spec.md](consolidation-spec.md)。

---

## 3. 业务视角（Business）

### 输入源

- 主 Index Guide
- 公司/解决方案叙事（VC、CAP、BL、BS）
- AGENTS.md（业务域定义，可选）
- 源代码包结构（FQCN 分析）

### 提取规则

#### VC（价值链层级）

- 提取自公司价值链叙事、商业模式资料
- **必须字段**：`id`（如 `VC-ORDER-FULFILLMENT`）、`description`；可选 `supported_by`（BD）、`implemented_by`（CAP）
- **禁止**：把组织部门直接当 VC；CAP 与 VC 混用

#### CAP（业务能力层级）

- 提取自公司业务能力；公司层首次定义
- **必须字段**：`id`、`description`、`implements_to`（所属 VC）
- **可选关系**：`mapped_by`（BSD-L1）
- 落 `business/{VC}/{id}.md`（缺 VC 父级不落盘）

#### BD（业务域层级）

- 提取自包路径域名首段、AGENTS.md 业务域定义
- **必须字段**：`id`（如 `BD-CHARGING-APPEAL`）、`description`、`children`（BSD-L1 id 列表）；可选 `supports_to`（VC）

#### BSD（业务子域层级）

- 一级提取自公司业务版图：`level: 1`、`parent` 所属 BD，公司层落盘；可选 `maps_to`（CAP）
- 二级提取自解决方案业务服务：`level: 2`、`parent` 所属 BSD-L1，解决方案层落盘；可选 `mapped_by`（BS）
- 三级提取自系统限界上下文之上：`level: 3`、`parent` 所属 BSD-L2，系统层落盘；可选 `implemented_by`（BC）
- **必须字段**：`id`、`level`、`parent`、`description`；可选：一级 `maps_to`（CAP）、二级 `mapped_by`（BS）、三级 `implemented_by`（BC）
- **禁止**：四级及以下 BSD、将 BC 直接作为 BSD、跨 BSD-L1 合并 BSD-L2、BC 挂到 BSD-L2

#### BL（业务线层级）

- 提取自公司业务线；公司层首次定义
- **必须字段**：`id`、`description`、`maps_to`（BSD-L1，一对一）
- 落 `business/BL/{id}.md`

#### BS（业务服务层级）

- 提取自解决方案业务服务；解决方案层首次定义
- **必须字段**：`id`、`description`、`maps_to`（BSD-L2，一对一）
- **可选关系**：`mapped_by`（PD）
- 落 `business/BS/{id}.md`

#### BC（限界上下文层级）

- 提取自宿主类父包名、限界上下文包路径
- **必须字段**：`id`（如 `BC-BILLING-APPEAL-CORE`）、`description`、`implements_to`（所属 BSD-L3）、`implemented_by`（AGG id 列表）；可选 `supported_by`（APP）
- **详细说明可选**：通用语言。缺了不算提取失败
- **禁止**：使用 Maven 模块名作为 BC-ID、单包对应多个 BC-ID

#### AGG（聚合层级）

- 提取自聚合根实体
- **必须字段**：`id`（如 `AGG-BILLING-APPEAL`）、`description`、`implements_to`（所属 BC）、`implemented_by`（AB id 列表）；可选 `mapped_by`（ENT 或 MS）
- **详细说明可选**：不变量。缺了不算提取失败

#### AB（聚合边界层级）

- 提取自入口 API、聚合边界定义
- **必须字段**：`id`（如 `AB-APPEAL-LIFECYCLE`）、`description`、`implements_to`（所属 AGG）；可选 `mapped_by`（UC）
- **详细说明可选**：能力概述。缺了不算提取失败

### 输出结构

业务视角：公司层每个 VC/BD/BL/BSD-L1/CAP 各一 `{ID}.md`；解决方案层每个 BSD-L2、BS 各一 `{ID}.md`；系统层每个 BSD-L3/BC/AGG/AB 各一 `{ID}.md`；同类树用 `parent`/`children`（另 BSP→BP），组成链用 `implements_to`/`implemented_by`（见 [glossary § 映射关系](../../../knowledge/glossary.md#映射关系常用)）。详见 [knowledge-schema-template.json](../assets/knowledge-schema-template.json) 与 [consolidation-spec.md](consolidation-spec.md)。

---

## 4. 产品视角（Product）

### 输入源

- 主 Index Guide
- 应用视角已提取的 SLN、SYS、MS、API，业务视角已提取的 BD、BSD、BL、BS、BC、AGG、AB
- README.md（产品概述、用户场景）
- PRD 文档（若有）

### 提取规则

#### PL（产品线层级）

- 提取自解决方案产品线章；解决方案层首次定义
- **必须字段**：`id`（如 `PL-BILLING-APPEAL`）、`description`、`maps_to`（BL，一对一）
- **详细说明可选**：目标用户。缺了不算提取失败

#### PD（产品服务层级）

- 提取自产品架构、解决方案边界；`implements_to` 所属 PL；`maps_to` BS（一对一）；**PD 解决方案层首次定义**
- **必须字段**：`id`（如 `PD-BILLING-APPEAL`）、`description`、`implements_to`（所属 PL）、`maps_to`（BS）
- 公司/系统/应用不落 PD 首次定义；`PM.implements_to` 引用解决方案 `PD-*`（有联邦 parent 则 HTTP，否则纯 ID）

#### BP（业务流程层级）

- 提取自解决方案业务流程；解决方案层首次定义；一个 SLN 一条
- **必须字段**：`id`、`description`、`implements_to`（所属 SLN）
- **可选关系**：`children`（BSP）
- 落 `product/BP/{id}.md`

#### BSP（业务子流程层级）

- 提取自业务流程下的子流程；解决方案层首次定义
- **必须字段**：`id`、`description`、`parent`（所属 BP）、`implements_to`（所属 PD）
- **详细说明可选**：子流程种类（core / branch / exception）。缺了不算提取失败
- 落 `product/BP/{id}.md`

#### PM（产品模块层级）

- 提取自产品功能分解；系统层首次定义。`implements_to` 所属解决方案 PD
- **必须字段**：`id`（如 `PM-BILLING-APPEAL-CORE`）、`description`、`implements_to`（所属 PD）、`implemented_by`（FT）；可选 `maps_to`（BC）、`depends_to`（其它 PM）
- **禁止**：`implements_to` 直挂 PL

#### FT（功能特性层级）

- 提取自用户操作提炼、API-* 接口分析
- **必须字段**：`id`、`description`、`implements_to`（所属 PM）、`implemented_by`（FR）
- **详细说明可选**：验收标准。缺了不算提取失败
- **禁止**：技术实现细节作为功能特性；FT↔UC 直连

#### FR（功能需求层级）

- 提取自功能点下的需求条目
- **必须字段**：`id`、`description`、`implements_to`（所属 FT）、`implemented_by`（UC|BR）
- **禁止**：FT↔UC 直连；UC 或 BR 越过 FR 直挂 FT

#### BR（业务规则层级）

- 提取自功能需求上的约束
- **必须字段**：`id`、`description`、`implements_to`（所属 FR）

#### UC（用例层级）

- 提取自 PRD 文档、用户场景文档、README.md 核心业务
- **必须字段**：`id`、`description`、`implements_to`（所属 FR）；可选 `maps_to`（AB）
- **禁止**：单一技术操作作为用例

### 输出结构

产品视角：解决方案层 PL、PD、BP、BSP 各一 `{ID}.md`（PD 位于 `PL/`，BSP 位于 `BP/`）；系统层 PM/FT/FR/UC/BR 各一 `{ID}.md`；组成链 PM → FT → FR → UC/BR，经 `implements_to`/`implemented_by`（跨层纯 ID 或 HTTP）。详见 [knowledge-schema-template.json](../assets/knowledge-schema-template.json) 与 [consolidation-spec.md](consolidation-spec.md)。

---

## 5. 技术视角（Technical）

### 输入源

- 主 Index Guide
- 公司平台（TPL）
- 解决方案技术选用（TSD）
- `application.yml` / Nacos 等配置（数据源、Redis、Kafka、MQ）
- `pom.xml` / `build.gradle`（关键依赖 allowlist）
- 解决方案层已登记的 **TSD-***（引用）

### 提取规则

#### TPL（技术平台层级）

- 提取自公司技术平台准入；公司层首次定义
- **必须字段**：`id`、`description`
- 落 `technical/{id}.md`
- **禁止**：APP↔TPL 直连

#### TSD（技术域层级）

- 提取自解决方案技术选用与例外；解决方案层首次定义
- **必须字段**：`id`、`description`、`implements_to`（所属 TPL）
- 落 `technical/{id}.md`

#### MW（中间件绑定）

- 提取自配置与部署绑定：数据源、缓存、MQ Topic/Group、注册配置等
- **必须字段**：`id`、`description`、`implements_to`（TSD）；可选 `used_by`（APP）、`uses_to`（DS）
- **详细说明可选**：绑定类型、配置键。缺了不算提取失败
- **禁止**：将 MS/API 宿主类登记为 MW；Consumer 类仍在 API 层；APP↔TPL 直连

#### CMP（组件）

- 提取自 Maven 依赖 allowlist（Dubbo、MyBatis、Redis、Kafka Client、关键 Spring Starter 等）
- **必须字段**：`id`、`description`、`maven_coordinates`、`implements_to`（MW）
- **禁止**：全量依赖扫描导致 CMP 爆炸；APP↔CMP 直连

### 输出结构

技术视角：公司层 TPL 落 `technical/{id}.md`；解决方案层 TSD 落 `technical/{id}.md`；应用层 MW 落 `technical/{id}/{id}.md`，CMP 落 `technical/{MW}/{id}.md`（缺 MW 父级不落盘）。

---

## 跨视角依赖

跨视角边以 [okf-spec.md](../../../knowledge/okf-spec.md) §4.1 的选含为准。下图只画各视角内的链：

```
应用  SLN → SYS → APP → MS → API
数据  MDG → DS → ENT → TBL
业务  BD → BSD-L1 → BSD-L2 → BSD-L3 → BC → AGG → AB
产品  BL ↔ PL → PD → PM → FT → FR → UC/BR
      BP → BSP
技术  TPL → TSD → MW → CMP
```

---

## 通用字段说明

所有实体的 frontmatter 用 okf-spec 的 9 个字段：

| 字段 | 必需 | 说明 |
|------|------|------|
| `type` | 是 | OKF type |
| `title` | 是 | 标题 |
| `description` | 是 | 实体描述 |
| `tags` | 是 | 标签 |
| `timestamp` | 是 | 时间戳 |
| `id` | 是 | 唯一实体 ID（如 `SYS-BILLING-APPEAL`） |
| `perspective` | 是 | 视角 |
| `hierarchy` | 是 | 层级标识 |
| `layer_scope` | 是 | 层范围 |

证据写在「依据与证据」。跨视角写在「跨视角」。`alias`、`name`、`evidence_chain`、`cross_references` 不是必须字段。

### metadata 与统计（可选）

每个 per-entity concept **必须**含上述 9 个 frontmatter 字段。

**统计**（各层级计数、`extraction_basis`、`schema_notes`、`changes_from_previous`）为可选：可写入 `--emit-report` 的 `extraction_report.md` 或 `agent/knowledge/{perspective}-meta.md` 备注；**不**再要求单独的 `{perspective}-entities.md` 统计节。

| 字段 | 说明 |
|------|------|
| `total_*` | 各层级实体数量统计 |
| `total_entities` | 全部实体总数 |
| `extraction_basis` | 提取依据说明 |
| `schema_notes` | Schema 格式备注 |
| `changes_from_previous` | 与前版差异说明（增量更新时填写） |
