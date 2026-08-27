# docs-extract 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

## 定位

本文件只做 `docs-extract` 对共享契约的 **binding**，不复制协议正文。

契约：

- [intent-clarify.md](../../../references/intent-clarify.md) — 写前意图澄清
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) — 单元推进、`C/M/G/S/F`、重开与前文回改
- [grilling-skill.md](../../../references/grilling-skill.md) — 写后烤干能力

主线口令：`澄清 → 生成 → 烤干`。用户动作与状态机见 unit-cycle-protocol（含 docs 语义族 `S`）。

## 单元定义

**当前单元** = 单个 `--overview` + 单批命中段落与对应的 `A/U/D` 集合。

一次只处理一个 overview；含 `--dry-run` 预览结果。

## 技能追加澄清字段

在公共六项之外追加（不可删减公共项）：

- **`--sources` 口径**：路径列表或文本片段
- **`--overview` 目标**：单个 overview 相对路径
- **写入模式**：正式写入 / `--dry-run` 预览
- **关键词附录**：已读取 `## 文档关键词`

## 写后默认

见 [workflow.md](workflow.md)「写后默认表」。本技能各 overview 单元默认必须烤干（含 dry-run 预览）。

## 高风险场景

须先给结论、推荐与数字选项，确认后再执行：

- 首次实质写第三列
- 命中异常多，需收窄关键词或来源范围
- 来源包含敏感文件或敏感目录
- 第三列已有大量内容，且本轮 `[U]` 影响面很大
- 要求跳过预览直接写入

`--dry-run` 是推荐方案；**仍须写前意图澄清**。

## 原子性 / 失败停顿

- 4.1 无命中时，禁止进入写入
- 4.3 写入失败时，当前单元整体回滚，禁止部分落盘
- `--dry-run` 不写第三列
- 当前单元未收敛前，不得自动推进到下一个 overview 或下一批来源

## 典型语义问题（烤干）

- 来源范围、关键词口径、overview 目标
- `A/U/D` / delta / 已覆盖行处理
