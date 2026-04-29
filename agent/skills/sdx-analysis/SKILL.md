---
name: sdx-analysis
description: >
  需求分析：基于解决方案文档与知识库进行深度研究、需求细化、MVP 拆分与依赖/风险评估，输出需求分析文档。
  当用户执行 /sdx-analysis、需要编写需求分析文档、将解决方案细化为可排期的功能需求、
  做 MVP 拆分规划、或需要识别需求依赖与风险时，务必使用本技能。
  即使用户只说"帮我分析一下需求"、"拆一下 MVP"、"细化一下方案"，也应触发本技能。
  须遵守正文 HARD-GATE：默认禁止在「草稿用户总确认」之前写入 {DOC_DIR}/analysis/ANALYSIS-*.md。
---

# 需求分析阶段（sdx-analysis）

在解决方案基础上，将共识级方案细化为**可评审、可排期、可验收**的需求分析：划清范围、拆 MVP、标优先级与依赖，并识别风险。产出结构以 [assets/analysis-template.md](assets/analysis-template.md) 为准：**六章**（§1 背景目标 → §2 功能需求 → §3 非功能 → §4 交付计划 → §5 依赖与风险 → §6 附录含 **§6.4 质量自查**）。

主要读者为**产品经理与需求分析师**；研发以本阶段产出为输入编写 PRD/技术方案。

---

## HARD-GATE

草稿总确认前，**禁止**写入 `{DOC_DIR}/analysis/ANALYSIS-*.md`。

**合法例外**（须在对话中留下明确依据）：
- 用户在同一轮对话中明示可跳过门禁、仅要草稿、或紧急直写终稿
- 环境变量 `SDX_ANALYSIS_ALLOW_ANALYSIS_WRITE=1`

**门禁标记**：Spec 中使用 `<!-- sdx-analysis-gate: PENDING -->`，总确认后改为 `<!-- sdx-analysis-gate: CONFIRMED -->`，且正文须出现目标 `ANALYSIS-*.md` 文件名。

**与 `/brainstorming` 的差异**：本技能会话的默认主产物是 `...-sdx-analysis.md` 与 `ANALYSIS-*.md`，**不以**独立 brainstorming 常见的 `*-design.md` + `writing-plans` 作为默认终态。阶段二若需 brainstorming 式交互，遵循 [reference/brainstorming-integration.md](reference/brainstorming-integration.md)。

---

## 阶段一：准备工作

**一次性**抛出以下三项参数供用户选择（支持快捷修改，如 `1.1 M IDEA-ID=XXX`）：

1. **IDEA-ID 主题**
   - 默认：`{YYMMDD}-{中文主题}`（规则见 [reference/core-concepts.md](reference/core-concepts.md)）；须与上游 `SOLUTION-{IDEA-ID}.md` 对齐
2. **门禁粒度**
   - 2.1 全量 **6G（G1–G6）**（与 analysis-template 六章一一对应）
   - 2.2 **精简 4G**：G(1–2)、G3、G4、G(5–6)（映射见 [reference/workflow-spec.md](reference/workflow-spec.md)）
3. **分析深度**
   - 3.1 `standard`（默认）
   - 3.2 `quick` 压缩叙述版
   - 3.3 `deep` 含对标与可行性要点（写入仍须业务表述）

---

## 阶段二：草稿确认

**路径**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-analysis.md`，骨架见 [assets/analysis-session-spec-template.md](assets/analysis-session-spec-template.md)。

### 标准四选项（每个门禁末尾附上）

```
C：确认，进入下一步
M：修改，格式 "M 旧内容 - 新内容"
S：跳过本门禁，按默认值推进
F：跳过全部门禁，直接拟定草稿、撰写终稿
```

### 门禁与模板映射（全量 6G）

| 门禁 | 对应模板章节 |
|------|-------------|
| G1 | §1 背景目标 |
| G2 | §2 功能需求 |
| G3 | §3 非功能需求 |
| G4 | §4 交付计划 |
| G5 | §5 依赖与风险 |
| G6 | §6 附录（含 §6.4 质量自查、文末 yaml） |

**精简 4G** 时，同一逻辑门覆盖多章，见 [reference/workflow-spec.md](reference/workflow-spec.md)「精简 4 门禁映射」。

**会话草稿「门禁进度」表**：门禁列与覆盖模板列均须为指向**本会话 spec 稿内** `## Gn` 小节锚点。占位与示例见 [assets/analysis-session-spec-template.md](assets/analysis-session-spec-template.md)「门禁进度」。

### 门禁节奏（强制）

