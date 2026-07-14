# docs-pull 工作流

[SKILL.md](../SKILL.md)；风险控制与动作协议 [gates.md](gates.md)。

## 参数向导

按以下顺序收口参数；用户已明确时可跳过对应项：

1. 运行模式：system（application → system）或 company（system → company）
2. `--app` / `--sys-name` / `--all`
3. 当前轮起始槽位单元

参数未收口前，不进入执行。

## 当前槽位单元

一个当前槽位单元就是单个联邦槽位：

- system 库下的 `application-{app_name}`
- company 库下的 `system-{sys_name}`

一次只处理一个当前槽位单元，不并行推进多个槽位。

## 执行循环

### 1 建联前提

- 在 system 知识库根执行 docs-link 建联（创建 `application-{app_name}/` 槽位）
- 在 company 知识库根执行 docs-link 建联（创建 `system-{sys_name}/` 槽位）
- 必须先有槽位目录，否则 `pull-slots.sh` 失败退出

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

- 仅使用本地 `path`，不 clone
- 要求源 `path` 为 Git 工作区
- 目标仓库 `.docsconfig` 必须完整可解析
- 同步时排除 `README.md`、`index.md`、`changelogs/`

### 4 风险校核

当前槽位单元同步后，立即校核：

- `knowledge-links.yaml` 字段是否完整
- `path` 是否存在且为 Git 工作区
- 目标 `.docsconfig` 与 `KNOWLEDGE_TYPE` 是否匹配
- 槽位 `changelogs/CHANGE-LOG.md` 是否已追加追溯记录

### 5 输出与动作停顿

当前槽位单元收敛后，停下等待 `C/M/S/F`：

- `C`：确认当前槽位单元并结束或进入下一槽位
- `M`：修改参数、范围或模式，再重新校核
- `S`：跳过当前槽位单元
- `F`：按已确认参数补齐剩余槽位
