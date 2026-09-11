# gotchas

- **须在源仓 Git 根执行**：company→system 或 system→application；应用仓打开工作区时技能应停，不代跑
- 目标须已有 `knowledge-links.yaml`（application 由 docs-install 落盘空清单）；缺则脚本失败
- `app_name`：`--app-name` > 已有登记 > Git 根目录名；槽位名 `application-{NAME}` / `system-{NAME}` 依赖此名，向导须确认
- 重复 link：合并更新同一条，不追加重复行；已有 `app_label` 不覆盖
- `type:meta`（docs-install 写入）写回时保活；pull/push 跳过 meta
- `--rewrite-http` 默认关；仅换父改正文；unlink **不**改 HTTP
- 槽位软链可悬空；正文回拉/修复走 `/docs-pull`，不要把 pull 收成本技能
- 建联脚本仅在 `agent/skills/docs-link/scripts/`；目标仓 `scripts/docs-link.sh` 为旧残留，不自动删，登记仍可用中央库脚本路径调用
- Bash 5+；依赖 `link-config.sh` 与 Agent 侧 `federation-slot-symlink.sh`（联邦布局）
