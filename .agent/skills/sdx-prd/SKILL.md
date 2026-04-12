---
name: sdx-prd
description: >
  产品需求说明（PRD）：将需求分析中当前 MVP 细化为可评审、可验收的产品方案——
  业务流程、用例模型、用户故事、功能模块、交互设计与业务规则。
  当用户执行 /sdx-prd、需要编写 PRD 文档、将需求分析细化为用户故事和用例、
  设计业务流程和功能模块、或需要产出可评审可验收的产品需求时，务必使用本技能。
  即使用户只说"帮我写个 PRD"、"细化一下用户故事"、"设计一下业务流程"、
  "把需求分析转成 PRD"，也应触发本技能。
  须遵守正文 HARD-GATE：默认禁止在「草稿用户总确认」之前写入
  {DOC_DIR}/requirements/**/PRD-*.md（会话约定的 REQUIREMENT-…/MVP-Phase-…/ 路径）。
---

# 产品需求阶段（sdx-prd）

**术语**：**应用知识库**指应用知识库目录 `DOC_DIR`（见 `.docsconfig`），对应路径前缀 `{DOC_DIR}/`。

在需求分析基础上，将**当前 MVP** 细化为可评审、可验收的 PRD：业务流程、用例、用户故事、模块与交互、业务规则与数据字典、NFR 与验收标准。产出结构以 [assets/prd-template.md](assets/prd-template.md) 为准：**十一章**（§1 产品概述 → … → §11 附录含 **§11.3 质量自查**）。

主要读者：**产品经理**（撰写与验收对齐）；**研发参与评审**（可行性、范围边界）。技术实现留给下游 sdx-design。

---

## HARD-GATE

草稿总确认前，**禁止**写入应用知识库下 **`{DOC_DIR}/requirements/**/PRD-*.md`**（须落在 `REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 约定目录，文件名 `PRD-{IDEA-ID}-{N}.md`，见 [命名约定](#命名约定)）。

**合法例外**（须在对话中留下明确依据）：

- 用户在同一轮对话中明示可跳过门禁、仅要草稿、或紧急直写终稿
- 环境变量 `SDX_PRD_ALLOW_PRD_WRITE=1`

**门禁标记**：Spec 中使用 `<!-- sdx-prd-gate: PENDING -->`，总确认后改为 `<!-- sdx-prd-gate: CONFIRMED -->`，且正文须出现目标 **`PRD-{IDEA-ID}-{N}.md`** 文件名。

**与 `/brainstorming` 的差异**：本技能会话的默认主产物是 `...-sdx-prd.md` 与 `PRD-*.md`，**不以**独立 brainstorming 常见的 `*-design.md` + `writing-plans` 作为默认终态。阶段二若需 brainstorming 式交互，遵循 [reference/brainstorming-integration.md](reference/brainstorming-integration.md)。

---

## 阶段一：准备工作

**一次性**抛出以下参数供用户选择（支持快捷修改，如 `1.1 M IDEA-ID=XXX`）：

1. **IDEA-ID 主题**
   - 默认：`{YYMMDD}-{中文主题}`（规则见 [reference/core-concepts.md](reference/core-concepts.md)）；须与上游 `ANALYSIS-{IDEA-ID}.md` **对齐**
2. **MVP 阶段编号 `N`**
   - 对应 `MVP-Phase-{N}` 与终稿文件名 `PRD-{IDEA-ID}-{N}.md`（与 `--mvp` 一致）
3. **门禁粒度**
   - 3.1 全量 **11G（G1–G11）**（与 prd-template 十一章一一对应）
   - 3.2 **精简 6G**：G(1)、G(2)、G(3)、G(4)、G(5)、G(6)（映射见 [reference/workflow-spec.md](reference/workflow-spec.md)）
4. **分析深度**
   - 4.1 `standard`（默认）
   - 4.2 `quick` 压缩叙述版
   - 4.3 `deep` 含对标与交互细化要点（业务表述为主）

---

## 阶段二：草稿确认

**路径**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-prd.md`，骨架见 [assets/prd-session-spec-template.md](assets/prd-session-spec-template.md)。

### 标准四选项（每个门禁末尾附上）

```
C：确认，进入下一步
M：修改，格式 "M 旧内容 - 新内容"
S：跳过本门禁，按默认值推进
F：跳过全部门禁，直接拟定草稿、撰写终稿
```

### 门禁与模板映射（全量 11G）

