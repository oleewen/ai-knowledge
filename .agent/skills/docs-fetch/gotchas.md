# docs-fetch 常见陷阱

---

## 前置条件

**应用未注册就直接拉取**：**应用知识库根目录**下 `applications/app-{APPNAME}/` 目录或 `{APPNAME}_manifest.yaml` 不存在时，终止并提示先执行 `docs-init --mode=central`。不要尝试从 manifest 缺失的目录推断仓库地址。

**manifest 中 `repo_url` 为空或缺失**：读取 manifest 后必须验证 `repo_url` 字段存在且非空；缺失时终止并提示用户手动补充 manifest 中的 `repo_url` 字段。

---

## 分支处理

**分支不存在时静默失败**：`git clone --branch {branch}` 失败时，明确提示分支不存在，列出远端可用分支供用户选择，不自动降级到其他分支（除非用户明确授权自动探测）。

**主干分支名不确定**：未指定 `--branch` 时，先尝试 `main`，失败再尝试 `master`；两者都不存在时终止并请用户指定分支，不猜测其他分支名。

---

## 文件覆盖

**changelog 目录被远端内容覆盖**：同步前必须备份应用知识库根目录下 `applications/app-{APPNAME}/changelogs/` 目录；同步完成后恢复本地 changelog，不允许远端内容覆盖本地同步记录。

**manifest 文件被远端内容覆盖**：`{APPNAME}_manifest.yaml` 是本仓库的联邦登记文件，不属于目标工程内容；同步后若发现被覆盖，立即从 Git 恢复（`git checkout -- applications/app-{APPNAME}/{APPNAME}_manifest.yaml`）。

**`docs_root` 路径映射错误**：目标工程文档目录可能是 `docs/`、`{DOC_DIR}/` 或其他路径，必须从 manifest 的 `docs_root` 字段读取，不硬编码假设路径。

---

## 同步记录

**changelog 未追加就宣称完成**：步骤 3 的 changelog 追加是必须步骤，不是可选步骤；即使文件无变化（0 新增 0 修改 0 删除），也须追加一条同步记录，记录分支和提交号。

**提交号获取失败时留空**：若无法获取远端最新提交号（如网络问题），在 changelog 中标注「提交号获取失败」，不编造或省略该字段。

---

## 快速自查清单

- [ ] manifest 已读取，`repo_url` 字段存在且非空
- [ ] 目标分支已确认（用户指定或自动探测成功）
- [ ] `changelogs/` 目录已备份，同步后已恢复
- [ ] `{APPNAME}_manifest.yaml` 未被覆盖（或已恢复）
- [ ] 应用知识库根目录下 `applications/app-{APPNAME}/` 目录结构完整（含 `knowledge/`、`requirements/`、`changelogs/`）
- [ ] `fetch-log.md` 已追加同步记录（含分支、提交号、文件统计）
