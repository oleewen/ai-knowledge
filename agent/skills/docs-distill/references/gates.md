# docs-distill 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

## 定位

本文件只做 `docs-distill` 对共享契约的 **binding**，不复制协议正文。

契约：

- [intent-clarify.md](../../../references/intent-clarify.md) — 写前意图澄清
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) — 单元推进、`C/M/G/S/F`、重开与前文回改
- [grilling-skill.md](../../../references/grilling-skill.md) — 写后烤干能力

主线口令：`澄清 → 生成 → 烤干`。用户动作与状态机见 unit-cycle-protocol（含 docs 语义族 `S`）。

## 单元定义

**当前单元** = 单个 `{NAME}-overview.md` + 单次全量范围。

一次只处理一个源名；含 `--dry-run` 预览结果。

## 技能追加澄清字段

在公共六项之外追加（不可删减公共项）：

- **`DOC_DIR` / `--doc-dir`**：`system` 或 `company`
- **`--name`**：应用名（system 边）或系统名（company 边）
- **写入模式**：正式写入 / `--dry-run` 预览
- **overview 状态**：新建 / 更新

意图澄清须写明边（源槽位 → 目标 overview）与 `--dry-run` 等关键参数摘要。模式恒为全量。

## 写后默认

见 [workflow.md](workflow.md)「写后默认表」。本技能各 overview 单元默认必须烤干（含 dry-run 预览）。

## 高风险场景

须先给结论、推荐与数字选项，确认后再执行：

- 全量覆盖已有第三列
- 首次创建 `{NAME}-overview.md`
- 未指定 `--name` 或多源候选
- `DOC_DIR` 不明（非 `system|company`）
- 槽位缺失或为空
- 源侧与目标层知识冲突，且规则无法自动消解
- 要求跳过预览直接写入

这些情形下，`--dry-run` 是推荐方案；**仍须写前意图澄清**。

## 原子性 / 失败停顿

- 只写目标 overview 第三列；**不写** `DISTILL-LOG`
- `--dry-run` 不写 overview
- 槽位空/未 pull → 停，不写
- 当前单元未收敛前，不得自动推进到下一源或另一边

## 典型语义问题（烤干）

- 边选择（system vs company）、全量覆盖口径、冲突处理
- 已覆盖行与 `[U]` 整段重摘要口径
- 首次建 overview；误把非槽位源当 distill（应 extract）
