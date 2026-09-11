# docs-link 工作流

[SKILL.md](../SKILL.md)；风险控制与动作协议 [gates.md](gates.md)。

## 参数向导

按以下顺序收口参数；用户已明确时可跳过对应项：

1. 源仓闸门：当前工作区 `.docsconfig` → `KNOWLEDGE_TYPE` 须为 `company` 或 `system`
2. 动作：`--link` 或 `--unlink`
3. `--target`（目标仓库根或已登记 remote URL）
4. 名称：system→application 时确认 `app_name`（可预填推断）；company→system 时确认系统名（脚本登记字段同源）
5. 是否 `--rewrite-http`（默认否；仅明示换父时讨论）

参数未收口前，不进入执行。

## 当前单元

一对源仓 × 一个 `--target` 的一次 link 或 unlink。

一次只处理一个当前单元；多目标用 `F` 逐个补齐，不得并行静默。

## 执行循环

### 1 源仓闸门

- 读当前仓 `.docsconfig` 的 `KNOWLEDGE_TYPE`
- 允许边：`company→system`、`system→application`
- 非法源（含 application）：停止并说明须切换到源仓工作区

### 2 解析目标与名称

- `--target` 须可解析；link 时目标须已有 `knowledge-links.yaml`（缺则失败，application 通常由 docs-install 落盘）
- 名称：向导必问，可预填「已有登记 > Git 根目录名」推断值；确认后再传 `--app-name`

### 3 dry-run

```bash
bash agent/skills/docs-link/scripts/docs-link.sh --link|--unlink --target <目标> [--app-name=<名>] [--rewrite-http] --dry-run
```

展示将改写的 links 路径、登记 identity、槽位动作；停下等 `C/M/S/F`。

### 4 真写（仅确认后）

去掉 `--dry-run` 重跑同一参数集。脚本负责：

- 源 links：向下 child（缺省无 type）；合并同 target，不追加重复行
- 子仓 links：唯一 `type:parent`；`type:meta` 保活
- 槽位：`application-{NAME}` / `system-{NAME}` → 下级 `DOC_ROOT`；unlink 删软链，共用日志保留
- `--rewrite-http`：仅显式开启时改目标 `knowledge/**` 跨层 HTTP 前缀

### 5 风险校核与停顿

真写后校核：源/目标 links、槽位软链、（若开启）HTTP 改写范围摘要。当前单元收敛后停下等 `C/M/S/F`。
