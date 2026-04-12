---
name: sdx-test
description: >
  测试方案设计：基于 PRD 与 ADD 制定测试策略与计划，设计测试用例、测试数据与回归范围，输出测试设计文档（TDD）。
  当用户执行 /sdx-test、需要编写测试设计文档、制定测试策略与用例、设计回归测试范围、
  需要测试进出标准、需要将 PRD/ADD 转化为可执行的测试方案、或需要覆盖功能/接口/业务规则/异常/性能测试时，务必使用本技能。
  即使用户只说"帮我写个测试方案"、"设计一下测试用例"、"出一份 TDD"、"把 PRD 转成测试用例"、
  "设计一下回归范围"、"制定一下进出标准"，也应触发本技能。
  须遵守正文 HARD-GATE：默认禁止在「草稿用户总确认」之前写入 {DOC_DIR}/requirements/**/TDD-*.md。
---

# 测试设计阶段（sdx-test）

**术语**：**应用知识库**指应用知识库目录 `DOC_DIR`（见 `.docsconfig`），对应路径前缀 `{DOC_DIR}/`。

基于产品需求文档与技术设计文档，制定当前 MVP 的测试策略与测试计划，设计测试用例、测试数据与回归范围，输出测试设计文档（TDD），为后续开发与测试验证提供依据。

主要读者：**测试/质量角色**（制定策略与用例）；**研发参与评审**（可执行性、数据与环境、与 ADD 一致性）。

---

## HARD-GATE

草稿总确认前，**禁止**写入 `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-*.md`（及同目录下其他 `TDD-*.md` 命名约定）。

**合法例外**（须在对话中留下明确依据）：

- 用户在同一轮对话中明示可跳过门禁、仅要草稿、或紧急直写终稿
- 环境变量 `SDX_TEST_ALLOW_TDD_WRITE=1`

**门禁标记**：Spec 中使用 `<!-- sdx-test-gate: PENDING -->`，总确认后改为 `<!-- sdx-test-gate: CONFIRMED -->`，且正文须出现目标 `TDD-*.md` 文件名。

**与 `/brainstorming` 的差异**：本技能会话的默认主产物是 `...-sdx-test.md` 与 `TDD-*.md`，**不以**独立 brainstorming 常见的 `*-design.md` + `writing-plans` 作为默认终态。阶段二若需 brainstorming 式交互，遵循 [reference/brainstorming-integration.md](reference/brainstorming-integration.md)。

---

## 阶段一：准备工作

**一次性**抛出以下三项参数供用户选择（支持快捷修改，如 `1.1 M IDEA-ID=XXX`）：

1. **IDEA-ID 主题**
   - 与 PRD/ADD 一致（规则见 [reference/core-concepts.md](reference/core-concepts.md)）
2. **门禁粒度**
   - 2.1 全量 **6G（G1–G6）**（与 tdd-template 六章一一对应）
   - 2.2 **精简 4G**：G(1–2)、G3、G4、G(5–6)（映射见 [reference/workflow-spec.md](reference/workflow-spec.md)）
3. **分析深度**
   - 3.1 `standard`（默认）
   - 3.2 `quick` 压缩叙述版
   - 3.3 `deep` 增加性能与安全等用例侧重

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

### 门禁与模板映射（全量 6G）

| 门禁 | 对应模板章节 |
|------|-------------|
| G1 | §1 概述 |
| G2 | §2 测试用例 |
| G3 | §3 测试数据 |
| G4 | §4 测试环境 |
| G5 | §5 测试进出标准 |
| G6 | §6 附录（含 §6.2 质量自查、文末 yaml） |

**精简 4G** 时，同一逻辑门覆盖多章，见 [reference/workflow-spec.md](reference/workflow-spec.md)「精简 4 门禁映射」。

### 门禁节奏（强制）

- 每次只呈现一段草案或一个待确认点，末尾附标准四选项
- Gn 未收口前不展开 G(n+1)（回跳除外）
- 进入本阶段后，**禁止**以「已在 `…/specs/….md` 中补充 G{n} 草案，要点如下：」起首；直接给出要点或提问
- 回跳到 G{k} 后，按强/弱依赖评估后续门禁是否需重审（详见 [reference/workflow-spec.md](reference/workflow-spec.md)）

### brainstorming 嵌入层（阶段二）

阶段二在门禁交互上**对齐** brainstorming 的可复用节奏，但以本会话 spec 与 `TDD-*.md` 为唯一交付主线。细则见 [reference/brainstorming-integration.md](reference/brainstorming-integration.md)。

- **单题澄清**：与 **Q-n** 协议一致（见 [reference/workflow-spec.md](reference/workflow-spec.md)）。
- **任意 G{n} 内多套可取舍方案**：当存在两条及以上真实可选路径时，**须在本门禁内**先完成 brainstorming 式对比（2–3 套、业务语义命名、利弊与推荐），再写入「本门禁结论」并收口该 Gn。

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

每块结束附标准四选项；用户可随时说「暂停」。

