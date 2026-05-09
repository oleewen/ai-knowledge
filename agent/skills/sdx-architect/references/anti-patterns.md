# sdx-architect 反模式

| 反模式 | 纠正 |
|--------|------|
| 未确认即写 `ASD-*.md` | 会话草稿 → 总确认 → 落盘；或记录合法例外 |
| ASD 内写实现级 API/DDL/完整规约 | 只保留架构边界与规约摘要；细节 → `/sdx-design` |
| 缺 §1/§2/§3 或只有图 | 按 `asd-template.md` 补全三节骨架再填内容 |
| 结论无法映射 PRD/ANALYSIS | 补来源引用，删无依据论断 |
| 文件名/目录/占位符不合规 | 统一规范路径与占位替换 |
| 未标 `PENDING`/`CONFIRMED` | 会话 spec 写明门禁状态（见 `gates.md`）|
| 有图无决策与理由 | 补决策表（取舍、备选） |
| 未跑 `validate-asd.sh` 即收尾 | validate 为必做收尾步骤 |
| `KNOWLEDGE_TYPE` 为 system/company 时在本库强写 DSD 或完整 `{DOC_DIR}/specs/` | 本层仅联邦概要 ASD；详设 → 应用库 `/sdx-design`（见 [knowledge-type-modes.md](knowledge-type-modes.md)）|
