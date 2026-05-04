---
name: docs-change
description: >
  当用户执行 /docs-change、需要生成或更新变更聚合 `CHANGE-LOG.md`、从 git/CHANGELOG/本地 mtime 做增量基线追踪、或下游 docs-indexing/docs-build 需要变更输入时，必须使用本技能。
  从 git commit、CHANGELOG/CHANGE-LOG、本地文件修改时间三维度采集变更，落盘为 Markdown：`CHANGE-LOG.md`（文末 HTML 注释承载增量基线）。
  即使用户只说「记录一下最近的改动」「生成变更日志」「哪些文件改了」「帮我看看最近改了什么」，也应触发。
  若用户已明确要求只做 docs-indexing（生成或更新 INDEX_GUIDE）、docs-build 实体提取、docs-archive 视角归档等为主路径，则不要以本技能为唯一主流程，应分流到对应技能。
---

# docs-change：文档变更聚合

本技能以「调度器」方式工作：先判定是否应由 `docs-change` 处理，再按 `references/` 规范执行多源采集与 `CHANGE-LOG.md` 更新，保证文末基线可被下游增量消费。

---

## 适用边界

- **本技能负责**：`CHANGE-LOG.md`（或用户指定 `--output` 下）多源聚合、时间统一、倒序插入、文末 `<!-- docs-change:baseline_time_ms=... -->` 维护。
- **本技能不负责**：生成或更新 `INDEX_GUIDE.md`、知识实体与 `KNOWLEDGE_INDEX`、overview 归档、全库定向替换（分别为 **docs-indexing**、**docs-build**、**docs-archive**、**docs-upgrade**）。
- **分流**：用户只要索引地图或只要扫描文档树时，以 **docs-indexing** 为主；变更列表为本技能的**输入侧协作**而非替代索引技能。

---

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 代码库根目录 |
| 可选输入 | `--since` 时间基准、`--output` 输出目录；增量基线取自已有 `CHANGE-LOG.md` 文末注释 |
| 固定输出 | `{output_dir}/CHANGE-LOG.md`（Markdown；人类可读 + 文末基线注释） |
| 不产出 | 不生成 `INDEX_GUIDE`、不修改知识实体、不更新 README/AGENTS |

### 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--since` | 否 | 自动 | 变更起始时间（`yyyy-MM-dd HH:mm:ss.SSS` 或 epoch ms） |
| `--output` | 否 | `./changelogs/` | 输出目录（优先级：用户指定 > `./changelogs/` > `./{DOC_DIR}/changelogs/`） |

时间基准优先级：`--since` 参数 > `CHANGE-LOG.md` 文末 `baseline_time_ms` > 默认值 `2020-01-01`。

---

## 前置确认（可选）

当**时间基准不清**、**输出目录多候选**、或用户声明**只采某一来源**时，须先与用户确认再继续。默认无歧义时可按 [references/gates.md](references/gates.md) 与 [references/workflow.md](references/workflow.md) 直接执行。

细则（仅 Git、多目录仲裁等）见 [references/gates.md](references/gates.md)「前置确认与歧义处理」。

---

## 执行路由（先读后写）

1. **边界与歧义**：先读 `references/gates.md`
2. **五步流程与脚本**：再读 `references/workflow.md`
3. **输出目录与三源规则**：读 `references/collection-rules.md`
4. **baseline / cutoff 语义**：不确定时读 `references/core-concepts.md`
5. **原则层**：对齐粒度时读 `references/design-principles.md`
6. **反模式**：收敛方案前读 `references/anti-patterns.md`
7. **验证与运维建议**：落盘后读 `references/quality-checklist.md`
8. **操作层陷阱**：时间/增量/来源问题时读 `gotchas.md`
9. **全目录索引**：按需读 `references/README.md`
10. **CHANGE-LOG 结构**：组织章节时参考 `assets/changes-index-template.md`（及 JSON 模板如需）

---

## 门禁要求（本技能）

- 无 SDD 式「终稿 HTML gate」；**有歧义须停顿确认**（见上文「前置确认」与 `references/gates.md`）。
- **禁止**在本技能流程中宣称已完成 **INDEX_GUIDE** 或知识实体更新（见适用边界）。

---

## 产出与校验

- **正式产物**：`{output_dir}/CHANGE-LOG.md`，结构参考 `assets/changes-index-template.md`。
- **校验**：执行 `references/quality-checklist.md`；时间比较与排除目录防循环见 `gotchas.md`。

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`（含 `expected_output` 与 `assertions`）
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 工程化支持

辅助脚本：[scripts/change-indexing.sh](scripts/change-indexing.sh)（原始数据采集至 `{output_dir}/.raw/`）。本仓库未为 `docs-change` 注册 `preToolUse` 钩子。

---

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 下游 | `docs-indexing` | 增量索引宜消费本轮 `CHANGE-LOG.md` |
| 下游 | `docs-build` | 可基于变更文件列表做增量提取 |

---

## 工作流阶段索引

| 步骤 | 摘要 | 详见 |
|------|------|------|
| 1 | 环境准备、Git 检测、歧义确认 | [references/workflow.md](references/workflow.md) |
| 2 | 时间基准计算 | 同上 |
| 3 | 三源采集（可调用脚本） | 同上 + [references/collection-rules.md](references/collection-rules.md) |
| 4 | 合并、排序、写入、更新基线 | [references/workflow.md](references/workflow.md) |
| 5 | 验证 | [references/quality-checklist.md](references/quality-checklist.md) |
