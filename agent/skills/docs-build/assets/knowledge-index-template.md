# KNOWLEDGE_INDEX

> **最后更新**: {YYYY-MM-DD}
> **文档定位**: 四视角链上实体 ID 的唯一维护位置（SSOT）
> **Schema**: 对齐 `*_knowledge.json` schema_version 2.1

---

## §1 技术实体（Technical）

| 层级 | ID | Full ID | 别名（英文名） | 名称 | 证据链 |
|------|----|---------|--------------|------|--------|
| SYS | 001 | SYS-{NAME} | {SystemAlias} | {系统名称} | {证据来源} |
| APP | 001 | APP-{NAME} | {AppAlias} | {应用名称} | {启动类路径}; {pom.xml 模块} |
| APP | 002 | APP-{NAME} | {AppAlias} | {应用名称} | {启动类路径}; {pom.xml 模块} |
| MS | 001 | - | {ServiceAlias} | {服务名称} | {宿主类路径}; INDEX_GUIDE.md §3 |
| API | 001 | - | {MS别名}.{method} | {接口名称} | {类}#{行号}; {HTTP路径或Dubbo接口} |

---

## §2 数据实体（Data）

| 层级 | ID | Full ID | 别名（英文名） | 名称 | 证据链 |
|------|----|---------|--------------|------|--------|
| DS | 001 | DS-{NAME} | {DataSourceAlias} | {数据源名称} | {配置文件路径}:{配置键} |
| ENT | 001 | ENT-001 | {EntityAlias} | {实体名称}（{physical_table}） | @Table(name="{表名}"); {实体类路径} |

---

## §3 业务实体（Business）

| 层级 | ID | Full ID | 别名（英文名） | 名称 | 能力概述 | 证据链 |
|------|----|---------|--------------|------|----------|--------|
| BD | 001 | BD-{NAME} | {DomainAlias} | {业务域名称} | - | {包路径}; AGENTS.md §{章节} |
| BSD | 001 | BSD-{NAME} | {SubDomainAlias} | {子域名称} | - | {包路径段} |
| BC | 001 | BC-{NAME} | {ContextAlias} | {上下文名称} | - | {包路径}; MS-{id} 宿主类 |
| AGG | 001 | AGG-{NAME} | {AggregateAlias} | {聚合名称} | - | MS-{id} {服务类}; BC-{id} 所属上下文 |
| AB | 001 | AB-{NAME} | {BoundaryAlias} | {边界名称} | {能力描述} | API-{id} {方法}; AGG-{id} 所属聚合 |

---

## §4 产品实体（Product）

| 层级 | ID | Full ID | 别名（英文名） | 名称 | 证据链 |
|------|----|---------|--------------|------|--------|
| PL | 001 | PL-{NAME} | {ProductAlias} | {产品名称} | README.md §产品概述; SYS-{id} |
| PM | 001 | PM-{NAME} | {ModuleAlias} | {模块名称} | MS-{id} {服务名称} |
| FT | 001 | FT-{NAME} | {FeatureAlias} | {功能名称} | API-{id} {方法}; {用户操作} |
| UC | 001 | - | {UseCaseAlias} | {用例名称} | README.md §核心业务; API-{id} |
