# docs-link 验收记录

2026-10-23：完成重构、精简及最终复审，所测范围无新增可复现问题。行为场景库共 14 项，不等于 14 项均已执行。

## 自动检查

| 检查 | 命令/范围 | 结果 |
| --- | --- | --- |
| 脚本回归 | `/opt/homebrew/bin/bash agent/skills/docs-link/tests/run.sh` | 21/21 通过，退出 0 |
| Skill 结构 | 已安装 skill-creator 的 `scripts/quick_validate.py agent/skills/docs-link` | `Skill is valid!`，退出 0 |
| Shell 语法 | Bash 5 `-n` 检查 scripts、tests 下全部 Shell 文件 | 通过 |
| Markdown 引用 | `/opt/homebrew/bin/bash agent/scripts/tools/validate-link-reachable.sh` | 通过；包含本技能引用 |
| 补丁格式 | `git diff --check HEAD -- agent/skills/docs-link` | 通过 |
| 场景数据 | JSON 解析、场景 ID 与场景内断言 ID 唯一性 | 14 项合法 |

原契约提及的 `agent/scripts/validate-agent-md-links.sh` 在当前树不存在，实际使用表中可用检查器；未将缺失脚本判为通过。

## 故障复现与修复验证

原有 12 项回归通过。新增回归在修复前分别复现：目标 meta 被 unlink 丢弃、源无 remote 时提前写入、已登记 URL link 失败、真实槽位目录被删除、重复目标被接受，以及 HTTP 越界文件软链被放行。最终这些回归全部通过。

测试可写数据均位于临时目录；旧用例对元库 `agent/configs` 的写入与清理已隔离。HTTP 前缀改写默认关闭，显式改写有独立回归。

## 独立行为与审查

| 实际执行场景 | 证据结论 |
| --- | --- |
| solution→system，本地 billing，名称 pay-system，只预览 | 退出 0；槽位 system-pay-system；双边计划正确，树快照不变 |
| 已登记 URL unlink，目标可达，只预览 | 退出 0；双边清单及槽位均列入计划，快照不变 |
| 已登记 URL link 并改名，只预览 | 退出 0；列出新槽位和旧槽位移除，快照不变 |
| system→application，已授权的 billing unlink | 退出 0；8 项产物核对通过，保留 meta、child、HTTP、共用日志；两项 P0 评分通过 |
| 代码独立复审 | 最终增量无新问题；另验 knowledge 根越界软链在 dry/apply 均拒绝、Bash 3 非零退出 |
| 文档独立复审 | 修正 link/unlink 验收描述混用后，无新可复现问题 |

前三项为独立命令级 forward testing；最后一项含模拟授权与 Agent 决策评分。未对其余场景逐项执行完整 Agent 评分，应记 `not_run`，不从脚本测试推定通过。

## 未覆盖边界

未做磁盘故障、权限竞争或进程中断注入。脚本不提供跨文件事务；失败后须检查两侧清单、槽位与正文，不能盲目重试。评测复跑方法见 [evaluation.md](../references/evaluation.md)。
