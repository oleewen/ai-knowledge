# docs-install 参数

CLI 语法以 [docs-install.sh](../scripts/docs-install.sh) 的 `--help` 为准。本文只解释选择与副作用。

## 选择参数

| 参数 | 必选 | 说明 |
| --- | --- | --- |
| `--target` | 是 | 工程内文档子目录；不猜目标，不传仓库根 |
| `--scope` | 否 | `knowledge(k)` \| `config(c)`，默认 `k` |
| `--type` | 否 | `application(a)` \| `system(s)` \| `solution(sln)` \| `company(c)`，默认 `a`（仅 scope=knowledge） |
| `--mode` | 否 | `standalone(s)` \| `central(c)`，默认 `s`（仅 type=application） |
| `--meta` | knowledge 视运行位置 | 元库根；仓内运行默认由脚本位置推导，已安装技能须显式指定。config 不需要 |
| `--force` | 否 | 允许重置非空目标；须明确授权。保正文更新用 docs-upgrade |
| `-r` | 否 | 允许工程根不存在时创建 |
| `--dry-run` | 否 | 默认先用；不建目录、不备份、不改配置或建联文件 |

system、solution、company 只支持 standalone。config 不同步模板，会移除旧 `KNOWLEDGE_TYPE`；授权细节见 [gates.md](gates.md)。

每个带值参数均支持 `--key VALUE` / `--key=VALUE`。缺值或无效值应先纠正，不能自动退回默认模式。

环境默认值仅保留 `SCOPE`、`MODE`。旧调用中的 `FORCE=1`、`CREATE_PROJECT_ROOT=1` 不再生效，须分别迁移为显式 `--force`、`-r`；传标志前仍须满足对应授权。

## 示例

```bash
# 在元库根运行，预览应用库
bash agent/skills/docs-install/scripts/docs-install.sh --target /workspace/app/docs --dry-run

# 从完整 Agent 安装树调用，显式指定元库
bash ~/.agents/skills/docs-install/scripts/docs-install.sh --meta /workspace/ai-knowledge --target /workspace/my-system/docs --type system --dry-run

# 仅预览路径配置重建，不需要模板源
bash ~/.agents/skills/docs-install/scripts/docs-install.sh --scope config --target /workspace/app/docs --dry-run
```

以上 `bash` 须为 5+，并需 Python 3；knowledge 另须 Perl，缺失时预览和实跑均停止。config 不依赖 Perl。macOS 默认 `/bin/bash` 可能不满足，先检查 `bash --version`。只拷贝单个技能目录时，共享脚本依赖可能缺失；使用完整 Agent 树或元库中的入口。
