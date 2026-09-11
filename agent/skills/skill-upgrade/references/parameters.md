# skill-upgrade 参数

生态 CLI：`npx skills --help`。补源：[find-source.md](find-source.md)。本仓 Agent 树见 [agent-install/SKILL.md](../../agent-install/SKILL.md)。

## 技能层

| 参数 | 必选 | 说明 |
| --- | --- | --- |
| `--find-source` | 否 | `ask`（默认）\| `yes` \| `no`；`ask`=列无源后问；`no`=跳过 find |
| `--dry-run` | 否 | 默认是（读 lock 出清单，不执行 update/add） |
| 具名 skills | 否 | 仅更新列出的生态技能（默认 lock 内全部） |

## 生态轨 / 补源

| 命令 | 说明 |
| --- | --- |
| `npx skills update -g -y` | 更新 global lock 技能 |
| `npx skills find <dir-name>` | 无源检索（编排层走 find-skills 质量门） |
| `npx skills add <owner/repo@skill> -g -y` | 仅建议桶/待决策确认后 |

## 示例

```bash
npx skills update -g -y
npx skills add vercel-labs/skills@find-skills -g -y
```
