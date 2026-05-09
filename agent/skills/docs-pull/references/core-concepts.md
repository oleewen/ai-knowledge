# 核心概念

字段详解：[manifest-spec.md](manifest-spec.md)。

| 术语 | 含义 |
| ------ | ------ |
| `{APPNAME}` | 与 `applications/app-{APPNAME}/` 同名段 |
| manifest 路径 | `applications/app-{APPNAME}/{APPNAME}_manifest.yaml` |
| `repo_url` | 远端 Git；**必需** |
| `docs_root` | 远端知识库根相对路径 |
| `pull-log.md` | `applications/.../changelogs/pull-log.md` |

**分支**：`--branch` > `default_branch` > `main`→`master`；失败则用户指定 → [gates.md](gates.md)。
