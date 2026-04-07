---

## name: docs-archive  
description: >  
  将应用知识库上行归档到系统知识库。  
  支持增量锚点（archive-log.yaml）、按 scope 筛选、dry-run 与全量 --full。  
  当用户执行 /docs-archive、说「归档」「同步应用知识到系统库」「上行」「把实体/SDD 同步到 system」、  
  或应用更新后需刷新系统侧索引与契约时，务必使用本技能；  
  即使用户只说「同步一下」「把应用侧内容推上去」「更新系统库」，也应触发本技能。

# 应用 → 系统归档（docs-archive）

**术语**：**应用知识库根目录**指路径前缀 `applications/`（单应用为 `applications/app-{APPNAME}/`）。**系统知识库根目录**指路径前缀 `application/`。

把应用知识库根目录下 `applications/app-{APPNAME}/` 里已核实、允许进入系统侧的内容，按联邦规则写入系统知识库根目录 `application/` 下约定路径。成功后更新应用侧增量锚点，使下次从 changelog 断点继续。

> **系统知识库根目录**下与归档职责相关的 `application/` 全树区域，不是 `application/knowledge/` 的同义词。

## 输入与输出


| 类型   | 内容                                                                                              |
| ---- | ----------------------------------------------------------------------------------------------- |
| 硬输入  | 应用知识库根目录下 `applications/app-{APPNAME}/`（含可归档内容之一：`knowledge/`、`solutions/`、`requirements/`、`analysis/` 等） |
| 可选输入 | `--app`、`--scope`、`--since`、`--full`、`--dry-run` 参数                                             |
| 固定输出 | 系统知识库根目录 `application/` 下本次涉及文件；`application/changelogs/upstream-from-applications/ARCHIVE-{YYYYMMDD}-{简述}.md`     |
| 增量产出 | 更新应用知识库根目录下 `applications/app-{APPNAME}/changelogs/archive-log.yaml`                                     |
| 不产出  | 不生成根目录 `INDEX_GUIDE.md`；不擅自改应用 manifest 结构；不默认全量重写 `SYSTEM_INDEX.md`                            |


## 参数


| 参数          | 默认    | 说明                                                              |
| ----------- | ----- | --------------------------------------------------------------- |
| `--app`     | 全部    | 仅处理应用知识库根目录下 `applications/app-{NAME}/`                                  |
| `--scope`   | `all` | `all` | `knowledge` | `solutions` | `analysis` | `requirements` |
| `--since`   | 锚点    | 手动指定 changelog 起点（覆盖锚点）                                         |
| `--full`    | 否     | 全量重扫；可能覆盖系统侧已有内容，需人工确认                                          |
| `--dry-run` | 否     | 只列出将执行的动作，不落盘                                                   |


各 scope 对应的应用侧扫描路径与系统侧落点见 [reference/archive-spec.md](reference/archive-spec.md)。

## 工作流（四步）

### 步骤 0：确认范围

读取各应用 `changelogs/archive-log.yaml` 与 `CHANGELOG.md`，确定本次条目区间；无新条目且非 `--full` 则可跳过。

增量逻辑与锚点格式见 [reference/archive-log-spec.md](reference/archive-log-spec.md)。

### 步骤 1：提取

按 changelog 区间与 `--scope`，从应用目录收集待上行项（路径级即可，不必通读全库）。

变更发现方式（git diff / 清单驱动 / 全量快照）见 [reference/archive-spec.md](reference/archive-spec.md)。

### 步骤 2：写入系统知识库根目录（`application/`）

- **先读再写**：打开将修改的系统侧文件及相邻 `*_meta.yaml`，确认已有 ID 与结构。
- **多类型同一批次**：严格按 `knowledge → solutions → analysis → requirements` 顺序，避免 `parent` 断链。
- knowledge 用**提炼**规则；SDD 目录用**直接/整包**规则。

字段级映射、操作细则与归档顺序原因见 [reference/federation-spec.md](reference/federation-spec.md)。

### 步骤 3：记录与锚点

1. 生成批次文档 `application/changelogs/upstream-from-applications/ARCHIVE-{YYYYMMDD}-{简述}.md`（格式见 [reference/archive-spec.md](reference/archive-spec.md)）。
2. **上述写入与批次文档均已成功后**，调用锚点更新脚本：

```bash
.agent/skills/docs-archive/scripts/update-archive-log.sh \
  --app APPNAME \
  --app-id APP-ID \
  --changelog-id v1.3.0 \
  --changelog-time "2026-04-05 10:00" \
  --archive-file "application/changelogs/upstream-from-applications/ARCHIVE-20260405-xxx.md"
```

锚点原子性规则见 [reference/archive-log-spec.md](reference/archive-log-spec.md)。

### 步骤 4：自检

执行 [reference/federation-spec.md](reference/federation-spec.md) §六质量自检；对照 [gotchas.md](gotchas.md) 完整清单。

## 核心约束


| 约束           | 说明                                                   |
| ------------ | ---------------------------------------------------- |
| 增量默认         | 以锚点为准，避免重复晋升同一 changelog 区间                          |
| 锚点原子性        | 系统知识库根目录侧写入失败则不更新 `archive-log.yaml`                  |
| knowledge 边界 | 契约与 ID，不整段复制应用侧长文                                    |
| ID 不可变       | 禁止改已有实体 id；新增须全局唯一                                   |
| 归档顺序         | knowledge → solutions → analysis → requirements，不可乱序 |
| 导航同步         | 变更影响全局入口时，同步 `SYSTEM_INDEX.md` 或相关 `README.md`       |


## 依赖关系


| 类型   | 技能/组件           | 说明                       |
| ---- | --------------- | ------------------------ |
| 可选前置 | `docs-fetch`    | 先拉应用镜像再归档                |
| 可选前置 | `docs-build`    | 先强化应用侧资产再归档              |
| 无关联  | `docs-indexing` | 本技能不替代根目录 INDEX_GUIDE 生成 |


## 参考


| 资源                                        | 路径                                                             | 何时读                    |
| ----------------------------------------- | -------------------------------------------------------------- | ---------------------- |
| 系统侧范围、scope 落点、变更发现、批次文档格式                | [reference/archive-spec.md](reference/archive-spec.md)         | 步骤 0–1 定范围、步骤 3 写批次文档时 |
| 联邦层级、knowledge 提炼、SDD 直接归档、归档顺序、操作细则、质量自检 | [reference/federation-spec.md](reference/federation-spec.md)   | 步骤 2 写入时，多类型顺序不确定时     |
| archive-log.yaml 格式、增量逻辑、锚点更新时机           | [reference/archive-log-spec.md](reference/archive-log-spec.md) | 步骤 0 读锚点、步骤 3 更新锚点时    |
| 锚点/ID/联邦边界陷阱与完整自查清单                       | [gotchas.md](gotchas.md)                                       | 步骤 4 自检，遇到异常时          |
| 参考文档总览                                    | [reference/README.md](reference/README.md)                     | 不确定去哪找规范时              |
| 锚点更新脚本                                    | [scripts/update-archive-log.sh](scripts/update-archive-log.sh) | 步骤 3 更新锚点时             |


