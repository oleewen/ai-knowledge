---
name: sdx-design
description: >
  技术方案设计：基于 PRD 进行系统架构设计，输出架构设计说明书（ADD）与规约（specs）。
  当用户执行 /sdx-design、需要编写 ADD、进行系统架构设计、设计接口与领域模型、生成 API/数据/领域规约、
  或需要将 PRD 转化为可落地的技术方案时，务必使用本技能。
  即使用户只说"帮我写个技术方案"、"设计一下接口"、"出一份 ADD"、"把 PRD 转成技术设计"、
  "设计一下数据库表"、"画一下架构图"，也应触发本技能。
  须遵守正文 HARD-GATE：默认禁止在「草稿用户总确认」之前写入 {DOC_DIR}/requirements/**/ADD-*.md。
---

# 方案设计阶段（sdx-design）

基于 PRD，结合系统架构与领域模型，输出**架构设计说明书（ADD）**与**规约文件（specs）**，为测试设计与开发提供技术蓝图。主要读者：**架构师与骨干开发**（见 [reference/audience-and-language.md](reference/audience-and-language.md)）。

**上游**：`sdx-prd`（必需）、`sdx-analysis`（推荐）；**下游**：`sdx-test`。

---

## HARD-GATE

草稿总确认前，**禁止**写入 `{DOC_DIR}/requirements/**/ADD-*.md`。

**合法例外**（须在对话中留下明确依据）：
- 用户在同一轮对话中明示可跳过门禁、仅要草稿、或紧急直写终稿
- 环境变量 `SDX_DESIGN_ALLOW_ADD_WRITE=1`

**门禁标记**：会话 spec 中使用 `<!-- sdx-design-gate: PENDING -->`，总确认后改为 `<!-- sdx-design-gate: CONFIRMED -->`，且正文须出现目标 `ADD-*.md` 文件名（basename）。

**规约落盘时机**：`specs/**/*.yaml` 在用户总确认之后的阶段三与 ADD 定稿同步落盘；阶段二可在会话 spec 内用 Markdown 描述规约要点，**不落盘 YAML**。

---

## 阶段一：准备工作

**一次性**抛出以下三项参数供用户选择（支持快捷修改，如 `1.1 M IDEA-ID=XXX`）：

1. **IDEA-ID / MVP 阶段**：与 PRD 同目录、同命名约定（`PRD-{IDEA-ID}-{N}.md`）
2. **门禁粒度**
   - 2.1 全量 **5G（G1–G5）**（与 add-template 五章一一对应）
   - 2.2 **精简 3G**：G(1–2)、G3、G(4–5)
3. **设计深度 `--depth`**
   - 3.1 `standard`（默认）
   - 3.2 `quick` 压缩叙述版
   - 3.3 `deep` 含性能建模与容量规划

---

## 阶段二：草稿确认

