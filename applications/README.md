# 应用知识库 (Applications Knowledge Repository)

本目录存放各应用/微服务的**应用级知识库与交付文档**，结构与命名遵循系统级规范，并与系统总库协同更新。

## 快速导航

| 文档                                   | 说明                                              |
| -------------------------------------- | ------------------------------------------------- |
| **[applications/APPLICATIONS_INDEX.md](APPLICATIONS_INDEX.md)** | 应用知识结构、方案与需求、治理信息导航（权威入口） |
| **[applications/app-APPNAME/APPNAME_INDEX.md](app-APPNAME/APPNAME_INDEX.md)** | 单应用联邦单元示例（`knowledge/`、`requirements/`、`changelogs/`；物理路径 `applications/app-APPNAME/`） |
| **[applications/app-APPNAME/application_meta.yaml](app-APPNAME/application_meta.yaml)** | 模板根 `*_meta.yaml`（与 `system/system_meta.yaml` 对照） |

## 关键入口（建议阅读顺序）

- [applications/APPLICATIONS_INDEX.md](APPLICATIONS_INDEX.md)（应用域总览与索引）
- [applications/app-APPNAME/APPNAME_INDEX.md](app-APPNAME/APPNAME_INDEX.md)（应用模板索引）
- [system/DESIGN.md](../system/DESIGN.md)（系统级目录结构与元模型）
- [system/SYSTEM_INDEX.md](../system/SYSTEM_INDEX.md)（系统级索引与映射字段）
- 初始化脚本与说明：`scripts/knowledge-init.sh`、`scripts/README.md`
