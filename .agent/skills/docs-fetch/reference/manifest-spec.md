# manifest 字段规范

`{APPNAME}_manifest.yaml` 是 `docs-init --mode=central` 生成的联邦登记文件，docs-fetch 依赖其中的字段定位目标工程仓库。

---

## 必需字段

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `schema_version` | string | manifest 格式版本 | `"1.1"` |
| `app_id` | string | 应用 ID，全局唯一 | `"APP-MYSERVICE"` |
| `repo_url` | string | 目标工程 Git 仓库地址（HTTPS 或 SSH） | `"https://github.com/org/myservice.git"` |
| `docs_root` | string | 目标工程知识库根目录（相对仓库根） | `"docs"` 或 `"system"` |

## 可选字段

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `default_branch` | string | `main` | 默认同步分支 |
| `app_name` | string | — | 应用中文名称 |
| `last_fetched_at` | string | — | 上次同步时间（ISO-8601），由 docs-fetch 自动更新 |
| `last_fetched_branch` | string | — | 上次同步分支，由 docs-fetch 自动更新 |
| `last_fetched_commit` | string | — | 上次同步提交号（short hash），由 docs-fetch 自动更新 |

---

## 完整示例

```yaml
schema_version: "1.1"
app_id: "APP-MYSERVICE"
app_name: "我的服务"
repo_url: "https://github.com/org/myservice.git"
docs_root: "docs"
default_branch: "main"
last_fetched_at: "2026-04-05T10:00:00+08:00"
last_fetched_branch: "main"
last_fetched_commit: "a1b2c3d"

mirrors_system_paths:
  - {DOC_DIR}/changelogs/changelogs_meta.yaml → changelogs/changelogs_meta.yaml
  - {DOC_DIR}/knowledge/** → knowledge/**
  - {DOC_DIR}/requirements/requirements_meta.yaml → requirements/requirements_meta.yaml

central_library:
  system_root: ../../{DOC_DIR}/
  repository_root: ../../
```

---

## docs-fetch 执行后自动更新的字段

每次成功同步后，docs-fetch 会更新 manifest 中的以下字段：

```yaml
last_fetched_at: "{ISO-8601 同步时间}"
last_fetched_branch: "{实际同步的分支}"
last_fetched_commit: "{short commit hash}"
```

若 manifest 中尚无这些字段，追加到文件末尾。
