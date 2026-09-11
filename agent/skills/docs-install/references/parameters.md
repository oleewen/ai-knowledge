# docs-install 参数

脚本 SSOT：`bash agent/skills/docs-install/scripts/docs-install.sh -h`。本文列技能编排层。

## 技能层

| 参数 | 必选 | 说明 |
| --- | --- | --- |
| `--target` | 是 | 目标工程文档目录 |
| `--scope` | 否 | `knowledge(k)` \| `config(c)`，默认 `k` |
| `--type` | 否 | `application(a)` \| `system(s)` \| `company(c)`，默认 `a`（仅 scope=knowledge） |
| `--mode` | 否 | `standalone(s)` \| `central(c)`，默认 `s`（仅 type=application） |
| `--force` | 否 | 强制覆盖（高风险，须明示） |
| `-r` | 否 | 允许工程根不存在时创建 |
| `--dry-run` | 否 | 只预览 |

## 示例

```bash
# 应用库 standalone，先预览
bash agent/skills/docs-install/scripts/docs-install.sh --target ~/ws/app/docs --type=application --dry-run

# 仅写 .docsconfig
bash agent/skills/docs-install/scripts/docs-install.sh --scope=config --target ~/ws/app/docs --dry-run

# 系统库
bash agent/skills/docs-install/scripts/docs-install.sh --scope=knowledge --type=system --target ~/ws/my-system --dry-run
```
