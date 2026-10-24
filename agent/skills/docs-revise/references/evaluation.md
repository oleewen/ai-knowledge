# 技能评测

[evals.json](../evals/evals.json) 定义行为用例；[grader](../agents/grader.md) 判证据；[analyzer](../agents/analyzer.md) 分析已观察到的失败。普通文档修订无需运行本评测。

## 执行行为用例

1. 在临时工作区准备每例的 `fixture_files`；保留改前副本或哈希。将单例 `prompt` 与 `conversation` 直接放进独立执行者的任务消息，并提供工作目录与技能入口；不泄露 `expected_output` 或 `assertions`。
2. 每例独立运行，先理解请求再操作文件。只允许修改临时文件；记录响应、读写/搜索轨迹、改后文件与 diff。用户确认只使用该例已给出的前序语境。批量清单驱动只算冒烟检查，关键边界另做单例独立验证。
3. 评审者按 grader 逐项填写 [结果模板](../evals/eval-metadata-template.json)。从定义校验输出取得 `suite_sha256`，连同本轮结果保存；未跑的用例或无证据的断言保留 `not_run`。
4. 汇总结果并分别报告静态校验、行为评测和覆盖限制。一次通过只证明该次观察；不得据此宣称稳定成功率。

`grading_examples` 是判分校准材料，不交给任务执行者。改动断言后，用其中的响应、文件结果及可选动作轨迹做独立判分，再对照预期失败列表；校准结果与真实任务执行分开记录。现有正负样例覆盖受众语言和“先改主文件，再查关联”的操作顺序。

## 校验与汇总

从仓库根执行；Python 3 标准库即可：

```bash
python3 agent/skills/docs-revise/scripts/score_evals.py
python3 -B -m unittest discover -s agent/skills/docs-revise/tests -v
python3 agent/skills/docs-revise/scripts/score_evals.py --results /tmp/docs-revise-results.json
```

首条只校验用例定义，不运行模型。结果命令读取 JSON 并向 stdout 输出逐断言结果；缺失用例/断言计为未测。退出码：`0` 用例定义有效或全部 P0 通过，`1` 有失败/未测，`2` 输入无效。

结果必须绑定完整 suite 的规范 JSON SHA-256（忽略键顺序与排版，保留内容和数组顺序）。判据变化、绑定缺失或不匹配均拒收，不能仅因 ID 相同沿用旧评分。历史结果原样保留；重审旧轨迹时另存新判据下的评分及重审依据，不能只补当前哈希便声称历史运行通过当前套件。

维护后另运行 skill-creator 的 `quick_validate.py`，检查 UI 元数据、相对链接和 `git diff --check`。测试脚本覆盖评分规则、缺失证据、未知/重复 ID 和 CLI 退出码，不替代真实行为评测。

最近一次实测见 [评测报告](../evals/evaluation-report.md)，保留 [首轮失败证据](../evals/initial-results.json) 与 [各用例最新证据](../evals/final-results.json)。