| 门禁 | 对应模板章节 |
|------|-------------|
| G1 | §1 产品概述 |
| G2 | §2 业务流程 |
| G3 | §3 产品交互 |
| G4 | §4 用例模型 |
| G5 | §5 用户故事 |
| G6 | §6 功能模块设计 |
| G7 | §7 业务规则汇总 |
| G8 | §8 数据字典 |
| G9 | §9 非功能需求 |
| G10 | §10 验收标准 |
| G11 | §11 附录（含 §11.3 质量自查、文末 yaml 占位说明） |

**精简 6G** 时，同一逻辑门覆盖多章，见 [reference/workflow-spec.md](reference/workflow-spec.md)「精简 6 门禁映射」。

### 门禁节奏（强制）

- 每次只呈现一段草案或一个待确认点，末尾附标准四选项
- Gn 未收口前不展开 G(n+1)（回跳除外）
- 进入本阶段后，**禁止**以「已在 `…/specs/….md` 中补充 G{n} 草案，要点如下：」起首；直接给出要点或提问
- 回跳到 G{k} 后，按强/弱依赖评估后续门禁是否需重审（详见 [reference/workflow-spec.md](reference/workflow-spec.md)）

### brainstorming 嵌入层（阶段二）

阶段二在门禁交互上**对齐** brainstorming 的可复用节奏，但以本会话 spec 与 `PRD-*.md` 为唯一交付主线。细则见 [reference/brainstorming-integration.md](reference/brainstorming-integration.md)。

- **单题澄清**：与 **Q-n** 协议一致（见 [reference/workflow-spec.md](reference/workflow-spec.md)）。
- **任意 G{n} 内多套可取舍方案**：当存在两条及以上真实可选路径时，**须在本门禁内**先完成 brainstorming 式对比（2–3 套、业务语义命名、利弊与推荐），再写入「本门禁结论」并收口该 Gn。**不限于 G4/G5**（G2 流程、G7 规则口径、G9 NFR 等均可触发）。

### 总确认（Qclose-1）

全部门禁收口后：

> 是否同意以当前草稿为唯一素材生成 `PRD-{IDEA-ID}-{N}.md`？（附标准四选项）

- C / S → 将 `PENDING` 改为 `CONFIRMED`，进入阶段三
- M → 返回修订 spec
- F → 不经总确认直写草稿（须符合 HARD-GATE 例外）

**确认人**：填写 `$HOME` 路径末级目录名（本机用户名），勿填显示名或占位词。

---

## 阶段三：草稿定稿

