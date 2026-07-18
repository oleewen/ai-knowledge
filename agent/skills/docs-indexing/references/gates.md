# docs-indexing 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

## 定位

本文件只做 `docs-indexing` 对共享契约的 **binding**，不复制协议正文。

契约：

- [intent-clarify.md](../../../references/intent-clarify.md) — 写前意图澄清
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) — 单元推进、`C/M/G/S/F`、重开与前文回改
- [grilling-skill.md](../../../references/grilling-skill.md) — 写后烤干能力

主线口令：`澄清 → 生成 → 烤干`。用户动作与状态机见 unit-cycle-protocol（含 docs 语义族 `S`）。

## 单元定义

**当前单元** = 单个索引输出组：

- 目标 `INDEX-GUIDE.md` + 对应 `changelogs/INDEXING-LOG.md`
- 例：根 `INDEX-GUIDE.md` + 根 `changelogs/INDEXING-LOG.md`；或 `{DOC_DIR}/INDEX-GUIDE.md` + `{DOC_DIR}/changelogs/INDEXING-LOG.md`

一次只处理一个输出组。

## 技能追加澄清字段

在公共六项之外可追加（不可删减公共项）：

- `mode` / `depth` / `since` 或基线策略摘要
- 本轮扫描范围或增量变更来源摘要

第 6 项「写入路径/容器」**必须**列出本轮将写入的**完整仓库根相对路径**（区分多域同名文件）：

- 目标 `INDEX-GUIDE.md`（如 `INDEX-GUIDE.md` 或 `application/INDEX-GUIDE.md`）
- 对应 `changelogs/INDEXING-LOG.md`（如 `application/changelogs/INDEXING-LOG.md`）

## 写后默认

见 [workflow.md](workflow.md)「写后默认表」。本技能各索引输出组默认必须烤干。

## 当前单元执行条件

参数向导收口后，进入单元推进前至少满足：

1. 仓库根可解析
2. `mode`、`depth` 已收口
3. `output` 已收口
4. 若为 incremental，`since` 或基线策略已收口
5. **输出根 `{DOC_DIR}`**：优先读目标工程 `.docsconfig` 的 `DOC_DIR=`；无配置或无效时默认为 `docs`（见 [session-spec-path.md](../../../references/session-spec-path.md)）
6. 意图澄清第 6 项已列出本轮双路径的完整仓库根相对路径

## 高风险场景

须先给结论、推荐与数字选项，确认后再执行：

- 请求 incremental 但无可用基线
- 同时涉及多个输出组且路径易混淆
- `output` 指向不常见位置
- depth 较深、扫描面明显扩大
- 要求跳过意图澄清或参数确认直接写索引
- 本轮将改导航路径或索引路径

## 原子性 / 失败停顿

- 当前单元写入失败时，不得继续写后续输出组
- 索引指南落盘失败时，禁止追加 `INDEXING-LOG`
- 当前单元未收敛前，不得自动推进下一输出组

## 典型语义问题（烤干）

- `mode` / `depth` / `output` / `since` / 基线策略变化
- 导航路径或索引路径变化
- 是否补写 `INDEXING-LOG`
- 扫描范围或增量策略变化
