# docs-agent 推进协议

共享契约：

- [intent-clarify.md](../../../references/intent-clarify.md)：写前六项澄清。
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)：`C/M/G/S/F`、单元推进与重开。
- [grilling-skill.md](../../../references/grilling-skill.md)：写后烤干。

## 当前单元

当前单元是单个根入口文件：`README.md` 或 `AGENTS.md`。`output=both` 默认按 README、AGENTS 顺序处理，一次只处理一个。

## 写前追加字段

公共六项之外，必须收口：

- 写入策略：`merge`、`overwrite` 或待确认。
- Index 锚点：本轮使用的 `INDEX-GUIDE.md` 相对路径。

未获写前 `C` 不得写入。当前单元烤干收敛后，等待 `C/M/G/S/F`；不得自动推进第二文件。

## 必须停下的情况

先给结论、推荐和数字选项，再等待确认：

- `create` / `update` 或覆盖边界不清。
- README 与 AGENTS 的职责分工需要改变。
- `output=both` 但用户只明确一个文件。
- 保留现有正文、链接或命令的口径不清。

## Index 边界

按 [execution-spec.md](execution-spec.md) 查找落盘 Index；找不到时停止并转 `/docs-indexing`。本技能只消费 Index，不重写其正文。
