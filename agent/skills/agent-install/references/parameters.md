# agent-install 参数

脚本 SSOT：`bash agent/skills/agent-install/scripts/agent-install.sh -h`。

## 技能层

| 参数 | 必选 | 说明 |
| --- | --- | --- |
| `--agents` | 否 | `cursor` / `trae` / `claude` / `kiro` / `codex` / `all`；多选逗号分隔 |
| `--target` | 否 | 安装根父目录，默认 `$HOME` |
| `--scope` | 否 | `a` \| `r` \| `s` \| `h` \| `sh` \| `k`/`knowledge`，默认 `a` |
| `--dry-run` | 否 | 只预览 |

## 示例

```bash
bash agent/skills/agent-install/scripts/agent-install.sh --agents=cursor --target "$HOME" --scope=a --dry-run
bash agent/skills/agent-install/scripts/agent-install.sh --target ~/workspace/my-repo --agents=all --dry-run
```
