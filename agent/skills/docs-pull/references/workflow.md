# 工作流

主干：[SKILL.md](../SKILL.md)；写盘：[gates.md](gates.md)。

## 范围

- **联邦镜像**：`applications/app-{APPNAME}/`  
- **SSOT**：远端 `{DOC_DIR}/`；本体**不因本技能默认被改**，只镜像树更新。

## IO

| 类型 | 内容 |
| ---- | ------ |
| 硬 | `applications/app-{APPNAME}/{APPNAME}_manifest.yaml`（`repo_url`、`docs_root`…） |
| 可选 | `--app`、`--branch`、`--dry-run`、`--force` |
| 出 | 更新镜像；**追加** `changelogs/pull-log.md` |
| 不做 | 改中央 `{DOC_DIR}/`；不自动 distill；不改 `APPLICATIONS_INDEX.md` |

## 参数

| 参数 | 默认 | 说明 |
| ---- | ------ | ------ |
| `--app` | 自动发现多个则列选 | |
| `--branch` | manifest `default_branch` 否则 `main`→`master` | 均无 → 停机 |
| `--dry-run` | 假 | 只打计划 |
| `--force` | 假 | 强覆盖 → [gates.md](gates.md) 额外一句确认 |

## 四步

### 1 发现与 manifest

无 `--app` → 扫 `applications/app-*/` 供选。读 manifest：**复述** `repo_url`、`docs_root`、`app_id`。分支：`--branch` > `default_branch` > `main`→`master`。字段 [manifest-spec.md](manifest-spec.md)。

### 2 拉取

```bash
agent/skills/docs-pull/scripts/pull-docs.sh \
  --app {APPNAME} --repo {repo_url} --branch {branch} \
  --docs-root {docs_root} --target applications/app-{APPNAME}
```

职责（脚本）：clone → 备份 `changelogs/`+manifest → rsync → 恢复保护文件 → 可能迁日志为 `pull-log.md` → 更新 `last_pulled_*`。  
**非 dry-run 前** → [gates.md](gates.md) HARD-GATE。

### 3 记录

在 `applications/app-{APPNAME}/changelogs/pull-log.md`**末尾追加**（**0 变更也写一条**）。格式 [../assets/pull-log-template.md](../assets/pull-log-template.md)。

### 4 收尾

核对 `knowledge/`、`requirements/`、`changelogs/`；manifest 未被覆盖（否则 `git checkout -- …manifest`）；输出分支、提交、统计摘要。

## 约束

| 项 | 要求 |
| -- | ------ |
| 注册前置 | manifest 可读且 `repo_url` 非空 |
| changelog | 本地 `changelogs/` **不被远端盖** |
| manifest | `{APPNAME}_manifest.yaml` **不被远端盖** |
| 幂等 | 同分支同提交重复结果一致 |
| 零幻觉 | 只汇报真实拉到的内容与提交 |

**预检**：参数齐可走快路径或多先 `--dry-run`；多 app、`--force`、大范围覆盖用语 → gates 分步确认。
