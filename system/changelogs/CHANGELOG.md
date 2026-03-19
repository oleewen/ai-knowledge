> **模板示例**：本文件为知识库模板示例，实际项目请按需替换内容与 ID。

# Changelog

记录 **system/** 文档体系（导航、模板链接、构建工作流说明等）的维护性变更；业务实体内容变更请在提交说明或 ADR 中另行说明。

## [未发布]

### 2026-03-19

- **标识**：在 `system/` 与 `applications/` 下全部 Markdown、YAML、JSON/JSONL、`.gitkeep` 中统一标注「模板示例」（文首说明块、YAML 首行注释或 JSON 字段 `template_example`），便于区分示例骨架与生产内容。
- **导航**：修正 `system/INDEX.md`、`system/CONTRIBUTING.md` 中指向仓库根 `.ai/` 的相对路径（`./.ai/` → `../.ai/`），避免从 `system/` 内打开链接时断链。
- **索引**：`system/INDEX.md` 新增「七、全库构建与索引（AI 工作流）」，链向 `knowledge-build` Skill、根目录 `INDEX.md` / `README.md` / `AGENTS.md` 与本目录变更记录。
- **约定**：在本仓库执行 `/knowledge-build` 时，**Doc Root** 与根 [README.md](../README.md) 一致，系统级知识库体系统辖 **`system/`**（含 `knowledge/`、`solutions/`、`analysis/`、`requirements/`、`specs/` 等）。
