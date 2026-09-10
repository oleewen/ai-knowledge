# docs-upgrade 参数

脚本 SSOT：`bash agent/skills/docs-upgrade/scripts/docs-upgrade.sh -h`。装机类总览仍见 [scripts/README.md](../../../../scripts/README.md)。本文列技能编排层。

## 技能层

| 参数 | 必选 | 说明 |
| --- | --- | --- |
| （工程根） | 是 | 含 `.docsconfig`；脚本从 cwd 向上解析 |
| `--meta-path PATH` | 否 | 覆盖 links 中 meta 的本机 path（仅本次；不改 yaml） |
| `--ref REF` | 否 | 对齐的 git ref；默认 `main`；仅 CLI 覆盖（yaml meta 条暂无 `ref` 字段） |
| `--dry-run` | 否 | 只出清单（脚本默认模式之一） |
| `--apply-scaffold` | 否 | 备份并将「新增骨架」写入本库（须已 `C`） |

## 脚本行为摘要

| 模式 | 行为 |
| --- | --- |
| `--dry-run` | fetch/解析 meta；打印四桶清单；不写盘、不备份 |
| `--apply-scaffold` | fetch/解析；备份将动路径；写入「新增骨架」桶；`system`/`company` 另写入「工具脚本」桶；不重填 md、不删本库独有 |

结构重填与未落位由 Skill/Agent 执行，不在脚本内自动合正文。

## 示例

```bash
# 目标工程根
cd /path/to/my-app
bash ~/workspaces/ai-knowledge/agent/skills/docs-upgrade/scripts/docs-upgrade.sh --dry-run
# 确认后
bash ~/workspaces/ai-knowledge/agent/skills/docs-upgrade/scripts/docs-upgrade.sh --apply-scaffold
```
