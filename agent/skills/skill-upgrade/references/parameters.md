# skill-upgrade 参数

脚本 SSOT：[scripts/README.md](../../../../scripts/README.md)。生态 CLI：`npx skills --help`。补源：[find-source.md](find-source.md)。

## 技能层

| 参数 | 必选 | 说明 |
| --- | --- | --- |
| `--tracks` | 否 | `agent` \| `ecosystem` \| `both`（默认 both 进清单） |
| `--repo-path` | 否 | 本地元库根 |
| `--agents` | 否 | 默认探测；空则 `cursor` |
| `--target` | 否 | 默认 `$HOME` |
| `--scope` | 否 | 本仓 scope；默认由子树勾选合成 |
| `--find-source` | 否 | `ask`（默认）\| `yes` \| `no`；`ask`=列无源后问；`no`=跳过 find |
| `--dry-run` | 否 | 默认是 |

## 本仓轨

| 场景 | 命令 |
| --- | --- |
| 本地元库 | `bash $REPO/scripts/agent-install.sh --agents=… --target=… --scope=… [--dry-run]` |
| 远程仅 agent 表面参 | `bash $REPO/scripts/docs-bootstrap.sh --components=agent --agents=… --agent-scope=home` |
| 远程 + 超出表面 | clone 后分步 `agent-install` |

## 生态轨 / 补源

| 命令 | 说明 |
| --- | --- |
| `npx skills update -g -y` | 更新 global lock 技能 |
| `npx skills find <dir-name>` | 无源检索（编排层走 find-skills 质量门） |
| `npx skills add <owner/repo@skill> -g -y` | 仅建议桶/待决策确认后 |

## 示例

```bash
REPO_ROOT=/path/to/ai-knowledge
bash "$REPO_ROOT/scripts/agent-install.sh" --agents=cursor --target "$HOME" --scope=s --dry-run

GIT_REPO_URL=https://github.com/oleewen/ai-knowledge.git \
  bash "$REPO_ROOT/scripts/docs-bootstrap.sh" --components=agent --agents=cursor --agent-scope=home

npx skills update -g -y
npx skills add vercel-labs/skills@find-skills -g -y
```
