# 应用知识库根目录（联邦单元模板）

物理路径：`applications/app-APPNAME/`。由 `scripts/knowledge-init.sh` 拷贝到目标工程的文档目录后，可将目录名改为实际应用名，并更新 `application_meta.yaml` 中 `template_directory` 等字段。

---

## 查阅顺序

1. 本目录 [APPNAME_INDEX.md](APPNAME_INDEX.md)（应用内导航与中央库指针）
2. [application_meta.yaml](application_meta.yaml)（机器可读根索引，与 `system/system_meta.yaml` 对照）
3. [knowledge/README.md](knowledge/README.md) 与各视角 `README.md`、`*_meta.yaml`
4. 中央库：[../../system/README.md](../../system/README.md)、[../../system/SYSTEM_INDEX.md](../../system/SYSTEM_INDEX.md)、[../../system/DESIGN.md](../../system/DESIGN.md)

---

## SDD 与联邦关系

| 位置 | 说明 |
|------|------|
| **本模板** | `knowledge/`、`requirements/`、`changelogs/` |
| **中央库** `system/` | `solutions/`、`analysis/`、全局 `knowledge/` 范本与阶段链 |

方案与分析一般在 **system/** 完成；本应用落地 **需求包** 与 **应用侧知识增量**，并通过 ID 与中央库对齐。详见 [APPNAME_INDEX.md](APPNAME_INDEX.md)「SDD 文档流」。

---

## 快速导航

| 文档 | 说明 |
|------|------|
| [application_meta.yaml](application_meta.yaml) | 联邦单元根 `*_meta.yaml` |
| [APPNAME_INDEX.md](APPNAME_INDEX.md) | 应用内索引、映射速查、中央库链接 |
| [knowledge/knowledge_meta.yaml](knowledge/knowledge_meta.yaml) | 知识树元数据 |
| [requirements/requirements_meta.yaml](requirements/requirements_meta.yaml) | 需求交付阶段元数据 |
| [changelogs/changelogs_meta.yaml](changelogs/changelogs_meta.yaml) | 变更日志元数据 |

---

## 初始化

- 从本仓库注入到目标工程：`scripts/knowledge-init.sh`（见 [scripts/README.md](../../scripts/README.md)）
- 拷贝后核对清单见脚本输出的 `post_init_checklist`
