# docs-push 参数

脚本：`agent/skills/docs-push/scripts/push-specs.sh`（Bash 5+）。

## `docs-core.sh` 解析顺序

`source` 前须找到 `docs-core.sh`：`DOCS_CORE_SH` → 技能树 `../../../scripts/docs-core.sh` → `~/.agents/scripts/` → `~/.cursor|.claude|.trea|.kiro/scripts/` → 自脚本/cwd 上溯 `agent/scripts/` → **`AIK_ROOT/agent/scripts/`**。

## 相对 `--links` 的中央根

路径**不得**含 `..`。

1. **`AIK_ROOT`**：且 `$AIK_ROOT/<相对路径>` 存在  
2. 自 **cwd** 上溯，首个含该文件的目录  
3. 自 cwd 上溯 **`agent/scripts/docs-core.sh`**，以其上三级为根  
4. 自脚本目录同理  

仍失败则用**绝对** `--links`。

| 变量 | 说明 |
|------|------|
| `DOCS_CORE_SH` | 显式 `docs-core.sh` 路径 |
| `AIK_ROOT` | 含相对 `links` 的仓库根 |

---

## 子命令

| 子命令 | 作用 |
|--------|------|
| `copy` | 匹配文件复制到 `{path}/{doc_dir}/…` |
| `git` | 在目标仓库根执行四档之一 |

---

## 公共选项

| 选项 | 必选 | 说明 |
|------|------|------|
| `--specs-dir DIR` | 是 |源根。**Legacy**：仅顶层 `*.md`。**spec-asd**：递归 `find`。`cd -P` 规范化（macOS 路径一致）。 |
| `--links FILE` | 是 | `knowledge-links.yaml`，绝对路径或相对中央根。 |
| `--mode` | 否 | `path`（默认）或 `repo`：`checkout -B` 后拷贝，不 clone。 |
| `--branch NAME` | repo 必填 | 分支名 |
| `--dry-run` | 否 | 只打印将执行的命令 |
| `--strict` | 否 | 任一 spec 无法路由则整批中止、不写文件 |
| `--allow-dirty` | 否 | `repo`/`git` 时放行「计划外 dirty」检查 |

## `git` 专有

| 选项 | 说明 |
|------|------|
| `--git-op` | `none` / `stage` / `commit` / `push`（必选） |
| `--message TEXT` | `commit`/`push` 必填 |
| `--remote NAME` | 默认 `origin` |

---

## 文件名与目标（双轨）

### Legacy：`spec-{yyMMdd}-{n}-{app}.md`

- 正则：`^spec-([0-9]{6})-([0-9]+)-([a-zA-Z0-9_.-]+)\.md$`；组 3 = **`app_name`**，须与 YAML **大小写一致**。
- 目标：`{path}/{doc_dir}/specs/<basename>`（仅顶层）。
- 顶层若存在 `spec-asd-*.md`，legacy 轨**静默跳过**该文件。

### spec-asd：`spec-asd-{IDEA-ID}-{MVP-PHASE}-{app-name}.md`

- 自右向左解析 `app-name`、数字 Phase、`IDEA-ID`（`IDEA-ID` 可含 `-`）。
- **`app-name`** 须命中登记 **`app_name`**。
- **`rel`** = 相对 `--specs-dir`：
  - **`rel` 以 `requirements/` 开头**：镜像 → `{path}/{doc_dir}/<rel>`；`dirname(rel)` 须匹配 `requirements/REQUIREMENT-*/MVP-Phase-*/specs(/…)?`。
  - **否则**：归位 → `…/requirements/REQUIREMENT-{IDEA}/MVP-Phase-{PHASE}/specs/<basename>`。
- `rel` 含独立 `..`：跳过；**`--strict` 整批失败**。

路由与 `--specs-dir` 语义见上文与本目录 [workflow.md](workflow.md)。

---

## 示例

```bash
# legacy，path，dry-run
bash agent/skills/docs-push/scripts/push-specs.sh copy \
  --specs-dir ./application/specs \
  --links system/knowledge-links.yaml --mode path --dry-run

# spec-asd 在 application 树下
bash agent/skills/docs-push/scripts/push-specs.sh copy \
  --specs-dir ./application \
  --links system/knowledge-links.yaml --mode path --dry-run

# repo + 暂存
bash agent/skills/docs-push/scripts/push-specs.sh copy ... --mode repo --branch feat/spec-sync
bash agent/skills/docs-push/scripts/push-specs.sh git ... --mode repo --branch feat/spec-sync --git-op stage
```

**push（须用户确认后再跑）**

```bash
bash agent/skills/docs-push/scripts/push-specs.sh git \
  ... --git-op push --message "docs(spec): 同步中央 spec"
```
