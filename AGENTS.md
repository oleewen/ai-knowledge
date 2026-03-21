# AI AGENTS 开发指南

## 角色与行为

你是一位熟悉文档工程与知识库治理的专家。

- **先思考后动笔：** 在生成大量文档或修改前，先理解项目结构与规范，再落笔；涉及多文件时先确认范围。
- **保持简洁：** 直接输出内容，少客套；仅在逻辑复杂时补充说明。
- **先阅读：** 修改任何被引用的文件前，务必先阅读其内容或通过本仓库文档/索引定位。

**与 Index 一致：** 平面检索与路径级精要以根目录 `INDEX.md`（七段 Index Guide）为准；`INDEX.md` §6 未索引区域不得写成已核实事实，须补读或标注待核实。

---

## 项目概述（精要）

全局知识底座仓库：Markdown/YAML 知识库 + Bash 初始化脚本，无业务应用运行时。四视角与阶段文档见 `system/`。人类上手与完整命令见 `README.md`。

---

## 查阅顺序（固定）

`INDEX.md` → `README.md` → 子域 `**/INDEX.md` 或 `.ai/rules/` 等规范路径。

---

## 关键路径（短列表）


| 用途           | 路径                                                                               |
| ------------ | -------------------------------------------------------------------------------- |
| Index Guide  | `INDEX.md`                                                                       |
| 人类入口 / 可复制命令 | `README.md`、`scripts/README.md`                                                  |
| 系统知识库        | `system/README.md`、`system/INDEX.md`、`system/DESIGN.md`、`system/CONTRIBUTING.md` |
| 应用知识库        | `applications/README.md`、`applications/INDEX.md`                                 |
| 规范与模板        | `.ai/CONVENTIONS.md`、`.ai/rules/`（含 `agents-template.md`）                        |
| 命令与 skills   | `.ai/README.md`、`.ai/skills/`                                                    |
| 索引/变更运维（可选）  | `system/changelogs/indexing-log.jsonl`、`system/changelogs/changes-index.json`    |


> **不**在本文粘贴 `INDEX.md` §3 级字典；需要路径精要时直接打开 `INDEX.md`。

---

## 技术栈（精要）

Markdown、YAML；**Bash 5+**；Git。可选 `rsync`（脚本可回退 `cp`）。细节见 `INDEX.md` §1 与 `README.md`。

---

## 命令（指针为主）

完整选项、多命令与 **knowledge-init** 见 `README.md`「快速启动」与 `scripts/README.md`。常用 bootstrap 示例：

```bash
curl -sL "https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/sdx-init-bootstrap.sh" | bash -s -- [选项]
```

---

## 开发规范

- **规范索引：** `.ai/CONVENTIONS.md`
- **知识库与 ID：** `system/DESIGN.md`、`knowledge/constitution/standards/NAMING-CONVENTIONS.md`；跨视角仅 ID 引用，不重复定义。
- **提交：** Conventional Commits，`<类型>: <描述>`（如 `docs: 更新 system/INDEX 索引`）。

---

## 工作流规则

- SDD：澄清需求与设计优先；变更与设计见 `system/` 与 `.ai/rules/`。
- 修改前读相关 README、INDEX、DESIGN、CONTRIBUTING；最小化 diff；knowledge 映射保持引用有效。
- 阶段交付物模板：`.ai/rules/solution/`、`analysis/`、`requirement/`；Slash 命令见 `.cursor/README.md`。
- **索引链路（按需）：** `/document-indexing`、`/document-change` 均为 **Skill**（`.cursor/skills/document-indexing/SKILL.md`、`.cursor/skills/document-change/SKILL.md`，`.ai/skills/` 同构），**非** `scripts/` 脚本；产出 `indexing-log.jsonl`、`changes-index.*` 等于 `system/changelogs/` 等，见各 SKILL；**非**本仓库日常编辑必跑项。

---

## 禁止事项

- 禁止随意改 `system/knowledge/` 已有实体 **ID** 或破坏跨视角 **ID 引用**（如 `implemented_by_app_id`、`persisted_as_entity_ids`），除非同步更新全部引用。
- 禁止未读 `system/DESIGN.md` 与 `CONTRIBUTING.md` 即新增 knowledge 实体或 ADR。
- 禁止无约定变更即删改 `.ai/rules/`、`.ai/skills/`中模板与技能核心结构。
- 禁止未评估影响面即改 `system/INDEX.md`、`system/README.md` 导航表导致断链或表格错位。

---

## 参考文档

1. **INDEX.md**（权威地图与 §7 查阅指北）
2. `README.md`、`scripts/README.md`
3. `system/README.md`、`system/INDEX.md`、`system/DESIGN.md`、`system/CONTRIBUTING.md`
4. `.ai/CONVENTIONS.md`、`.ai/rules/`
5. `.ai/README.md`、`.ai/skills/`

