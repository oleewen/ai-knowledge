# docs-agent 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

## 定位

本文件只做 `docs-agent` 对共享契约的 **binding**，不复制协议正文。

契约：

- [intent-clarify.md](../../../references/intent-clarify.md) — 写前意图澄清
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) — 单元推进、`C/M/G/S/F`、重开与前文回改
- [grilling-skill.md](../../../references/grilling-skill.md) — 写后烤干能力

主线口令：`澄清 → 生成 → 烤干`。用户动作与状态机见 unit-cycle-protocol（含 docs 语义族 `S`）。

## 单元定义

**当前单元** = 单个根入口文档：

- `README.md`
- `AGENTS.md`

`output=both` 时默认顺序：README → AGENTS。一次只处理一个入口文件。

## 技能追加澄清字段

在公共六项之外追加（不可删减公共项）：

- **写入策略**：`merge` / `overwrite` / 待确认
- **INDEX 锚点**：本轮依赖的 `INDEX-GUIDE.md` 相对路径

## 写后默认

见 [workflow.md](workflow.md)「写后默认表」。本技能各入口文档单元默认必须烤干。

## 高风险场景

须先给结论、推荐与数字选项，确认后再执行：

- `update` 与覆盖边界不清
- README 与 AGENTS 职责边界需要调整
- 已有内容是否保留存在歧义
- `output=both` 但用户只明确了一个文件

## 原子性 / 失败停顿

- 未获写前 `C`，不得写入当前单元正文
- 当前单元未收敛前，不默认推进下一入口文件
- 烤干默认只拷当前单元；另一入口文件属前文，回改须走 unit-cycle-protocol 前文回改（回改后当前单元 `reopened` → 再澄清）

## 与 INDEX 的关系

- INDEX 须已落盘；无 INDEX 不编造
- 本技能不替代 `docs-indexing`
- INDEX 落盘约束见 [execution-spec.md](execution-spec.md)，独立生效

## 典型语义问题（烤干）

- 职责边界、覆盖策略、保留口径、INDEX 对齐口径
- 跨入口文件的术语/职责冲突（触发前文回改）
