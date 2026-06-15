# sdx-prd 工作流

门禁 [gates.md](gates.md)。原则与表格级反模式 [design-principles.md](design-principles.md)；叙事反模式 [anti-patterns.md](anti-patterns.md)。

## 目标

在 **ANALYSIS** 与**当前 MVP** 内产出可评审、可验收 **PRD**（十一章），为下游 **ASD/DSD** 提供 US/UC/FR/BR/AC 锚点。

**公司库**（`KNOWLEDGE_TYPE=company`）：上游为 `company/analysis/ANALYSIS-*.md`（含各系统功能归属）；**本技能在 `system/` 文档根执行**，产出落在对应 **`system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-*.md`**（按 ANALYSIS 拆解的系统逐项编写，非 `company/requirements/`）。布局见 [knowledge-layout.md](../../../references/knowledge-layout.md)。

## 核心约束（须满足）

| 约束 | 说明 |
|------|------|
| 模板驱动 | 跟 `prd-template.md` 十一章；空节标「不适用/待补充」 |
| 证据优先 | US/流程/BR 须有 FR-n/BR-n 等锚点 |
| MVP 聚焦 | 仅 `--mvp` 范围 |
| 业务可读 | 见 [audience-and-language.md](audience-and-language.md) |
| 歧义标注 | 待澄清勿自补 |
| 可追溯 | US→FR；UC↔US；BR 与 ANALYSIS 一致；AC/NAC 可指回 |
| 路径 | `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md` |

---

## 阶段一：准备

一次性确认（支持快捷回复如 `1.1 M IDEA-ID=XXX`）：

1. **IDEA-ID** — 默认 `{YYMMDD}-{主题}`，与 `ANALYSIS-{IDEA-ID}.md` 一致（见 [core-concepts.md](core-concepts.md)）。  
2. **`N`** — `MVP-Phase-{N}` 与文件名。  
3. **门禁粒度** — 11G（G1–G11）或精简 6G（映射见下）。  
4. **depth** — `standard`（默认）/ `quick` / `deep`。

**硬输入**：`{DOC_DIR}/analysis/ANALYSIS-{IDEA-ID}.md` 当前 MVP；无则停，提示 `sdx-analysis`。

---

## 阶段二：草稿

路径：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-sdx-prd.md`，骨架 [../assets/prd-session-spec-template.md](../assets/prd-session-spec-template.md)。每门禁末附 **C/M/S/F**（见 `gates.md`）。

### G 与模板（11G）

| 门禁 | 覆盖模板 | 状态 | 备注 |
|------|----------|------|------|
| [G{n}](#gn-xx) | [§{n} XX](#gn-xx) | 草案/已确认 | 按需复制扩展 |

**精简 6G** 见下表。「门禁进度」列须链到**本会话 spec** 内 `## Gn` 锚点。

### 节奏

- 一次一段草案或一个确认点 + 四选项。  
- **Gn 未收口不展 G(n+1)**（回跳除外）。  
- 禁止以「已在 specs 补充 Gn…」起首空转；直接给要点。  
- 回跳 G{k} 后按强/弱依赖决定是否重审后续（见「回跳」）。

**brainstorming**：阶段二对齐其节奏，交付仍以本会话 spec + **PRD** 为准；详见 [brainstorming-integration.md](brainstorming-integration.md)。**Qclose-1**：见 `gates.md`。

---

## 阶段三：定稿

**骨架**：在 `MVP-Phase-{N}/` 下建 `PRD-{IDEA-ID}-{N}.md`，按 [prd-template.md](../assets/prd-template.md) 落十一章标题、表架、§11.3（`- [ ]`）、文末 yaml；可先标「草稿填充中」。

**分块填充**（11 chunk ↔ G1–G11；6G 时可 6 chunk）：

