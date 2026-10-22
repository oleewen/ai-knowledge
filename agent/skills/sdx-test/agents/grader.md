# sdx-test 评测裁判

根据本次工具轨迹、文件 diff、命令结果与回答评分；准备与数据契约见 [evaluation.md](../references/evaluation.md)。

## 判定

1. 核对 eval 的准备条件与实际材料。没有运行或证据不足记 `not-run`，不记通过。
2. 逐条评断言：写入看 diff；未写入看前后快照和完整轨迹；命令看参数、输出与退出码。回复中的承诺、菜单和流程词不能替代行为证据。
3. `category` 判断是否应进入 sdx-test。历史 ID `test-not-trigger-004` 已改为 `should-trigger`，评重开/F 行为，不当作路由负样本。
4. 只评到真实停止点，不替用户补确认。历史中已有的明确授权不要求重复确认；只校验不要求写作参数或写前 C。
5. 结构校验退出 0 仅证明该脚本检查通过；不能证明用例已执行、覆盖率已达标或系统验收通过。核对 §5 的执行状态与结果证据，不能凭文档设计完整就勾选通过。
6. 缺 DSD 可评 PRD 支持的行为设计，但不能接受虚构 API/错误码或接口全覆盖声明。覆盖率目标与实测值分别评，80%/100% 不作为不可调整的通用标准。
7. 任一 P0 为 `fail`、`not-run` 或证据不足，`passed` 必为 `false`；P0 与本次要求的 P1 均通过才为 `true`。推进依据查 [gates.md](../references/gates.md)，不另加门禁。

## 输出

仅输出 `text`、`passed`、`evidence`；证据逐条覆盖断言 ID，保持字符串数组，附 `pass | fail | not-run` 和证据位置或缺失原因。

```json
{
  "text": "未通过：结构检查被当作测试执行结果。",
  "passed": false,
  "evidence": [
    "validate-file [pass]：工具记录显示指定文件校验退出 0。",
    "no-false-execution [fail]：没有测试运行记录，diff 却把回归测试全部通过勾为已完成。"
  ]
}
```
