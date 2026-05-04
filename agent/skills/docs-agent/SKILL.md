---
name: docs-agent
description: >
  当用户执行 /docs-agent、需要初始化或更新仓库根目录 README.md（人类）与 AGENTS.md（AI 契约）、做仓库 onboarding、
  或入口文档与 INDEX 不同步时，必须使用本技能。以落盘 INDEX_GUIDE.md 为唯一地图，三文件职责不重叠。
  即使用户只说「帮我写个 README」「更新一下 AGENTS」「整理一下项目文档入口」，也应触发。
  若用户已明确要求仅跑 /docs-indexing、仅 docs-build、仅 docs-upgrade 或 SDD/docs-distill/docs-extract 等，则不要以本技能为主路径，应分流到对应技能。
---

# 仓库入口文档（docs-agent）

本技能以「调度器」方式工作：先完成步骤 0 范围对齐与门禁，再按阶段读取规范文件，经落盘 INDEX 驱动生成根目录 `README.md` / `AGENTS.md`。

**主要读者**：维护仓库协作入口的工程师与 Agent。索引维护留给 **`docs-indexing`**；知识实体构建留给 **`docs-build`**。

---

## 适用边界

- **本技能负责**：根目录 `README.md`、`AGENTS.md`；以 INDEX 为地图的最小阅读集；`--output` / `--mode`；步骤 0 参数确认书；与 INDEX 对齐的目录树与指针；`validate-guide.sh` 校验。
- **本技能不负责**：生成或重写 `INDEX_GUIDE.md`（须单独 `/docs-indexing`）；`application/knowledge` 实体提取（`docs-build`）；术语批量替换（`docs-upgrade`）；SDD 与 docs-distill/extract/archive 主流程。
- **边界分流**：用户只要更新索引地图 → `docs-indexing`；只要实体与 KNOWLEDGE_INDEX → `docs-build`；入口双文件已由本技能覆盖时不要重复主路径。

---

## 输入与前置检查

执行前最少确认：

- 落盘 **INDEX** 是否存在（默认门禁）；例外仅见 `references/execution-spec.md` 未命中节。
- 用户目标含 **`--output`**（`readme` / `agents` / `both`）与 **`--mode`**（`create` / `update`），或可走快速路径由自然语言唯一推断。
- 已 `source` 共享引导并得到 **`REPO_ROOT`** / **`DOC_ROOT`**（见 `references/workflow.md` 步骤 1）。

---

## 执行路由（先读后写）

1. **门禁与参数对齐**：先读 `references/gates.md`
2. **步骤节奏与 Index 引导命令**：再读 `references/workflow.md`
3. **Index 解析、探索策略、错误处理**：读 `references/execution-spec.md`
4. **三文件去重**：不确定内容归属时读 `references/three-file-spec.md`
5. **验收清单与反模式**：落盘前读 `references/quality-standards.md`
6. **执行层陷阱**：对话易错时读 `gotchas.md`
7. **模板与骨架**：`assets/readme-skeleton.md`、`assets/agents-skeleton.md`

---

## 门禁要求（必须执行）

- 写入或覆盖根目录 `README.md` / `AGENTS.md` 前，须完成步骤 0 参数确认书与用户 **C / S**（或等价明确同意）；禁止未确认即覆盖。细节见 `references/gates.md` 与 [agent/rules/CONVENTIONS.md](../../rules/CONVENTIONS.md) 中等风险说明。

---

## 产出与校验

- **固定输出**：`{REPO_ROOT}` 下 `README.md`、`AGENTS.md`（由 `--output` 限定范围时可只写其一）。
- 落盘后执行：

  ```bash
  bash agent/skills/docs-agent/scripts/validate-guide.sh --root .
  ```

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`（含 `expected_output` 与 `assertions`）
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 依赖关系

| 类型 | 技能/组件     | 说明                          |
| ---- | --------- | --------------------------- |
| 前置 | `docs-indexing` | INDEX 须已落盘；更新 INDEX 请单独运行 |
