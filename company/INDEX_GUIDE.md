---
type: Agent Index Guide
title: company 索引指南（INDEX_GUIDE）
---
# company 索引指南（INDEX_GUIDE）

> **最后更新**: 2026-06-22  
> **文档定位**: 面向 AI Agent 的 **`company/` 文档根**九章机器索引；描述公司知识库、五视角企业架构与 **`system-{name}/`** 镜像槽位。系统层实体见 [../system/](../system/)；应用层见 [../application/](../application/)。

---

## 一、项目概览（Project Overview）

### 1.1 速查表

| 组件 | 路径 | 描述 |
|------|------|------|
| 公司库人类入口 | [README.md](README.md) | 子目录表、阅读顺序 |
| 设计契约 | [DESIGN.md](DESIGN.md) | 目录边界、公司层 SSOT、同步闭环 |
| 架构入口 | [knowledge/README.md](knowledge/README.md) | 五视角索引 |
| OKF 根索引 | [index.md](index.md) | `okf_version: "0.1"` |
| 目录元数据 | [docs-meta.md](docs-meta.md) | Directory Meta |
| 联邦建联 | [knowledge-links.yaml](knowledge-links.yaml) | 系统建联登记 |
| 运维日志 | [changelogs/README.md](changelogs/README.md) | CHANGE-LOG、INDEXING-LOG |
| 仓库根全索引 | [../INDEX_GUIDE.md](../INDEX_GUIDE.md) | 中央库根地图 |
| 系统侧索引 | [../system/INDEX_GUIDE.md](../system/INDEX_GUIDE.md) | system 九章索引 |

### 1.2 元信息

- **目录角色**: **公司知识库** — 公司层 BD/CAP/PL/SYS/MDG/TPL SSOT、`knowledge/` 五视角叙事、`system-{name}/` 镜像槽位
- **技术栈**: Markdown、YAML（knowledge-links.yaml）
- **已跟踪文件规模**（仅 `company/` 前缀）: **72** 个文件（`git ls-files company/`，2026-06-22）
- **精读深度**: 本轮 **depth=3**

---

## 二、架构视图（Architecture View）

### 2.1 模块结构

```text
company/
├── README.md / INDEX_GUIDE.md / DESIGN.md / docs-meta.md / index.md
├── knowledge-links.yaml
├── knowledge/
├── solutions/ analysis/
├── system-SYSNAME/
└── changelogs/
```

### 2.2 文档目录

- **架构入口**: [knowledge/README.md](knowledge/README.md)
- **系统侧对照**: [../system/knowledge/README.md](../system/knowledge/README.md)

---

## 三、接口清单（Interface Catalog）

| 小节 | 状态 | 说明 |
|------|------|------|
| 3.1～3.4 | [未索引] | 无运行时 API |

---

## 四、模块依赖（Module Dependencies）

| 上游 | 下游 | 关系 |
|------|------|------|
| `company/knowledge/` | `system/knowledge/` | 公司层实体 SSOT |
| `company/solutions/` | `company/analysis/` | SDD 上游 |

---

## 五、详细索引（Detailed Index）

| 实体 | 路径 |
|------|------|
| BD-EXAMPLE | [knowledge/business/BD-EXAMPLE/BD-EXAMPLE.md](knowledge/business/BD-EXAMPLE/BD-EXAMPLE.md) |
| CAP-EXAMPLE-L1 | [knowledge/business/BD-EXAMPLE/CAP-EXAMPLE-L1.md](knowledge/business/BD-EXAMPLE/CAP-EXAMPLE-L1.md) |
| CAP-EXAMPLE | [knowledge/business/BD-EXAMPLE/CAP-EXAMPLE.md](knowledge/business/BD-EXAMPLE/CAP-EXAMPLE.md) |
| PL-EXAMPLE | [knowledge/product/PL-EXAMPLE.md](knowledge/product/PL-EXAMPLE.md) |
| SYS-EXAMPLE | [knowledge/application/SYS-EXAMPLE.md](knowledge/application/SYS-EXAMPLE.md) |
| MDG-EXAMPLE | [knowledge/data/MDG-EXAMPLE.md](knowledge/data/MDG-EXAMPLE.md) |
| TPL-EXAMPLE | [knowledge/technical/TPL-EXAMPLE.md](knowledge/technical/TPL-EXAMPLE.md) |

扫描索引：[knowledge/KNOWLEDGE_INDEX.md](knowledge/KNOWLEDGE_INDEX.md)

---

## 六、API / 字典边界（Boundaries）

overview 缓冲区：[knowledge/overview/NAME-overview.md](knowledge/overview/NAME-overview.md)

---

## 七、变更与运维（Operations）

[changelogs/README.md](changelogs/README.md)

---

## 八、技能与脚本（Skills & Scripts）

| 项 | 路径/命令 |
|----|----------|
| OKF 校验 | `bash scripts/validate-okf.sh --bundle company` |
| OKF 迁移 | `bash scripts/okf-migrate.sh`（须目标工程 `.docsconfig`） |
| docs-okf Skill | [../agent/skills/docs-okf/SKILL.md](../agent/skills/docs-okf/SKILL.md) |
| 测试套件 | `bash scripts/tests/docs-okf/run.sh`（resolve-okf-paths 门禁） |

---

## 九、附录（Appendix）

[viz.html](viz.html)

---

**索引元数据**: 本次运行 **mode=full**，**depth=3**，**since_ms=0**，输出 **company/INDEX_GUIDE.md**；运行记录见 [changelogs/INDEXING-LOG.md](changelogs/INDEXING-LOG.md)（2026-06-22）。
