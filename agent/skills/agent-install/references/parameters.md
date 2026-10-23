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

## 安装过滤

所有 scope 共用以下规则，rsync 与 cp 回退一致：

- 排除各层 `README`、`README.md`、`readme.md`。
- 排除研发资源：`tests`、`evals`、`test-core.sh`、`grader.md`，以及 `__pycache__`、`.pytest_cache`、`.hypothesis`、`*.pyc`、`*.pyo` 缓存。
- 保留运行脚本、共享库、`agents/openai.yaml` 和技能执行所需的 `validate-*` 等产物校验脚本；不按名称中的 `test` 或 `validate` 泛删。

同步目录内旧的排除项会清理；顶层只清理元库同名研发资源，及所选 IDE 中指向对应实体的旧链接。hooks 按既有规则整树同步，也清理源端已移除的研发资源所遗留的 IDE 链接。未选 scope、hooks 以外的非元库同名资源和 IDE 自有文件不受此规则清理。所选分类内保留的第三方资源也会建立 IDE 链接，但不因建立链接而清理其内容。预览报告过滤、清理和链接范围，不写盘。

研发资源留在元库，相关维护说明中的测试、评测路径须在元库执行。

## `--workspace` 推断

未传 `--workspace` 时：

1. 自调用时 cwd 上溯找 `.docsconfig`。
2. 从 `AGENT_ROOT/AGENT_DIR/configs` 读取 `WORK_SPACE`。
3. 任一文件、字段缺失时，询问 `--workspace`；不猜路径。

显式 `--workspace` 绕过上述推断，因此工程级 target 不要求 `.docsconfig`。推断源只用于读取；本次仍写入 `$HOME/.agents/configs`。

若推断值与已有全局 `WORK_SPACE` 不同，dry-run 显示冲突，实跑在任何写入前退出。用户确认保留旧值或使用新值后，显式传入所选 `--workspace` 再执行。全局值缺失或与推断值相同则正常执行；已显式给值时无需再次确认同一参数。

## 安装副本调用

技能依赖同一 Agent 树的 `scripts/` 共享库；不能只复制技能目录到空环境后执行安装器。已有完整安装树时：

```bash
bash "$HOME/.agents/skills/agent-install/scripts/agent-install.sh" \
  --meta /path/to/ai-knowledge --scope=r --target /path/to/project \
  --agents=codex --workspace "$HOME/workspaces" --dry-run
```
