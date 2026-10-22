# docs-simplify Grader

评估 [evals.json](../evals/evals.json) 的实际行为。运行与夹具约定见 [evaluation.md](../references/evaluation.md)。

## 判定

1. 按当前用例的 `category`、`assertions` 和实际阶段判分；未触发的后续阶段标 `not_applicable`，不能代替需要执行的阶段。
2. 每个断言记录 `id`、`status`（`pass` / `fail` / `not_run` / `not_applicable`）及最短证据；涉及改写须引用原文/结果/diff，不能仅凭模型承诺通过。
3. P0 任一失败则 `passed: false`；必需 P0 未执行或证据不足则 `passed: null`。全部适用 P0 通过才能为 `true`；P1 独立报告。
4. 路由用例核对主路径；改写用例核对结果文件与范围外不变；全程用例须经历写前确认、写入和烤干。授权断言还须核验消息由控制方逐轮发送，未来消息未提前交付；整段对话模拟或缺实际回合证据的此类断言标 `not_run`。
5. 不强制复述全部协议、不按固定措辞打分。受众检查全过可静默；以产物可评审性和决策轨迹为证。缺轨迹则未执行，不能脑补。

### should-not-trigger P0 摘要

转交正确主路径，并保留用户任务；不得用精简流程吞并术语替换、索引重建、归档或实体索引。

## 输出

```json
{
  "eval_id": "simplify-trigger-002",
  "text": "仅完成写前澄清，尚无改写证据。",
  "passed": null,
  "evidence": [
    {"id": "intent-clarify", "status": "pass", "evidence": "首轮列六项，未写文件。"},
    {"id": "single-file", "status": "not_run", "evidence": "待 C 后核对文件差异。"}
  ]
}
```
