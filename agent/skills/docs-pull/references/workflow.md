# docs-pull 工作流

[SKILL.md](../SKILL.md)；风险控制与动作协议 [gates.md](gates.md)。

## 参数向导

按以下顺序收口参数；用户已明确时可跳过对应项：

1. 运行模式：system（application → system）或 company（system → company）
2. `--app` / `--sys-name` / `--all`
3. 当前轮起始槽位单元

参数未收口前，不进入执行。

## 当前槽位单元

一个当前槽位单元就是单个联邦槽位软链：

- system 库下的 `application-slots/application-{NAME}` → 应用 `DOC_ROOT`
- company 库下的 `system-slots/system-{NAME}` → 系统 `DOC_ROOT`

一次只处理一个当前槽位单元，不并行推进多个槽位。

## 执行循环

### 1 建联前提

- 优先已用 docs-link 建联（写 yaml + 建软链；可悬空）
- 共用日志目录：`application-slots/changelogs/` 或 `system-slots/changelogs/`

### 2 选择当前槽位单元

- `--app <app_name>`：同步单个 application 槽位
- `--sys-name <sys_name>`：同步单个 system 槽位
- `--all`：先选择一个当前槽位单元处理，收敛后再决定是否继续剩余槽位

### 3 执行同步

```bash
bash agent/skills/docs-pull/scripts/pull-slots.sh --app <app_name>
bash agent/skills/docs-pull/scripts/pull-slots.sh --sys-name <sys_name>
bash agent/skills/docs-pull/scripts/pull-slots.sh --all
```

脚本约束：

- path 不存在 → `git clone <repository> <path>`
- path 已存在 → `origin` 须匹配 `repository`；脏工作区拒绝；否则 `git pull --ff-only`（远端默认分支）
- 软链目标：有 `.docsconfig` 用其 `DOC_ROOT`，否则 `{path}/{doc_dir}`
- 旧真目录槽位：合并旧 `ARCHIVE-LOG` 进共用文件后删除，再建软链（静默）；不再维护 CHANGE-LOG
- 追溯：`SYNC_OK` 含 commit / source / action；变更看下级仓 git

### 4 风险校核

当前槽位单元同步后，立即校核：

- `knowledge-links.yaml` 字段是否完整
- path / origin / 软链是否有效
- 目标 `.docsconfig` 与 `KNOWLEDGE_TYPE` 是否匹配
- `SYNC_OK` 是否含可核对的 `commit`

### 5 输出与动作停顿

当前槽位单元收敛后，停下等待用户动作（字母见 [light-flow-actions.md](../../../references/light-flow-actions.md)，`C/M/S/F`，无 `G`）。
