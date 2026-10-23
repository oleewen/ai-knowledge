# docs-link 评测方法

**分开报告结构校验、脚本回归和 Agent 行为。** 任一层通过都不能替代另外两层；没有执行轨迹的行为场景记为 `not_run`。

既有 link/unlink 已执行范围见 [验收记录](../evals/results.md)，新增 check/repair 见 [维护验收记录](../evals/maintenance-results.md)。两者分开报告；未跑的行为场景记 `not_run`。

## 可重复的脚本回归

从元库根运行，`bash` 须为 Bash 5+；macOS 可指定 `/opt/homebrew/bin/bash`。依赖 Git、Python 3、rg，不需要网络或远端凭证。

```bash
bash agent/skills/docs-link/tests/run.sh
```

用例自建临时 Git 仓、Agent configs 和清单；只读复用共享库，不写元库 `agent/configs` 或全局配置。断言检查实际文件、软链、退出状态与用户可见计划，不 grep 生产源码。路径边界、check 与 dry-run 用前后快照核对。维护场景还须比较两侧清单、正文、槽位 readlink/lstat、HEAD、分支、Git index 内容与 mtime、FETCH_HEAD 及未选槽位；用隔离的 Git 包装器记录并拒绝网络/写入命令，证明没有远端访问或 Git 变更。

| 用例 | 行为覆盖 |
| --- | --- |
| 01–05 | 非法 path、占位符写入、label 保留、remote 必填、安装布局 |
| 06–09、13 | 三层建联、unlink 不改 HTTP、保留 meta/child/无关 parent |
| 10–12、14 | WORK_SPACE、双边预检、只读预览、失败无提前写入 |
| 15–17 | URL 本地解析、普通目录冲突、单目标 CLI 与 cwd |
| 18–20 | 三层名称及改名、HTTP opt-in、失联注销、槽位父目录边界 |
| 21 | HTTP 改写拒绝越界软链，预览与实跑均不改外部文件 |
| 22–26 | 全量只读检查、单槽位修复、精确选择、配置/路径/身份保护、CLI 互斥与建链失败 |
| 27 | 拒绝 `links: []` 后继续列条目的非法混合清单；check/repair 均非零且零写入 |
| 28 | 拒绝源/目标清单的嵌套身份字段与嵌套列表；保持合法平面列表可用 |
| 29 | 首个 child 的重复/旧字段逐项报错，后续正常 child 仍检查并汇总；单选隔离无关错误 |
| 30 | 重复 `type` 作为结构歧义拒绝，不能覆盖 child 身份后误报检查成功 |

新增缺陷先写可复现用例，记录修复前失败与修复后通过。不要把测试跳过当通过，也不要为了覆盖率测试措辞或内部函数结构。

## 槽位维护验收

在独立夹具中建联后注入故障，运行以下动作；记录真实退出码与前后快照，不能只检查响应措辞。

| 场景 | 动作与断言 |
| --- | --- |
| 全量含失败项 | `--check` 无 target；首项失败后仍覆盖其余 child，总体非零、逐项结果完整 |
| 单项与三层映射 | `--check --target` / `--repair --target`；按登记 path 精确选择，未选项不变 |
| 缺失、悬空或错误软链 | `--repair --target ... --dry-run` 无变化；在已确认范围实跑后仅槽位变化 |
| 正确相对软链 | repair 无操作；readlink、lstat 与 Git 元数据不变 |
| 真文件/目录或父目录软链 | check/repair 非零，原内容与链接保留 |
| 缺仓、配置/身份/反向 parent 不符 | 非零阻塞，不补 YAML、不猜路径、不 clone/install |
| dirty/detached | 可检查/修复，用户改动、分支及全部 Git 元数据不变 |
| CLI 与执行失败 | 四动作冲突、repair 缺目标、非 link 名称/改正文旗标均拒绝；注入 ln 失败须非零并保留失败证据 |

可重复执行的完整回归仍使用上节 `tests/run.sh`；行为评测按下节执行，不从回归成功推断 Agent 行为已通过。

## Agent 行为评测

场景来自 [evals.json](../evals/evals.json)，评分按 [grader.md](../agents/grader.md)。

1. 在独立临时目录按场景 `setup` 建立原始仓库/清单。可复用 `tests/test-lib.sh` 的 `fixture_pair`；check/repair 夹具先合法 link，再注入该场景的单一故障；所有写入限定临时目录，Git remote 仅作身份字符串。
2. 给独立评估 Agent：用户 prompt、技能路径、实际 cwd、最少夹具。隐藏 `expected_output`、断言、已知缺陷与修复意见，避免提示答案。分流场景只提供技能描述目录。
3. 保存原始响应、工具命令、退出码、stdout/stderr、文件前后快照。需真实写入的场景，模拟用户只授权已展示的具体预览；不能把测试授权带到真实仓库。
4. 将证据与全部断言交给评分者。修复有证据的问题，重跑受影响场景；最终独立审查无新可复现问题后结束。

## 结构与交付校验

- 用当前 `skill-creator/scripts/quick_validate.py` 校验技能入口；该脚本来自技能安装位置，不是本仓依赖。
- 从元库根运行 `bash agent/scripts/tools/validate-link-reachable.sh`，检查引用可达性；语法检查覆盖修改的 Shell 文件。
- 最终报告写清版本/日期、命令、测试计数、行为场景状态、证据位置及未测边界。不要把“无新发现”写成绝对无缺陷。
