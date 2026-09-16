# AI AGENTS 开发约定

> **结论**：本文是 `agent/rules/` 总入口；产出走参数向导 + `澄清 → 生成 → 烤干`；闸门见 [#artifact-gates](#artifact-gates)。  
> **范围**：本仓 Markdown/YAML 知识库 + Bash 初始化；勿套无关业务代码约束。

## 适用范围

适用于本仓库文档工程与知识库治理。

---

## 一、规则索引

| 分类 | 文件 | 说明 |
| --- | --- | --- |
| 编码与协作（`coding/`） | [coding/git-guidelines.md](coding/git-guidelines.md) | Git：Conventional Commits、**提交前须经用户确认**、**SSH 优先**、原子提交 |
| 编码与协作（可选） | [coding/project-structure.md](coding/project-structure.md) | **按需**：目标工程采用 DDD/六边形时启用；非本仓默认 |
| 编码与协作（可选） | [coding/java-guidelines.md](coding/java-guidelines.md) | **按需**：目标工程为 Java 时启用 |
| 编码与协作（可选） | [coding/maven-guidelines.md](coding/maven-guidelines.md) | **按需**：目标工程为 Maven 时启用 |
| 设计（`design/`） | [design/design-guidelines.md](design/design-guidelines.md) | 设计规则总纲 |
| 测试（`testing/`） | [testing/testing-guidelines.md](testing/testing-guidelines.md) | 测试策略总则 |
| 文档（`document/`） | [document/document-guidelines.md](document/document-guidelines.md) | 文档写作与 A/B/C 分类（`title` / H1 / MD025） |
| 文档产出协议 | 下文 [第三节](#artifact-gates) | 参数向导、共通模式、总表与闸门分层 |

---

## 二、关键约定（摘要）

### 1) 文件引用强校验

- `agent/` 内：相对当前文件。
- `agent/` 外：仓库根 **`REPO_ROOT`** 相对路径（与 `.docsconfig` 的 `REPO_ROOT` 一致，见 [docs-install/SKILL.md](../skills/docs-install/SKILL.md)）。
- 自检：`bash agent/scripts/tools/validate-link-reachable.sh`。

### 2) Skills 与脚本边界

- `skills/` 中 `SKILL.md` = 工作流定义，非可执行脚本。
- Slash 清单以 [../skills/README.md](../skills/README.md) 为准；本文不重复命令详情。

### 3) Git：提交前确认与 SSH 优先

- **禁止**未获用户明确同意即 `git commit` / `git push`（Agent 与全部 Skill 同责）。见 [coding/git-guidelines.md](coding/git-guidelines.md)。
- 远程默认 SSH；`origin` 为 HTTPS 时 Agent 静默修正。见同文件「远程传输：SSH 优先」。

### 4) superpowers 引用隔离

#### superpowers-ref-isolation

`{docroot}/superpowers/` 为会话工作稿区，**不是**正式 SSOT。

- **禁止**：除 `{application|system|company|docs}/superpowers/**` **内部**外，全仓不得引用 superpowers 下**具名文件**（路径含 `superpowers/(specs|plans)/YYYY-MM-DD-` 且指向 `.md`）。
- **允许**：目录契约、占位模式、hooks 通用正则、无日期测试桩。
- **验收**：`bash agent/scripts/tools/forbidden-ref-outer.sh`；套件：`bash agent/scripts/tests/forbidden-file-refs/run.sh`。
- **细则**：[session-spec-path.md](../references/session-spec-path.md)。

### 5) 文档分类矩阵（`title` / `H1` / `MD025`）

新增或改造 Markdown 前**先判类**，再定 `frontmatter title`、可见 `# H1` 与 `MD025`：

- **A** 人类入口 · **B** 机器规约 · **C** 元数据/混合。
- 细则与豁免见 [document/document-guidelines.md](document/document-guidelines.md)（本文不复述）。

---

## 三、文档产出协议（SDD 与 docs-*）

### artifact-gates

受管终稿或等价写入（含工具调用）前：

1. **参数向导**：收口关键参数、目标范围、输出路径与批量策略。
2. **一次一单元**：`sdx-*` 以章节/设计块为主；`docs-*` 以目标块/路径组/实体批次/归档块等为主。
3. **主线** `澄清 → 生成 → 烤干`：
   - 写前澄清：[intent-clarify.md](../references/intent-clarify.md)
   - 生成 → 烤干 → 动作/重开：[unit-cycle-protocol.md](../references/unit-cycle-protocol.md)
   - 烤干提问：[grilling-skill.md](../references/grilling-skill.md)
   - 受众质检：[audience-and-language.md](../references/audience-and-language.md)（烤干 A/B/C/E；轻流程写后 A/B）
   - 生成步原则：[simplify-principles.md](../references/simplify-principles.md)（默认强制；用户明示可豁免）；烤干修订后另有 **simplify 遍**（见 unit-cycle-protocol）
4. **绑定**：全部 `/sdx-*` 与语义族 docs-*（含 indexing/build/agent/simplify）绑意图澄清；`docs-okf` / `docs-link` / `docs-pull` / `docs-push` / `docs-tag` / `docs-install` / `agent-install` / `docs-upgrade` / `skill-upgrade` 维持轻流程。
5. **动作**：烤干收敛（或合法跳过）后，用户以 `C/M/G/F`（docs 另有 `S`）推进；`C` 同符异义，靠阶段横幅区分。
6. **语义变更**：先结论、推荐与数字选项，确认后再改。
7. **技能特有**：校验或确认书以该技能 `SKILL.md` / `gates.md` 为准。

完整流程见各 `agent/skills/<...>/SKILL.md`。

### 总表

**推进协议短码**（全文见上文；无 HTML gate / 无写前 hook）：

| 短码 | 含义 |
| --- | --- |
| **语义** | 意图澄清 + `澄清 → 生成 → 烤干` + `C/M/G/F`（`sdx-*`） |
| **语义-docs** | 同上，动作含 `S` → `C/M/G/S/F` |
| **轻** | 不绑意图澄清；`C/M/S/F` 见 [light-flow-actions.md](../references/light-flow-actions.md)（本表不列轻流程技能行） |

| 阶段 | 规则 globs（Cursor） | 终稿 / 写入范围 | 辅助工作稿 | 推进协议 | 环境变量例外 | Skill |
| --- | --- | --- | --- | --- | --- | --- |
| sdx-solution | `application/solutions/**/*`、`company/solutions/**/*` | `{DOC_DIR}/solutions/SOLUTION-*.md` | 可选工作稿 | 语义 | 无 | [sdx-solution/SKILL.md](../skills/sdx-solution/SKILL.md) |
| sdx-analysis | `application/analysis/**/*`、`company/analysis/**/*` | `{DOC_DIR}/analysis/ANALYSIS-*.md` | 可选工作稿 | 语义 | 无 | [sdx-analysis/SKILL.md](../skills/sdx-analysis/SKILL.md) |
| sdx-architect | `application/requirements/**/ASD-*.md` | `application/requirements/**/ASD-*.md` | 可选工作稿 | 语义 | 无 | [sdx-architect/SKILL.md](../skills/sdx-architect/SKILL.md) |
| sdx-design | `application/requirements/**/DSD-*.md` | `application/requirements/**/DSD-*.md` | 可选工作稿 | 语义 | 无 | [sdx-design/SKILL.md](../skills/sdx-design/SKILL.md) |
| sdx-prd | `application/requirements/**/*` | `application/requirements/**/PRD-*.md` | 可选工作稿 | 语义 | 无 | [sdx-prd/SKILL.md](../skills/sdx-prd/SKILL.md) |
| sdx-test | `application/requirements/**/TDD-*.md` | `application/requirements/**/TDD-*.md` | 可选工作稿 | 语义 | 无 | [sdx-test/SKILL.md](../skills/sdx-test/SKILL.md) |
| docs-agent | `README.md`、`AGENTS.md`（仓库根） | 根 `README.md` / `AGENTS.md`（一次只其一） | 可选工作稿 | 语义-docs | 无 | [docs-agent/SKILL.md](../skills/docs-agent/SKILL.md) |
| docs-distill | `system/knowledge/**/*`、`company/knowledge/**/*` | `system\|company/knowledge/overview/` 受管第三列 | 可选工作稿 | 语义-docs | 无 | [docs-distill/SKILL.md](../skills/docs-distill/SKILL.md) |
| docs-extract | `system/knowledge/overview/**/*`、`company/knowledge/overview/**/*` | `system|company/knowledge/overview/*.md` | 可选工作稿 | 语义-docs | 无 | [docs-extract/SKILL.md](../skills/docs-extract/SKILL.md) |
| docs-archive | `system/knowledge/overview/**/*`、`company/knowledge/overview/**/*` | `system|company/knowledge/overview/*.md` | 可选工作稿 | 语义-docs | 无 | [docs-archive/SKILL.md](../skills/docs-archive/SKILL.md) |
| docs-build | `{DOC_DIR}/knowledge/**/*` | `{DOC_DIR}/knowledge/` 下 JSON、README、KNOWLEDGE-INDEX | 可选工作稿 | 语义-docs | 无 | [docs-build/SKILL.md](../skills/docs-build/SKILL.md) |
| docs-indexing | `**/INDEX-GUIDE.md`、`**/changelogs/INDEXING-LOG.md` | 各文档根 `INDEX-GUIDE.md` 与对应 `INDEXING-LOG.md` | 可选工作稿 | 语义-docs | 无 | [docs-indexing/SKILL.md](../skills/docs-indexing/SKILL.md) |
| docs-revise | 不固定（按用户确认范围） | 已确认范围内的 Markdown / 注释 / 配置文本 | 可选工作稿 | 语义-docs | 无 | [docs-revise/SKILL.md](../skills/docs-revise/SKILL.md) |
| docs-simplify | 不固定（按用户确认范围） | 已确认范围内的 Markdown（默认排除索引/日志/生成物，点名则纳入） | 可选工作稿 | 语义-docs | 无 | [docs-simplify/SKILL.md](../skills/docs-simplify/SKILL.md) |

**说明**：`sdx-prd` / `sdx-test` 的 globs 均覆盖 `application/requirements/**/*`，以文件名 `PRD-*.md` / `TDD-*.md` 区分。  
技能专细则见各 skill `gates.md`，不在本文件展开。

### 闸门分层说明

| 层级 | 技能 | 推进协议 | hook |
| --- | --- | --- | --- |
| **中高风险** | sdx-*、docs-distill、docs-extract、docs-archive、docs-build、docs-indexing、docs-revise、docs-simplify | 语义 / 语义-docs | ❌ |
| **中等风险** | docs-agent | 语义-docs | ❌ |
| **低风险** | docs-tag、docs-pull、docs-okf、docs-push、docs-install、agent-install、docs-upgrade、skill-upgrade | 轻 | ❌ |

---

## 四、参考文档

- AI 协作说明：[../README.md](../README.md)
- 知识库布局：[knowledge-layout.md](../references/knowledge-layout.md)
- 意图澄清 / 推进环 / 烤干 / 受众 / 精简原则：[intent-clarify.md](../references/intent-clarify.md) · [unit-cycle-protocol.md](../references/unit-cycle-protocol.md) · [grilling-skill.md](../references/grilling-skill.md) · [audience-and-language.md](../references/audience-and-language.md) · [simplify-principles.md](../references/simplify-principles.md)