| Chunk | 章 | 要点 |
|-------|-----|------|
| 1 | §1 | SOLUTION/ANALYSIS/MVP、成功标准、角色 |
| 2 | §2 | 主流程 Mermaid + 六要素表；EX-n；跨系统或「不适用」 |
| 3 | §3 | 交互旅程；校验与反馈 |
| 4 | §4 | 用例图；UC-n 要素齐全 |
| 5 | §5 | FR-n→US-n；Given-When-Then 含异常 |
| 6 | §6 | 业务能力域模块 |
| 7 | §7 | BR-n 汇总表 |
| 8 | §8 | 术语；状态流转 |
| 9 | §9 | 本 MVP NFR |
| 10 | §10 | AC→US；NAC↔§9 |
| 11 | §11 | 原型；变更史；§11.3 自查 |

每块末可附四选项；用户可说「暂停」。

**终检**：[quality-checklist.md](quality-checklist.md)；达标则 §11.3 `- [ ]`→`- [x]`，禁虚假勾选。

---

## 状态机

```
[阶段一] → [阶段二：11G 或 6G，每 G：草案→(多方案)→确认→收口] → [Qclose-1] → [阶段三：骨架→chunks→终检]
```

### 精简 6G 映射

| G(#) | 全量 | 章节 |
|------|------|------|
| G(1) | G1 | §1 |
| G(2) | G2–G3 | §2–§3 |
| G(3) | G4 | §4 |
| G(4) | G5 | §5 |
| G(5) | G6–G8 | §6–§8 |
| G(6) | G9–G11 | §9–§11 |

---

## 回跳

后续门禁若与 G{k} **结论矛盾**或**同一条 US/UC/FR** → **强依赖**，须重确认；大量引用术语/范围 → **弱依赖**，建议重审；无关 → **保持**。  
*例*：改 §2 主流程 → §4、§5 常强依赖。由用户选「仅强」或「强弱一并」重走。

---

## G{n} 多方案与 Q-n

**多方案**：同 G 内≥2条真实路径 → 2–3 套**业务命名**方案、利弊、推荐 → C/M/S/F → 写入「本门禁结论」。与 **Q-n** 分工：**Q-n**=事实缺口；多方案=信息够但分叉。详 [brainstorming-integration.md](brainstorming-integration.md)。

**Q-n 格式**：单题、`Q-{n}`、背景、具体选项、`C/M/S/F`；结论写入 FR/US/UC 映射，不单开「待澄清章」；**S** 须标推迟影响。

---

## 各章执行摘要（细则以模板与 quality-checklist 为准）

载入 **ANALYSIS**：按 `--mvp` 取 FR/BR/NFR/角色；缺 MVP 节则终止。

- **§1**：链 SOLUTION/ANALYSIS/MVP；成功标准 SMART 或待澄清；范围与 Growth 表；角色与 §4 一致。  
- **§2**：主流程表六要素；`[BR-n]` 引用，规则汇 §7；EX-n；跨系统 sequence 或不适用。  
- **§3**：核心任务路径；校验与反馈。  
- **§4**：用例图盖全角色；UC 前后置/主路径/扩展；UC↔US。  
- **§5**：每 FR≥1 US；GWT；INVEST；链 FR/BR。  
- **§6**：按业务域模块；邻接 US。  
- **§7**：BR 全字段；互斥规则写化解。  
- **§8**：术语；状态与非法转换策略。  
- **§9**：仅本 MVP NFR；可度量或待澄清。  
- **§10**：AC 可测；NAC 链 §9 或标不适用。  
- **§11**：原型；变更史；§11.3 对照 quality-checklist。

### 文末元数据

仅文末 `## 文档元数据` 下 fenced yaml；**禁止**文件头 `---`。

```yaml
id: "PRD-{IDEA-ID}-{N}"
title: "{标题}"
version: "1.0.0"
status: "draft"
created: "{YYYY-MM-DD}"
updated: "{YYYY-MM-DD}"
author: "product-designer"
reviewers: []
parent: "ANALYSIS-{IDEA-ID}"
mvp_phase: "MVP-Phase-{N}"
```