**3.1 骨架**：在 `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 下新建 `PRD-{IDEA-ID}-{N}.md`，按 [assets/prd-template.md](assets/prd-template.md) 落十一章标题、表架、§11.3（`- [ ]`）、文末 fenced yaml；标注「草稿填充中」。

**3.2 分块填充**（默认 **11 chunk**，与 G1–G11 / §1–§11 对齐；精简 6G 时可用 **6 chunk**，与 `workflow-spec` 合并表一致）：

| Chunk | 覆盖章节 |
|-------|---------|
| 1 | §1 |
| 2 | §2 |
| 3 | §3 |
| 4 | §4 |
| 5 | §5 |
| 6 | §6 |
| 7 | §7 |
| 8 | §8 |
| 9 | §9 |
| 10 | §10 |
| 11 | §11（含 §11.3 勾选与 yaml） |

每块结束附标准四选项；用户可随时说「暂停」。各章填充算法、前置加载 ANALYSIS、编号与 Mermaid 要求见 [reference/workflow-spec.md](reference/workflow-spec.md)（含原「五步」算法与模板章节的对应关系）。

**终检**：对照 [reference/quality-checklist.md](reference/quality-checklist.md) 与模板 §11.3 逐项判定，已达标项将 `- [ ]` 改为 `- [x]`，未达标项保持 `- [ ]`，禁止虚假勾选。

```bash
.agent/skills/sdx-prd/scripts/validate-prd.sh
# 可选：检查门禁标记
.agent/skills/sdx-prd/scripts/validate-prd.sh --file path/to/PRD-xxx.md --gate-check
```

---

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 需求分析文档 `{DOC_DIR}/analysis/ANALYSIS-{IDEA-ID}.md` 中当前 MVP 章节 |
| 可选输入 | `knowledge/product/`、`knowledge/business/`（按需加载，禁止通读全仓） |
| 固定输出 | `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md` |
| 不产出 | ADD、TDD、代码（使用下游 sdx-design / sdx-test） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `IDEA-ID` | 与上游 `ANALYSIS-{IDEA-ID}.md` 共用 IDEA-ID |
| `--requirement` | 否 | — | 上游需求分析编号，自动定位对应文件 |
| `--mvp` | 否 | `1` | 目标 MVP 阶段编号（对应 `MVP-Phase-{N}` 与文件名 `{N}`） |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 已有需求分析，需将 MVP 转化为详细产品需求 | ✅ |
| 需编写完整业务流程、用户故事与用例 | ✅ |
| 收到业务需求/工单，需先输出解决方案文档 | ❌ → sdx-solution |
| 已有解决方案，需进行需求分析与 MVP 拆分 | ❌ → sdx-analysis |
| 已有 PRD，需技术方案设计 | ❌ → sdx-design |
| 已有 PRD 与 ADD，需测试设计 | ❌ → sdx-test |

---

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 严格遵循 `prd-template.md` 十一章；无内容章节保留标题并标注「不适用」 |
| 证据优先 | 用户故事与业务规则须引用 FR-n / BR-n，禁止臆测 |
| MVP 聚焦 | 仅覆盖 `--mvp` 对应范围，不混入后续 MVP |
| 业务可读 | 正文以产品/业务语言为主；细则见 [reference/audience-and-language.md](reference/audience-and-language.md) |
| 歧义标注 | 不确定项标为待澄清，暂停确认，禁止自行假设 |
| 可追溯 | US-n→FR-n，UC-n↔US-n，BR-n 与 ANALYSIS 一致，AC/NAC 可指回 US 或 §9 |
| 自查勾选 | §11.3 已通过项须为 `- [x]`；未通过项保持 `- [ ]` 直至修复 |

完整原则、FR 句式、反模式、编号体系与错误处理见 [reference/design-principles.md](reference/design-principles.md)。

---

## 命名约定

- 落盘路径（应用知识库）：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`
- 阶段目录：`MVP-Phase-{N}`（不是 `MVP-{N}/`），`{N}` 为正整数
- IDEA-ID 与上游 `ANALYSIS-{IDEA-ID}.md` 完全一致，不得只写日期而省略 slug
- 元数据位置：文末「## 文档元数据」下的 fenced YAML；**禁止**在文件开头使用 `---` frontmatter

---

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（必需） | `sdx-analysis` | 提供需求分析文档与 MVP 拆分 |
| 上游（可选） | `docs-build` | 提供 `knowledge/` 基线 |
| 下游 | `sdx-design` | 基于 PRD 进行技术方案设计 |
| 下游 | `sdx-test` | 基于 PRD 与 ADD 进行测试设计 |

---

## 参考资源（按需打开）

| 资源 | 路径 | 何时读 |
|------|------|--------|
| brainstorming 嵌入、与独立 `/brainstorming` 的差异、Gn 内多方案子流程 | [reference/brainstorming-integration.md](reference/brainstorming-integration.md) | 阶段二对话节奏、多方案取舍时 |
| 门禁状态机、精简 6G、回跳影响面、Q-n 协议、填充算法（原五步） | [reference/workflow-spec.md](reference/workflow-spec.md) | 流程不确定、阶段三按章填充时 |
| 核心概念与 IDEA-ID / 编号规则 | [reference/core-concepts.md](reference/core-concepts.md) | 编号规则不确定时 |
| 受众定位与语言转写规则 | [reference/audience-and-language.md](reference/audience-and-language.md) | 终检或语言审查时 |
| 设计原则与错误处理 | [reference/design-principles.md](reference/design-principles.md) | 遇到边界判断或错误场景时 |
| 反模式与常见陷阱 | [gotchas.md](gotchas.md) | 遇到流程设计、用户故事、MVP 范围相关问题时 |
| 质量验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 终检、§11.3 逐项勾选时 |
| PRD 文档模板（十一章） | [assets/prd-template.md](assets/prd-template.md) | 阶段三生成终稿时 |
| 会话草稿骨架 | [assets/prd-session-spec-template.md](assets/prd-session-spec-template.md) | 阶段二落草稿时 |

---

## 工程化支持

仓库 [.agent/hooks.json](../../hooks.json) 注册了 `preToolUse` 钩子（`Write` / `StrReplace`），脚本见 [.agent/hooks/sdx-prd-gate-write.py](../../hooks/sdx-prd-gate-write.py)；需启用 Hooks 方生效。
