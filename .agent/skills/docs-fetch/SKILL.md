---

## name: docs-fetch
description: >
  从已注册的应用知识库（central 模式登记的目标工程）拉取最新文档内容，
  更新本仓库联邦镜像 applications/app-{APPNAME}/（目标态槽位见 system/application-{name}/ 设计），并记录同步 changelog。
  当用户执行 /docs-fetch、需要同步应用知识库内容、更新联邦镜像、
  或应用侧文档有更新需要拉取到中央库时，务必使用本技能。
  即使用户只说"同步一下应用文档"、"拉取最新知识库"、"更新应用镜像"，也应触发本技能。

# 应用知识库拉取（docs-fetch）

> **路径约定（知识库 v2）**：`docs-init --mode=central` 仍可能在仓库根 `**applications/app-<后缀>/`** 维护联邦镜像（与 `scripts/docs-init.sh` 一致）。**目标态**组织级槽位为 `**system/application-{name}/`**。下文以当前 central 落盘路径为准；迁移期两种叙述可能并存。

**术语**：**应用联邦镜像根**指本仓库内由 central 登记的应用文档镜像（路径前缀 `applications/`，单应用为 `applications/app-{APPNAME}/`）。**应用知识库 SSOT**指路径前缀 `{DOC_DIR}/`（本技能默认不修改）。

从已通过 `docs-init --mode=central` 注册的目标工程知识库，拉取指定分支的文档内容，覆盖更新本仓库应用知识库根目录下 `applications/app-{APPNAME}/` 联邦镜像目录，并在 `applications/app-{APPNAME}/changelogs/` 下追加同步记录。

## 前置条件

目标应用必须已通过 `docs-init --mode=central` 注册，即：

- 应用知识库根目录下 `applications/app-{APPNAME}/` 目录存在
- `applications/app-{APPNAME}/{APPNAME}_manifest.yaml` 存在且包含 `repo_url` 字段

未注册的应用须先执行 `docs-init --mode=central` 完成登记。

## 输入与输出


| 类型   | 内容                                                                                       |
| ---- | ---------------------------------------------------------------------------------------- |
| 硬输入  | 应用知识库根目录下 `applications/app-{APPNAME}/{APPNAME}_manifest.yaml`（含 `repo_url`、`docs_root`） |
| 可选输入 | `--branch` 目标分支（默认 `main` 或 `master`）、`--app` 应用名称                                       |
| 固定输出 | 更新后的应用知识库根目录 `applications/app-{APPNAME}/` 目录内容                                          |
| 附加产出 | `applications/app-{APPNAME}/changelogs/fetch-log.md`（同步记录，追加）                            |
| 不产出  | 不修改应用知识库 `{DOC_DIR}/`、不触发 `docs-archive`、不修改 `APPLICATIONS_INDEX.md`                |


## 参数


| 参数          | 必需  | 默认值               | 说明                                                             |
| ----------- | --- | ----------------- | -------------------------------------------------------------- |
| `--app`     | 否   | 自动发现              | 应用名称（对应应用知识库根目录下 `applications/app-{APPNAME}/`）；未指定时列出已注册应用供选择 |
| `--branch`  | 否   | `main` 或 `master` | 目标工程分支；自动探测主干（先尝试 `main`，再尝试 `master`）                         |
| `--dry-run` | 否   | `false`           | 预览模式，仅打印将要执行的操作，不实际拉取                                          |
| `--force`   | 否   | `false`           | 强制覆盖，跳过冲突确认                                                    |


## 工作流（四步）

### 步骤 1：应用发现与 manifest 解析

1. 若未指定 `--app`，扫描应用知识库根目录 `applications/` 下所有 `app-*/` 目录，列出已注册应用（含 manifest 的目录）供用户选择
2. 读取 `applications/app-{APPNAME}/{APPNAME}_manifest.yaml`，提取：
  - `repo_url`：目标工程 Git 仓库地址
  - `docs_root`：目标工程文档目录（默认 `docs/` 或 `{DOC_DIR}/`，依对方仓库约定）
  - `app_id`：应用 ID（如 `APP-MYSERVICE`）
