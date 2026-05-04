---
name: docs-distill
description: >
  将应用知识库（system/application-{name}/）已核实内容蒸馏后写入系统知识库（system/architecture/overview/{APPNAME}-overview.md）。
  只要用户提到以下任意一种意图，就应立即触发本技能，不要等用户明确说出命令名：
  「知识蒸馏」「提炼应用知识到系统」「同步应用知识到系统」「把应用侧内容提炼后推上去」「更新主库」「上行蒸馏」
  「推送到系统库」「knowledge 蒸馏」「SDD 蒸馏」「生成 overview」「更新 overview」「overview 需要更新」
  「应用知识有变更要同步」「帮我蒸馏一下 {app}」「把最新变更同步上去」「系统库需要刷新」。
  支持 --app --since --full --dry-run，默认按增量锚点蒸馏。
  用户执行 /docs-distill 时必须触发。
  若用户已明确要求以 docs-extract、docs-archive、docs-indexing、仅写 SDD 终稿等为主路径，则不要以本技能为唯一主流程，应分流到对应技能。
---

# docs-distill：应用知识蒸馏并上行到系统库

本技能以「调度器」方式工作：先判定是否应由 `docs-distill` 处理，再按阶段读取 `references/` 下规范文件，经会话 spec 与门禁后更新 `{APPNAME}-overview.md` 与 `DISTILL-LOG.md`。

> 把 `system/application-{name}/` 的可晋升内容蒸馏入 `system/architecture/overview/{APPNAME}-overview.md` 第三列。overview 正文不记录来源脚注；追溯走 CHANGE-LOG、DISTILL-LOG 与会话 spec。

---

## 适用边界

- **本技能负责**：应用已核实内容 → 系统 overview 第三列；增量/全量策略；`DISTILL-LOG` 锚点；会话 spec 与 `docs-distill-gate` 门禁；`--dry-run` 三层预览。
- **本技能不负责**：从任意源抽取写入 overview 的 **docs-extract** 主流程；overview 按视角 **归档**的 **docs-archive** 主流程；索引重建 **docs-indexing**；SDD 终稿（`SOLUTION-*` / `ASD-*` 等）的正文代写。
- **分流**：用户明确只要上述下游时，转对应 `docs-*` 或 `sdx-*` 技能。

---

## 输入与前置检查

- 应用侧存在可读的 `system/application-{name}/changelogs/CHANGE-LOG.md`（过短则先补背景）。
- 明确或推导 `{APPNAME}` / `--app`；多应用待蒸馏时优先带 `--app`。
- 知晓会话 spec 路径 `docs/superpowers/specs/` 与系统 overview 路径 `system/architecture/overview/`。

---

## 执行路由（先读后写）

1. **门禁与例外**：先读 `references/gates.md`
2. **流程、参数、两日志、五阶段**：再读 `references/workflow.md`
3. **交互节奏与 dry-run 约定**：读 `references/interaction-gate.md`
4. **术语与锚点语义**：不确定时读 `references/core-concepts.md`
5. **蒸馏目标树与变更发现**：定范围时读 `references/distill-spec.md`
6. **联邦与第三列写入规则**：执行 4.2–4.3 时读 `references/federation-spec.md`
7. **DISTILL-LOG 与增量逻辑**：读/写锚点时读 `references/distill-log-spec.md`
8. **原则层**：边界判断时读 `references/design-principles.md`
9. **反模式（概念层）**：收敛方案前读 `references/anti-patterns.md`
10. **落盘前验收**：阶段 4 末读 `references/quality-checklist.md`
11. **操作层陷阱**：异常或 CLOSE 前读 `gotchas.md`
12. **多方案嵌入节奏**：长澄清链时读 `references/brainstorming-integration.md`
13. **会话骨架**：新建 spec 时可复制 `assets/docs-distill-session-spec-template.md`

---

## 门禁要求（必须执行）

- 阶段 3 未 `CONFIRMED`（且无合法例外依据）前，禁止执行阶段 4 落盘。合法例外与环境变量见 `references/gates.md`。
- 建议在会话 spec 使用 `PENDING` / `CONFIRMED` 语义（HTML 注释形态见 `gates.md`）。

---

## 产出与校验

- **会话 spec**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-distill.md`（可选从 `assets/docs-distill-session-spec-template.md` 起稿）。
- **正式产物**：`system/architecture/overview/{APPNAME}-overview.md`（第三列）；`system/changelogs/DISTILL-LOG.md`（仅于 4.3 成功后追加）。
- 脚本入口（从仓库根）：

  ```bash
  agent/skills/docs-distill/scripts/run-docs-distill.sh --help
  ```

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`（含 `expected_output`；可扩展 `assertions`）
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 工程化支持

钩子：`python3 agent/hooks/sdx_gate_common.py --gate distill`，注册见 `agent/hooks.json`；需启用 Hooks 且满足会话激活条件方可能拦截。证据与会话 spec 中 `<!-- docs-distill-gate: CONFIRMED -->` 及目标 overview basename 对齐。详见 `references/gates.md` 与 `agent/hooks/README.md`。

---

## 快速定向表

| 需要做什么 | 去读 |
|-----------|------|
| 全目录索引与何时打开 | [references/README.md](references/README.md) |
