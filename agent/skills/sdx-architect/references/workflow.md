# sdx-architect 工作流

按当前段直写 ASD；推进权限见 [gates.md](gates.md)，输出粒度见 [类型模式](knowledge-type-modes.md)。

## 参数向导

先复用请求和已读材料中的值，只补影响当前段的缺口；可逐项询问，也可一次确认组合。参数齐全不重复走问卷。

| 参数 | 取值与约束 |
| --- | --- |
| `DOC_DIR`、`KNOWLEDGE_TYPE` | 读取 `.docsconfig`；类型检查先于创建目录/文件 |
| PRD、`IDEA-ID`、`N` | 同一条已共识需求链；不能从主题臆造 ID 或用未确认基线替代 PRD |
| 标题、起始段、范围 | 新建默认从 §1 开始；续写以用户指定段为准 |
| `depth` | `quick` 补指定段；`standard` 默认；`deep` 加深方案取舍，均不越入 DSD |
| `spec-asd-*` | 按需生成；仅需要摘要时不创建独立规约 |

最小可写条件：类型允许、PRD 可读取并对齐、当前段范围明确、目标可写。必要输入缺失时先补齐，不创建替代业务事实。

## 终稿骨架初始化

新建任务参数收口后，用 [模板](../assets/asd-template.md) 初始化 frontmatter、三章标题和表头。保留未写标记；骨架不代表正文已确认。已有文件不重新初始化。

正文按 [写前意图澄清](../../../references/intent-clarify.md) 与 [单元推进](../../../references/unit-cycle-protocol.md) 执行。模板示例须替换成已核实内容；未读的 ANALYSIS、overview 不写成已核实来源。

## 产物路径

| 产物 | 路径 |
| --- | --- |
| ASD | `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ASD-{IDEA-ID}-{N}.md` |
| 可选概设规约 | `{DOC_DIR}/specs/spec-asd-{IDEA-ID}-{N}-{app-name}.md` |

`{app-name}` 使用 `a-z0-9._-`，与 `knowledge-links.yaml` 对齐。从上述 ASD 位置引用概设规约，使用 `../../../specs/spec-asd-…md`；不要写成同级 `./specs/`。实际输出布局不同则按真实位置计算相对链接。`docs-push` 的下游复制位置由其自身契约决定。

## Section Cycle（指针）

按 [gates.md](gates.md) 选定当前段。存在两条以上真实架构路径时，在段内比较约束、收益和代价，再由用户决定取舍。写后调用 [烤干能力](../../../references/grilling-skill.md)，不先攒整篇再集中收口。

## 写后默认表

| 对象 | 默认烤干 | 停顿条件 |
| --- | --- | --- |
| 章节、DD、服务变更项、交互链路、规约摘要行 | 必须 | 语义决策未确认，或触及前文边界、归属、模式、规约口径 |

## 整体验证与质量基线

当前段收口按 [质量清单](quality-checklist.md) 检查；全部完成或 `F` 补齐后，再查跨段一致性并执行严格校验。命令从目标工程内运行，脚本位置按安装后的 Agent 树替换：

```bash
bash agent/skills/sdx-architect/scripts/validate-asd.sh --help
bash agent/skills/sdx-architect/scripts/validate-asd.sh --strict --file path/to/ASD-ORDER-1.md
# 扫描 DOC_DIR/requirements 下全部 ASD
bash agent/skills/sdx-architect/scripts/validate-asd.sh --strict
```

使用 Bash 5+；`--file` 相对调用时目录。默认模式供草稿检查，警告不致退出失败；收尾用 `--strict`。无文件不代表已有 ASD 通过。

脚本检查 frontmatter 边界/模板字段、同链标识和正文结构，不解析完整 YAML，也不证明引用目标存在、业务语义正确或用户已确认。上述项目仍须人工/Agent 对照来源验收。
