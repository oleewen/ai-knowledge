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

**当前单元** = 单个 `{APPNAME}-overview.md` + 单次增量范围或单次 `--full` 范围。

一次只处理一个应用；含 `--dry-run` 预览结果。

## 技能追加澄清字段

在公共六项之外追加（不可删减公共项）：

- **`--app`**：目标应用
- **时间范围**：自动锚点 / `--since` / `--full`
- **写入模式**：正式写入 / `--dry-run` 预览
- **overview 状态**：新建 / 更新

意图澄清须写明目标应用与 `--full` / `--since` / `--dry-run` 等关键参数摘要。

## 写后默认

见 [workflow.md](workflow.md)「写后默认表」。本技能各 overview 单元默认必须烤干（含 dry-run 预览）。

## 高风险场景

须先给结论、推荐与数字选项，确认后再执行：

- `--full`
- 锚点缺失或 `CHANGE-LOG` 无法定位增量起点
- 首次创建 `{APPNAME}-overview.md`
- 多应用但未指定 `--app`
- 应用侧与系统侧知识冲突，且规则无法自动消解
- 要求跳过预览直接写入

这些情形下，`--dry-run` 是推荐方案；**仍须写前意图澄清**。

## 原子性 / 失败停顿

- overview 第三列写入成功后，才能追加 `DISTILL-LOG`
- overview 写入失败时，禁止追加 `DISTILL-LOG`
- `--dry-run` 不写 overview，也不写 `DISTILL-LOG`
- 涉及 `system/changelogs/CHANGE-LOG.md` 与 `system/application-*/changelogs/ARCHIVE-LOG.md` 的追加与锚点更新，与当前蒸馏写入**同一原子事务**，适用同一交互与确认要求
- 当前单元未收敛前，不得自动推进到下一应用或下一批范围

## 典型语义问题（烤干）

- 应用范围、增量/全量策略、冲突处理口径
- 首次建 overview、是否补写 `DISTILL-LOG`
