# manifest 字段

`applications/app-{APPNAME}/{APPNAME}_manifest.yaml`：建联生成的登记；docs-pull 依赖其定位远端。

## 必需

| 字段 | 说明 | 例 |
| ------ | ------ | --- |
| `schema_version` | 格式版本 | `"1.1"` |
| `app_id` | 全局唯一 | `"APP-MYSERVICE"` |
| `repo_url` | HTTPS/SSH | `"https://github.com/org/myservice.git"` |
| `docs_root` | 知识库相对仓根路径 | `"docs"` / `"system"` |

## 可选

| 字段 | 默认 | 说明 |
| ------ | ------ | ------ |
| `default_branch` | `main` | 同步分支 |
| `app_name` | — | 展示名 |
| `last_pulled_*` | — | 成功后由脚本写 ISO / 分支 / short hash |

## 示例（节选）

```yaml
schema_version: "1.1"
app_id: "APP-MYSERVICE"
repo_url: "https://github.com/org/myservice.git"
docs_root: "docs"
default_branch: "main"
mirrors_system_paths:
  - {DOC_DIR}/knowledge/** → knowledge/**
central_library:
  system_root: ../../{DOC_DIR}/
  repository_root: ../../
```

## 成功后脚本更新块

```yaml
last_pulled_at: "{ISO-8601}"
last_pulled_branch: "{branch}"
last_pulled_commit: "{short}"
```

尚无则追加；脚本可清理已废弃元数据键。
