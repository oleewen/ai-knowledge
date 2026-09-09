# docs-bootstrap 参数

脚本 SSOT：[scripts/README.md](../../../../scripts/README.md)。本文件只列技能编排层与常用透传；细节以各脚本 `--help` / README 为准。

## 技能层

| 参数 | 必选 | 说明 |
| --- | --- | --- |
| `--components` | 否 | `docs` \| `agent` \| `both`（默认 `both`）。技能概念参数，**不是** bootstrap 脚本旗标。 |
| source | 自动 | `local` 或 `remote`（见 [workflow.md](workflow.md)）；`docs-bootstrap.sh` 仅为 remote 下可选执行路径 |

## 与 bootstrap 表面参数对齐

| 技能/用户说法 | 映射 |
| --- | --- |
| `--doc-target PATH` | docs-install `--target PATH`；bootstrap `--doc-target` |
| `--agents=LIST` | agent-install / bootstrap `--agents` |
| `--agent-scope=home\|project` | bootstrap 同名；local 时推导 agent `--target`（`home`→`$HOME`，`project`→`dirname(doc-target)`） |

## docs-install 透传（components 含 docs）

| 选项 | 说明 |
| --- | --- |
| `--target` | 目标工程文档目录（必填） |
| `--scope` | `knowledge(k)` \| `config(c)`，默认 `k` |
| `--type` | `application(a)` \| `system(s)` \| `company(c)`，默认 `a` |
| `--mode` | `standalone(s)` \| `central(c)`，默认 `s` |
| `--dry-run` | 只预览 |
| `--force` | 强制覆盖（高风险，须明示） |

完整列表：`bash scripts/docs-install.sh -h`。

## agent-install 透传（components 含 agent）

| 选项 | 说明 |
| --- | --- |
| `--agents` | `cursor` / `trae` / `claude` / `kiro` / `codex` / `all`；多选逗号分隔 |
| `--target` | 安装根父目录，默认 `$HOME` |
| `--scope` | `a` \| `r` \| `s` \| `h` \| `sh` \| `k`/`knowledge`，默认 `a` |
| `--dry-run` | 只预览 |

完整列表：`bash scripts/agent-install.sh -h`。

## docs-bootstrap.sh（仅 both + remote + 表面三参）

| 选项 | 说明 |
| --- | --- |
| `--doc-target` | 目标工程文档目录 |
| `--agents` | 同上 |
| `--agent-scope` | `home` \| `project` |

环境变量：`GIT_REPO_URL`、`GIT_REF`（见脚本头注释）。

**能力边界**：无 `--components`；无统一 `--dry-run` / `--force` / `--type` / `--mode` / docs|agent `--scope`。  
**透传规则**：分步调用 `docs-install.sh` / `agent-install.sh` 时透传各自全参数；走 `docs-bootstrap.sh` 时**只能**表面三参。用户一旦声明超出表面的旗标 → 禁止 bootstrap，改分步透传（见 [workflow.md](workflow.md)）。

## 示例

```bash
# local + both，先 dry-run
bash scripts/docs-install.sh --target ~/ws/app/docs --dry-run
bash scripts/agent-install.sh --agents=cursor --target "$HOME" --dry-run

# local + 仅 docs，带 type/mode
bash scripts/docs-install.sh --target ~/ws/app/docs --type=system --mode=standalone --dry-run

# 非 local + both
bash scripts/docs-bootstrap.sh --doc-target ~/ws/app/docs --agents=cursor,kiro --agent-scope=home
```
