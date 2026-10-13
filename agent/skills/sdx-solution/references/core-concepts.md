# sdx-solution 核心概念

## IDEA-ID

格式：`{YYMMDD}-{主题}`。只属于该解决方案库的交付包，不与系统库、应用库的 `ANALYSIS` / `FEATURE` 共用。

| 产物 | 路径 |
| --- | --- |
| 切分叙事 | `{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md` |
| 事实 | 同库 `knowledge/` 的 `PD`、`BP`、`BSP`、`MDG`、`TSD` |

## 多份与现行

- 一仓可有多份。每一份是对当时最新 knowledge 的一次增量。
- `parent` 指向上一份 `SOLUTION-{IDEA-ID}`。第一份 `parent` 为空。
- 旧文件不改。没有被其他文件写成 `parent` 的那份是现行。
- 后继只能有一个。已有后继再写第二份 → 硬停。

## 读者与禁区

读者是架构与产品。写取舍和边界。不写需求条目，不写实现，不出现 `SYS`，不抄实体字段定义。长文留在 knowledge 章节，正文只点 ID。
