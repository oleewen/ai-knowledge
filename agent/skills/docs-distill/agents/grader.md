# docs-distill Grader

按 `evals/evals.json` 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 按 `category` 区分 `should-trigger` 与 `should-not-trigger`。
2. 逐条核对 `assertions`；`evidence` 逐条记录断言 id、判定状态及实际证据；仅填 id 不能证明断言通过。
3. 任一 P0 失败即 `passed: false`。
4. `should-trigger` 需同时检查：参数与边、写前澄清、职责/粒度契约、全量、第三列 delta、dry-run 不写盘、写后烤干。
5. `should-not-trigger` 需点名正确下游，并且不把槽位 distill 作为主路径。

## 证据要求

保留 `text`、`passed`、`evidence` 字段；`evidence` 继续使用字符串数组，每条写明断言 id、`pass` / `fail` / `not_run` 及依据。逐条覆盖当前 eval 的全部 assertions，不能用样例中的子集替代本场断言。

- 响应行为：引用实际响应短句，并标明响应或步骤位置。
- 执行行为：给出实际工具调用、退出状态及关键输出；只说“将运行”不证明已执行。
- 产物行为：给出实际文件路径与相关内容、差异或只读前后对照。
- 未取得所需响应、工具轨迹或产物时标 `not_run`；缺证据不能推定通过。不存在实际执行时，不编造日志或文件。

任一 P0 为 `fail` 或 `not_run`，`passed` 均为 `false`；`text` 区分失败和未评测。只有全部 P0 有证据通过才可填 `true`。P1 也须逐条报告实际状态，不隐去未执行项。`must_not_conflict` 应核对完整响应和相关工具轨迹，不能仅凭某句话未出现判通过。

评测提示覆盖「契约缺失硬停」「双边冲突不偏边」「受众违例改写或停问」时，必须验证停顿、数字选项和落盘路径，不得只看技能名是否触发。

未运行示例（对应 eval id 1）：

```json
{
  "text": "未评测。尚无该场景的实际响应、工具轨迹或产物，不能判断通过。",
  "passed": false,
  "evidence": [
    "intent-clarify-before-write | not_run | 未提供实际运行记录，暂无可核对证据。",
    "system-edge | not_run | 未提供实际运行记录，暂无可核对证据。",
    "full-only-no-distill-log | not_run | 未提供实际运行记录，暂无可核对证据。",
    "dry-run-no-write | not_run | 未提供实际运行记录，暂无可核对证据。",
    "single-unit-stop | not_run | 未提供实际运行记录，暂无可核对证据。"
  ]
}
```
