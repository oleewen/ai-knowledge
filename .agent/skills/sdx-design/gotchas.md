# sdx-design 常见陷阱

反模式与设计原则见 [reference/design-principles.md](reference/design-principles.md)；本文件聚焦**操作层易错点**。

---

## 闸门与会话 spec

**未完成 Qclose-1 即写入 ADD**：须先在 `docs/superpowers/specs/` 维护 `...-sdx-design.md`，全部门禁收口后将 `<!-- sdx-design-gate: PENDING -->` 改为 `CONFIRMED`，且正文包含目标 `ADD-*.md` 文件名。跳过此步骤会导致钩子拦截或评审口径不一致。

---

## 前置输入

**无 PRD 直接开始技术设计**：PRD 是硬输入，不存在时终止并提示先执行 `sdx-prd`。缺少 PRD 会导致 DD-n / API-n 无法追溯到 US-n / FR-n，可追溯链从根部断裂。

**knowledge 目录缺失时不标注**：应在 §1 设计概述中显式标注「缺少知识库基线，以下架构设计仅基于 PRD 与 AGENTS.md」，避免凭印象假设现有架构。

---

## 架构设计（步骤 1）

**关键设计决策无备选方案**：每个 DD-n 必须包含决策点、决策结果、决策理由、备选方案四个字段。缺少备选方案，后续评审或需求变更时无法理解决策背景。

**忽略 MVP 边界直接设计全量功能**：严格聚焦 `--mvp` 指定的 MVP 范围；未包含的 FR-n 一律不纳入本次设计。

---

## 详细设计（步骤 2）

**API 设计缺少幂等性说明**：每个 API-n 必须包含幂等性字段，说明保障方案（分布式锁键、业务唯一键等）；无需幂等的接口须显式标注原因。

**API 设计缺少错误码定义**：每个 API-n 必须定义错误码列表，包含错误码、错误信息、触发条件、HTTP 状态码，区分 BusinessException / SystemException / ValidationException。

**数据表设计缺少 `gmt_create` / `gmt_modified`**：所有新增表必须包含这两个字段（`gmt_create` insert 时填充，`gmt_modified` insert/update 均填充）。

**数据表设计无索引策略**：索引设计必须结合实际查询场景分析，说明每个索引对应的查询模式；避免冗余索引。

**循环内调用 RPC 或数据库**：业务逻辑伪代码或流程图中禁止在 `for` 循环内调用 RPC 接口或执行数据库查询；批量操作须设计批量接口或批量查询。

**忽略非功能性设计**：§3.5 必须覆盖安全设计与可观测设计，不能留空或写「参考通用方案」。

---

## 规约生成（步骤 3）

**规约文件与 ADD 设计内容不一致**：规约文件必须从 ADD 对应章节直接提取，不得独立修改；ADD 变更时规约同步更新。

**规约文件缺少追溯标注**：每个规约文件头部必须标注 `source`（关联 ADD 章节）和 `requirement`（关联 PRD 需求）。

**规约目录结构不规范**：严格按 `specs/{service-name}/api/`、`domain/`、`data/`、`integration/` 四类目录组织，不平铺在 `specs/` 下。

---

## 文档输出（步骤 4）

**跳过或重排模板章节**：章节结构与 `add-template.md` 完全一致；无内容的章节保留标题并标注「不适用」或「待补充」，不删除。

**文末元数据缺少 `mvp_phase` 或误用文件头 frontmatter**：勿在文件开头写 YAML frontmatter；仅在文末「## 文档元数据」fenced `yaml` 中填写；须包含 `id`、`title`、`version`、`status`、`created`、`updated`、`parent`、`mvp_phase`。

**Mermaid 图表语法错误**：输出前验证 Mermaid 语法；时序图用 `sequenceDiagram`，状态机用 `stateDiagram-v2`，ER 图用 `erDiagram`，类图用 `classDiagram`，架构图用 `flowchart`。
