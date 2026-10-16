# agent-install 参数

脚本 SSOT：`bash agent/skills/agent-install/scripts/agent-install.sh -h`。

书写序：`meta → scope → target → agents → workspace → dry-run`。

## 技能层

| 参数 | 必选 | 说明 |
| --- | --- | --- |
| `--meta` | 否 | 元库根，默认本脚本所在仓库 |
| `--scope` | 否 | `a` \| `r` \| `s` \| `h` \| `sh` \| `k`/`knowledge`，默认 `a` |
| `--target` | 否 | IDE 软链父目录，默认 `$HOME`（与 `--workspace` 职责不同，勿合并） |
| `--agents` | 否 | `cursor` / `trae` / `claude` / `kiro` / `codex` / `a`\|`all`；多选逗号分隔；默认 `a`（全量 IDE） |
| `--workspace` | 条件 | 工作区目录，写入 `configs` 的 `WORK_SPACE`。未传时见下方推断规则 |
| `--dry-run` | 否 | 只预览 |

## `--workspace` 推断

未传 `--workspace` 时：

1. 自 cwd 上溯找 `.docsconfig`
2. 读 `AGENT_ROOT`、`AGENT_DIR`；任一缺失 → **必须**显式 `--workspace`
3. 组装 `AGENT_ROOT/AGENT_DIR/configs`；若文件内有 `WORK_SPACE` → 直接用作 workspace
4. 文件不存在或无 `WORK_SPACE` → **必须**显式 `--workspace`

首次装机（尚无 configs）须显式传入。

## 示例

```bash
bash agent/skills/agent-install/scripts/agent-install.sh --scope=a --target "$HOME" --agents=a --workspace ~/workspaces --dry-run
bash agent/skills/agent-install/scripts/agent-install.sh --dry-run
# ↑ 默认 agents=a；已有 .docsconfig + configs/WORK_SPACE 时可省略 --workspace
```
