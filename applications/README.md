# 应用知识库 (Applications Knowledge Repository)

本目录存放各应用/微服务的**应用级知识库与交付文档**，结构与命名遵循系统级规范，并与系统总库协同更新。

## 快速导航

| 文档                                   | 说明                                              |
| -------------------------------------- | ------------------------------------------------- |
| **[知识索引](./INDEX.md)**                  | 应用内知识与交付全局导航，索引各核心文档               |
| **[应用知识库根目录 · 模板索引](./app-APPNAME/INDEX.md)** | 单应用联邦单元示例（`knowledge/`、`requirements/`、`changelogs/`；物理路径 `applications/app-APPNAME/`） |
| **[application_meta.yaml](./app-APPNAME/application_meta.yaml)** | 模板根 `*_meta.yaml`（与 `system/system_meta.yaml` 对照） |

## 关键入口（建议阅读顺序）

- [应用知识库根目录/INDEX.md](./app-APPNAME/INDEX.md)（应用模板索引）
- [applications/INDEX.md](./INDEX.md)（应用域总览）
- [system/DESIGN.md](../system/DESIGN.md)（系统级目录结构与元模型）
- [system/INDEX.md](../system/INDEX.md)（系统级索引与映射字段）
- 初始化脚本与说明：`scripts/sdx-init.sh`、`scripts/README.md`
