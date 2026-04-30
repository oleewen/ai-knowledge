---
name: sdx-test
description: >
  测试方案设计：基于 PRD 与详细设计 **DSD**（及上游 **ASD**）制定测试策略与计划，设计测试用例、测试数据与回归范围，输出测试设计文档（TDD）。
  当用户执行 /sdx-test、需要编写测试设计文档、制定测试策略与用例、设计回归测试范围、
  需要测试进出标准、需要将 PRD/DSD 转化为可执行的测试方案、或需要覆盖功能/接口/业务规则/异常/性能测试时，务必使用本技能。
  即使用户只说"帮我写个测试方案"、"设计一下测试用例"、"出一份 TDD"、"把 PRD 转成测试用例"、
  "设计一下回归范围"、"制定一下进出标准"，也应触发本技能。
  须遵守正文 HARD-GATE：默认禁止在「草稿用户总确认」之前写入 {DOC_DIR}/requirements/**/TDD-*.md。
---

# 测试设计阶段（sdx-test）

基于 PRD、**ASD**（架构）与 **DSD**（详细设计及规约），制定当前 MVP 的测试策略与计划，设计测试用例、测试数据与回归范围，输出测试设计文档（TDD）。主要读者：**测试/质量角色**（制定策略与用例）；**研发参与评审**（可执行性、数据与环境、与 **DSD** 一致性）。

**上游**：`sdx-prd`（必需）、**`sdx-architect`、`sdx-design`**（均推荐）；**不产出**：自动化测试代码、测试报告。

---

## HARD-GATE

草稿总确认前，**禁止**写入 `{DOC_DIR}/requirements/**/TDD-*.md`。

**合法例外**（须在对话中留下明确依据）：
- 用户在同一轮对话中明示可跳过门禁、仅要草稿、或紧急直写终稿
- 环境变量 `SDX_TEST_ALLOW_TDD_WRITE=1`

**门禁标记**：会话 spec 中使用 `<!-- sdx-test-gate: PENDING -->`，总确认后改为 `<!-- sdx-test-gate: CONFIRMED -->`，且正文须出现目标 `TDD-*.md` 文件名。

---

## 阶段一：准备工作

**一次性**抛出以下三项参数供用户选择（支持快捷修改，如 `1.1 M IDEA-ID=XXX`）：

1. **IDEA-ID / MVP 阶段**：与 PRD/DSD（及 ASD）同目录命名一致（`PRD-{IDEA-ID}-{N}.md`）
2. **门禁粒度**
   - 2.1 全量 **6G（G1–G6）**（与 tdd-template 六章一一对应）
   - 2.2 **精简 4G**：G(1–2)、G3、G4、G(5–6)
3. **分析深度**
   - 3.1 `standard`（默认）
   - 3.2 `quick` 仅 P0 功能与核心接口
   - 3.3 `deep` 增加性能与安全用例

---

## 阶段二：草稿确认

**路径**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-test.md`，骨架见 [assets/test-session-spec-template.md](assets/test-session-spec-template.md)。

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

精简 4G 映射：G(1–2)→§1–§2，G3→§3，G4→§4，G(5–6)→§5–§6。

**会话草稿「门禁进度」表**：门禁列与覆盖模板列均须为指向**本会话 spec 稿内** `## Gn` 小节锚点。占位与示例见 [assets/test-session-spec-template.md](assets/test-session-spec-template.md)「门禁进度」。

### 门禁节奏（强制）

- 每次只呈现一段草案或一个待确认点，末尾附标准四选项
- Gn 未收口前不展开 G(n+1)（回跳除外）
- 进入本阶段后，**禁止**以「已在 `…/specs/….md` 中补充 G{n} 草案，要点如下：」起首；直接给出要点或提问
- 回跳到 G{k} 后，按强/弱依赖评估后续门禁是否需重审（详见 [reference/workflow-spec.md](reference/workflow-spec.md)）

### brainstorming 嵌入

任意 G{n} 内存在两条及以上真实可选路径时，须先完成方案对比（2–3 套、语义命名、利弊与推荐），再写入「本门禁结论」并收口。细则见 [reference/brainstorming-integration.md](reference/brainstorming-integration.md)。

### 总确认（Qclose-1）

全部门禁收口后：

> 是否同意以当前草稿为唯一素材生成 `TDD-{IDEA-ID}-{N}.md`？（附标准四选项）

- C / S → 将 `PENDING` 改为 `CONFIRMED`，进入阶段三
- M → 返回修订 spec
- F → 不经总确认直写草稿（须符合 HARD-GATE 例外）

**确认人**：填写 `$HOME` 路径末级目录名（本机用户名），勿填显示名或占位词。

---

## 阶段三：草稿定稿

**3.1 骨架**：在 `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 新建 `TDD-{IDEA-ID}-{N}.md`，按 [assets/tdd-template.md](assets/tdd-template.md) 落六章标题、表架、§6.2（`- [ ]`）、文末 fenced yaml；标注「草稿填充中」。

**3.2 分块填充**（默认 6 chunk，与 G1–G6 对齐）：

| Chunk | 覆盖章节 |
|-------|---------|
| 1 | §1 |
| 2 | §2 |
| 3 | §3 |
| 4 | §4 |
| 5 | §5 |
| 6 | §6（含 §6.2 勾选与 yaml） |

精简 4G 时 chunk 合并：1→§1–§2，2→§3，3→§4，4→§5–§6。每块结束附标准四选项；用户可随时说「暂停」。

**终检**：对照 [reference/quality-checklist.md](reference/quality-checklist.md) 逐项判定；已达标项将 `- [ ]` 改为 `- [x]`，未达标项保持 `- [ ]`，**禁止虚假勾选**。

```bash
agent/skills/sdx-test/scripts/validate-test.sh
# 可选：检查门禁标记
agent/skills/sdx-test/scripts/validate-test.sh --file path/to/TDD-xxx.md --gate-check
```

---

## 参考资源（按需打开）

| 资源 | 路径 | 何时读 |
|------|------|--------|
| 门禁状态机、回跳影响面、Q-n 协议、G{n} 填充要点 | [reference/workflow-spec.md](reference/workflow-spec.md) | 流程不确定、阶段三填充时 |
| brainstorming 嵌入细则、与独立 `/brainstorming` 的差异 | [reference/brainstorming-integration.md](reference/brainstorming-integration.md) | 阶段二多方案取舍时 |
| 受众定位与文档语言 | [reference/audience-and-language.md](reference/audience-and-language.md) | 终检或语言审查时 |
| 设计原则、反模式、编号体系、错误处理 | [reference/design-principles.md](reference/design-principles.md) | 边界判断、遇到错误场景时 |
| 质量验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 终检时 |
| TDD 文档模板（六章） | [assets/tdd-template.md](assets/tdd-template.md) | 阶段三生成终稿时 |
| 会话草稿骨架 | [assets/test-session-spec-template.md](assets/test-session-spec-template.md) | 阶段二落草稿时 |
| 常见陷阱 | [gotchas.md](gotchas.md) | 遇到用例设计、范围控制问题时 |

---

## 工程化支持

仓库 [agent/hooks.json](../../hooks.json) 注册了 `preToolUse` 钩子（`Write` / `StrReplace`），脚本见 [agent/hooks/sdx_gate_common.py](../../hooks/sdx_gate_common.py)（`python3 agent/hooks/sdx_gate_common.py --gate test`）；需启用 Hooks 方生效。
