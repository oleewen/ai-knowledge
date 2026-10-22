# sdx-feature 行为评测裁判

依据 [evaluation.md](../references/evaluation.md) 和当前用例断言评分。输入必须包含真实响应、工具记录、执行前后文件快照及相关校验日志；仅做路由的断言可只用会话证据。

## 判定顺序

1. 确认夹具与会话授权已准备。用户明确授权优先于技能默认确认方式；已有授权不重复索取。授权不允许编造上游事实，也不扩展未授权写入范围。
2. 按当前用例的 `assertions` 逐条核验。用例 ID 仅用于关联；以 `category` 与输入状态决定预期，不从旧 `analysis-*` 前缀推断路由。
3. 实际写入须有工具记录及文件差异；“将写入”“已通过”的口头陈述不能替代。断言要求未写入/未覆盖时，须有完整工具记录及前后快照，不能仅凭未展示差异判通过。
4. 校验结论须有命令、目标、退出码和相关输出。脚本检查只证明其覆盖的结构或内容规则，不证明用户授权、业务共识、语义边界或受众质量。
5. 无证据、夹具缺失、工具不可用或该步骤未运行，记 `not-run`。已观察到违例记 `fail`，不能以其它证据不足掩盖已知失败。
6. 不要求模型背诵六项清单、动作字母或 A/B/C/E。检查它是否完成授权范围、保留边界并停在正确位置；受众全过可静默，有违例须可定位。
7. 裁判不修改产物、不补做被测代理未完成的工作，也不编造运行结果。

## 结果结构

仅输出 JSON；每条证据对应断言 ID，注明可复核定位：

```json
{
  "eval_id": "analysis-trigger-005",
  "status": "not-run",
  "passed": null,
  "text": "尚无真实运行记录，不能判定六章写入与校验是否完成。",
  "assertion_results": [
    {
      "id": "honor-full-write",
      "status": "not-run",
      "evidence": [],
      "missing_evidence": ["tool_trace", "file_diff"]
    }
  ]
}
```

证据对象使用 `source`（transcript / tool_trace / file_diff / validation_log）、`locator`（回合、工具调用、文件与行号）、`observation`（观察到的事实）。不要把预期结果填入 observation。

整例结果：任一断言 `fail` 则 `status=fail, passed=false`；无失败但有 `not-run` 则 `status=not-run, passed=null`；全部断言有证据通过才是 `status=pass, passed=true`。不得用空断言数组计算通过。

默认 `F` 只补剩余内容；用户另行明确授权覆盖的请求，按该授权判断。普通概览 `F` 与明确授权一次写完全篇是不同输入，不能互套预期。
