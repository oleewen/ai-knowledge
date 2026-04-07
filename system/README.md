# 系统知识库（顶层 `system/`）

本目录为 **目标态下的「系统知识库」语义**：组织级视图、架构文档与 **`application-{name}/`** 联邦槽位（后续可通过 fetch 同步应用镜像）。

> 四视角实体、阶段交付（solutions/analysis/requirements）等 **SSOT** 在仓库 **[`../application/`](../application/)**。

## 子目录

| 路径 | 说明 |
|------|------|
| [`constitution/`](constitution/README.md) | 系统级宪法与治理：术语边界、槽位约定；与 `application/constitution/` 职责划分见该目录 README |
| [`architecture/`](architecture/README.md) | 业务 / 产品 / 系统 / 数据 架构文档（子结构可演进） |
| [`application-APPNAME/`](application-APPNAME/README.md) | 占位槽位；真实应用名替换 `APPNAME`，内容可由 fetch 填入 |

初始化与参数约定见仓库根 [`docs/superpowers/specs/2026-04-07-knowledge-layout-v2-design.md`](../docs/superpowers/specs/2026-04-07-knowledge-layout-v2-design.md)。
