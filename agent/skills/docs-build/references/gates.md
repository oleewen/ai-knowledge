# docs-build 推进协议（binding）

本文件只绑定技能特有约束；公共六项与动作状态见 [intent-clarify.md](../../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)。写后烤干见 [grilling-skill.md](../../../references/grilling-skill.md)，未安装 grilling 时用该文 fallback。

## 单元与写前确认

当前单元是一个视角批次、路径组或实体集合。前置为可用主 INDEX、已解析 DOC_DIR/知识层、明确批次及提取策略。

公共六项中：

- 范围列出本轮视角、来源、预计新增/变更 ID；重命名另列全部引用影响。
- 第 6 项列出仓库根相对的 `{DOC_DIR}/knowledge/{视角}/…/{ID}.md`、视角 `README.md`、可选报告，以及 **`{DOC_DIR}/INDEX-GUIDE.md` 第四章导航块**。INDEX 不位于 knowledge 内。
- 参数变化、跨批次依赖或多种修复方案需要决策时，先给结论、推荐和数字选项。既有确认适用于相同范围，不重复索取。

未获写前 `C` 不写当前单元；扩大范围、改 ID 或改变重建策略须重新澄清。

## 写后与失败停顿

- 所有批次默认必须烤干，含受众维 A/B/C/E；具体顺序见 [workflow.md](workflow.md)。
- 实体/README 预检失败，不归并导航；终检失败，不推进下一批。
- 保留已写内容与失败清单，修复后重跑对应校验；不得用批量覆盖或删除消除错误。
- 收敛后给共享协议 `C/M/G/S/F` 并停等用户。`S` 按 docs 语义族暂存当前单元。

主 INDEX 缺失、输出路径不明或层职责冲突时，停止依赖写入并说明所缺信息。脚本通过不能替代关系语义与证据核验。
