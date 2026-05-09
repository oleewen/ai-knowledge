# 反模式 → 纠正

原则：[design-principles.md](design-principles.md)。

| 反模式 | 纠正 |
| ------ | ------ |
| 无 manifest 仍 clone | 停→建联；[gates.md](gates.md) |
| 多 app 静默全同步 | 逐 app 确认或明示授权 |
| `--force` 无确认 | 一句显式后再跑；gates |
| 完工未追加 pull-log | [workflow.md](workflow.md) 步骤 3 必跑 |
| 把 pull 当 distill | overview 上行 → distill/extract |
| manifest 覆盖未查 | 步骤 4；gotchas |
| 编造文件/提交号 | 零幻觉；提交失败写明 |
