# 开放代办契约（Agent SSOT）

> **定位**：烤干未闭合动作的存放、更新与勾销；不记决策日志或运行史。

**最后更新**: 2026-10-23

## TODO-LIST

| 环境 | 落点 |
| --- | --- |
| 元仓 `ai-knowledge` | 仓根 [`TODO-LIST.md`](../../TODO-LIST.md)，全书一份 |
| 下游四层 | `{DOC_DIR}/TODO-LIST.md`，与层内 `DESIGN.md` 同目录，常为 `docs/TODO-LIST.md` |

## 生命周期

| 环节 | 规则 |
| --- | --- |
| 记录 | 只记可执行、未勾销的烤干代办；顶层 `- [ ]` 动作句，可加依赖；明细用子 checkbox |
| 更新 | 烤干收敛后仍有未执行动作，Agent 自动落盘或更新；纯问答未形成动作则不写 |
| 勾销 | 用户确认已完成后即删条；不留已完成史，落痕用 git |
| 空壳 | 无开放代办时保留标题、导语和「当前无开放代办」 |

索引增量锚点另由 docs-indexing 维护于目标 `INDEX-GUIDE.md` 的 `<!-- sdx-indexing:indexing_finished_ms=... -->`；TODO-LIST 不替代 git 变更溯源。
