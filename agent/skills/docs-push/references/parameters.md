# docs-push 参数说明

脚本：`agent/skills/docs-push/scripts/push-specs.sh`（Bash 5+）。

### `docs-core.sh` 加载路径（与仓库根解耦）

须先加载 `docs-core.sh`（内含 knowledge-links 只读解析）。**不**再要求「仓库根」与 core 同树。解析顺序：

1. **`DOCS_CORE_SH`**：显式指向 `docs-core.sh` 文件（须存在）；
2. **`${脚本目录}/../../../scripts/docs-core.sh`**：`agent-install` 后的技能路径（`.agents/skills/.../scripts` 或经 symlink 的 `~/.cursor/skills/...`）；
3. **`$HOME/.agents/scripts/docs-core.sh`**；
4. **`$HOME/.cursor|.claude|.trea|.kiro/scripts/docs-core.sh`**（依次尝试）；
5. 自脚本**物理目录**上溯，查找 `agent/scripts/docs-core.sh`；
6. 自**当前工作目录**物理路径上溯，同上；
7. **`AIK_ROOT/agent/scripts/docs-core.sh`**（若已设置 `AIK_ROOT`）。

### 相对 `--links` 的中央库根

`--links` 为相对路径时，解析为「含该文件的仓库根」，顺序：

1. **`AIK_ROOT`**：必须满足 **`$AIK_ROOT/<相对路径>`** 为已存在的文件（用于仅有安装产物、工作区不在中央库树等场景）；
2. 自**当前工作目录**上溯，找到第一个满足 **`$d/<相对路径>`** 存在的目录 `d`；
3. 自当前工作目录上溯 **`agent/scripts/docs-core.sh`**，以其父级的父级的父级为仓库根（与中央库布局一致）；
4. 自脚本目录上溯 **`agent/scripts/docs-core.sh`**（同上）。

相对路径**不得**包含 `..`。若仍无法解析，请改用**绝对路径** `--links`。

| 变量 | 必选 | 说明 |
|------|------|------|
| `DOCS_CORE_SH` | 否 | 显式指定要 `source` 的 `docs-core.sh`。 |
| `AIK_ROOT` | 否 | 指向含 `knowledge-links` 相对路径的仓库根；**相对 `--links` 时**，若已设置则**必须**能在其下找到该文件。也参与 `docs-core` 解析（见上第 7 步）。 |

---

## 子命令

| 子命令 | 作用 |
|--------|------|
| `copy` | 将匹配的 spec 文件复制到目标 `{path}/{doc_dir}/specs/`。 |
| `git` | 按同一批文件在目标 Git 仓库根下执行四档之一（见下）。 |

---

## 公共选项

| 选项 | 必选 | 说明 |
|------|------|------|
| `--specs-dir DIR` | 是 | 源目录，内含 `spec-{yyMMdd}-{n}-{app_name}.md`。 |
| `--links FILE` | 是 | `knowledge-links.yaml`；**绝对路径**，或相对**中央知识库仓库根**的相对路径。 |
| `--mode path \| repo` | 否 | 默认 `path`。`repo` 时在目标 `path` 上执行 `git checkout -B <branch>` 再拷贝（**不** `clone`）。 |
| `--branch NAME` | repo 必填 | 检出或创建并检出的分支名。 |
| `--dry-run` | 否 | 只打印将执行的 `install` / `git` 命令，不写盘、不执行 git。 |
| `--strict` | 否 | 任一 spec 无法路由（命名不符或缺少 `app_name` 登记）则**整批中止**且不写任何文件。 |
| `--allow-dirty` | 否 | 仅 `repo` / `git`：`git status` 存在与本次计划**精确路径**以外变更时默认失败；本开关放行脏工作区检查。 |

---

## `git` 子命令专有

| 选项 | 必选 | 说明 |
|------|------|------|
| `--git-op none \| stage \| commit \| push` | 是 | `none`：仅 `git status -sb`；`stage`：`git add` 计划内文件；`commit`：add + `commit`；`push`：add + commit + `git push`。 |
| `--message TEXT` | commit/push 必填 | 提交说明。 |
| `--remote NAME` | 否 | 默认 `origin`。 |

---

## 文件名约定

- 正则：`^spec-([0-9]{6})-([0-9]+)-([a-zA-Z0-9_.-]+)\.md$`
- 捕获组 3 为 **`app_name`**，须与 `knowledge-links.yaml` 中 **`app_name`** 字段**大小写敏感、完全相等**。

---

## 示例

**path 模式 dry-run：**

```bash
bash agent/skills/docs-push/scripts/push-specs.sh copy \
  --specs-dir ./docs/superpowers/specs \
  --links system/knowledge-links.yaml \
  --mode path --dry-run
```

**repo 模式实跑后暂存：**

```bash
bash agent/skills/docs-push/scripts/push-specs.sh copy \
  --specs-dir ./docs/superpowers/specs \
  --links system/knowledge-links.yaml \
  --mode repo --branch feat/spec-sync

bash agent/skills/docs-push/scripts/push-specs.sh git \
  --specs-dir ./docs/superpowers/specs \
  --links system/knowledge-links.yaml \
  --mode repo --branch feat/spec-sync \
  --git-op stage
```

**提交并推送（须用户确认后再执行）：**

```bash
bash agent/skills/docs-push/scripts/push-specs.sh git \
  --specs-dir ./docs/superpowers/specs \
  --links system/knowledge-links.yaml \
  --mode repo --branch feat/spec-sync \
  --git-op push --message "docs(spec): 同步中央 spec"
```
