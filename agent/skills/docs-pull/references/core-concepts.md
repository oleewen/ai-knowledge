# docs-pull 核心概念

[SKILL.md](../SKILL.md) 为主干；字段细节见 [manifest-spec.md](manifest-spec.md)。

---

## 路径与对象

| 术语 | 含义 |
|------|------|
| `{APPNAME}` | 应用目录名，与 `applications/app-{APPNAME}/` 段一致 |
| `{APPNAME}_manifest.yaml` | 联邦登记文件路径：`applications/app-{APPNAME}/{APPNAME}_manifest.yaml` |
| `repo_url` | 目标工程 Git 地址；**硬依赖** |
| `docs_root` | 目标工程内知识库根相对路径（如 `docs`、`system`） |
| `pull-log.md` | 每应用同步历史，路径在 `applications/.../changelogs/pull-log.md` |

---

## 分支解析优先级

`--branch`（CLI） > manifest `default_branch` > 自动探测 `main` → `master`。

探测失败须停机，由用户指定分支（见 [gates.md](gates.md)）。
