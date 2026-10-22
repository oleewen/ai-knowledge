# 触发评测记录

当前执行方法见 [evaluation.md](../references/evaluation.md)。本轮发现用例未重跑；产物行为实测见 [验证记录](evaluation-report.md)。以下仅保留历史来源。

| 项 | 历史记录 |
| --- | --- |
| 日期 | 2026-07-19（原说明日期） |
| 结果 | [trigger-eval-results.json](trigger-eval-results.json)：16/16 |
| 检测口径 | 已装 skill 名；工具加载路径含 skills/sdx-analysis/ |
| 描述与样本 | 结果文件内保存的旧 description/query，与当前版本不同 |
| 模型、技能提交、原始轨迹 | 未记录，不能补造 |
| 运行器 | 历史 /tmp/run_installed_trigger_eval.py；2026-10-22 核查不存在，非仓库依赖 |

原结果文件不改写。旧 16/16 仅表示历史发现样本结果，不证明当前流程、产物或新增案例通过。非法 F 的发现与协议分类见评测说明。
