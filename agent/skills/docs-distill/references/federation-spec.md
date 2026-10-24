# 联邦与 overview 写入规范

布局、路径和表行真源：[knowledge-layout.md](../../../references/knowledge-layout.md)。本文件只定义槽位上行到 system、solution、company overview 的写法。

## 目标边

路径与知识层分开解析，见 [工作流参数与路径](workflow.md#参数与路径)。源槽位位于实际 DOC_DIR 下，按 system←application、solution←system、company←solution 选择前缀；目标为 `{DOC_DIR}/knowledge/overview/{NAME}-overview.md`。

目标不存在时，从同层 `NAME-overview.md` 创建，并同步替换文件名和标题。`application/knowledge/overview` 不属于本技能目标；非槽位源走 `docs-extract`。

槽位内 `knowledge` 与 SDD 正文中的已核实内容是事实来源，须读取并按目标表行提炼，不整段复制。槽位外正文和 legacy `architecture/`/`ea/` 路径不作为本次蒸馏来源。

## 第三列规则

第三列是待归档的 delta 区。逐行读取目标层模板和同层 README 表行，再读取槽位来源；禁止整段复制。

### 比对与相同判定

1. 优先读表行副标题链接的锚点小节；锚点不可读时读主标题整章。
2. 目标层已有段落或实体已实质覆盖要点时，第三列写 `—` 或保持不动。
3. 事实一致、只是表述不同，也视为已覆盖。
4. 目标 overview 的旧第三列用于核对待归档项，不是新事实来源，也不能单独证明知识正文已覆盖；覆盖结论必须来自上述目标正文。源正文用于提炼事实，不能仅据此判定目标层已覆盖。

### A/U/D

| 标记 | 用法 |
| --- | --- |
| `[A]` | 目标行没有覆盖，源侧有新增要点 |
| `[U]` | 已有要点发生变化；默认只写变更 delta，无法拆分时停等「delta / 整段重摘要」选择 |
| `[D]` | 删除说明，供 `docs-archive` 回写；归档完成后恢复 `—` |
| 无标记 | 已覆盖、无命中或无变化；写 `—` 或保持原值 |

### dry-run

输出三分区：

1. 将写入：A/U/D；超过 10 行时给统计与样例，用户要求后再展开。
2. 跳过：已覆盖要点。
3. 无命中：没有契约证据的表行写 `—`。

`--dry-run` 不修改 overview，也不生成日志。

## 目标层表行

表行以当前 `DOC_DIR` 的 overview 模板和同层五视角 README 为唯一真源。逐行处理全部主标题及副标题，不用静态摘要替代表行，也不跨层套用。

第三列可用短段、列表或小表；无证据写 `—`。不得写 `(来源…)` 堆链、OpenAPI 全文、整段 DDL 或实现类名清单。

## 自检

- [ ] 当前层全部表行已处理。
- [ ] 已覆盖要点没有重复全文。
- [ ] A/U/D 与目标层表行一致。
- [ ] 文件名和标题中的 `{NAME}` 一致。
- [ ] 未写 `DISTILL-LOG`。
