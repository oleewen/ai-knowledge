# docs-link 风险控制与确认点

[SKILL.md](../SKILL.md)；执行循环 [workflow.md](workflow.md)。

## 与 CONVENTIONS

按 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md#artifact-gates)，docs-link 为**低风险工程同步**：按参数确认与风险校核推进。

非 `--dry-run` **改双边 knowledge-links.yaml / 槽位软链** 或开启 **`--rewrite-http` 改正文** 前，须在对话取得用户明确同意。

## 参数确认

参数向导至少收口以下内容：

- 源仓 `KNOWLEDGE_TYPE`（须 company 或 system）
- `--link` / `--unlink`
- `--target`
- 名称（`app_name` 或系统名；可预填，须确认）
- 是否 `--rewrite-http`（默认否）
- 是否已完成 dry-run 并授权真写

满足任一时，先澄清再执行：

- 用户只说「建联一下」但未给 target / 动作
- 当前工作区不是合法源边
- 是否改正文 HTTP 不清

## 风险确认

以下情况属于风险项，必须先给出结论、推荐方案与动作选项，再等待用户确认：

- 当前仓非 company/system（须切换工作区）
- 目标缺 `knowledge-links.yaml` 或 `.docsconfig`
- 重复 link（将合并更新，不追加）
- unlink（删 parent 条 + 槽位软链）
- `--rewrite-http`（改正文；二次确认）
- dry-run 摘要与用户预期不一致
- 准备用 `F` 继续下一 `--target`

推荐会话格式（字母见 [light-flow-actions.md](../../../references/light-flow-actions.md)）：

```text
即将执行 /docs-link，当前参数如下：
- source KNOWLEDGE_TYPE: <company|system>
- action: <--link|--unlink>
- target: <路径或 URL>
- app-name / sys-name: <名或 n/a>
- rewrite-http: <yes|no>
- mode: <dry-run|apply>
- 当前单元: <源仓 × target>

C 确认当前单元 / M 修改参数 / S 跳过当前单元 / F 补齐剩余目标
```

## 默认授权边界

- 已收口参数下，可直接执行非语义性动作：读 `.docsconfig`、读 links、跑 `--dry-run`
- 真写、`--rewrite-http`、继续下一 target，按语义性处理（须确认）

## 约束

- 脚本 SSOT：`agent/skills/docs-link/scripts/docs-link.sh`（及 `link-config.sh`）；下级仓不再拷贝；旧残留不自动删
- 单目标单元；不静默批量
- unlink 不改正文 HTTP；共用 `*-slots/changelogs/` 保留
