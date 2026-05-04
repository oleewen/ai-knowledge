---
name: docs-indexing
description: >
  为代码库生成结构化文档索引（INDEX_GUIDE.md），产出标准化九章文档地图，
  作为 Agent 导航与 RAG 上下文的权威来源；索引运行记录写入 `changelogs/INDEXING-LOG.md` 主表（最新在上，见 `references/indexing-log-spec.md`）。
  支持全量/增量扫描与三级深度（拓扑/结构/精读）。
  当用户执行 /docs-indexing、需要生成或更新项目索引、建立文档地图、做项目 Onboarding、
  或下游 docs-build/docs-agent 需要 INDEX_GUIDE.md 时，务必使用本技能。
  即使用户只说「帮我建个索引」「生成一下项目文档」「更新一下 INDEX」「项目文档太乱了帮我整理一下」，也应触发本技能。
  默认门禁：未完成中间会话 spec 与用户总确认（`docs-indexing-gate: CONFIRMED`）前，禁止写入各 `INDEX_GUIDE.md` 与 `*/changelogs/INDEXING-LOG.md`（与 CONVENTIONS 高风险一致；Hooks 启用时由 `sdx_gate_common.py --gate indexing` 拦截）。
  若用户已明确要求只做 docs-build、docs-distill、docs-extract、仅写 SDD 终稿等为主路径，则不要以本技能为唯一主流程，应分流到对应技能。
---

# 文档索引生成器（docs-indexing）

本技能以「调度器」方式工作：先判定是否应由 `docs-indexing` 处理，再按序读取 `references/` 下规范，经**参数 Qclose-1**、**落盘会话 spec** 与 **`docs-indexing-gate`** 后写入 `INDEX_GUIDE.md` 与 `INDEXING-LOG.md`。

将代码库解析为结构化、可检索的 `INDEX_GUIDE.md`，作为 Agent 与开发者的系统全景导航；其质量直接影响下游 `docs-build`、`docs-agent` 等技能能否准确定位信息。

---

## 适用边界

- **本技能负责**：各文档根 `INDEX_GUIDE.md`（九章）、`changelogs/INDEXING-LOG.md` 主表行、全量/增量与深度 1/2/3 扫描流程。
- **本技能不负责**：知识实体 `*_knowledge.json`、`KNOWLEDGE_INDEX`（**docs-build**）；根 `INDEX_GUIDE.md` 以外的业务终稿（**sdx-***）；系统 overview（**docs-distill** / **docs-extract**）。
- **分流**：用户明确只要下游产物时，转对应技能。

---

## 输入与前置检查

- 知晓本轮 `DOC_ROOT` / 输出路径及 `docs/superpowers/specs/` 可写。
- 增量模式须理解 `INDEXING-LOG` 基线或 `--since`（见 `references/indexing-log-spec.md`）。

---

## 执行路由（先读后写）

1. **门禁与路径证据**：先读 `references/gates.md`
2. **六步流程与参数**：再读 `references/workflow.md`
3. **会话 spec 与节奏**：读 `references/interaction-gate.md`
4. **扫描配置与话术**：步骤 1～2 读 `references/scan-config-onboarding.md`
5. **扫描执行规则**：步骤 4 读 `references/scan-spec.md`
6. **九章结构**：步骤 6 读 `references/nine-chapter-spec.md`
7. **质量验证**：步骤 5 读 `references/quality-standards.md`
8. **日志格式与增量**：读/写日志时读 `references/indexing-log-spec.md`
9. **与 SDD 边界**：需求超范围时读 `references/brainstorming-integration.md`
10. **反模式**：收敛前读 `references/anti-patterns.md`
11. **操作层陷阱**：读 `gotchas.md`
12. **会话骨架**：新建 spec 时可复制 `assets/docs-indexing-session-spec-template.md`

---

## 门禁要求（必须执行）

- **参数**：未完成 [workflow.md](references/workflow.md) 步骤 2 的 **Qclose-1（C）**，不得进入扫描与写盘编排。
- **写入**：未完成 `docs-indexing-gate: CONFIRMED` 及 spec 内**路径清单**前，禁止 `Write` / `StrReplace` 写入受管 `INDEX_GUIDE.md` 与 `*/changelogs/INDEXING-LOG.md`。合法例外见 `references/gates.md`。

---

## 产出与校验

- **会话 spec**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-indexing.md`（骨架见 `assets/docs-indexing-session-spec-template.md`）。
- **正式产物**：已确认的 `INDEX_GUIDE.md`、`INDEXING-LOG.md` 主表更新。
- **辅助脚本**（参数须与用户确认一致）：

  ```bash
  agent/skills/docs-indexing/scripts/indexing.sh --mode <mode> --depth <depth>
  ```

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 工程化支持

钩子：`python3 agent/hooks/sdx_gate_common.py --gate indexing`；会话须曾出现 `/docs-indexing` 以激活（见 `sdx_session_gate.py`）。注册见 `agent/hooks.json`；语义见 `agent/hooks/README.md` 与 `references/gates.md`。

---

## 快速定向表

| 需要做什么 | 去读 |
|-------------|------|
| 全目录索引与何时打开 | [references/README.md](references/README.md) |
