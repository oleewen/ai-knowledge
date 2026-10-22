# agent-install 参数

以 [脚本](../scripts/agent-install.sh) `--help` 为 CLI 真源。示例按 `meta / scope / target / agents / workspace / dry-run` 排列，解析不限制顺序。

| 参数 | 含义与默认值 |
| --- | --- |
| `--meta PATH` | 含 `agent/` 的元库根。源码入口默认本仓；安装副本须显式指定元库 |
| `--scope SCOPE` | `a` 全部；`r` rules；`s` skills；`h` hooks；`sh` scripts；`k`/`knowledge` 为 knowledge + references。默认 `a` |
| `--target PATH` | IDE 软链父目录，默认 `$HOME`；不改变实体树位置 |
| `--agents LIST` | `cursor`、`codex`、`claude`、`trae`、`kiro`，逗号或空格分隔；`a`/`all` 单独表示全部。优先级：显式值、`AGENTS_OPT`、默认 `a` |
| `--workspace PATH` | 写入 `$HOME/.agents/configs` 的工作区路径；省略时按下文推断 |
| `--dry-run` | 只输出计划，不创建目录、配置、备份或链接 |

有值选项均支持 `--key=value`。空值、缺值、未知参数及无效枚举必须在写盘前报错。

## `--workspace` 推断

未传 `--workspace` 时：

1. 自调用时 cwd 上溯找 `.docsconfig`。
2. 从 `AGENT_ROOT/AGENT_DIR/configs` 读取 `WORK_SPACE`。
3. 任一文件、字段缺失时，询问 `--workspace`；不猜路径。

显式 `--workspace` 绕过上述推断，因此工程级 target 不要求 `.docsconfig`。推断源只用于读取；本次仍写入 `$HOME/.agents/configs`。

## 安装副本调用

技能依赖同一 Agent 树的 `scripts/` 共享库；不能只复制技能目录到空环境后执行安装器。已有完整安装树时：

```bash
bash "$HOME/.agents/skills/agent-install/scripts/agent-install.sh" \
  --meta /path/to/ai-knowledge --scope=r --target /path/to/project \
  --agents=codex --workspace "$HOME/workspaces" --dry-run
```
