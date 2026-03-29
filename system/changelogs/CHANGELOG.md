# Changelog

记录 **system/** 文档体系（导航、模板链接、构建工作流说明等）的维护性变更；业务实体内容变更请在提交说明或 ADR 中另行说明。

## [未发布]

### 2026-03-22

- **导航**：根目录索引以 **`INDEX_GUIDE.md`** 为准；根 `INDEX.md`、`README`、`AGENTS`、`system/`、applications 模板与相关 Skill 链接已对齐。
- **导航**：`applications/INDEX.md` 正文迁至 **`applications/APPLICATIONS_INDEX.md`**；保留 `applications/INDEX.md` 短入口；根 `INDEX`/`README`/`AGENTS` 与相关 Skill 链接已对齐。
- **导航**：`system/INDEX.md` 正文迁至 **`system/SYSTEM_INDEX.md`**；根目录保留 `system/INDEX.md` 短入口；全库与脚本、meta、Skill 链接已对齐。

### 2026-03-21

- **结构**：移除中央库 `system/specs/` 目录；规约统一落在各 `requirements/REQUIREMENT-*/…/specs/` 或 `knowledge/technical/`；已同步 `system_meta`、`INDEX`/`README`、`DESIGN`、applications 模板与相关 Skill 表述。

### 2026-03-20（Skill 表述修正）

- **约定**：明确 `/document-change`、`/document-indexing` 为 **Skill**（`.ai/skills/<name>/SKILL.md`），**非** `scripts/` 可执行脚本；已同步 `document-indexing`、`document-change` SKILL、根 `README`/`AGENTS`/`INDEX`、`system/changelogs/README`、`system/SYSTEM_INDEX` §七。

### 2026-03-20（document-indexing 重跑）

- **索引**：根目录 `INDEX.md` 文首元信息按技能约定更新（生成时间、Mode 3 全量、`indexing-log.jsonl` 指针）；追加 `system/changelogs/indexing-log.jsonl` 运行记录一行。

### 2026-03-20

- **结构**：按根目录 `README.md` / `AGENTS.md` / `INDEX.md` 对齐，重写 `system/README.md`、`INDEX.md`、`DESIGN.md`、`CONTRIBUTING.md` 与各阶段 `README.md`；统一 SDD 步骤表述与索引分工说明。
- **导航**：修正四视角 `README` 中「根目录 INDEX」链接（区分 `system/SYSTEM_INDEX.md` 与仓库根 `INDEX.md`）；新增 `specs/README.md`、`changelogs/README.md`。
- **索引**：`system/SYSTEM_INDEX.md` 去除已不存在的业务示例路径，改为元数据锚点 + 现存示例目录描述。
- **根 INDEX**：`INDEX.md` §2.1 / §3.2 / §6 / §7 与 `system/README`「快速导航」对齐；§3.2 拆为顶层与阶段子目录两表；§6 区分 changelogs 入口与工具产出未精读范围。

### 2026-03-19

- **标识**：在 `system/` 与 `applications/` 下全部 Markdown、YAML、JSON/JSONL、`.gitkeep` 中统一标注（文首说明块、YAML 首行注释或 JSON 字段 `template_example`），便于区分示例骨架与生产内容。
- **导航**：修正 `system/SYSTEM_INDEX.md`、`system/CONTRIBUTING.md` 中指向仓库根 `.ai/` 的相对路径（`./.ai/` → `../.ai/`），避免从 `system/` 内打开链接时断链。
- **索引**：`system/SYSTEM_INDEX.md` 新增「七、全库构建与索引（AI 工作流）」，链向 `knowledge-build` Skill、根目录 `INDEX.md` / `README.md` / `AGENTS.md` 与本目录变更记录。
- **约定**：在本仓库执行 `/knowledge-build` 时，**Doc Root** 与根 [README.md](../../README.md) 一致，系统级知识库体系统辖 **`system/`**（含 `knowledge/`、`solutions/`、`analysis/`、`requirements/` 等；规约随各需求包 `specs/`）。
