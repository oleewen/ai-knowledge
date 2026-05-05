# docs-push 参数说明

脚本：`agent/skills/docs-push/scripts/push-specs.sh`（Bash 5+）。

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
