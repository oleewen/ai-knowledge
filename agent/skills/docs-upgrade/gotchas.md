# docs-upgrade 陷阱

- **误跑 docs-install knowledge**：会清空 DOC_DIR。升级只用 `docs-upgrade.sh` + Agent 重填。
- **缺 type:meta**：装机未完成或 links 被手改。硬停；用 install upsert 或 `--meta-path`，勿猜。
- **多条 type:meta**：非法；硬停至剩一条。
- **path 未 fetch**：本机工作区脏/旧 ≠ 远端最新。脚本须 fetch 对齐 ref。
- **把未落位自动追加文末**：禁止；须清单确认。
- **覆盖 knowledge-links.yaml**：禁止；会丢 parent/child/meta。
- **联邦槽位**：`application-*` / `system-*` 首段路径一律忽略；勿把槽位当本层骨架升级（用 `/docs-pull`）。
- **建联脚本**：仅 `system`/`company` 同步；源在元库根 `scripts/`，不是 `{doc_dir}/`。application 无此桶。
- **Agent 树**：本技能不管；走 `/docs-bootstrap --components=agent`。
- **Bash 5+**、Git 必需。
- **中央脚本路径**：在目标工程执行时须指向元库/中央库的 `agent/skills/docs-upgrade/scripts/docs-upgrade.sh`。
