# applications — 应用知识库

`applications/` 用于承载应用的联邦知识单元。  
它强调“与系统总库对齐并可独立演进”，不重复 `system/` 的全局规则描述。

## 你在这里要做什么

- 为应用建立或维护独立知识目录（`knowledge/`、`requirements/`、`changelogs/`）
- 通过统一命名与映射字段接入系统总库
- 在应用侧沉淀增量，再按治理流程回收至系统级知识库

## 核心入口

| 入口 | 用途 |
|------|------|
| [APPLICATIONS_INDEX.md](APPLICATIONS_INDEX.md) | 应用域总索引（权威） |
| [app-APPNAME/APPNAME_INDEX.md](app-APPNAME/APPNAME_INDEX.md) | 单应用模板索引与目录示例 |
| [app-APPNAME/application_meta.yaml](app-APPNAME/application_meta.yaml) | 应用根元数据样例 |

## 与系统库关系

- 系统级结构与映射原则： [../system/DESIGN.md](../system/DESIGN.md)
- 系统级接入与索引位置： [../system/SYSTEM_INDEX.md](../system/SYSTEM_INDEX.md)
- 应用初始化方式： [../scripts/README.md](../scripts/README.md)

> 应用侧文档可按业务节奏更新，但跨视角实体引用需保持与系统库一致。
