# skill-upgrade 行为评分

读取 [evals.json](../evals/evals.json)，按每个场景的 `assertions` 评估实际动作与输出，返回 `text`、`passed`、`evidence`；证据对应 assertion ID。

- `should-trigger` 检查升级、范围和授权行为；`should-not-trigger` 检查是否分流。
- P0 任一失败则该场景失败。未运行场景记「未执行」，不能当通过。
- 判定行为，不要求复述固定标题、动作字母或质检术语；受众 A/B 全过可静默。
- 预览场景不得执行真实 update/add。行为模拟须使用给定事实；缺少 CLI 能力证据时应保留待核实状态。

执行边界见 [gates.md](../references/gates.md)，分类依据见 [workflow.md](../references/workflow.md)，候选规则见 [find-source.md](../references/find-source.md)。
