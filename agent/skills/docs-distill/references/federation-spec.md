# 联邦与 overview 写入规范

布局、路径和表行真源：[knowledge-layout.md](../../../references/knowledge-layout.md)。本文件只定义槽位上行到 system、solution、company overview 的写法。

## 目标边

路径与知识层分开解析，见 [工作流参数与路径](workflow.md#参数与路径)。源槽位位于实际 DOC_DIR 下，按 system←application、solution←system、company←solution 选择前缀；目标为 `{DOC_DIR}/knowledge/overview/{NAME}-overview.md`。

目标不存在时，从同层 `NAME-overview.md` 创建，并同步替换文件名和标题。`application/knowledge/overview` 不属于本技能目标；非槽位源走 `docs-extract`。

槽位内 `knowledge` 与 SDD 正文中的已核实内容是事实来源，须读取并按目标表行提炼，不整段复制。槽位外正文和 legacy `architecture/`/`ea/` 路径不作为本次蒸馏来源。

## 第三列规则

先读 [overview 增量语义](../../../knowledge/overview-spec.md#第三列增量语义)，按其覆盖判定、A/U/D 和删除证据要求提炼。本节只定义 distill 的全量写入方式。

逐行读取目标层模板、同层 README 表行、槽位来源和目标知识正文。全量比对后重建各行第三列，不把 extract 的命中批次保留方式套用到本技能：

- 有未覆盖或已变更要点：按共用语义形成该行完整待归档 delta，再替换第三列。
- 全行已覆盖或无变化：写 `—` 或保持原值，按已确认写入范围执行。
- 无契约证据：写 `—`；这只是本次缓冲列处理，不表示目标正文的事实已废止。
- 覆盖关系、删除依据或旧项替换影响未明：先澄清，不以“全量”绕过未决项，也不清除已有待核实 delta。

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