- 每次只呈现一段草案或一个待确认点，末尾附标准四选项
- Gn 未收口前不展开 G(n+1)（回跳除外）
- 进入本阶段后，**禁止**以「已在 `…/specs/….md` 中补充 G{n} 草案，要点如下：」起首；直接给出要点或提问
- 回跳到 G{k} 后，按强/弱依赖评估后续门禁是否需重审（详见 [reference/workflow-spec.md](reference/workflow-spec.md)）

### brainstorming 嵌入层（阶段二）

阶段二在门禁交互上**对齐** brainstorming 的可复用节奏，但以本会话 spec 与 `ANALYSIS-*.md` 为唯一交付主线。细则见 [reference/brainstorming-integration.md](reference/brainstorming-integration.md)。

- **单题澄清**：与 **Q-n** 协议一致（见 [reference/workflow-spec.md](reference/workflow-spec.md)）。
- **任意 G{n} 内多套可取舍方案**：当存在两条及以上真实可选路径时，**须在本门禁内**先完成 brainstorming 式对比（2–3 套、业务语义命名、利弊与推荐），再写入「本门禁结论」并收口该 Gn。**不限于 G2/G4**（G1 范围、G3 非功能、G5 风险应对等均可触发）。

### 总确认（Qclose-1）

全部门禁收口后：

> 是否同意以当前草稿为唯一素材生成 `ANALYSIS-{IDEA-ID}.md`？（附标准四选项）

- C / S → 将 `PENDING` 改为 `CONFIRMED`，进入阶段三
- M → 返回修订 spec
- F → 不经总确认直写草稿（须符合 HARD-GATE 例外）

**确认人**：填写 `$HOME` 路径末级目录名（本机用户名），勿填显示名或占位词。

---

## 阶段三：草稿定稿

**3.1 骨架**：在 `{DOC_DIR}/analysis/` 新建文件，按 [assets/analysis-template.md](assets/analysis-template.md) 落六章标题、表架、§6.4（`- [ ]`）、文末 fenced yaml；标注「草稿填充中」。

**3.2 分块填充**（默认 6 chunk，与 G1–G6 对齐）：

| Chunk | 覆盖章节 |
|-------|---------|
| 1 | §1 |
| 2 | §2 |
| 3 | §3 |
| 4 | §4 |
| 5 | §5 |
| 6 | §6（含 §6.4 勾选与 yaml） |

每块结束附标准四选项；用户可随时说「暂停」。

**终检**：对照 [reference/quality-checklist.md](reference/quality-checklist.md) 逐项判定，已达标项将 `- [ ]` 改为 `- [x]`，未达标项保持 `- [ ]`，禁止虚假勾选。

```bash
agent/skills/sdx-analysis/scripts/validate-analysis.sh
# 可选：检查门禁标记
agent/skills/sdx-analysis/scripts/validate-analysis.sh --file path/to/ANALYSIS-xxx.md --gate-check
```

---

## 参考资源（按需打开）

| 资源 | 路径 | 何时读 |
|------|------|--------|
| brainstorming 嵌入、与独立 `/brainstorming` 的差异、Gn 内多方案子流程 | [reference/brainstorming-integration.md](reference/brainstorming-integration.md) | 阶段二对话节奏、多方案取舍时 |
| 门禁状态机、精简 4G、回跳影响面、Q-n 协议、G1–G6 填充要点 | [reference/workflow-spec.md](reference/workflow-spec.md) | 流程不确定时 |
| 核心概念与 IDEA-ID / 编号规则 | [reference/core-concepts.md](reference/core-concepts.md) | 编号规则不确定时 |
| 受众定位与语言转写规则 | [reference/audience-and-language.md](reference/audience-and-language.md) | 终检或语言审查时 |
| 设计原则与错误处理 | [reference/design-principles.md](reference/design-principles.md) | 遇到边界判断或错误场景时 |
| 反模式与常见陷阱 | [gotchas.md](gotchas.md) | 遇到歧义处理、MVP 拆分等问题时 |
| 质量验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 终检、§6.4 逐项勾选时 |
| 需求分析文档模板（六章） | [assets/analysis-template.md](assets/analysis-template.md) | 阶段三生成终稿时 |
| 会话草稿骨架 | [assets/analysis-session-spec-template.md](assets/analysis-session-spec-template.md) | 阶段二落草稿时 |

---

## 工程化支持

仓库 [agent/hooks.json](../../hooks.json) 注册了 `preToolUse` 钩子（`Write` / `StrReplace`），脚本见 [agent/hooks/sdx_gate_common.py](../../hooks/sdx_gate_common.py)（`python3 agent/hooks/sdx_gate_common.py --gate analysis`）；需启用 Hooks 方生效。
