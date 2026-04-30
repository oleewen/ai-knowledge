---
name: sdx-solution
description: >
  解决方案制定：从业务描述中提取结构化诉求，评估影响面，识别并化解冲突，形成共识级解决方案文档。
  当用户执行 /sdx-solution、需要编写解决方案文档、收到业务需求需要结构化分析、
  需求模糊或矛盾需要冲突识别、或需要制定 MVP 与里程碑时，务必使用本技能。
  即使用户只说"帮我写个方案"、"分析一下这个需求"、"整理一下业务目标"，也应触发本技能。
  须遵守正文 HARD-GATE：默认禁止在「草稿用户总确认」之前写入 {DOC_DIR}/solutions/SOLUTION-*.md。
---

# 解决方案阶段（sdx-solution）

从业务描述中提取结构化诉求，评估影响面并化解冲突，产出**可供业务与产品评审**的共识级解决方案。主要读者为业务方与产品；技术实现留给下游 sdx-analysis / sdx-prd / **sdx-architect** / **sdx-design**。

---

## HARD-GATE

草稿总确认前，**禁止**写入 `{DOC_DIR}/solutions/SOLUTION-*.md`。

**合法例外**（须在对话中留下明确依据）：
- 用户在同一轮对话中明示可跳过门禁、仅要草稿、或紧急直写终稿
- 环境变量 `SDX_SOLUTION_ALLOW_SOLUTION_WRITE=1`

**门禁标记**：Spec 中使用 `<!-- sdx-solution-gate: PENDING -->`，总确认后改为 `<!-- sdx-solution-gate: CONFIRMED -->`，且正文须出现目标 `SOLUTION-*.md` 文件名。

**与 `/brainstorming` 的差异**：本技能会话的默认主产物是 `...-sdx-solution.md` 与 `SOLUTION-*.md`，**不以**独立 brainstorming 常见的 `*-design.md` + `writing-plans` 作为默认终态。阶段二若需 brainstorming 式交互，遵循 [reference/brainstorming-integration.md](reference/brainstorming-integration.md)。

---

## 阶段一：准备工作

**一次性**抛出以下三项参数供用户选择（支持快捷修改，如 `1.1 M IDEA-ID=XXX`）：

1. **IDEA-ID 主题**
   - 默认：`{YYMMDD}-{中文主题}`（规则见 [reference/core-concepts.md](reference/core-concepts.md)）
2. **门禁粒度**
   - 2.1 逐章 7G（G1–G7）
   - 2.2 精简 5G（G(1-2)、G3、G4、G(5-6)、G7）
3. **分析深度**
   - 3.1 `standard`（默认）
   - 3.2 `quick` 压缩叙述版
   - 3.3 `deep` 含数据影响及深度逻辑版

---

## 阶段二：草稿确认

**路径**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-solution.md`，骨架见 [assets/solution-session-spec-template.md](assets/solution-session-spec-template.md)。

### 标准四选项（每个门禁末尾附上）

```
C：确认，进入下一步
M：修改，格式 "M 旧内容 - 新内容"
S：跳过本门禁，按默认值推进
F：跳过全部门禁，直接拟定草稿、撰写终稿
```

### 门禁与模板映射

| 门禁 | 覆盖模板 | 状态 | 备注 |
|------|----------|------|------|
| [G{n}](#g{n}-XX) | [§{n} XX](#g{n}-XX) | 草案/已确认 | 示例行；按需复制为 G{n+1} |

**会话草稿「门禁进度」表**：门禁列与覆盖模板列均须为指向**本会话 spec 稿内** `## Gn` 小节锚点。占位与示例见 [assets/solution-session-spec-template.md](assets/solution-session-spec-template.md)「门禁进度」。

### 门禁节奏（强制）

- 每次只呈现一段草案或一个待确认点，末尾附标准四选项
- Gn 未收口前不展开 G(n+1)（回跳除外）
- 进入本阶段后，**禁止**以「已在 `…/specs/….md` 中补充 G{n} 草案，要点如下：」起首；直接给出要点或提问
- 回跳到 G{k} 后，按强/弱依赖评估后续门禁是否需重审（详见 [reference/workflow-spec.md](reference/workflow-spec.md)）

