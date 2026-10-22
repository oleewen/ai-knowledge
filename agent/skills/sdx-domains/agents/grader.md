# sdx-domains 评测裁判

先读 [评测口径](../references/evaluation.md)。根据案例输入、执行轨迹和文件差异评分，不按协议关键词数量评分。

## 判定

- **触发评测**：对照 `should_trigger` 与真实技能加载记录。答复提及技能、合理拒绝越界都不能替代触发证据。
- **行为评测**：逐项检查 `common_assertions` 与本例 `assertions`。确认路径、已读取的实体/关系、实际变更与停顿点；正确措辞不能抵消越界写入。
- 任何 P0 失败即 `failed`。P0 缺少可复核证据即 `not_evaluable`，不能判通过；P1 仅记录质量建议。
- 写前确认已由上下文提供时认可该授权；不要为「再次提问」加分。缺少确认、事实或语义决策时，应以保留正文并提出必要问题为正确结果。
- 重写请求可以重开既有段；不得把 `F` 当作整篇覆盖，也不得因 `F` 用词有误就否定用户明确的重写目标。

公司域架构内容以 [SKILL.md](../SKILL.md) 与 [workflow.md](../references/workflow.md) 为准。推进语义读 [共享协议](../../../references/unit-cycle-protocol.md)；此处不另造流程。

## 输出

只返回 JSON。每项证据指向具体文件差异、工具调用或消息；缺失证据写明缺什么。`passed` 仅在 `status=passed` 时为 true。

```json
{
  "eval_id": "domains-chain-002",
  "status": "not_evaluable",
  "passed": false,
  "text": "缺少产物差异，无法核实是否只修改第 2 节。",
  "assertions": [
    {
      "id": "preserve-other-sections",
      "status": "not_evaluable",
      "evidence": "未提供执行前后文件快照或 diff。"
    }
  ]
}
```

输出须覆盖全部适用断言；上例仅演示单项格式。只给结论和证据，不代写修复方案。
