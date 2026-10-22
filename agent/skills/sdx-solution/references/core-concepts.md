# sdx-solution 核心概念

## IDEA-ID

格式：`{YYMMDD}-{主题}`，语法见 [命名约定](../../../knowledge/naming-conventions.md)。这是该解决方案库的交付包标识，不与系统/应用的 `ANALYSIS`、`FEATURE` 共用。

| 产物 | 路径 |
| --- | --- |
| 切分叙事 | `{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md` |
| 事实 | 同库 `knowledge/` 的 `PD`、`BP`、`BSP`、`MDG`、`TS` |

## 多份与现行

- 每份记录当时 knowledge 下的切分决策；后续版本只写相对前驱的增量。
- `parent` 填已有的 `SOLUTION-{IDEA-ID}`，不用路径或 `.md` 后缀；首份为空。同一前驱最多一个后继，链不得自指或成环。
- 未被其他文件用作 `parent` 的文件是现行候选。若有多份候选，由用户选择本次前驱，不按日期猜测。
- 新建后继不改前驱；用户明确指定的当前草稿可以续写、`M` 修改或按协议重开。不能因草稿已落盘就另建一份。

## 读者与禁区

见 [受众差额](audience-and-language.md)；实体与正文边界见 [gates.md](gates.md#写入约束)。
