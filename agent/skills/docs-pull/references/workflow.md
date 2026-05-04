# docs-pull 工作流

[SKILL.md](../SKILL.md) 为主干；写盘前条件与何时停问见 [gates.md](gates.md)。

---

## 术语与范围

- **联邦镜像**：本仓库内 `applications/app-{APPNAME}/`（中央知识库挂载建联登记）。
- **应用知识库 SSOT**：目标工程内 `{DOC_DIR}/`；本技能**默认不修改**中央库 `{DOC_DIR}/` 本体，只更新联邦镜像树。

---

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | `applications/app-{APPNAME}/{APPNAME}_manifest.yaml`（含 `repo_url`、`docs_root`） |
| 可选输入 | `--app`、`--branch`、`--dry-run`、`--force` |
| 固定输出 | 更新后的 `applications/app-{APPNAME}/` 目录内容 |
| 附加产出 | `applications/app-{APPNAME}/changelogs/pull-log.md`（追加同步记录） |
| 不产出 | 不修改中央 `{DOC_DIR}/`、不自动触发 `docs-distill`、不修改 `APPLICATIONS_INDEX.md` |

---

## 参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--app` | 自动发现 | 应用名；未指定时列出已注册应用供选择 |
| `--branch` | `main` → `master` | 目标分支；自动探测；均不存在时终止 |
| `--dry-run` | `false` | 仅打印计划，不实跑拉取 |
| `--force` | `false` | 强制覆盖；须过 [gates.md](gates.md) 额外确认 |

---

## 四步工作流

### 步骤 1：应用发现与 manifest 解析

1. 若未指定 `--app`，扫描 `applications/app-*/` 列出已注册应用供选择。
2. 读取 manifest，提取 `repo_url`、`docs_root`、`app_id`；向用户**复述**将使用的值。
3. 分支优先级：`--branch` > manifest `default_branch` > 自动探测（`main` → `master`）。

字段规范见 [manifest-spec.md](manifest-spec.md)。

### 步骤 2：拉取目标工程文档

```bash
agent/skills/docs-pull/scripts/pull-docs.sh \
  --app {APPNAME} \
  --repo {repo_url} \
  --branch {branch} \
  --docs-root {docs_root} \
  --target applications/app-{APPNAME}
```

（从仓库根执行；路径以实际仓库为准。）

脚本负责：clone → 备份 `changelogs/` 与 manifest → rsync 同步 → 恢复保护文件 → 必要时迁移旧版同步日志为 `pull-log.md` → 更新 manifest `last_pulled_*` 并清理废弃元数据行 → 输出统计。

**实跑本步前**须满足 [gates.md](gates.md) 写盘 HARD-GATE。

### 步骤 3：追加同步 changelog

在 `applications/app-{APPNAME}/changelogs/pull-log.md` **末尾追加**一条记录（即使文件无变化也须追加）。格式见 [../assets/pull-log-template.md](../assets/pull-log-template.md)。

### 步骤 4：验证与收尾

- 验证 `applications/app-{APPNAME}/` 结构完整（含 `knowledge/`、`requirements/`、`changelogs/`）。
- 验证 `{APPNAME}_manifest.yaml` 未被覆盖（若被覆盖则 `git checkout` 恢复）。
- 输出摘要：分支、提交号、增删改统计。

---

## 核心约束

| 约束 | 说明 |
|------|------|
| 注册前置 | manifest 存在且 `repo_url` 非空，否则终止 |
| changelog 保留 | 本地 `changelogs/` 不被远端覆盖，仅追加 |
| manifest 保护 | `{APPNAME}_manifest.yaml` 不被远端覆盖 |
| 幂等性 | 同分支同提交重复执行结果一致 |
| 零幻觉 | 只同步实际拉取到的文件，不编造内容 |

---

## 预检策略（执行节奏）

参数已齐且无歧义时可直接执行（或先 `--dry-run`）。遇多应用、分支失败、`--force`/大范围覆盖等，按 [gates.md](gates.md) 分步确认后再实跑。
