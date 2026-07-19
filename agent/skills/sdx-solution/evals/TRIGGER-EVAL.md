# Trigger eval harness note

## 2026-07-19 复跑（网关恢复 + 检测器修复）

检测：已装 skill 真名；`Skill`/`Read` 路径含 `skills/<name>/` 算触发。勿在首条 `message_stop` 早退（模型常先 Bash 再读 SKILL）。

| 技能 | 分数 | 备注 |
| --- | --- | --- |
| docs-distill | **10/10**（边缘句套件内曾 flake，隔离 3 跑复核后通过） | `trigger-eval-results.json` |
| sdx-solution | **16/16** | 含「一口气整篇 / F 补齐 / 非法 F 重写」 |

脚本：`/tmp/run_installed_trigger_eval.py`
