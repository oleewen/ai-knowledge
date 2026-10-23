# docs-link 评测方法

**分开报告结构校验、脚本回归和 Agent 行为。** 任一层通过都不能替代另外两层；没有执行轨迹的行为场景记为 `not_run`。

本次已执行范围见 [验收记录](../evals/results.md)，后续改动须重新验证。

## 可重复的脚本回归

从元库根运行，`bash` 须为 Bash 5+；macOS 可指定 `/opt/homebrew/bin/bash`。依赖 Git、Python 3、rg，不需要网络或远端凭证。

```bash
bash agent/skills/docs-link/tests/run.sh
```

用例自建临时 Git 仓、Agent configs 和清单；只读复用共享库，不写元库 `agent/configs` 或全局配置。断言检查实际文件、软链、退出状态与用户可见计划，不 grep 生产源码。路径边界与 dry-run 用前后快照核对。

| 用例 | 行为覆盖 |
| --- | --- |
| 01–05 | 非法 path、占位符写入、label 保留、remote 必填、安装布局 |
| 06–09、13 | 三层建联、unlink 不改 HTTP、保留 meta/child/无关 parent |
| 10–12、14 | WORK_SPACE、双边预检、只读预览、失败无提前写入 |
| 15–17 | URL 本地解析、普通目录冲突、单目标 CLI 与 cwd |
| 18–20 | 三层名称及改名、HTTP opt-in、失联注销、槽位父目录边界 |
| 21 | HTTP 改写拒绝越界软链，预览与实跑均不改外部文件 |

新增缺陷先写可复现用例，记录修复前失败与修复后通过。不要把测试跳过当通过，也不要为了覆盖率测试措辞或内部函数结构。

## Agent 行为评测

场景来自 [evals.json](../evals/evals.json)，评分按 [grader.md](../agents/grader.md)。

1. 在独立临时目录按场景 `setup` 建立原始仓库/清单。可复用 `tests/test-lib.sh` 的 `fixture_pair`；所有写入限定临时目录，Git remote 仅作身份字符串。
2. 给独立评估 Agent：用户 prompt、技能路径、实际 cwd、最少夹具。隐藏 `expected_output`、断言、已知缺陷与修复意见，避免提示答案。分流场景只提供技能描述目录。
3. 保存原始响应、工具命令、退出码、stdout/stderr、文件前后快照。需真实写入的场景，模拟用户只授权已展示的具体预览；不能把测试授权带到真实仓库。
4. 将证据与全部断言交给评分者。修复有证据的问题，重跑受影响场景；最终独立审查无新可复现问题后结束。

## 结构与交付校验

- 用当前 `skill-creator/scripts/quick_validate.py` 校验技能入口；该脚本来自技能安装位置，不是本仓依赖。
- 从元库根运行 `bash agent/scripts/tools/validate-link-reachable.sh`，检查引用可达性；语法检查覆盖修改的 Shell 文件。
- 最终报告写清版本/日期、命令、测试计数、行为场景状态、证据位置及未测边界。不要把“无新发现”写成绝对无缺陷。
