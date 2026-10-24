# docs-install 陷阱

| 症状 | 处理 |
| --- | --- |
| 已安装技能找不到模板源 | knowledge 传 `--meta <元库根>`；config 无需模板。脚本共享依赖缺失则使用完整 Agent 树 |
| 提示工程根不存在 | 核实路径与 `-r` 授权后重新预览；不为完成 dry-run 手动创建目标 |
| `WORK_SPACE` 缺失、旧建联路径或越界 | 检查 Agent 树的 `configs` 与文件所属库配置，按 [路径契约](../../knowledge/knowledge-governance.md) 处理；不能把工作区塞进 `.docsconfig` 或绕过校验 |
| `AGENT_ROOT` 指向实体树 | 改为父目录，配合 `AGENT_DIR`；缺失或失效时的探测规则见 [workflow.md](references/workflow.md)。agent-install 不替工程写回这些键 |
| 已有正文需要保留 | 用 docs-upgrade；不要用 `--force` 重装来修补正文或路径 |
| 旧环境变量不再启用重装/创建目录 | `FORCE`、`CREATE_PROJECT_ROOT` 已停用；按授权迁移为 `--force`、`-r`，不自行扩大范围 |
| knowledge 提示缺 Perl | 预检不会写入；报告依赖缺口，不为绕过错误切成 config 或改全局环境 |
| 复制或后处理失败 | 按 [失败处置](references/workflow.md#预览与执行) 核实退出状态与产物，不能只凭“同步完成”日志判成功 |

重装备份 `DOC_DIR/.agents` 时只移动软链本身，不跟随实体树；[路径重写](references/workflow.md#产物校核) 与 [覆盖和配置风险](references/gates.md) 分别按对应契约处理。
