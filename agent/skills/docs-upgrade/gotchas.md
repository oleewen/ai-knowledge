# docs-upgrade 陷阱

遇到下列现象，先核对对应规则；不要临时改分类或扩大升级范围。

| 易错假设 | 核对位置 |
| --- | --- |
| 未传 ref 就是 main；传了 ref 可忽略脏工作区 | [源解析](references/workflow.md#源解析) |
| 当前版本号等于 HEAD；全仓新发布意味着全层文件升级 | [版本范围与推进](references/workflow.md#版本范围与推进) |
| scaffold 成功即可推进 version；指定 DESIGN 也可推进整库 | [版本最后更新](references/workflow.md#版本范围与推进) |
| 重填后一定已重写 Agent 路径；IDE 段也应改 | [路径收尾的执行边界](references/workflow.md#路径收尾) |
| 备份只含实际改动文件；指定模式也有 scaffold 备份 | [整树执行](references/workflow.md#整树执行)、[指定路径执行](references/workflow.md#指定路径执行) |
| 槽位真文件全部排除；changelogs 有单独保留策略 | [分类与排除](references/merge-rules.md#3-清单桶脚本) |
| 任意同前缀目录都是真实例；指定模式也跳示例 | [实例判定](references/merge-rules.md#31-整树缺失示例与真实实例) |
| 指定目录只扫描本库；附件必须带 @；脚本可传 --path | [路径展开](references/parameters.md#指定路径展开) |
| 未落位只需逐项菜单；轻流程 S 可跳过全部未落位 | [未落位策略](references/gates.md#未落位策略) |

根级 DESIGN 的本地契约修改会被元库模板覆盖；需要保留的模板契约应先更新元库。安装、Agent 更新与联邦操作分流见 [SKILL.md](SKILL.md)。
