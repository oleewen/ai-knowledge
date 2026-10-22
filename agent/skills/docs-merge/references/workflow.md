# docs-merge 工作流

从材料得到可审阅的增量计划，再按已确认决议一次写回。规则见 [merge-spec.md](merge-spec.md)，共享协议绑定见 [gates.md](gates.md)。

## 参数向导

收口 source、已存在的单个 target 与正式/`--dry-run` 模式；已有明确输入直接沿用。参数判定按 [合入规范 §1](merge-spec.md#1-解析-source--target)。

overview 第三列关键词提炼交 `docs-extract`；正文精简交 `docs-simplify`；术语替换交 `docs-revise`。仅目标文件名含 overview 不构成分流依据。

## 执行顺序

1. **检查输入**：读取源、目标并记录基线；按需读取 knowledge 治理规则。
2. **拟定计划**：切块、落位、去重、标记冲突，公布变更清单。此时可以展示草案与缺口，不写文件。
3. **意图澄清**：正式模式先收口落位，再按 [合入规范 §6](merge-spec.md#6-逐项提问确认新增--更新) 逐项决定新增、更新与冲突；决议齐备后，汇总 [共享六项](../../../references/intent-clarify.md) 及本地字段，取得正式写前 `C`。dry-run 只确认预览范围，可保留未落位和内容冲突供审阅。
4. **生成**：按下表执行。正文遵循 [精简原则](../../../references/simplify-principles.md)，不改变未确认的含义。
5. **烤干**：核对 [验收清单](quality-checklist.md) 与 [受众要求](audience-and-language.md)，报告实际结果、未决问题，按 [单元推进协议](../../../references/unit-cycle-protocol.md) 停等动作。

| 模式 | 生成内容与停点 |
| --- | --- |
| dry-run | 完整计划与清单；无文件写入，进入烤干 |
| 首次正式 | 逐项决议与正式写前 `C` 齐备后，一次写回 |
| dry-run 转正式 | 重读基线，按正式模式收口落位与逐项决议，再取得正式写前 `C` 并写回 |
| 无增量或全部跳过 | 报告无写入，核对文件未变后进入烤干 |

首次正式执行不重复索取同一份写前 `C`。跨模式、新增材料或改变范围时，重核受影响计划与授权。

## 写后默认表

| 当前单元 | 默认烤干 | 检查重点 |
| --- | --- | --- |
| 单个 target 与本批 source 的计划或写入 | 必须 | 落位、计数、逐项决议、冲突、源只读、无关内容保留、引用与受众 |

## 命令示例

```text
/docs-merge ./notes/snippet.md ./docs/guide.md --dry-run
/docs-merge "支持用户下单、支付、退款三个流程" ./docs/guide.md
```

正式合入使用同一组参数并省略 `--dry-run`；预览通过不自动授权正式写入。
