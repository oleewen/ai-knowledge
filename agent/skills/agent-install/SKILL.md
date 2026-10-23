---
name: agent-install
description: >
  将 ai-knowledge 元库的 Agent 资源安装或更新到 ~/.agents，并为指定 IDE 建立软链。
  用于 /agent-install、安装本仓 rules/skills/hooks 或配置 IDE 共享 Agent 树；
  知识库初始化用 docs-install，第三方生态技能升级用 skill-upgrade。
---

# agent-install

通过 [agent-install.sh](scripts/agent-install.sh) 安装。实体始终写入 `$HOME/.agents`；`--target` 只指定 IDE 软链父目录，`--workspace` 写入实体树 `configs` 的 `WORK_SPACE`。不创建或修改工程 `.docsconfig`。

仅安装运行资源：排除研发测试、评测和缓存，保留技能运行时的产物校验。具体范围见 [安装过滤](references/parameters.md#安装过滤)。

## 执行

1. 沿用用户已给参数，按 [parameters.md](references/parameters.md) 补齐缺口。用 Bash 5+；安装副本须提供 `--meta`。
2. 先运行 `--dry-run`，汇总实体树、IDE 链接、覆盖范围和 `WORK_SPACE`。对照 [gates.md](references/gates.md) 核实实跑授权；仅预览请求到此结束。
3. 对已确认计划去掉 `--dry-run` 执行。失败即停并报告已发生的改动；后续处理见 [失败边界](references/gates.md#失败边界)。
4. 按 [workflow.md](references/workflow.md) 校核产物与链接，区分「预览完成」与「已安装」，通过受众 A/B 后交付结果。

```bash
bash agent/skills/agent-install/scripts/agent-install.sh \
  --scope=a --target "$HOME" --agents=codex \
  --workspace "$HOME/workspaces" --dry-run
```

双轨装机先满足 Agent 安装树与 `WORK_SPACE` 前置，再运行 `docs-install`；仓根 `bootstrap.sh` 选择 both 时先运行本技能脚本；已有元库可用 `--meta PATH` 复用。仅配置 IDE 且已给 workspace 时，无须初始化知识库。

## 诊断与维护

执行异常查 [gotchas.md](gotchas.md)。维护须回到 `--meta` 元库的 `agent/skills/agent-install/`：运行 `tests/run.sh`，再按 `agents/grader.md` 检查 `evals/evals.json`；这些研发资源不随技能安装。
