# gotchas

- 优先 `docs-link` 建联（软链可悬空）；`docs-pull` 负责校验/修复软链并在失效时 clone/pull
- 目标仓库 `.docsconfig` 必须完整且可解析（clone 之后仍缺则失败）
- 软链目标：有 `.docsconfig` 用 `WORK_SPACE/REPO_DIR/DOC_DIR`，否则 `{path}/{dir}`。缺 `type` 或出现旧键（`doc_dir`、`*_name`、`*_label`）则失败，不读旧键
- `knowledge-links.yaml` 字段合同为强约束：缺字段直接失败
- `origin` 必须与 `repository` 匹配（规范化比较）；脏工作区拒绝 `git pull`
- 追溯在下级仓 `git log` / `SYNC_OK` 的 `commit` 字段，不写 `CHANGE-LOG.md`
