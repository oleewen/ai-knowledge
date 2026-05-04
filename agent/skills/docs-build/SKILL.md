---
name: docs-build
description: >
  从工程代码与文档中按四视角（技术→数据→业务→产品）提取链上实体 ID，生成 *_knowledge.json（schema 2.1），
  刷新各视角 README 索引表，归并更新 {DOC_DIR}/knowledge/KNOWLEDGE_INDEX.md。
  只要用户提到以下任意场景，就应立即使用本技能，不要等用户明确说"/docs-build"：
  初始化知识库、同步知识库、提取实体、更新知识索引、代码重构后对齐实体 ID、
  补全四视角知识资产、下游 docs-indexing 需要知识实体输入、
  "帮我把代码里的实体整理一下"、"知识库和代码对不上了"、"更新一下 KNOWLEDGE_INDEX"。
  若用户已明确要求只做 docs-indexing（根 INDEX_GUIDE）、docs-distill、docs-extract、docs-archive、仅写 SDD 终稿等为主路径，则不要以本技能为唯一主流程，应分流到对应技能。
---

# 知识实体提取（docs-build）

本技能以「调度器」方式工作：先判定是否应由 `docs-build` 处理，再按序读取 `references/` 下规范，经会话 spec 与 **Qclose-1** 后写入 `{DOC_DIR}/knowledge/`。

**术语**：**应用知识库**指 `.docsconfig` 中 `DOC_DIR` 对应目录，路径前缀 `{DOC_DIR}/`。

---

## 适用边界

- **本技能负责**：四视角 `*_knowledge.json`（schema 2.1）、各视角 `README.md` 索引表、`KNOWLEDGE_INDEX.md` 归并与校验脚本。
- **本技能不负责**：根目录 `INDEX_GUIDE.md`（**docs-indexing**）；系统 overview 上行（**docs-distill** / **docs-extract**）；overview 按视角归档（**docs-archive**）；`SOLUTION-*` / `ASD-*` 等 SDD 终稿。
- **分流**：用户明确只要上述下游时，转对应技能。

---

## 输入与前置检查

- 主 Index Guide 已可用（否则先 `/docs-indexing`）。
- 知晓 `{DOC_DIR}/knowledge/` 可写；会话 spec 目录 `docs/superpowers/specs/`。

---

## 执行路由（先读后写）

1. **门禁与 Qclose-1**：先读 `references/gates.md`
2. **四阶段、参数、预检策略**：再读 `references/workflow.md`
3. **会话节奏与 spec 路径**：读 `references/interaction-gate.md`
4. **内置配置与完整约束**：阶段 1 读 `references/builtin-config.md`
5. **四视角提取规则**：阶段 2 读 `references/extraction-rules.md`
6. **README 填充**：阶段 3 读 `references/readme-fill-spec.md`
7. **归并与主索引**：阶段 4 读 `references/consolidation-spec.md`
8. **术语**：不确定时读 `references/core-concepts.md`
9. **原则层**：读 `references/design-principles.md`
10. **反模式**：收敛前读 `references/anti-patterns.md`
11. **与 SDD / brainstorming 边界**：读 `references/brainstorming-integration.md`
12. **提取后验收**：阶段 4 后读 `references/quality-checklist.md`
13. **操作层陷阱**：读 `gotchas.md`
14. **会话骨架**：新建 spec 时可复制 `assets/docs-build-session-spec-template.md`

---

## 门禁要求（必须执行）

- 阶段 1 完成后的 **Qclose-1** 与 `docs-build-gate: CONFIRMED` 前，禁止写入 `{DOC_DIR}/knowledge/`。合法例外见 `references/gates.md`。

---

## 产出与校验

- **会话 spec**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-build.md`（可选从 `assets/docs-build-session-spec-template.md` 起稿）。
- **正式产物**：各视角 `*_knowledge.json`、`README.md`、`KNOWLEDGE_INDEX.md`。
- **验证**：

  ```bash
  agent/skills/docs-build/scripts/validate-extraction.sh
  ```

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 工程化支持

钩子：`python3 agent/hooks/sdx_gate_common.py --gate build`，注册见 `agent/hooks.json`；须启用 Hooks 且会话激活。证据：`<!-- docs-build-gate: CONFIRMED -->` 与目标文件名引用。详见 `references/gates.md` 与 `agent/hooks/README.md`。

---

## 快速定向表

| 需要做什么 | 去读 |
|-----------|------|
| 全目录索引与何时打开 | [references/README.md](references/README.md) |
