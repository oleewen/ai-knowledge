# docs-upgrade 陷阱

- **误跑 docs-install knowledge**：会清空 DOC_DIR。升级只用 `docs-upgrade.sh` + Agent 重填（文件模式亦禁清空 install）。
- **缺 type:meta**：装机未完成或 links 被手改。硬停；用 install upsert 或 `--meta-path`，勿猜。
- **多条 type:meta**：非法；硬停至剩一条。
- **path 未 fetch**：本机工作区脏/旧 ≠ 远端最新。脚本须 fetch 对齐 ref；文件模式同源。
- **把未落位自动追加文末**：禁止；须清单确认。
- **覆盖 knowledge-links.yaml**：禁止；会丢 parent/child/meta。
- **联邦槽位**：`application-*` / `system-slots` / 遗留 `system-*` 首段路径一律忽略/拒绝；勿把槽位当本层骨架升级（用 `/docs-pull`）。
- **建联脚本**：仅 `system`/`company` 同步；源在元库根 `scripts/`，不是 `{doc_dir}/`。application 无此桶。文件模式仅允许两文件名或 `@scripts/` 只展开这两条。
- **整树与文件模式混用**：禁止同单元；有 `@` 只走文件强制对齐。
- **文件模式无脚本 `--path`**：scaffold/重填由 Agent 写；勿臆造 CLI 过滤。
- **文件模式无强制备份**：依赖 git；勿假设已有 `upgrade-{stamp}`。
- **`@` 目录展开过大**：总览未 `C` 前不写盘；注意递归「所有文件」后非 md 仅可 scaffold。
- **Agent 树 / 生态技能追新**：本技能不管；走 `/skill-upgrade`（装机仍用 `/docs-bootstrap --components=agent`）。
- **Bash 5+**、Git 必需（整树脚本路径）。
- **中央脚本路径**：整树在目标工程执行时须指向元库/中央库的 `agent/skills/docs-upgrade/scripts/docs-upgrade.sh`。
