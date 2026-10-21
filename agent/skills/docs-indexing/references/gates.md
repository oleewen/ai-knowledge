# docs-indexing 推进协议（binding）

共享契约：

- [intent-clarify.md](../../../references/intent-clarify.md)：写前意图澄清。
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)：单元推进与 `C/M/G/S/F`。
- [grilling-skill.md](../../../references/grilling-skill.md)：写后烤干。

## 当前单元与写前条件

当前单元是一个 `INDEX-GUIDE.md` 及其文内锚点；一次只处理一个输出组。

写前六项清单按共享契约列出，补充 `mode/depth/output/since`、扫描范围与变更来源。第 6 项填写完整仓库根相对路径，例如 `application/INDEX-GUIDE.md（含文内锚点）`。

写入前须满足：

1. 仓库根、扫描范围和目标路径可解析，文件名为 `INDEX-GUIDE.md`。
2. mode、depth、output 已收口；incremental 有有效基线或用户已选择新的基线策略。
3. 已完成当前单元写前意图澄清并取得 `C`；此前只能只读检查或预览。

## 需要重新决策的情形

缺少增量基线、多个同名输出组无法区分、扫描范围或输出路径发生变化时，先说明影响，给出推荐与数字选项。不要重复确认已有明确授权的同一参数。

用户明确调整流程时遵循其指示；仍须取得执行所需事实，不能用流程豁免猜测基线或扩大写入范围。

## 写后与失败

写后默认见 [workflow.md](workflow.md)。指南、导航和基线解释验证通过后，才可收敛并等待写后动作；不得自动切换下一输出组。

- 只读请求不写指南、目录、配置或锚点。
- 当前单元失败则停在当前单元，保留原有完成锚点。
- 脚本运行成功仅证明候选统计完成；锚点只能在指南正文完成后显式更新。
- 重写须保留已有 docs-build 实体块；如其中引用需变更，报告给对应维护流程。
