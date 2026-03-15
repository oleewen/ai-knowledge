# sdd-init：SDD 开发环境初始化

在任意目录执行 `sdd-init`，可从本仓库（ai-sdd-docs）拉取内容并对**当前目录**完成 SDD 开发初始化，无需先克隆整个仓库到本地。

## 功能概述

1. **文档与知识库**：将仓库内除 `.ai`、`.cursor`、`.git`、`scripts` 外的所有目录和文件拷贝到执行目录的 **docs** 文件夹（默认，可参数指定）。
2. **AI 配置**：将仓库的 **.ai** 目录拷贝到执行目录的 **.ai**（可参数指定）。
3. **Agent 的 command 与 skill**：当前仅支持 **Cursor**。从仓库的 `.cursor` 目录按选择拷贝 skills 到执行目录的 `.cursor`，并生成可用的 Slash 命令说明（README）。

## 使用方式

### 方式一：从 Git 拉取并初始化（任意目录）

在需要初始化的项目目录下执行：

```bash
cd /path/to/your-project
curl -sL "https://raw.githubusercontent.com/oleewen/ai-sdd-docs/main/scripts/sdd-init-bootstrap.sh" | bash -s -- [sdd-init 选项]
```

- 脚本会先将仓库克隆到临时目录，再对**当前目录**执行初始化，完成后删除临时克隆。
- 若仓库地址不同，可设置环境变量后再执行：
  ```bash
  export GIT_REPO_URL=https://github.com/oleewen/ai-sdd-docs.git
  export GIT_REF=main   # 可选，默认使用默认分支
  curl -sL "..." | bash -s -- [选项]
  ```

### 方式二：已克隆本仓库时

在**目标项目目录**下执行（由你指定仓库根与目标）：

```bash
cd /path/to/your-project
REPO_ROOT=/path/to/ai-sdd-docs /path/to/ai-sdd-docs/scripts/sdd-init.sh [选项]
# 或指定目标目录
/path/to/ai-sdd-docs/scripts/sdd-init.sh [选项] /path/to/your-project
```

## 选项说明

| 选项 | 说明 | 默认 |
|------|------|------|
| `--docs-dir=DIR` | 文档根目录（相对目标目录） | `docs` |
| `--ai-dir=DIR` | .ai 配置目录（相对目标目录） | `.ai` |
| `--cursor-dir=DIR` | Cursor 配置目录（相对目标目录） | `.cursor` |
| `--skills=LIST` | 要安装的 Cursor skills：`all` 或逗号分隔，如 `sdd-solution,sdd-analysis,sdd-prd` | `all` |
| `--dry-run` | 仅打印将要执行的操作，不实际拷贝 | - |
| `-h`, `--help` | 显示帮助 | - |

可用的 skill 名称：`knowledge-build`, `sdd-solution`, `sdd-analysis`, `sdd-prd`, `sdd-design`, `sdd-test`。

## 示例

```bash
# 使用默认配置（docs、.ai、.cursor，全部 skills）
curl -sL "https://raw.githubusercontent.com/oleewen/ai-sdd-docs/main/scripts/sdd-init-bootstrap.sh" | bash -s

# 文档放到 content/，只安装部分 skills
curl -sL "..." | bash -s -- --docs-dir=content --skills=sdd-solution,sdd-analysis,sdd-prd

# 先预览再执行
curl -sL "..." | bash -s -- --dry-run
```

## 初始化后的目录结构（目标目录）

- `docs/`：知识库、solutions、analysis、requirements、specs、changelogs 等（与仓库除 .ai/.cursor 外一致）。
- `.ai/`：规则、模板、agents、workflows、context 等。
- `.cursor/`：`skills/<name>/SKILL.md` 及生成的 `README.md`（Slash 命令索引）。

Cursor 中可通过 `/命令名` 或 `@技能名` 使用已安装的 skills。
