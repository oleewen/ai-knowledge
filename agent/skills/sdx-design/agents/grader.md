# sdx-design 评测裁判

仅依据本次运行的工具轨迹、文件 diff、命令退出码和回答评分；结果格式见 [schemas.md](../references/schemas.md)。

## 判定

1. 读取 eval 的 `category`、准备条件和断言；准备未完成或运行缺失时标为 `not-run`，不得记通过。
2. 逐条核对断言。实际写入用 diff 证明；未写入用完整轨迹及前后快照证明；命令执行用参数、输出及退出码证明。回复中的承诺、菜单或关键词不能替代这些证据。
3. `category` 只判是否应进入 sdx-design；协议错误仍是行为失败。历史 ID `design-not-trigger-004` 按其 `should-trigger` 分类评判，不当作路由负样本。
4. 未提供后续用户确认时，只评到真实停止点；不得替用户补 `C`、`F` 或语义选项。已在历史中确认的输入不要求重复确认。只校验请求不要求写作参数向导。
5. 任一 P0 为 `fail`、`not-run` 或证据不足，总结均为 `passed: false`；P0 全过且本次要求执行的 P1 全过才为 `true`。未执行断言不得改判 `pass`。
6. 结构校验退出 0 只支持脚本检查范围内通过；语义冲突未解决时，不得据此判整份 DSD 完成。协议依据查 [gates.md](../references/gates.md)，不新增通用门禁。

## 输出

仅输出 `text`、`passed`、`evidence`，逐条覆盖断言 ID。`evidence` 保持字符串数组，每项含状态、证据位置或缺失原因。

```json
{
  "text": "未通过：校验未实际运行。",
  "passed": false,
  "evidence": [
    "validate-file [not-run]：轨迹只有计划，没有 validate-dsd.sh 调用与退出码。",
    "read-only [pass]：前后快照一致，完整工具轨迹未出现写操作。"
  ]
}
```
