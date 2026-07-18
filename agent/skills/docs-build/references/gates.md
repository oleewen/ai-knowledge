# docs-build 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

## 定位

本文件只做 `docs-build` 对共享契约的 **binding**，不复制协议正文。

契约：

- [intent-clarify.md](../../../references/intent-clarify.md) — 写前意图澄清
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) — 单元推进、`C/M/G/S/F`、重开与前文回改
- [grilling-skill.md](../../../references/grilling-skill.md) — 写后烤干能力

主线口令：`澄清 → 生成 → 烤干`。用户动作与状态机见 unit-cycle-protocol（含 docs 语义族 `S`）。

## 单元定义

**当前单元**可以是：

- 单个视角批次（如 technical / data / business / product）
- 单个路径组
- 单批实体集合

一次只处理一个批次。写后完成前须 `validate-extraction.sh` 通过（或用户确认例外策略）。

## 技能追加澄清字段

在公共六项之外可追加：

- `--perspectives` / `--skip-existing` / `--confidence-threshold` / `--emit-report` 摘要
- 预计新增/变更实体 ID 列表摘要
- 校验策略或修复预案摘要

第 6 项「写入路径/容器」**必须**写明：

- 当前单元类型：视角批次 / 路径组 / 实体批次
- 本轮将写入的 `{DOC_DIR}/knowledge/` 下仓库根相对路径（如 `application/knowledge/technical/` 下 `{ID}.md`、`README.md`、`KNOWLEDGE_INDEX.md`）

## 写后默认

见 [workflow.md](workflow.md)「写后默认表」。本技能各视角/路径/实体批次默认必须烤干。

## 当前单元执行条件

参数向导收口后，进入单元推进前至少满足：

1. 主 Index Guide 可用
2. `{DOC_DIR}` 可解析
3. 当前视角范围或当前批次已明确
4. `--skip-existing`、`--confidence-threshold`、`--emit-report` 等策略已收口

## 高风险场景

须先给结论、推荐与数字选项，确认后再执行：

- 主 Index Guide 缺失
- `{DOC_DIR}` 或知识输出路径不明
- 视角范围过大或需跨多批次重建
- 校验失败且存在多种修复策略
- 要求跳过意图澄清或参数确认直接批量重建 knowledge
- 涉及实体 ID 变更、重命名或跨引用链更新

## 原子性 / 失败停顿

- 当前单元写入失败时，不得继续写后续批次
- 当前单元校验失败时，不得继续归并或生成 `KNOWLEDGE_INDEX`
- 当前单元未收敛前，不得自动推进下一视角或下一批实体

## 典型语义问题（烤干）

- 视角范围 / 输出路径 / 跳过策略 / 置信度策略变化
- 实体 ID 变更或重命名
- 是否生成 README / `KNOWLEDGE_INDEX`
