---
name: docs-fetch
description: >
  从已通过中央知识库挂载建联注册的目标工程拉取最新文档，覆盖更新本仓库联邦镜像
  applications/app-{APPNAME}/，并追加同步 changelog。
  只要用户提到以下任意场景，就应立即使用本技能，不要等用户明确说"/docs-fetch"：
  同步应用文档、拉取最新知识库、更新联邦镜像、应用侧有更新要拉到中央库、
  "把应用的文档同步过来"、"拉一下最新的"、"应用知识库更新了帮我同步"、
  "更新一下 app 镜像"、"docs-fetch 一下"。
---

# 应用知识库拉取（docs-fetch）

**术语**：**联邦镜像**指本仓库内 `applications/app-{APPNAME}/`（由中央知识库挂载建联登记）。**应用知识库 SSOT** 指 `{DOC_DIR}/`，本技能默认不修改。

## 前置条件

目标应用必须已通过中央知识库挂载建联注册：

- `applications/app-{APPNAME}/` 目录存在
- `applications/app-{APPNAME}/{APPNAME}_manifest.yaml` 存在且含 `repo_url` 字段

未注册的应用须先执行中央知识库挂载建联。

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | `applications/app-{APPNAME}/{APPNAME}_manifest.yaml`（含 `repo_url`、`docs_root`） |
| 可选输入 | `--app` 应用名、`--branch` 目标分支 |
| 固定输出 | 更新后的 `applications/app-{APPNAME}/` 目录内容 |
| 附加产出 | `applications/app-{APPNAME}/changelogs/fetch-log.md`（追加同步记录） |
| 不产出 | 不修改 `{DOC_DIR}/`、不触发 `docs-distill`、不修改 `APPLICATIONS_INDEX.md` |

## 参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--app` | 自动发现 | 应用名称；未指定时列出已注册应用供选择 |
| `--branch` | `main` → `master` | 目标分支；自动探测主干，两者均不存在时终止 |
| `--dry-run` | `false` | 预览模式，仅打印操作计划，不实际拉取 |
| `--force` | `false` | 强制覆盖，跳过冲突确认 |

## 工作流

**预检策略**：参数已齐且无歧义时直接执行（或先 `--dry-run`）。遇多应用未指定、分支失败、`--force`/大范围覆盖等高风险情形，按 [reference/preflight.md](reference/preflight.md) 分步确认，**写盘前须满足 HARD-GATE**。

### 步骤 1：应用发现与 manifest 解析

1. 若未指定 `--app`，扫描 `applications/app-*/` 列出已注册应用供选择
2. 读取 manifest，提取 `repo_url`、`docs_root`、`app_id`；向用户复述将使用的值
3. 确认分支优先级：`--branch` > manifest `default_branch` > 自动探测（`main` → `master`）

manifest 字段规范见 [reference/manifest-spec.md](reference/manifest-spec.md)。

### 步骤 2：拉取目标工程文档

```bash
scripts/fetch-docs.sh \
  --app {APPNAME} \
  --repo {repo_url} \
  --branch {branch} \
  --docs-root {docs_root} \
  --target applications/app-{APPNAME}
```

脚本负责：clone → 备份 `changelogs/` 和 manifest → rsync 同步 → 恢复保护文件 → 更新 manifest `last_fetched_*` 字段 → 输出统计。

### 步骤 3：追加同步 changelog

在 `applications/app-{APPNAME}/changelogs/fetch-log.md` 末尾追加一条记录（即使文件无变化也须追加）。格式见 [assets/fetch-log-template.md](assets/fetch-log-template.md)。

### 步骤 4：验证与收尾

- 验证 `applications/app-{APPNAME}/` 目录结构完整（含 `knowledge/`、`requirements/`、`changelogs/`）
- 验证 `{APPNAME}_manifest.yaml` 未被覆盖（若被覆盖则 `git checkout` 恢复）
- 输出同步摘要：分支、提交号、增删改统计

## 核心约束

| 约束 | 说明 |
|------|------|
| 注册前置 | manifest 必须存在且 `repo_url` 非空，否则终止 |
| changelog 保留 | 本地 `changelogs/` 不被远端覆盖，仅追加 |
| manifest 保护 | `{APPNAME}_manifest.yaml` 不被远端覆盖 |
| 幂等性 | 相同分支相同提交重复执行结果一致 |
| 零幻觉 | 只同步实际拉取到的文件，不编造内容 |

## 参考资源

| 资源 | 路径 | 何时读 |
|------|------|--------|
| 预检与写盘闸门 | [reference/preflight.md](reference/preflight.md) | 多应用/分支歧义/强制覆盖前；实跑前确认时 |
| manifest 字段规范 | [reference/manifest-spec.md](reference/manifest-spec.md) | 解析 manifest 时；字段不确定时 |
| 拉取脚本 | [scripts/fetch-docs.sh](scripts/fetch-docs.sh) | 步骤 2 执行拉取时 |
| changelog 模板 | [assets/fetch-log-template.md](assets/fetch-log-template.md) | 步骤 3 生成记录时 |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) | 遇到 manifest 缺失、分支失败、覆盖问题时 |

## 依赖关系

| 类型 | 技能 | 说明 |
|------|------|------|
| 前置 | 中央知识库挂载建联 | 应用须已注册，manifest 须存在 |
| 协作 | `docs-distill` | 同步后可将应用侧有效信息上行到系统库 |
| 协作 | `docs-change` | 同步后可生成变更索引 |