**终检**：对照 [reference/quality-checklist.md](reference/quality-checklist.md) 逐项判定，已达标项将 `- [ ]` 改为 `- [x]`，未达标项保持 `- [ ]`，禁止虚假勾选。

```bash
.agent/skills/sdx-test/scripts/validate-test.sh
# 可选：检查门禁标记
.agent/skills/sdx-test/scripts/validate-test.sh --file path/to/TDD-xxx.md --gate-check
```

---

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 严格遵循 `tdd-template.md` 六章结构；无内容章节保留标题并标注「不适用」 |
| 证据优先 | 用例须引用 PRD US-n/BR-n 与 ADD API 规约，禁止臆测 |
| MVP 聚焦 | 仅覆盖目标 MVP 范围，不超越 MVP 边界 |
| 歧义标注 | 不确定项标为待澄清，暂停确认，禁止自行假设 |
| 可追溯 | TC-n → US-n/API/BR-n/影响面；编号体系见 [reference/design-principles.md](reference/design-principles.md) |
| 自查勾选 | §6.2 已通过项须为 `- [x]`；未通过项保持 `- [ ]` 直至修复 |

完整原则、反模式、编号体系与错误处理见 [reference/design-principles.md](reference/design-principles.md)。

---

## 命名约定

- 落盘路径（应用知识库）：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md`
- IDEA-ID 与上游 `PRD-{IDEA-ID}-{N}.md`、`ADD-{IDEA-ID}-{N}.md` 完全一致
- 元数据位置：文末「## 文档元数据」下的 fenced YAML；**禁止**在文件开头使用 `---` frontmatter

---

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（必需） | `sdx-prd` | 提供产品需求文档（用户故事、业务规则） |
| 上游（推荐） | `sdx-design` | 提供架构设计文档（接口规约、影响面分析） |
| 上游（可选） | `docs-build` | 提供 `knowledge/` 基线 |

---

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 已有 PRD 与 ADD，需制定测试方案 | ✅ |
| 需设计测试用例、测试数据与回归策略 | ✅ |
| 需制定可度量的测试进出标准 | ✅ |
| 已有解决方案，需进行需求分析 | ❌ → sdx-analysis |
| 已有需求分析，需编写 PRD | ❌ → sdx-prd |
| 已有 PRD，需技术方案设计 | ❌ → sdx-design |

---

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `IDEA-ID` | 与 PRD/ADD 一致 |
| `--prd` | 否 | — | 上游 PRD stem，自动定位对应文件 |
| `--mvp` | 否 | `1` | 目标 MVP 阶段编号（`MVP-Phase-{N}`） |
| `--depth` | 否 | `standard` | 设计深度：`quick` / `standard` / `deep`（见 [reference/workflow-spec.md](reference/workflow-spec.md)） |

---

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 产品需求文档（应用知识库 `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`） |
| 可选输入 | 架构设计（`ADD-{IDEA-ID}-{N}.md`）、规约（`specs/`）、`knowledge/`（按需加载，禁止通读全仓） |
| 会话 spec | `docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-test.md`（阶段二，门禁与总确认） |
| 固定输出 | 应用知识库下 `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md` |
| 不产出 | 代码、自动化测试脚本、测试执行报告（实现与执行阶段产出） |

---

## 参考资源（按需打开）

| 资源 | 路径 | 何时读 |
|------|------|--------|
| brainstorming 嵌入、与独立 `/brainstorming` 的差异、Gn 内多方案子流程 | [reference/brainstorming-integration.md](reference/brainstorming-integration.md) | 阶段二对话节奏、多方案取舍时 |
| 门禁状态机、精简 4G、回跳影响面、Q-n 协议、G1–G6 填充要点 | [reference/workflow-spec.md](reference/workflow-spec.md) | 流程不确定时 |
| 核心概念与 IDEA-ID / 编号规则 | [reference/core-concepts.md](reference/core-concepts.md) | 口径对齐、编号规则不确定时 |
| 受众定位与语言转写规则 | [reference/audience-and-language.md](reference/audience-and-language.md) | 终检或语言审查时 |
| 设计原则与错误处理 | [reference/design-principles.md](reference/design-principles.md) | 遇到边界判断或错误场景时 |
| 反模式与常见陷阱 | [gotchas.md](gotchas.md) | 遇到用例设计、范围控制、追溯相关问题时 |
| 质量验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 终检、§6.2 逐项勾选时 |
| TDD 文档模板（六章） | [assets/tdd-template.md](assets/tdd-template.md) | 阶段三生成终稿时 |
| 会话草稿骨架 | [assets/test-session-spec-template.md](assets/test-session-spec-template.md) | 阶段二落草稿时 |

---

## 工程化支持

仓库 [.agent/hooks.json](../../hooks.json) 注册了 `preToolUse` 钩子（`Write` / `StrReplace`），脚本见 [.agent/hooks/sdx-test-gate-write.py](../../hooks/sdx-test-gate-write.py)；需启用 Hooks 方生效。