### brainstorming 嵌入层（阶段二）

阶段二在门禁交互上**对齐** brainstorming 的可复用节奏，但以本会话 spec 与 `SOLUTION-*.md` 为唯一交付主线。细则见 [reference/brainstorming-integration.md](reference/brainstorming-integration.md)。

- **单题澄清**：与 **Q-n** 协议一致（见 [reference/workflow-spec.md](reference/workflow-spec.md)）。
- **任意 G{n} 内多套可取舍方案**：当存在两条及以上真实可选路径时，**须在本门禁内**先完成 brainstorming 式对比（2–3 套、业务语义命名、利弊与推荐），再写入「本门禁结论」并收口该 Gn。**不限于 G4**（G2 边界、G3 化解路径、G5 应对、G6 切分等均可触发）。

### 总确认（Qclose-1）

全部门禁收口后：

> 是否同意以当前草稿为唯一素材生成 `SOLUTION-{IDEA-ID}.md`？（附标准四选项）

- C / S → 将 `PENDING` 改为 `CONFIRMED`，进入阶段三
- M → 返回修订 spec
- F → 不经总确认直写草稿（须符合 HARD-GATE 例外）

**确认人**：填写 `$HOME` 路径末级目录名（本机用户名），勿填显示名或占位词。

---

## 阶段三：草稿定稿

**3.1 骨架**：在 `{DOC_DIR}/solutions/` 新建文件，按 [assets/solution-template.md](assets/solution-template.md) 落七章标题、表架、§7.4（`- [ ]`）、文末 fenced yaml；标注「草稿填充中」。

**3.2 分块填充**（默认 5 chunk）：

| Chunk | 覆盖章节 |
|-------|---------|
| 1 | §1、§2 |
| 2 | §3 |
| 3 | §4 |
| 4 | §5、§6 |
| 5 | §7（含 §7.4 勾选） |

每块结束附标准四选项；用户可随时说「暂停」。

**终检**：对照 [reference/quality-checklist.md](reference/quality-checklist.md) 逐项判定，已达标项将 `- [ ]` 改为 `- [x]`，未达标项保持 `- [ ]`，禁止虚假勾选。

```bash
agent/skills/sdx-solution/scripts/validate-solution.sh
# 可选：检查门禁标记
agent/skills/sdx-solution/scripts/validate-solution.sh --file path/to/SOLUTION-xxx.md --gate-check
```

---

## 参考资源（按需打开）

| 资源 | 路径 | 何时读 |
|------|------|--------|
| brainstorming 嵌入、与独立 `/brainstorming` 的差异、Gn 内多方案子流程 | [reference/brainstorming-integration.md](reference/brainstorming-integration.md) | 阶段二对话节奏、多方案取舍时 |
| 门禁状态机、回跳影响面、Q-n 协议 | [reference/workflow-spec.md](reference/workflow-spec.md) | 流程不确定时 |
| 核心概念与 IDEA-ID / 编号规则 | [reference/core-concepts.md](reference/core-concepts.md) | 编号规则不确定时 |
| 受众定位与语言转写规则 | [reference/audience-and-language.md](reference/audience-and-language.md) | 终检或语言审查时 |
| 设计原则与错误处理 | [reference/design-principles.md](reference/design-principles.md) | 遇到边界判断或错误场景时 |
| 反模式与常见陷阱 | [gotchas.md](gotchas.md) | 遇到歧义处理、冲突分析问题时 |
| 质量验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 终检、§7.4 逐项勾选时 |
| 解决方案文档模板（七章） | [assets/solution-template.md](assets/solution-template.md) | 阶段三生成终稿时 |
| 会话草稿骨架 | [assets/solution-session-spec-template.md](assets/solution-session-spec-template.md) | 阶段二落草稿时 |

---

## 工程化支持

仓库 `agent/hooks.json` 注册了 `preToolUse` 钩子（`Write` / `StrReplace`），脚本见 `agent/hooks/sdx_gate_common.py`（`python3 agent/hooks/sdx_gate_common.py --gate solution`）；需启用 Hooks 方生效。
