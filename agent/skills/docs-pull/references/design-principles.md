# docs-pull 设计原则

与 [anti-patterns.md](anti-patterns.md) 互补；**操作层**见 [../gotchas.md](../gotchas.md)。

---

## 原则

1. **登记真源**：无 manifest / 无 `repo_url` 不拉取，不从目录名猜远程仓。
2. **保护本地登记与日志**：`{APPNAME}_manifest.yaml` 与 `changelogs/` 不被远端覆盖；同步后校验并可 `git checkout` 恢复。
3. **分支不静默漂移**：clone 失败不自动换分支，除非用户明示。
4. **可预览**：高风险或不确定时优先 `--dry-run`。
5. **可审计**：每次实跑后追加 `pull-log.md`，无变化也记一条。
6. **范围克制**：只更新联邦镜像；不冒充 `docs-distill` / `docs-extract` / SDD 落盘。
7. **与 CONVENTIONS 一致**：低风险路径不虚构 spec gate 或 hooks 依赖。
