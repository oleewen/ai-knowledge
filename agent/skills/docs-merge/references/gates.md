# docs-merge 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。算法真源：[merge-spec.md](merge-spec.md)。

本文件只做 binding，不复制协议正文。

契约：

- [intent-clarify.md](../../../references/intent-clarify.md)
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) — `C/M/G/S/F`
- [grilling-skill.md](../../../references/grilling-skill.md) — 写后烤干；**生成中冲突亦 grilling 一问一答**

主线：`澄清 → 生成 → 烤干`。

## 单元定义

**当前单元** = 单个已存在 `<target>` + 本批 `<source>` 的一次合入计划（含 `--dry-run` 预览）。一次一个 target。

## 技能追加澄清字段

公共六项之外追加：

- `<source>` 口径（路径或内联；判定见 merge-spec §1）
- `<target>`（已存在单个 `.md`）
- 写入模式：正式 / `--dry-run`
- 落位策略摘要：已对齐 / 已确认新建；**写前 `C`（正式写入）前未落位须为空**
- **dry-run → 正式写入**：须**重新**写前 `C`，并证明未落位已空；禁止沿用 dry-run 次 C 直接落盘

## 写后默认

见 [workflow.md](workflow.md)「写后默认表」。

## 高风险场景

先结论 + 推荐 + 数字选项：

- 首次实质改 target；未落位需新建；合并/冲突面大
- 目标在 `*/knowledge/**`；跳过预览直接写
- source/target 歧义
- dry-run 后请求「按预览直接写」而未重新澄清

`--dry-run` 推荐；**仍须写前澄清**。

## 原子性 / 失败停顿

见 merge-spec §6。补充：当前单元未收敛，不得推进下一 target / 下一批 source；dry-run 授权 ≠ 正式写入授权。

## 典型语义问题（烤干）

- source/target 与落位；新增 vs 合并；冲突决议；knowledge 边界
