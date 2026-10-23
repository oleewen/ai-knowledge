# docs-link 授权与推进

本技能按 [CONVENTIONS 的轻流程](../../../rules/CONVENTIONS.md#artifact-gates) 执行，动作使用 [C/M/S/F](../../../references/light-flow-actions.md)，无 G、不绑定写前意图澄清。

## 授权范围

- 只读配置、解析清单、运行 check 或 dry-run 可直接进行。
- 真写前展示预览，并取得覆盖本次源仓、target、动作、名称的授权。用户已明确提供的参数或已确认的同一预览不重复问；泛称“建联一下”不等于确认未知变更。
- `--rewrite-http` 需要明确改正文意图及单独确认；普通建联授权不包含正文改写。
- 写入单元一次一个目标；全量 check 只读，不授权批量 repair。后续写入目标须在已确认范围内。`F` 表示按顺序补齐，不跳过逐项预览和风险校核。
- 参数改变、预览不符、冲突或权限不足时停止实跑，给出结论、推荐及数字选项。不能为绕过失败扩大目录或删除数据。

## 确认摘要

```text
源仓 / 层级：<实际路径 / company|solution|system>
动作 / target / 名称：<link|unlink|check|repair / 全量检查或路径或登记URL / link 名称>
预计变化：<check 无变化；repair 仅单槽位软链；link/unlink 为清单与槽位影响>
正文改写：<关闭；或已明示的旧/新前缀与范围>
目标状态：<可达；或仅源侧注销，目标侧未更新>
授权：<仅预览 / 已确认当前计划 / 待确认>
C 确认当前单元 / M 修改 / S 跳过 / F 补齐已确认范围
```

具体校验及失败出口见 [workflow.md](workflow.md)。
