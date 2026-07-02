# sdx-design 易错点

原则与反模式见 [references/design-principles.md](references/design-principles.md)；本文件为**操作层**。

## 闸门与会话 spec

未完成 **Qclose-1** 勿写 **DSD**：先在 `{DOC_DIR}/superpowers/specs/` 维护 **`...-sdx-design.md`**，收口后 `PENDING`→`CONFIRMED`，正文含目标 **`DSD-*.md`** 全名。否则易触发钩子或评审口径不一致。

## 前置

- **无 PRD 开写**：缺 PRD 则停，提示先 `sdx-prd`；否则 DD/API 无法追溯 US/FR。  
- **knowledge 缺失未声明**：在 ASD 或 DSD「关联文档」写明基线盲区。

## 与 ASD

详设前应有 **ASD**（或用户明示例外并在对话留痕）。DD 主要在 ASD 收口时须与 DSD 内 API/TBL 一致。

## §2 详设

- 每 **API-n**：幂等策略（或注明无需幂等的原因）；错误码表（码、信息、条件、HTTP；区分业务/系统/校验异常）。  
- 新表须有 **`gmt_create` / `gmt_modified`**；索引须对应真实查询，避免冗余。  
- 伪代码/流程图：**禁止**在 `for` 内 RPC/DB；用批量接口或批量查。  
- **§2.5** 安全、可观测须实质填写，勿仅写「参考通用方案」。
- 与 **FR-n**、**ASD §3**（或 **spec-asd** 中需求条目）的对应关系**写在 §2**，避免双源。

## DSD-*.md 输出

- 章节与 **dsd-template**（§1–§3）一致；空节保留标题，标「不适用/待补充」。  
- **要求**在文件头用 YAML frontmatter；含 `mvp_phase` 等必填项。  
- Mermaid：输出前自检语法；`sequenceDiagram` / `stateDiagram-v2` / `erDiagram` / `classDiagram` / `flowchart` 择类而用。
