# sdx-feature 工作流

将同库已共识的 ANALYSIS 细化为六章 FEATURE。推进停点见 [gates.md](gates.md)，内容约束见 [core-concepts.md](core-concepts.md)。

## 参数向导

先读工程 `.docsconfig`，确定 `DOC_DIR`、`KNOWLEDGE_TYPE`，再读取指定上游和已有 FEATURE。只补未决参数；用户已明确的值与授权不重复询问。

| 参数 | 处理 |
| --- | --- |
| 上游 / IDEA-ID | 使用同库 `ANALYSIS-{IDEA-ID}.md`，继承其 IDEA-ID |
| 标题 | 沿用用户主题或上游题名 |
| depth | 默认 `standard`；`quick` / `deep` 差异见 core-concepts |
| 当前段 | 指定章、小节或 FR；新文档默认 §1，续写先核实已有确认状态 |

缺多项可逐项确认，也可提供「标准全篇 / 快速补段 / 深度评审」组合。参数向导不替代当前段的意图澄清。

## 产物路径

| 产物 | 路径 |
| --- | --- |
| FEATURE | `{DOC_DIR}/features/FEATURE-{IDEA-ID}.md` |
| 新技术决策（仅需要时） | `{DOC_DIR}/adr/ADR-*.md`、`{DOC_DIR}/adr/CONTEXT.md` |

路径须属于系统或应用库。已有文件先读后改；仅新文档初始化标题、frontmatter、六章标题和必要表头。未写章节标待补充，不能把模板示例当成已确认需求。创建骨架不代表正文已获授权。

## 分段生成

1. 按 [意图澄清](../../../references/intent-clarify.md) 收口当前段；补充字段见 gates。沿用适用于本段的明确授权，仍有范围或语义缺口时先问清。
2. 按 [精简原则](../../../references/simplify-principles.md) 写入。只读取本段需要的上游章节、知识索引及命中实体，不通扫 `knowledge/**`。
3. §2 先写概览，再按已确认清单写 FR；FR 段可同步对齐对应概览行，涉及已确认语义时按前文回改处理。§2 收口检查清单与正文一致。
4. §4 按交付价值和依赖装载 FR，不把里程碑数量机械转换为 MVP 数量。规则与验收见 core-concepts。
5. 按下表烤干，再依 [单元推进协议](../../../references/unit-cycle-protocol.md) 返回 `C/M/G/F`（无 `S`）。显式改变推进方式的用户指令见 gates。

## 写后默认表

| 对象 | 默认烤干 | 检查重点 |
| --- | --- | --- |
| 章节、小节、概览、单个 FR | 必须 | 证据、范围、内容约束、跨段一致性、受众 A/B/C/E |

使用 [烤干契约](../../../references/grilling-skill.md) 与本地 [受众要求](audience-and-language.md)。当前段有两条以上真实可行路径时先比选；只有一条时不凑方案。语义冲突、前文回改和技术决策停点见 gates。

## 结构校验

脚本依赖 Bash 5+、Python 3 标准库。显式 `--file` 相对调用时目录解析，可在无 `.docsconfig` 的目录检查文件；省略它时使用共享 docsconfig 解析并扫描文档根 `features/FEATURE-*.md`。

```bash
bash agent/skills/sdx-feature/scripts/validate-feature.sh --help
bash agent/skills/sdx-feature/scripts/validate-feature.sh --file path/to/FEATURE-xxx.md --strict
```

- 默认模式：内容问题报 warning；读取失败或 frontmatter 不闭合等致命问题返回非零。
- `--strict`：内容 warning 也返回非零。阶段性草稿用默认模式观察缺口，完整交付用严格模式。
- 检查实际章节内的结构、元数据同链、概览与 FR 对齐、MVP 装载及 ADR 引用；注释和代码围栏中的示例不充当正文。
- 解析范围为模板的 ATX 标题、管道表格、frontmatter 边界与字段，不提供完整 YAML/Markdown 语法验证。ADR/CONTEXT 使用本地内联 Markdown 链接；显式 ADR 链接须指向本层实际文件。
- 无文件时报告未执行内容检查，不把空扫描视为终稿验收。
- 不验证里程碑是否忠实于上游、模块语义、业务价值、依赖图无环、共识状态或会话确认；这些须人工/Agent 对照证据评审。

收尾对照 [质量清单](quality-checklist.md)，区分脚本结果与语义评审结果，不将退出码等同于已确认。