**路径**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-design.md`，骨架见 [assets/design-session-spec-template.md](assets/design-session-spec-template.md)。

### 标准四选项（每个门禁末尾附上）

```
C：确认，进入下一步
M：修改，格式 "M 旧内容 - 新内容"
S：跳过本门禁，按默认值推进
F：跳过全部门禁，直接拟定草稿、撰写终稿
```

### 门禁与模板映射

| 门禁 | 对应 ADD 章节 |
|------|--------------|
| G1 | §1 设计概述 |
| G2 | §2 架构设计 |
| G3 | §3 详细设计 |
| G4 | §4 需求规约 |
| G5 | §5 附录（含质量自查） |

精简 3G 映射：G(1–2)→§1–§2，G3→§3，G(4–5)→§4–§5。

### 门禁节奏（强制）

- 每次只呈现一段草案或一个待确认点，末尾附标准四选项
- Gn 未收口前不展开 G(n+1)（回跳除外）
- 进入本阶段后，**禁止**以「已在 `…/specs/….md` 中补充 G{n} 草案，要点如下：」起首；直接给出要点或提问
- 回跳到 G{k} 后，按强/弱依赖评估后续门禁是否需重审（详见 [reference/workflow-spec.md](reference/workflow-spec.md)）

### brainstorming 嵌入

任意 G{n} 内存在两条及以上真实可选路径时，须先完成方案对比（2–3 套、语义命名、利弊与推荐），再写入「本门禁结论」并收口。细则见 [reference/brainstorming-integration.md](reference/brainstorming-integration.md)。

### 总确认（Qclose-1）

全部门禁收口后：

> 是否同意以当前草稿为唯一素材生成目标 `ADD-*.md`？（附标准四选项）

- C / S → 将 `PENDING` 改为 `CONFIRMED`，进入阶段三
- M → 返回修订 spec
- F → 不经总确认直写草稿（须符合 HARD-GATE 例外）

**确认人**：填写 `$HOME` 路径末级目录名（本机用户名），勿填显示名或占位词。

---

## 阶段三：草稿定稿

**3.1 骨架**：在 `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 下新建 `ADD-{IDEA-ID}-{N}.md`，按 [assets/add-template.md](assets/add-template.md) 落五章标题、表架、文末 fenced yaml；可先标注「草稿填充中」。

**3.2 分块填充**（默认 5 chunk，与 G1–G5 对齐）：

| Chunk | 覆盖章节 |
|-------|---------|
| 1 | §1 |
| 2 | §2 |
| 3 | §3 |
| 4 | §4 |
| 5 | §5 |

精简 3G 时 chunk 合并：1→§1–§2，2→§3，3→§4–§5。每块结束附标准四选项；用户可随时说「暂停」。

**3.3 规约**：ADD 整合完成后，从 §1–§3 抽取，按服务写入 `specs/{service-name}/{type}/`（`type` 为 `api/`、`domain/`、`data/`、`integration/`）；规约头部须标注 `source`（ADD 章节）与 `requirement`（FR-n）。

**终检**：对照 [reference/quality-checklist.md](reference/quality-checklist.md) 逐项判定；已达标项将 `- [ ]` 改为 `- [x]`，未达标项保持 `- [ ]`，**禁止虚假勾选**。

```bash
agent/skills/sdx-design/scripts/validate-design.sh
# 可选：检查门禁标记
agent/skills/sdx-design/scripts/validate-design.sh --file path/to/ADD-xxx.md --gate-check
```

---

## 参考资源（按需打开）

| 资源 | 路径 | 何时读 |
|------|------|--------|
| 门禁状态机、回跳影响面、Q-n 协议、四步内容生成算法 | [reference/workflow-spec.md](reference/workflow-spec.md) | 流程不确定、阶段三填充时 |
| brainstorming 嵌入细则、与独立 `/brainstorming` 的差异 | [reference/brainstorming-integration.md](reference/brainstorming-integration.md) | 阶段二多方案取舍时 |
| 受众定位与文档语言 | [reference/audience-and-language.md](reference/audience-and-language.md) | 终检或语言审查时 |
| 设计原则、反模式、错误处理 | [reference/design-principles.md](reference/design-principles.md) | 边界判断、遇到错误场景时 |
| 质量验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 终检时 |
| ADD 模板 | [assets/add-template.md](assets/add-template.md) | 阶段三生成终稿时 |
| 规约摘录模板 | [assets/spec-template.md](assets/spec-template.md) | 生成规约时 |
| 会话草稿骨架 | [assets/design-session-spec-template.md](assets/design-session-spec-template.md) | 阶段二落草稿时 |
| 常见陷阱 | [gotchas.md](gotchas.md) | 遇到设计/规约问题时 |

---

## 工程化支持

仓库 [agent/hooks/hooks.json](../../hooks/hooks.json) 注册了 `preToolUse` 钩子（`Write` / `StrReplace`），脚本见 [agent/hooks/sdx_gate_common.py](../../hooks/sdx_gate_common.py)（`python3 agent/hooks/sdx_gate_common.py --gate design`）；需启用 Hooks 方生效。