3. 确认目标分支：用户指定 `--branch` > manifest 中 `default_branch` > 自动探测（`main` → `master`）

详细 manifest 字段规范见 [reference/manifest-spec.md](reference/manifest-spec.md)。

### 步骤 2：拉取目标工程文档

使用辅助脚本执行拉取：

```bash
scripts/fetch-docs.sh \
  --app {APPNAME} \
  --repo {repo_url} \
  --branch {branch} \
  --docs-root {docs_root} \
  --target applications/app-{APPNAME}
```

脚本职责：

- `git clone --depth=1 --branch {branch} {repo_url}` 到临时目录
- 将 `{docs_root}/` 内容同步到应用知识库根目录下 `applications/app-{APPNAME}/`（rsync 或 cp -r）
- 保留 `applications/app-{APPNAME}/changelogs/` 目录（不覆盖本地 changelog）
- 清理临时目录

脚本输出原始同步统计（新增/修改/删除文件数），由 Agent 生成 changelog 记录。

### 步骤 3：生成同步 changelog

在应用知识库根目录 `applications/app-{APPNAME}/changelogs/fetch-log.md` 末尾追加一条同步记录：

```markdown
## {YYYY-MM-DD HH:mm} 同步 — {branch}@{short_commit}

| 字段 | 值 |
|------|-----|
| 应用 | {APPNAME}（{app_id}） |
| 仓库 | {repo_url} |
| 分支 | {branch} |
| 提交 | {short_commit}（{commit_message}） |
| 同步时间 | {ISO-8601} |
| 新增文件 | {added_count} |
| 修改文件 | {modified_count} |
| 删除文件 | {deleted_count} |
```

changelog 格式规范见 [assets/fetch-log-template.md](assets/fetch-log-template.md)。

### 步骤 4：验证与收尾

- 验证应用知识库根目录下 `applications/app-{APPNAME}/` 目录结构完整（含 `knowledge/`、`requirements/`、`changelogs/`）
- 验证 `{APPNAME}_manifest.yaml` 未被覆盖（若被覆盖则从 Git 恢复）
- 输出同步摘要：分支、提交号、文件变更统计

## 核心约束


| 约束           | 说明                                                    |
| ------------ | ----------------------------------------------------- |
| 注册前置         | 目标应用必须已通过 `docs-init --mode=central` 注册，manifest 必须存在 |
| changelog 保留 | 本地 `changelogs/` 目录不被远端内容覆盖，仅追加同步记录                   |
| manifest 保护  | `{APPNAME}_manifest.yaml` 不被远端内容覆盖                    |
| 幂等性          | 相同分支相同提交重复执行结果一致                                      |
| 零幻觉          | 只同步实际拉取到的文件，不编造文件内容                                   |


## 依赖关系


| 类型  | 技能/组件                      | 说明                                 |
| --- | -------------------------- | ---------------------------------- |
| 前置  | `docs-init --mode=central` | 应用须已注册，manifest 须存在                |
| 协作  | `docs-archive`             | 同步后可运行 docs-archive 将应用侧有效信息上行到系统库 |
| 协作  | `docs-change`              | 同步后可运行 docs-change 生成变更索引          |


## 参考


| 资源            | 路径                                                           | 何时读                       |
| ------------- | ------------------------------------------------------------ | ------------------------- |
| manifest 字段规范 | [reference/manifest-spec.md](reference/manifest-spec.md)     | 解析 manifest 时，字段不确定时      |
| 拉取脚本          | [scripts/fetch-docs.sh](scripts/fetch-docs.sh)               | 步骤 2 执行拉取时                |
| changelog 模板  | [assets/fetch-log-template.md](assets/fetch-log-template.md) | 步骤 3 生成记录时                |
| 常见陷阱与防错       | [gotchas.md](gotchas.md)                                     | 遇到 manifest 缺失、分支冲突、覆盖问题时 |


