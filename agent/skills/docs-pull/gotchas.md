# gotchas

- 优先 `docs-link` 建联（软链可悬空）；`docs-pull` 负责校验/修复软链并在失效时 clone/pull
- 目标仓库 `.docsconfig` 必须完整且可解析（clone 之后仍缺则失败）
- 软链目标：有 `.docsconfig` 用 **`DOC_ROOT`**，否则 `{path}/{doc_dir}`；不要再拼一层 `DOC_DIR`
- `knowledge-links.yaml` 字段合同为强约束：缺字段直接失败
- `origin` 必须与 `repository` 匹配（规范化比较）；脏工作区拒绝 `git pull`
- 旧真目录槽位会静默迁移（合并旧日志进共用 `changelogs/` 后删除）
- 追溯在 `application-slots/changelogs/CHANGE-LOG.md` 或 `system-slots/changelogs/CHANGE-LOG.md`，不在槽位内部
