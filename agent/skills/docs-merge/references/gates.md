# docs-merge 推进协议（binding）

## 共享契约

绑定 [写前意图澄清](../../../references/intent-clarify.md)、[单元推进](../../../references/unit-cycle-protocol.md) 与 [写后烤干](../../../references/grilling-skill.md)。本文件只补 docs-merge 差额；步骤见 [workflow.md](workflow.md)，合入规则见 [merge-spec.md](merge-spec.md)。

## 当前单元与追加字段

当前单元是一个已存在 target 与本批 source 的一次合入计划，含 dry-run 预览。公共六项外补：

- source 类型及路径/正文，target 路径，正式或 dry-run 模式。
- 落位摘要及未落位数；正式写前须为零。
- 新增 A、更新 U、合计 N、无变更 D 与逐项决议状态。
- 是否由 dry-run 转正式；源与目标是否仍匹配原计划基线。

## 授权与停顿

逐项答复收口具体内容与冲突；决议齐备后，写前 `C` 授权将该版本计划写入当前单元。二者不能互相替代。已有有效确认沿用；dry-run 的 `C` 不能当作正式写入授权。

参数歧义、未落位、冲突未决、范围变化或基线改变时，先列结论、推荐与数字选项，解决当前问题再继续。清单中的逐项流转与项内冲突规则见 [合入规范 §6](merge-spec.md#6-逐项提问确认新增--更新)。

`F` 依共享协议批确认剩余意图，不能据此默认采纳尚无决议的合入项；`S` 与恢复遵循[共享暂停契约](../../../references/unit-cycle-protocol.md#s暂停与恢复)。当前单元收敛后停等，不能自动换 target 或追加 source。

## 写后与失败

唯一写后默认表见 [workflow.md](workflow.md#写后默认表)。预览与正式执行都必须烤干；语义问题按共享协议处理。

候选内容、并发修改、失败恢复和源只读按 [合入规范 §7](merge-spec.md#7-落盘) 执行。不得将“要求原子写回”表述成未经工具验证的原子性保证。
