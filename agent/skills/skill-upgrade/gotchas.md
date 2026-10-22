# skill-upgrade 易错处

| 误判 | 正确处理 |
| --- | --- |
| lock 中有记录，所以存在更新 | 本地记录仅证明已登记；远端状态须检查 |
| HTTP 429 / 认证失败，所以来源失效 | 保留来源并标检查失败，不触发换源 |
| 用户只选一个，仍运行全量 update | 先核实选择能力；不能限范围就停在计划 |
| dry-run 可直接传给 CLI | 它是编排层只读模式；CLI 参数另行核实 |
| 补源后再次全量更新 | 只执行计划中尚未完成的动作 |
| 同名或知名 owner 可直接安装 | 核对来源证据，候选仍须用户确认 |
| 目录名与本仓技能相同，就排除 | 用安装来源或软链目标判定归属 |
| 命令退出成功，就宣称全部最新 | 核对安装结果与 lock，无法验证则明示 |

决策规则以 [workflow.md](references/workflow.md)、[parameters.md](references/parameters.md) 和 [find-source.md](references/find-source.md) 为准。
