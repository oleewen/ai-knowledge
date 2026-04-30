---
name: sdx-architect
description: >
  当用户需要基于 PRD/ANALYSIS 产出架构设计说明书 ASD（§1/§2/§3）时，必须使用本技能。
  若用户要求实现级 API/DDL/规约 YAML/DSD，请不要继续本技能，改为分流到 /sdx-design。
  本技能默认执行门禁：未完成“用户总确认”前，禁止写入 {DOC_DIR}/requirements/**/ASD-*.md。
  当用户提到服务边界、架构图、服务变更表、系统级联邦概要（KNOWLEDGE_TYPE=system/company）等场景，也应优先触发本技能。
---

# 架构设计阶段（sdx-architect）

本技能以“调度器”方式工作：先判定是否应由 `sdx-architect` 处理，再按阶段读取对应规范文件，最终产出可校验的 ASD。

---

## 适用边界

- **本技能负责**：ASD（`§1/§2/§3`）、架构边界、服务变更、规约摘要行、门禁执行。
- **本技能不负责**：DSD、实现级 API/DDL、完整规约 YAML 落盘。
- **边界分流**：出现实现级细节诉求时，转 `[/sdx-design](../sdx-design/SKILL.md)`。

---

## 输入与前置检查

执行前最少确认：

- `PRD`（必需）
- `ANALYSIS`（推荐）
- `.docsconfig` 的 `KNOWLEDGE_TYPE`（建议）

若输入不全，先补澄清，不直接进入正式 ASD 落盘。

---

## 执行路由（先读后写）

1. **流程与阶段**：先读 `references/workflow.md`
2. **门禁与例外**：再读 `references/gates.md`
3. **质量检查**：落盘前读 `references/quality-checklist.md`
4. **反模式规避**：遇到歧义时读 `references/anti-patterns.md`
5. **输出样式**：参考 `assets/asd-template.md` 与 `assets/samples/mini-asd-example.md`

---

## 门禁要求（必须执行）

- 总确认前，禁止写 `{DOC_DIR}/requirements/**/ASD-*.md`
- 合法例外仅限：
  - 用户明确要求跳过
  - `SDX_ARCHITECT_ALLOW_ASD_WRITE=1`
- 建议在会话草稿使用状态标记：
  - `PENDING`（未确认）
  - `CONFIRMED`（已确认）

会话草稿模板使用：`assets/architect-session-spec-template.md`。

---

## 产出与校验

- 正式产物路径：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ASD-{IDEA-ID}-{N}.md`
- 使用模板：`assets/asd-template.md`
- 联邦模式补充：`assets/asd-stub-sections-federated.md`
- 落盘后执行：

  ```bash
  agent/skills/sdx-architect/scripts/validate-asd.sh
  agent/skills/sdx-architect/scripts/validate-asd.sh --file path/to/ASD-xxx.md --gate-check
  ```

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 工程化支持

钩子：`python3 agent/hooks/sdx_gate_common.py --gate architect`，注册见 `agent/hooks.json`。
