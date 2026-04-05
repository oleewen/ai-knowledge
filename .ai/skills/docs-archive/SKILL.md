---
name: docs-archive
description: >
  应用知识库归档与系统知识库上行同步：汇总应用侧变更记录（归档），并将经核实的有效信息按联邦原则补充进系统级知识库（上行）。
  当用户执行 /docs-archive、需要归档应用知识变更、将应用侧实体同步到系统库、
  做知识库上行同步、或应用代码更新后需要更新系统知识索引时，务必使用本技能。
  即使用户只说"同步一下应用知识"、"归档一下变更"、"把应用的实体更新到系统库"，也应触发本技能。
---

# 知识归档与系统库同步（docs-archive）

两件事：**（一）应用知识库变更归档**；**（二）应用有效信息上行补充系统知识库**。可同一次执行，也可分步。

## 适用前提

- **应用侧**：以 `applications/README.md`、`applications/APPLICATIONS_INDEX.md` 为准——联邦单元、`manifest.yaml`、全局唯一 ID（`APP-*`、`MS-*`、`ENT-*` 等）
- **系统侧**：以 `system/knowledge/README.md`、`system/CONTRIBUTING.md`、`system/DESIGN.md`、`system/SYSTEM_INDEX.md` 为准——四视角 YAML/_meta、跨视角仅 ID 引用、单一事实源（SSOT）

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 应用知识库路径（联邦模式：`applications/*/`；独立模式：`application/`） |
| 可选输入 | Git 基线（提交号/标签）、用户指定变更文件列表、应用 `manifest.yaml`、各视角 `*_meta.yaml` |
| 步骤一产出 | `system/changelogs/upstream-from-applications/ARCHIVE-{YYYYMMDD}-{简述}.md`；应用内 `CHANGELOG.md` 或 `promotion-notes.md` |
| 步骤二产出 | 更新后的 `system/knowledge/` 各视角文件；必要时更新 `system/SYSTEM_INDEX.md` |
| 不产出 | 不生成 INDEX_GUIDE、不修改应用侧 manifest、不重建知识库结构 |

## 工作流（四步）

### 步骤 0：确认执行范围

与用户确认：**仅归档** / **仅上行** / **归档 + 上行**；确认应用列表与可选 Git 基线。

### 步骤 1：归档——汇总应用知识变更

发现变更（Git diff / 用户清单 / 全量快照，择一或组合），按应用分节生成批次归档文档。

归档范围、变更发现方式与产物格式见 [reference/archive-spec.md](reference/archive-spec.md)。

### 步骤 2：上行——补充系统知识库

以步骤一的归档清单或用户指定文件为输入，按联邦映射表将应用侧有效信息写入系统库对应文件。

**先读再写**：打开拟修改的系统文件与相邻 `*_meta.yaml`，确认现有 ID，再写入。

联邦原则、映射表与撰写规则见 [reference/federation-spec.md](reference/federation-spec.md)。

### 步骤 3：质量自检

- 新增/修改的 YAML 可被解析；无断链 ID
- 应用独有细节仍保留在应用库；系统库无大段与 manifest 重复的冗余正文
- 变更影响全局导航时，已同步更新 `system/SYSTEM_INDEX.md` 或对应视角 `README.md`

完整自查清单见 [gotchas.md](gotchas.md)。

## 核心约束

| 约束 | 说明 |
|------|------|
| 联邦边界 | 应用库放细节，系统库放契约与 ID 映射；禁止整段复制 |
| 只增不改 ID | 已有实体禁止改 id；新增 ID 须全局唯一 |
| 交叉引用仅 ID | 关联字段只写 ID，不写重复长描述 |
| 冲突以 manifest 为准 | 应用侧与系统侧冲突时，以代码与 manifest 为准或标为待人工确认 |
| 先读再写 | 打开系统文件确认现有 ID 后再写入，禁止盲写 |

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 协作 | `docs-build` | 应用侧知识实体提取；上行前可先运行 docs-build 确保应用侧 JSON 最新 |
| 协作 | `docs-indexing` | 系统库从零构建时的前置步骤 |

## 参考

| 资源 | 路径 | 何时读 |
|------|------|--------|
| 联邦原则与映射规范 | [reference/federation-spec.md](reference/federation-spec.md) | 步骤 2 上行时，不确定映射落点时 |
| 归档范围与产物格式 | [reference/archive-spec.md](reference/archive-spec.md) | 步骤 1 归档时 |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) | 遇到 ID/引用/联邦边界相关问题时 |
| 应用侧约定 | `applications/README.md`、`applications/APPLICATIONS_INDEX.md` | 确认联邦单元与 manifest 约定时 |
| 系统侧约定 | `system/CONTRIBUTING.md`、`system/DESIGN.md` | 确认系统库写入规范时 |
