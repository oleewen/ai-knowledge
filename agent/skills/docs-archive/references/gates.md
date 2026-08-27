# docs-archive 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

## 定位

本文件只做 `docs-archive` 对共享契约的 **binding**，不复制协议正文。

契约：

- [intent-clarify.md](../../../references/intent-clarify.md) — 写前意图澄清（经**确认书**承载，避免两套停顿）
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) — 单元推进、`C/M/G/S/F`、重开与前文回改
- [grilling-skill.md](../../../references/grilling-skill.md) — 写后烤干能力

主线口令：`澄清 → 落盘 → 烤干`。用户动作与状态机见 unit-cycle-protocol（含 docs 语义族 `S`）。

操作层易错：[gotchas.md](../gotchas.md)。路径与链接：[links-and-index.md](links-and-index.md)。

## 单元定义

**当前单元** = 单个目标章节落盘 + 对应 overview 行回写（先目标章节，再 overview）。

**确认书 = 写前意图澄清门禁**：批次确认书收口后，各单元落盘前不再重复六项全清单；仅摘取本单元目标与写入路径（映射表一行即可）。

## 技能追加澄清字段

确认书须并入公共六项，并含 archive 特有项：

- 来源清单、目标清单、映射
- 冲突策略、来源清理策略
- 方案候选与推荐（见 [archive-template.md](../assets/archive-template.md)）

## 写后默认

见 [workflow.md](workflow.md)「写后默认表」。本技能各当前单元默认必须烤干。

## 高风险场景

须先给结论、推荐与数字选项，确认后再执行：

- 来源与目标冲突，无法自动消解
- overview 行内链接缺失或断链
- 要求直接全量归档多个视角
- 要求直接删 overview 而不保留索引壳
- 目标章节体例与来源结构差异很大

## 原子性 / 失败停顿

- 必须先落目标章节，再回写 overview
- 目标章节落盘失败时，禁止回写 overview
- overview 回写后若断链或悬空半句，当前单元未收敛，须继续修复或暂存
- 当前单元未收敛前，不得自动推进下一章节或下一行块

## 典型语义问题（烤干）

- 来源范围 / 目标章节 / 冲突策略 / 来源清理策略变化
- 索引壳与否
- `[D]` 删除说明是否已在目标章落实
