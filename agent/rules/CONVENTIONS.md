# AI AGENTS 开发约定

## 适用范围

本文件是 `agent/rules/` 的规则总入口，适用于本仓库的文档工程与知识库治理工作。  
本仓库核心形态为 **Markdown/YAML 知识库 + Bash 初始化脚本**，不应套用与当前仓库无关的业务代码约束。

---

## 一、规则索引

| 分类 | 文件 | 说明 |
| --- | --- | --- |
| 编码与协作（`coding/`） | [coding/git-guidelines.md](coding/git-guidelines.md) | Git 提交规范：Conventional Commits、**提交前须经用户确认**、**SSH 优先（`origin` 静默修正）**、原子提交、检查清单 |
| 编码与协作（`coding/`） | [coding/project-structure.md](coding/project-structure.md) | 项目结构与分层职责约定（用于组织文档与工程目录） |
| 编码与协作（`coding/`） | [coding/java-guidelines.md](coding/java-guidelines.md) | 语言专项参考（仅在对应技术栈项目落地时启用） |
| 编码与协作（`coding/`） | [coding/maven-guidelines.md](coding/maven-guidelines.md) | 构建专项参考（仅在 Maven 项目落地时启用） |
| 设计（`design/`） | [design/design-guidelines.md](design/design-guidelines.md) | 设计规则总纲：术语一致性、架构表达、评审基线 |
| 测试（`testing/`） | [testing/testing-guidelines.md](testing/testing-guidelines.md) | 测试策略与质量门槛总则 |
| 文档（`document/`） | [document/document-guidelines.md](document/document-guidelines.md) | 文档写作与注释规范（结构、可读性、可追溯） |
| 文档产出闸门 | 下文 [第三节](#artifact-gates) | SDD（solution / analysis / design / prd / test）与 docs-distill：中间 spec、闸门标记、环境变量例外与 Skill 指针（总表） |

---

## 二、关键约定（摘要）

### 1) 文件引用强校验

- `agent` 内文件引用，避免误用仅能在根目录解析的短链：
  - Agent 语义可达
  - `agent/` 内文件引用，须以相对当前文件为准。
  - `agent/` 外文件引用，须用仓库根 **`REPO_ROOT`** 相对路径（目标工程侧与 `.docsconfig` 之 **`REPO_ROOT`** 语义一致，见 [scripts/README.md](../../scripts/README.md)）。
  - 仓库根执行自检：`bash agent/scripts/validate-agent-md-links.sh`。

### 2) Skills 与脚本边界

- `skills/` 中 `SKILL.md` 是工作流定义，不是可执行脚本。
- Slash 命令清单与用法以 `../skills/README.md` 为准，本文件不重复维护命令详情。

### 3) Git：提交前确认与 SSH 优先

- **禁止**未获用户明确同意即执行 `git commit` / `git push`（Agent 与全部 Skill 工作流同责）。细则与例外见 [coding/git-guidelines.md](coding/git-guidelines.md) 第一节。
- 远程操作（`fetch` / `pull` / `push`）默认 SSH；`origin` 为 HTTPS 时 Agent 静默修正。细则见 [coding/git-guidelines.md](coding/git-guidelines.md)「远程传输：SSH 优先」。

### 4) superpowers 引用隔离

#### superpowers-ref-isolation

`{docroot}/superpowers/`（如 `docs/superpowers/`）为会话闸门 spec 与 brainstorming 设计备忘区，**不是**正式 SSOT。

- **禁止**：除 `{application|system|company|docs}/superpowers/**` **内部**外，全仓任何文件不得引用 superpowers 下**具名文件**（路径含 `superpowers/(specs|plans)/YYYY-MM-DD-` 且指向 `.md` 文件名）。
- **允许**：目录契约（`{DOC_DIR}/superpowers/specs/`）、占位模式（`YYYY-MM-DD-<topic>-*.md`、`*-docs-indexing.md`）、hooks 通用正则、无日期测试桩（如 `x.md`）。
- **验收**（仓库根）：`bash agent/scripts/check-forbidden-file-refs.sh`；套件：`bash agent/scripts/tests/forbidden-file-refs/run.sh`。
- **细则**：见 [session-spec-path.md](../references/session-spec-path.md)；上游 decouple 设计备忘位于 `docs/superpowers/specs/`（superpowers 内部，库外不链具名文件）。

---

## 三、文档产出闸门（SDD 与 docs-distill）

### artifact-gates

### 共通模式

对受管终稿或等价写入（含工具调用）前：

1. **须先**完成中间会话 spec：路径符合 `{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-<阶段后缀>.md`，见 [session-spec-path.md](../references/session-spec-path.md)），并完成闸门 **用户总确认**（阶段后缀与 Skill 见下表）。
2. 在会话 spec 文末使用标记：`<!-- <stage>-gate: CONFIRMED -->`（总确认前为 `PENDING`）；文中须出现目标终稿文件名，或（`docs-distill`）须写明目标应用与 `--full` / `--since` / `--dry-run` 等关键参数摘要，供钩子与校验脚本识别。
3. **例外**：用户在同一对话中**明示**跳过闸门或授权直写终稿时，可遵循用户指令；或按下表设置环境变量为 `1`（仅限人工知情场景，仅适用于有环境变量例外的阶段）。`docs-distill`、`docs-extract`、`docs-archive`、`docs-build`、`docs-indexing` **无 bypass 环境变量**，须完整走确认流程。

完整流程、HARD-GATE 与校验命令见各阶段 `agent/skills/<...>/SKILL.md`。

### 总表

| 阶段 | 规则 globs（Cursor） | 终稿 / 写入范围 | 中间会话 spec 文件名后缀 | 闸门标记 | 环境变量例外 | Skill |
| --- | --- | --- | --- | --- | --- | --- |
| sdx-solution | `application/solutions/**/*`、`company/solutions/**/*` | `{DOC_DIR}/solutions/SOLUTION-*.md` | 可选工作稿（无固定后缀要求） | 无 HTML gate；按当前段状态与 `C/M/G/S/F` 推进 | 无 | [sdx-solution/SKILL.md](../skills/sdx-solution/SKILL.md) |
| sdx-analysis | `application/analysis/**/*`、`company/analysis/**/*` | `{DOC_DIR}/analysis/ANALYSIS-*.md` | `-sdx-analysis.md` | `<!-- sdx-analysis-gate: CONFIRMED -->` | `SDX_ANALYSIS_ALLOW_ANALYSIS_WRITE` | [sdx-analysis/SKILL.md](../skills/sdx-analysis/SKILL.md) |
| sdx-architect | `application/requirements/**/ASD-*.md` | `application/requirements/**/ASD-*.md` | `-sdx-architect.md` | `<!-- sdx-architect-gate: CONFIRMED -->` | `SDX_ARCHITECT_ALLOW_ASD_WRITE` | [sdx-architect/SKILL.md](../skills/sdx-architect/SKILL.md) |
| sdx-design | `application/requirements/**/DSD-*.md` | `application/requirements/**/DSD-*.md` | `-sdx-design.md` | `<!-- sdx-design-gate: CONFIRMED -->` | `SDX_DESIGN_ALLOW_DSD_WRITE` | [sdx-design/SKILL.md](../skills/sdx-design/SKILL.md) |
| sdx-prd | `application/requirements/**/*` | `application/requirements/**/PRD-*.md` | `-sdx-prd.md` | `<!-- sdx-prd-gate: CONFIRMED -->` | `SDX_PRD_ALLOW_PRD_WRITE` | [sdx-prd/SKILL.md](../skills/sdx-prd/SKILL.md) |
| sdx-test | `application/requirements/**/*` | `application/requirements/**/TDD-*.md` | `-sdx-test.md` | `<!-- sdx-test-gate: CONFIRMED -->` | `SDX_TEST_ALLOW_TDD_WRITE` | [sdx-test/SKILL.md](../skills/sdx-test/SKILL.md) |
| docs-distill | `system/knowledge/**/*`、`company/knowledge/**/*` | `system/knowledge/overview/` 受管区块及蒸馏相关日志的写入 | `-docs-distill.md` | `<!-- docs-distill-gate: CONFIRMED -->` | 无（必须走确认流程） | [docs-distill/SKILL.md](../skills/docs-distill/SKILL.md) |
| docs-extract | `system/knowledge/overview/**/*`、`company/knowledge/overview/**/*` | `system/knowledge/overview/*.md`、`company/knowledge/overview/*.md` 写入 | `-docs-extract.md` | `<!-- docs-extract-gate: CONFIRMED -->` | 无（必须走确认流程） | [docs-extract/SKILL.md](../skills/docs-extract/SKILL.md) |
| docs-archive | `system/knowledge/overview/**/*`、`company/knowledge/overview/**/*` | `system/knowledge/overview/*.md`、`company/knowledge/overview/*.md` 写入 | `-docs-archive.md` | `<!-- docs-archive-gate: CONFIRMED -->` | 无（必须走确认流程） | [docs-archive/SKILL.md](../skills/docs-archive/SKILL.md) |
| docs-build | `{DOC_DIR}/knowledge/**/*` | `{DOC_DIR}/knowledge/` 下 JSON、README、KNOWLEDGE_INDEX 写入 | `-docs-build.md` | `<!-- docs-build-gate: CONFIRMED -->` | 无（必须走确认流程） | [docs-build/SKILL.md](../skills/docs-build/SKILL.md) |
| docs-indexing | `**/index.md`、`**/changelogs/INDEXING-LOG.md` | 各文档根下 `index.md` 与对应 `changelogs/INDEXING-LOG.md` 主表写入 | `-docs-indexing.md` | `<!-- docs-indexing-gate: CONFIRMED -->` | 无（必须走确认流程） | [docs-indexing/SKILL.md](../skills/docs-indexing/SKILL.md) |

**说明**：`sdx-prd` 与 `sdx-test` 的规则 globs 均覆盖 `application/requirements/**/*`，以**文件名模式** `PRD-*.md` / `TDD-*.md` 区分终稿类型。

### 闸门分层说明

技能按写入风险分三层，闸门强度不同：

| 层级 | 技能 | 闸门形式 | hook 保护 |
| --- | --- | --- | --- |
| **高风险**（落盘 spec + hook） | sdx-analysis/prd/architect/design/test、docs-distill/extract/archive/build/indexing | 落盘 spec 文件（`{DOC_DIR}/superpowers/specs/`，见 [session-spec-path.md](../references/session-spec-path.md)）+ `PENDING` → `CONFIRMED` + hook 证据校验（`docs-indexing` 须在 spec 正文**逐字列出**本轮将写入的仓库根相对路径，与 `sdx_gate_common.py --gate indexing` 一致） | ✅ |
| **中高风险**（直写终稿 + 段落推进协议） | sdx-solution | 参数向导 + 分段直写终稿 + 当前段 `C/M/G/S/F`；可选工作稿仅作暂存，不要求落盘 spec / HTML gate | ❌ |
| **中等风险**（会话内确认书） | docs-upgrade、docs-agent | 会话内参数确认书 + Qclose-1，无需落盘 spec 文件；SKILL.md 中有 HARD-GATE 描述 | ❌（写入路径不固定或契约不要求 hook） |
| **低风险**（现有参数确认） | docs-change、docs-tag、docs-pull | 保持现有参数确认机制，不加 spec gate | ❌ |

### docs-distill 补充

- 会话 spec 除上述共通要求外，须写明目标应用与 `--full` / `--since` / `--dry-run` 等关键参数摘要。
- 涉及 `system/changelogs/CHANGE-LOG.md` 与 `system/application-*/changelogs/ARCHIVE-LOG.md` 的追加与锚点更新，与上述闸门**同一原子事务**，适用同一交互与确认要求。详见 [docs-distill/references/interaction-gate.md](../skills/docs-distill/references/interaction-gate.md)。

### docs-indexing 补充

- 会话 spec 除 `CONFIRMED` 标记外，须在正文中列出本轮将写入的 **`index.md` 与 `*/changelogs/INDEXING-LOG.md` 的完整仓库根相对路径**（例如 `application/index.md`），以便钩子区分多域同名文件。参数 `mode` / `depth` / `output` / `since` 摘要建议写入同一会话 spec。详见 [docs-indexing/references/interaction-gate.md](../skills/docs-indexing/references/interaction-gate.md)。
- **会话 spec 路径**：`{DOC_DIR}/superpowers/specs/` 中 `{DOC_DIR}` **优先**读目标工程 **`.docsconfig`** 的 `DOC_DIR=`；无配置或无效时默认为 **`docs`**。未在 `.docsconfig` 声明的 `application` / `system` / `company` 下不得放置会话 spec（见 [session-spec-path.md](../references/session-spec-path.md)）。

---

## 四、参考文档

- AI 协作说明：`agent/README.md`
- 知识库布局（路径、overview、流水线 SSOT）：[knowledge-layout.md](../references/knowledge-layout.md)
