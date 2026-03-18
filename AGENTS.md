# AI AGENTS 开发指南

## 角色与行为

你是一位熟悉文档工程与知识库治理的专家。

- **先思考后动笔：** 在生成大量文档或修改前，先理解项目结构与规范，再落笔；涉及多文件时先确认范围。
- **保持简洁：** 直接输出内容，少客套；仅在逻辑复杂时补充说明。
- **先阅读：** 修改任何被引用的文件前，务必先阅读其内容或通过本仓库文档/索引定位。

---

## 项目概述

**ai-sdd-docs** 是企业级软件系统的**全局知识底座**仓库，用于管理架构与知识体系（业务/产品/技术/数据四视角、解决方案、需求分析与需求交付文档）。本仓库不包含业务应用代码，以 Markdown、YAML 与 Shell 脚本为主。完整使用说明与初始化方式见 `README.md`。

---

## 关键路径

- **仓库入口与初始化：** `README.md`、`scripts/sdx-init.sh`、`scripts/README.md`
- **系统知识库：** `system/README.md`、`system/INDEX.md`、`system/DESIGN.md`
- **知识库主体：** `system/knowledge/`（constitution、business、product、technical、data）
- **阶段文档：** `system/solutions/`、`system/analysis/`、`system/requirements/`、`system/specs/`
- **规范与模板：** `.ai/CONVENTIONS.md`、`.ai/rules/`（含 `agents-template.md`）
- **Agent 技能与命令：** `.cursor/skills/`、`.cursor/README.md`（Slash 命令表）、`.ai/skills/`

---

## 技术栈

- **文档格式：** Markdown、YAML（_meta.yaml、实体定义）
- **脚本：** Bash 5+（`sdx-init`、`sdx-init-bootstrap`）
- **版本与协作：** Git；规范遵从 `.ai/rules/` 与 `.ai/CONVENTIONS.md`

---

## 命令

```bash
# 从 Git 拉取并对当前目录执行 SDD 初始化（需在目标项目目录执行）
curl -sL "https://raw.githubusercontent.com/oleewen/ai-sdd-docs/main/scripts/sdx-init-bootstrap.sh" | bash -s -- [选项]

# 已克隆本仓库时，在目标目录执行
cd /path/to/your-project
REPO_ROOT=/path/to/ai-sdd-docs /path/to/ai-sdd-docs/scripts/sdx-init.sh [选项]

# 常用选项：--mode=standalone|federation、--ds=knowledge|full、--as=no-solution-analysis|full、--agents=cursor,trea、--skills=all、--force、--dry-run
```

详见 `scripts/README.md`。

---

## 开发规范

- **规范索引与摘要：** 见 `.ai/CONVENTIONS.md`（编码/设计/测试/文档/解决方案/需求分析/需求交付、项目特定约束）。
- **文档与知识库：** 遵循 `system/DESIGN.md` 的目录约定与 ID 命名（`knowledge/constitution/standards/naming-conventions.md`）；跨视角仅通过 ID 引用，不重复定义。
- **提交与分支：** 遵从 Conventional Commits；提交信息格式：`<类型>: <描述>`（如 `docs: 更新 system/INDEX 索引`）；类型含 feat、fix、docs、refactor、chore 等。

---

## 工作流规则

- 采用 OpenSpec SDD 开发规范：澄清需求与设计优先于实现；变更与设计见 `system/` 与 `.ai/rules/`。
- 修改文档前先阅读相关 README、INDEX、DESIGN 与 CONTRIBUTING，保持与现有目录和映射一致。
- 做最小化、聚焦的修改；涉及 knowledge 映射时，确保 ID 引用有效、无断链。
- 新增或调整解决方案/需求分析/需求交付时，遵循对应模板（`.ai/rules/solution/`、`analysis/`、`requirement/`）与技能（`.ai/skills/sdx-*`、`.cursor/README.md`）。

---

## 禁止事项

- 禁止随意修改 `system/knowledge/` 下已有实体的 **ID** 或破坏跨视角 **ID 引用**（如 `implemented_by_app_id`、`persisted_as_entity_ids`），除非同步更新所有引用处。
- 禁止在未阅读 `system/DESIGN.md` 与 `CONTRIBUTING.md` 的前提下新增 knowledge 实体或 ADR。
- 禁止删除或改写 `.ai/rules/`、`.ai/skills/`、`.cursor/skills/` 中模板与技能的核心结构，除非约定变更已记录（如 ADR）。
- 禁止在未确认影响面的情况下修改 `system/INDEX.md`、`system/README.md` 的导航与索引表，导致链接或表格错位。

---

## 参考文档

- **项目概述与初始化：** `README.md`、`scripts/README.md`
- **系统知识库与索引：** `system/README.md`、`system/INDEX.md`、`system/DESIGN.md`、`system/CONTRIBUTING.md`
- **规范与模板：** `.ai/CONVENTIONS.md`、`.ai/rules/`（含 `agents-template.md`）
- **Cursor 命令与技能：** `.cursor/README.md`、`.cursor/skills/`
