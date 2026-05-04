---
name: docs-extract
description: >
  从用户指定的任意文件或目录中，按段落级关键词相关度筛选，提炼业务知识写入指定 XX-overview.md 第三列（A/U/D 合并更新）。
  只要用户意图涉及以下任一场景，就应立即触发本技能，不要等用户说出命令名：
  「从文件提炼到 overview」「从这些文档抽取业务知识」「把这个目录的内容整理进系统库」
  「从 design.md 提炼知识写进 overview」「从源文件提取业务知识」「把这些文档的知识同步到 overview」
  「从指定文件提炼」「抽取业务知识到系统库」「把这个文件的内容写进 overview」
  「从文档里提取业务规则」「把设计文档整理进知识库」。
  即使用户只说「帮我从这几个文件提炼业务知识」或「把这个目录整理进 billing-overview」也应触发。
  支持 --sources --overview --dry-run。
  用户执行 /docs-extract 时必须触发。
  若用户已明确要求以 docs-distill、docs-archive、docs-indexing、仅写 SDD 终稿等为主路径，则不要以本技能为唯一主流程，应分流到对应技能。
---

# docs-extract：从任意文件提炼业务知识到 overview

本技能以「调度器」方式工作：先判定是否应由 `docs-extract` 处理，再按阶段读取 `references/` 下规范文件，经会话 spec 与门禁后更新 `--overview` 的**第三列**。

> 从 `--sources` 按关键词相关度筛选段落，提炼写入 `XX-overview.md` 第三列；**不**维护 `DISTILL-LOG`；overview 正文第三列不写来源脚注。

---

## 适用边界

- **本技能负责**：任意源 → overview 第三列；段落级筛选；`docs-extract-gate` 与 `--dry-run` 两层预览；A/U/D 合并更新。
- **本技能不负责**：应用知识库上行主路径 **docs-distill**；视角归档 **docs-archive**；索引 **docs-indexing**；`{DOC_DIR}` 下 SDD 终稿代写。
- **分流**：用户明确只要上述下游时，转对应 `docs-*` 或 `sdx-*` 技能。

---

## 输入与前置检查

- `--sources` 与 `--overview` 可解析；overview 含 `## 文档关键词` 附录（缺失则先补，见 gotchas）。
- 知晓会话 spec 目录 `docs/superpowers/specs/` 与受管路径 `system/architecture/overview/`。

---

## 执行路由（先读后写）

1. **门禁与例外**：先读 `references/gates.md`
2. **流程、参数、五阶段、与 distill 差异**：再读 `references/workflow.md`
3. **交互节奏与 dry-run**：读 `references/interaction-gate.md`
4. **术语**：不确定时读 `references/core-concepts.md`
5. **关键词、段落算法、写入规范**：阶段 1 与 4.1–4.3 读 `references/extract-spec.md`
6. **原则层**：边界判断时读 `references/design-principles.md`
7. **反模式（概念层）**：收敛方案前读 `references/anti-patterns.md`
8. **落盘前验收**：阶段 4 末读 `references/quality-checklist.md`
9. **操作层陷阱**：异常或 CLOSE 前读 `gotchas.md`
10. **多方案嵌入节奏**：长澄清链时读 `references/brainstorming-integration.md`
11. **会话骨架**：新建 spec 时可复制 `assets/docs-extract-session-spec-template.md`

---

## 门禁要求（必须执行）

- 阶段 3 未 `CONFIRMED`（且无合法例外依据）前，禁止执行阶段 4。例外仅同会话明示，见 `references/gates.md` 与 [agent/rules/CONVENTIONS.md](../../rules/CONVENTIONS.md#artifact-gates)。

---

## 产出与校验

- **会话 spec**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-extract.md`（可选从 `assets/docs-extract-session-spec-template.md` 起稿）。
- **正式产物**：`--overview` 指向的 `*.md`（第三列更新）；**不**由本技能写入 `DISTILL-LOG`。

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 工程化支持

钩子：`python3 agent/hooks/sdx_gate_common.py --gate extract`，注册见 `agent/hooks.json`；需启用 Hooks 且满足会话激活条件方可能拦截。证据与会话 spec 中 `<!-- docs-extract-gate: CONFIRMED -->` 及目标 overview basename 对齐。详见 `references/gates.md` 与 `agent/hooks/README.md`。

---

## 快速定向表

| 需要做什么 | 去读 |
|-----------|------|
| 全目录索引与何时打开 | [references/README.md](references/README.md) |
