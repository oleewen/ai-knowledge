# 应用知识库 — 索引

本文件为 applications 的索引入口。结构与约定参照系统级知识库（见 `system/SYSTEM_INDEX.md`、`system/DESIGN.md`），应用侧在此基础上做最小必要的补充。

**单应用模板（本仓库）**：[应用知识库根目录/INDEX.md](./app-APPNAME/INDEX.md) — 内含完整 `knowledge/`、`requirements/`、`changelogs/` 树，与 `system/` 对齐后可由 `knowledge-init` 拷贝到目标工程（模板目录名 `applications/app-APPNAME/`）。

| 模板根元数据 | 说明 |
|--------------|------|
| [app-APPNAME/application_meta.yaml](./app-APPNAME/application_meta.yaml) | 联邦单元一级目录与中央库指针（与 `system/system_meta.yaml` 对照） |

---

## 一、应用知识结构

> 与 system 侧四视角保持一致；如需扩展，优先补充到 system（可复用）或在应用侧注明差异。下文路径以 **应用知识库根目录** 模板为例（链接目标为 `app-APPNAME/`；真实应用目录为 `applications/{你的应用名}/`）。

| 入口 | 说明 |
|------|------|
| [应用知识库根目录/application_meta.yaml](./app-APPNAME/application_meta.yaml) | 模板根目录索引（knowledge / requirements / changelogs） |
| [应用知识库根目录/knowledge/README.md](./app-APPNAME/knowledge/README.md) | 应用知识四视角与映射约定 |
| [应用知识库根目录/knowledge/knowledge_meta.yaml](./app-APPNAME/knowledge/knowledge_meta.yaml) | 知识树元数据 |
| [应用知识库根目录/knowledge/business/](./app-APPNAME/knowledge/business/) | 应用级业务域/子域/聚合（BD/BC/AGG） |
| [应用知识库根目录/knowledge/product/](./app-APPNAME/knowledge/product/) | 产品线/模块/功能点/用例（PL/PM/FT/UC） |
| [应用知识库根目录/knowledge/technical/](./app-APPNAME/knowledge/technical/) | 应用子系统、服务、接口（APP/MS） |
| [应用知识库根目录/knowledge/data/](./app-APPNAME/knowledge/data/) | 业务主数据、实体、数据字典（ENT/DS） |

*可根据实际情况删减/补充，所有ID须保持全局唯一，跨仓库可追溯。*

---

## 二、应用方案与需求 (solutions, analysis, requirements)

**本仓库应用模板**仅在 **应用知识库根目录**（`app-APPNAME/`）内提供 **需求交付**；solutions / analysis 一般在中央库 **system/**。

| 入口 | 说明 |
|------|------|
| [../system/solutions/README.md](../system/solutions/README.md) | 中央库解决方案阶段 |
| [../system/analysis/README.md](../system/analysis/README.md) | 中央库需求分析阶段 |
| [应用知识库根目录/requirements/README.md](./app-APPNAME/requirements/README.md) | 应用模板：需求交付（PRD/ADD/TDD 等） |
| [应用知识库根目录/requirements/requirements_meta.yaml](./app-APPNAME/requirements/requirements_meta.yaml) | 需求交付目录元数据 |
| [应用知识库根目录/changelogs/changelogs_meta.yaml](./app-APPNAME/changelogs/changelogs_meta.yaml) | 变更日志目录元数据 |
- 方案、分析与交付文档应按推荐命名与目录组织，便于与 system 映射与追踪；接口/数据规约放在各需求包 `specs/` 或 `knowledge/technical/`。

---

## 三、关联与治理信息

- 治理与命名：参考 `system/knowledge/constitution/`
- 映射字段：参考 `system/SYSTEM_INDEX.md`（映射速查）

---

## 四、快速导航与模板引用

- [README.md](./README.md)：applications 总览与入口
- [system/DESIGN.md](../system/DESIGN.md)
- [system/SYSTEM_INDEX.md](../system/SYSTEM_INDEX.md)
- [scripts/knowledge-init.sh](../scripts/knowledge-init.sh)

---
