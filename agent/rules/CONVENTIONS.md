# AI AGENTS 开发约定

> **结论**：本文是 `agent/rules/` 总入口；产出先判技能族，再按对应协议推进；闸门见 [#artifact-gates](#artifact-gates)。
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
| 文档产出协议 | 下文 [第三节](#artifact-gates) | 协议路由与共享约束 |

---

## 二、关键约定（摘要）

### 1) 文件引用强校验

- `agent/` 内：相对当前文件。
- `agent/` 外：仓库根相对路径（由 `WORK_SPACE`/`REPO_DIR` 拼出，见 [docs-install/SKILL.md](../skills/docs-install/SKILL.md)）。
- 自检：`bash agent/scripts/tools/validate-link-reachable.sh`。

### 2) Skills 与脚本边界

- `skills/` 中 `SKILL.md` = 工作流定义，非可执行脚本。
- Slash 清单以 [../skills/README.md](../skills/README.md) 为准；本文不重复命令详情。

### 3) Git：提交前确认与 SSH 优先

- **禁止**未获用户明确同意即 `git commit` / `git push`（Agent 与全部 Skill 同责）。见 [coding/git-guidelines.md](coding/git-guidelines.md)。
- 远程默认 SSH；`origin` 为 HTTPS 时 Agent 静默修正。见同文件「远程传输：SSH 优先」。

### 4) superpowers 引用隔离

#### superpowers-ref-isolation

工程根 `.superpowers/` 为会话材料区，规格、计划、执行证据分别放在 `specs/`、`plans/`、`sdd/`，不作为正式 SSOT。

- **禁止**：会话目录外不得引用 `.superpowers/` 或历史 `superpowers/` 下的任何具体文件，覆盖无日期、无扩展名及日志、JSON、diff。隐藏或被 Git 忽略的外部正文同样检查。知识库已有引用须先将必要结论整理至正式知识来源，再移除或改引。
- **允许**：会话目录内部互引、目录契约、占位模式和通用正则。测试用例在隔离夹具中构造路径，不在源码中写死具体会话文件引用。历史目录的内部豁免不代表它是合法的新产物落点。
- **验收**：`bash agent/scripts/tools/forbidden-ref-outer.sh`；套件：`bash agent/scripts/tests/forbidden-file-refs/run.sh`。
- **细则**：[session-spec-path.md](../references/session-spec-path.md)。

### 5) 文档分类矩阵（`title` / `H1` / `MD025`）

新增或改造 Markdown 前**先判类**，再定 `frontmatter title`、可见 `# H1` 与 `MD025`：

- **A** 人类入口 · **B** 机器规约 · **C** 元数据/混合。
- 细则与豁免见 [document/document-guidelines.md](document/document-guidelines.md)（本文不复述）。

---

## 三、文档产出协议（SDD 与 docs-*）

### artifact-gates

先按 [工作流路由](../references/workflow-routing.md) 判定技能族；语义族遵循 **澄清 → 生成 → 烤干**，轻流程按对应契约执行。技能名单与共享能力分工只在路由中维护。

- 写前收口目标、范围与输出，见 [意图澄清](../references/intent-clarify.md)。同范围且基线仍有效的明确授权沿用。
- 单元、动作与重开见 [推进协议](../references/unit-cycle-protocol.md)；轻流程及特例见 [轻流程动作](../references/light-flow-actions.md) 和各技能工作流。
- 写后检查见 [烤干](../references/grilling-skill.md)、[受众质检](../references/audience-and-language.md)；表达遵循 [精简原则](../references/simplify-principles.md)。
- 技能独有输入、产物路径、校验与失败处理，查对应 `SKILL.md` 及其 workflow/gates；入口见 [技能清单](../skills/README.md)。

---

## 四、参考文档

- AI 协作说明：[../README.md](../README.md)
- 知识库布局：[knowledge-layout.md](../references/knowledge-layout.md)
- 意图澄清 / 推进环 / 烤干 / 受众 / 精简原则：[intent-clarify.md](../references/intent-clarify.md) · [unit-cycle-protocol.md](../references/unit-cycle-protocol.md) · [grilling-skill.md](../references/grilling-skill.md) · [audience-and-language.md](../references/audience-and-language.md) · [simplify-principles.md](../references/simplify-principles.md)
