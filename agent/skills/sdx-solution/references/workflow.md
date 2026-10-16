# sdx-solution 工作流

主干：[SKILL.md](../SKILL.md)。推进 binding：[gates.md](gates.md)。

## 目标

通过参数向导 + 分段「澄清 → 生成 → 烤干」，写一份交付包切分叙事 `SOLUTION-{IDEA-ID}.md`。

**仅解决方案库**（`KNOWLEDGE_TYPE=solution` 或 `sln`）。交付物 `{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md`。公司 → `/sdx-domains`。系统/应用 → `/sdx-analysis`。

## 参数向导

最小可写条件：

- 主题已明确
- `IDEA-ID` 已给出或可按 `{YYMMDD}-{主题}` 生成
- 已确认是第一份，或已给出上一份 ID 且该份还没有后继
- `{DOC_DIR}/solutions/` 可写

推荐顺序：`IDEA-ID` → 标题 → 上一份 ID → 本轮起始段。

## 段落

1. `## 这次改了什么`（第一份写首份）
2. `## 为什么这样切`
3. `## 范围内外`
4. `## 流程怎么串`
5. `## 主数据主权`
6. `## 技术例外`

事实取自当时 knowledge。写完一段即烤干，用户确认后再写下一段。
