# gotchas

- 必须先用 docs-link 建联并创建槽位目录，否则 docs-pull 会失败退出
- 目标仓库 `.docsconfig` 必须完整且可解析
- `knowledge-links.yaml` 字段合同为强约束：缺字段直接失败
- 同步保护排除会阻止上游覆盖槽位包装文件（README/index/changelogs）

