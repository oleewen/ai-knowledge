# sdx-design 工作流

主干：[SKILL.md](../SKILL.md)。推进协议：[gates.md](gates.md)。

## 目标

通过**参数向导 + 分段「澄清 → 生成 → 烤干」**，逐步形成可评审的 `DSD-{IDEA-ID}-{N}.md`（`§1-§3`）。
本技能默认采用**单段收敛**的工作方式，而不是先准备整份前置草稿、再一次性集中收口。

契约分工：

- 写前**意图澄清**：[intent-clarify.md](../../../references/intent-clarify.md)
- 写后**烤干** `grilling`：[grilling-skill.md](../../../references/grilling-skill.md)

本文只定义二者在 `sdx-design` Section Cycle 中的绑定。

**公司库**（`KNOWLEDGE_TYPE=company`）：
上游为 `company/requirements/` 下已共识 PRD/ASD；
详设须明确跨系统接口契约、协作依赖与实现归属；
交付物落在 `company/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/`；
`system/company` 层原则上由应用库承接 DSD，见 [knowledge-type-modes.md](knowledge-type-modes.md)。

---

## 总流程

```mermaid
flowchart TD
    A["开始 /sdx-design"] --> B{"参数向导模式"}
    B -->|逐项模式| C["一次确认一个参数"]
    B -->|快捷组合模式| D["选择参数组合预设"]
    D --> E["局部改写参数"]
    C --> F["参数集收口"]
    E --> F

    F --> G["创建 DSD-*.md 终稿骨架"]
    G --> H["选择当前段落 / API / DDL / LOGIC / 错误码组 / 时序块"]
    H --> IC["意图澄清（六项清单）"]
    IC -->|写前 C| I["按模板生成当前段到终稿"]
    I --> J["烤干：自动 grilling 直到收敛"]

    J --> K{"是否遇到语义性问题或前文回改"}
    K -->|否| L["进入用户动作选择"]
    K -->|是| M["停下并等待用户确认"]
    M --> N["确认后修订当前段或前文"]
    N --> J

    L --> O{"用户动作"}
    O -->|C| P{"是否还有下一段"}
    O -->|M| Q["按用户要求修改当前段"]
    O -->|G| R["追加一轮深挖 grilling"]
    O -->|F| S["批确认剩余段意图表后批量补齐"]
    Q --> J
    R --> J

    P -->|有| H
    P -->|无| T["整体验证"]
    S --> T
    T --> U["完成"]
```

---

## 阶段一：参数向导

### 模式

1. **逐项模式**：一次只确认一个参数。
2. **快捷组合模式**：先选预设参数组合，再按需改单项。

### 最小可写条件

满足以下条件即可创建终稿骨架：

- 上游 `PRD-{IDEA-ID}-{N}.md` 已明确
- 至少具备 `ASD-{IDEA-ID}-{N}.md` 或 `spec-asd-{IDEA-ID}-{N}-{app-name}.md` 其一，若缺失需显式标注基线盲区或先回 `sdx-architect`
- `IDEA-ID` 与 `N` 已给出或可按规则生成
- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 可写
- 至少能确定本轮起始章节，或默认从 `§1` 开始

### 推荐参数顺序

1. `IDEA-ID`
2. `N` / `MVP-Phase-{N}`
3. 上游输入：`ASD`、`spec-asd`、`PRD`
4. 标题 / 主题
5. `depth`：`quick | standard | deep`
6. 本轮起始章节 / 范围
7. 是否优先展开 `API / DDL / LOGIC / 错误码 / 时序 / 非功能`

### 快捷组合

- `标准全篇`：`depth=standard`，从 `§1` 开始，默认完整 `§1-§3`
- `接口补段`：`depth=quick`，只处理单个 `API` 契约、错误码组或幂等策略
- `数据补段`：`depth=quick`，只处理单个 `TBL/DDL`、索引或事务策略
- `深度详设`：`depth=deep`，强化 `§2` 的契约完整度与追溯

用户选定组合后，仍可局部修改任一参数。
参数未收口时，继续留在参数向导逐项澄清，不引入额外协同机制名。

---

## 阶段二：终稿骨架初始化

参数达到最小可写条件后，立即创建：

- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/DSD-{IDEA-ID}-{N}.md`

初始化内容包括：

- 文档标题
- `§1-§3` 标题与必要表头
- 文首 frontmatter 元数据占位
- 当前未写章节保留占位说明

此阶段目标是建立**可持续增量写入**的终稿容器，而非等待整篇草稿成熟后再落盘。
骨架创建**不**替代各章写入前的意图澄清。

---

## 阶段三：Section Cycle（澄清 → 生成 → 烤干）

### 基本单位

一次只处理一个章节或子章节。
默认顺序按模板推进，也可由用户指定跳转到任意段。
在 `§2` 中可进一步细化到单个 `API` 契约块、单个 `LOGIC`、单个 `TBL/DDL`、单个错误码组、单个幂等/事务/时序/安全策略块作为当前段。

### 写后默认表

`sdx-design`：**各 § 默认必须烤干**（含 `§2` 内单个 API/DDL/LOGIC/错误码/时序块；启发式只可升级、不可降级跳过）。

### 固定循环

1. 选定当前段
2. **意图澄清**：输出公共六项清单，标明「当前阶段：意图澄清」；有缺口则一问一答；用户写前 `C` 后方可写入
3. 按模板生成当前段，直接写入终稿对应位置
4. 若当前段存在 `>=2` 条真实实现路径，先在当前段内完成方案比选
5. **烤干**：对当前段执行自动 `grilling`，直到收敛；标明「当前阶段：烤干」
6. 若打出语义性问题或前文回改，暂停等待用户确认
7. 当前段收敛后，用户用 `C/M/G/F` 做写后动作选择
8. 收口后再进入下一段，或在用户选 `F` 后先批确认剩余意图再批量补齐

### 约束

- 未完成写前意图澄清（无写前 `C`），不得写入当前段正文
- `grilling` 默认只拷当前段，不跨多段发散
- 若环境未安装 `grilling` Skill，则按 [grilling-skill.md](../../../references/grilling-skill.md) 的 fallback 协议执行
- 进入 `grilling` 阶段，默认授权仅用于**非语义性修订**（不改变含义的错别字、编号、排版等）
- `grilling` 打出**语义性问题**时，必须先输出结论、推荐修订与数字选项并等待用户确认；未获确认不得修订当前段
- 自动 `grilling` 收敛前，不默认推进到下一段
- `G` 不是每轮必选动作，只在自动收敛后由用户手动追加深挖
- 若本段依赖前文结论，则前文变更会触发本段重开（重开后须再意图澄清）

---

## 前文回改规则

若当前段 `grilling` 打出的问题仅影响当前段，则只修当前段。
若问题涉及接口语义变化、数据模型调整、事务边界变化、错误码口径冲突、上游追溯变化等，则允许回改前面段落。

### 回改后的强制动作

一旦前文被改，当前段必须：

1. 重新读取受影响前提
2. 状态 `reopened`，回到**意图澄清**
3. 写前 `C` 后重写或修订当前段
4. 重新进入自动 `grilling`
5. 再进入用户确认或批量补齐

也就是说，**前文回改不会直接视为当前段已通过**。

### 回改授权边界

- `grilling` 可直接识别“需要回改前文”，但不得把前文回改视为当前段默认授权的一部分
- 涉及前文时，先输出受影响前提、推荐方案与数字选项，再等待用户选择
- 只有用户明确选择后，才执行前文回改
- 前文一旦被改，当前段立即 `reopened`，并按本流程重新澄清与烤干

---

## 段落状态

```mermaid
stateDiagram-v2
    [*] --> selected: 选定当前段
    selected --> clarifying: 意图澄清
    clarifying --> intent_confirmed: 写前 C
    intent_confirmed --> draft: 生成当前段到终稿
    draft --> grilling: 进入烤干
    grilling --> revised: 自动修订当前段
    revised --> grilling: 继续自动收口
    grilling --> reopened: 前文被回改
    reopened --> clarifying: 基于新前提再澄清
    grilling --> grilled: 当前段已收敛
    grilled --> confirmed: 写后 C 确认当前段
    grilled --> revised: M 修改当前段
    grilled --> grilling: G 继续深挖当前段
    grilled --> batch_intent: F 批确认剩余意图
    confirmed --> [*]
```

状态含义：

- `clarifying`：写前意图澄清中，尚未写入
- `intent_confirmed`：写前 `C` 已过，即将/正在生成
- `draft`：当前段已写入终稿，但仍是初稿
- `grilling`：当前段处于烤干中
- `revised`：当前段刚被自动或人工修改，待继续收口
- `reopened`：因前文改动，当前段重新打开
- `grilled`：当前段已烤干收敛，可等待写后用户动作
- `confirmed`：用户写后确认通过

---

## 阶段四：批量补齐与整体验证

当全部目标段落已完成，或用户选择 `F` 进入全部生成时，进入收尾阶段。

### `F` 的执行方式

- 保留已确认或已收敛的前文
- **先**汇总剩余未完成章节/块的意图表（公共六项摘要），用户一次写前语境 `C` 确认
- 确认后再从当前段之后连续生成剩余章节（段间不再单独停意图澄清）
- 每个剩余章节写入后都要自动 `grilling` 到收敛
- 中途若遇到语义性问题或前文回改，立即停下等待用户确认；回改后受影响段须再澄清

### 验证目标

- 章节完整性
- 术语一致性
- 编号连续性（`DD-n`、`API-n`、`LOGIC-n`、`TBL-n`）
- 跨段无未解释矛盾
- 文首 frontmatter 完整
- 实现级设计集中在 `DSD §2`，不产生第二正文源

### 质量基线

终检对齐 [quality-checklist.md](quality-checklist.md)。
