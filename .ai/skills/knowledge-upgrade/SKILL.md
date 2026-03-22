---
name: knowledge-upgrade
description: >
  应用级知识库增量升级：在 applications/应用名 或 **应用知识库根目录**（模板 `app-APPNAME/`）工程目录内，更新应用知识库
  先做 document-indexing 索引，再按该应用 INDEX、knowledge 各 README 与模板格式选择性阅读工程代码/文档，
  提炼并回写更新现有知识文档。不含全库 AGENTS/README 初始化（无第二阶段）。使用 /knowledge-upgrade。
---

# 知识库升级（应用联邦单元）

在 **单个应用工程** 或 **主库 `applications/<应用>/`** 目录内，对已有应用知识库做 **提炼、归纳、增量更新**，不替代系统级 `knowledge-build` 的全仓初始化流程。

## 适用范围

| 形态 | 典型路径 | 说明 |
|------|----------|------|
| **主库内应用目录** | `applications/your-app/` | 与 [applications/README.md](../../../applications/README.md) 一致 |
| **独立应用仓库** | 根目录或 `app-your-app/` 等命名 | 用户指定 **应用知识根**（常为 sdx-init 的 `--dd` 目标，如 `docs/system`） |
| **命名约定** | **应用知识库根目录**（本仓库模板为 `app-APPNAME/`） | 与业务约定的应用前缀一致即可；以用户给出的 **工作区根路径** 为准 |

执行前须明确：**(1) 应用根路径**（代码与文档所在仓库根或 `applications/xxx`）**(2) 应用知识库根**（含 `PROJECT_INDEX.md` / `INDEX.md`、`knowledge/` 或与 [applications/INDEX.md](../../../applications/INDEX.md) 结构等价的目录）。

## 工作要求

- 模型要足够强；精读工程源码/配置时遵循 **零幻觉**：Index §6 未覆盖处写入前须补读或标注待核实。
- **严格遵从应用侧已有文档结构**：优先读取并遵守以下文件中的约定（若存在）：
  - **`PROJECT_INDEX.md`** / **`INDEX.md`**（应用/仓库全局入口，结构参考主库 [applications/INDEX.md](../../../applications/INDEX.md)）
  - **`knowledge/README.md`** 及各视角子目录 `README.md`
  - **`application/knowledge/knowledge_meta.yaml`、`application/manifest.yaml`**（及各阶段目录下的 `{scope}_meta.yaml` / `manifest.yaml`）
  - 应用内 **`.ai/rules/`**、设计/需求模板中对段落、字段的说明
- 更新时 **最小必要 diff**：保留已有 ID 与交叉引用；新增实体须符合应用命名规范与全局唯一性说明。
- 维护 **`MS-*` / technical** 时与 **`.cursor/skills/knowledge-extract/SKILL.md` §8.1.1～§8.1.2** 对齐：**仅**由 **API/MQ/Job 等宿主类** 聚类得 MS；**禁止**以 **Maven 模块名** 建 MS 或作为 MS 分条依据（模块 → **`APP-*`** / `dependencies`）。

## 入口判断：阶段一是否已完成

检测应用知识库或应用根下是否存在落盘 Index（如 `docs/INDEX-GUIDE.md`、`INDEX-GUIDE.md` 等，路径以应用实际为准）。

**若已存在**：

1. 展示检测结果。
2. **询问用户**：**重新执行阶段一**（重做 document-indexing）还是 **跳过阶段一**（沿用现有 Index 进入阶段三）。

**若无 Index**：直接执行阶段一。

---

### 第一阶段：文档索引（document-indexing）

**完整遵循** `.cursor/skills/document-indexing/SKILL.md`，作用域为 **应用工作区**（代码 + 配置 + 应用文档）：

1. 与用户确认 **read_mode 1 / 2 / 3**（升级场景建议 **read_mode ≥ 2**，以便 §4/§5 支撑配置与数据流更新）。
2. 产出标准 **七段 Index Guide**。
3. **附加要求**：
   - §2 / §3 显式包含 **应用知识库根** 下各视角与 `solutions/`、`analysis/`、`requirements/`、各需求包内 `specs/`（若存在）的路径与角色。
   - Index 建议落盘至应用内便于复用路径（如 `docs/INDEX-GUIDE.md` 或应用约定目录），并在会话中保留全文供阶段三使用。

---

### 第二阶段：按应用格式归纳并回写

**不**对工程无差别通读。以 **阶段一 Index** 为主导航，并 **先读透应用侧格式契约**：

1. 阅读 **`PROJECT_INDEX.md`** / **`INDEX.md`**（以仓库实际落盘为准），明确各表格与章节对应的维护责任。
2. 阅读 **`knowledge/`** 下各 `README.md` 与代表性元数据 YAML（系统库为 `business_meta.yaml`、`product_meta.yaml`、`knowledge_meta.yaml`、各视角 `*_meta.yaml` 等；应用侧为 `knowledge_meta.yaml` 等同模式的 `{scope}_meta.yaml`）、实体文件，掌握 **YAML/Markdown 字段与 ID 规则**。
3. 按 Index §3 **选择性精读** ⭐⭐⭐ 及与本次升级目标相关的源码、OpenAPI、迁移脚本、变更说明等。
4. **回写策略**（择一或组合，由用户目标决定）：
   - **补缺**：INDEX 或 knowledge 中已列但内容为空、过时的条目。
   - **同步**：将代码中已变更的接口、配置、模块边界反映到 technical/data 视角文档。
   - **归纳**：将散落 commit/CHANGELOG/设计草稿中的工程结论写入 solutions/specs 或对应知识实体说明（不改变模板字段名除非应用规范允许）。
5. **禁止**：编造未读文件的行为；随意修改已有实体 **ID**；破坏 `manifest.yaml` 与主库联邦字段语义（仅按应用内说明更新）。

---

### 第三阶段：检查与质量验证

- **结构**：产出仍符合应用 **PROJECT_INDEX.md** / **INDEX.md** 导航与 **knowledge/** 目录约定。
- **可追溯**：重要变更新增内容可注明依据路径（或 Index §3 条目）。
- **一致性**：对照 Index §3，核心模块在应用知识文档中有反映；§6 盲区若在文档中被断言，须已补读或已删除武断表述。
- **ID 与引用**：元数据 YAML（含各阶段 `{scope}_meta.yaml` 与各视角索引/实体 `*_meta.yaml`）、`manifest`、实体文件间引用完整；与主库 `system/knowledge` 的关联 ID 若存在，不得无故断开。

---

## 参考

- **索引方法**：`.cursor/skills/document-indexing/SKILL.md`
- **全库从零构建**（含 AGENTS/README）：`.cursor/skills/knowledge-build/SKILL.md`
- **应用联邦约定**：[applications/README.md](../../../applications/README.md)、[applications/INDEX.md](../../../applications/INDEX.md)
- **系统设计**：[system/DESIGN.md](../../../system/DESIGN.md)、[system/CONTRIBUTING.md](../../../system/CONTRIBUTING.md)
