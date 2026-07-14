<!-- markdownlint-disable-file MD040 MD060 -->
# sdx-prd 工作流

主干：[SKILL.md](../SKILL.md)。推进协议：[gates.md](gates.md)。

## 目标

通过**参数向导 + 分段直写终稿 + 自动 grilling 补强**的方式，逐步形成可评审的 `PRD-{IDEA-ID}-{N}.md`（十一章）。
本技能默认采用**单段收敛**的工作方式，而不是先准备整份前置草稿、再一次性集中收口。
`grilling` 的公共能力契约见
[grilling-skill.md](../../../references/grilling-skill.md)；
本文只定义其在 `sdx-prd` Section Cycle 中的绑定方式。

**公司库**（`KNOWLEDGE_TYPE=company`）：
上游为 `company/analysis/ANALYSIS-*.md`（含跨系统能力拆解）；
本技能在对应 `system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 写入 `PRD-*.md`，
由下游 `sdx-architect / sdx-design / sdx-test` 继续承接。

---

## 总流程

```mermaid
flowchart TD
    A["开始 /sdx-prd"] --> B{"参数向导模式"}
    B -->|逐项模式| C["一次确认一个参数"]
    B -->|快捷组合模式| D["选择参数组合预设"]
    D --> E["局部改写参数"]
    C --> F["参数集收口"]
    E --> F

    F --> G["创建 PRD-*.md 终稿骨架"]
    G --> H["选择当前段落 / 小节 / 单个 US 或 UC"]
    H --> I["按模板生成当前段到终稿"]
    I --> J["自动 grilling 直到当前段收敛"]

    J --> K{"是否遇到语义性问题或前文回改"}
    K -->|否| L["进入用户动作选择"]
    K -->|是| M["停下并等待用户确认"]
    M --> N["确认后修订当前段或前文"]
    N --> J

    L --> O{"用户动作"}
    O -->|C| P{"是否还有下一段"}
    O -->|M| Q["按用户要求修改当前段"]
    O -->|G| R["追加一轮深挖 grilling"]
    O -->|F| S["批量补齐剩余章节"]
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

- 上游 `ANALYSIS-{IDEA-ID}.md` 已明确，或已有等价分析材料
- `IDEA-ID` 与 `N` 已给出或可按规则生成
- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 可写
- 至少能确定本轮起始章节，或默认从 `§1` 开始

### 推荐参数顺序

1. `IDEA-ID`
2. `N` / `MVP-Phase-{N}`
3. 标题 / 主题
4. `depth`：`quick | standard | deep`
5. 本轮起始章节 / 范围
6. 表达粒度与语言风格

### 快捷组合

快捷组合用于减少重复确认，允许如下一次性输入：

- `标准全篇`：`depth=standard`，从 `§1` 开始，默认完整十一章
- `快速补段`：`depth=quick`，只处理用户指定章节、`US` 或 `UC`
- `深度验收`：`depth=deep`，强化 `流程/故事/验收/NFR` 的细化力度

用户选定组合后，仍可局部修改任一参数。
参数未收口时，继续留在参数向导逐项澄清，不引入额外协同机制名。

---

## 阶段二：终稿骨架初始化

参数达到最小可写条件后，立即创建：

- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`

初始化内容包括：

- 文档标题
- 十一章标题与必要表头
- 文首 frontmatter 元数据占位
- 当前未写章节可保留占位说明

此阶段目标是建立**可持续增量写入**的终稿容器，而非等待整篇草稿成熟后再落盘。

---

## 阶段三：Section Cycle

### 基本单位

一次只处理一个章节或子章节。
默认顺序按模板推进，也可由用户指定跳转到任意段。
在 `§4/§5/§10` 中可进一步细化到单个 `UC`、单个 `US`、单个 `AC/NAC` 作为当前段。

### 固定循环

1. 选定当前段
2. 按模板生成当前段
3. 直接写入终稿对应位置
4. 若当前段存在 `>=2` 条真实产品路径，先在当前段内完成方案比选
5. 对当前段执行自动 `grilling`，直到“烤干”
6. 若打出语义性问题或前文回改，暂停等待用户确认
7. 当前段收敛后，用户用 `C/M/G/F` 做动作选择
8. 收口后再进入下一段，或在用户选 `F` 后批量补齐余段

### 约束

- `grilling` 默认只拷当前段，不跨多段发散
- 若环境未安装 `grilling` Skill，
  则按 [grilling-skill.md](../../../references/grilling-skill.md) 的 fallback 协议执行
- 进入 `grilling` 阶段，默认授权仅用于**非语义性修订**（不改变含义的错别字、编号、排版等）
- `grilling` 打出**语义性问题**时，必须先输出结论、推荐修订与数字选项并等待用户确认；未获确认不得修订当前段
- 自动 `grilling` 收敛前，不默认推进到下一段
- `G` 不是每轮必选动作，只在自动收敛后由用户手动追加深挖
- 若本段依赖前文结论，则前文变更会触发本段重开

---

## 前文回改规则

若当前段 `grilling` 打出的问题仅影响当前段，则只修当前段。
若问题涉及前文设定错误、范围漂移、MVP 切分失真、角色定义冲突、流程主干变化、验收口径变化等，则允许回改前面段落。

### 回改后的强制动作

一旦前文被改，当前段必须：

1. 重新读取受影响前提
2. 回到当前段
3. 重新进入自动 `grilling`
4. 再进入用户确认或批量补齐

也就是说，**前文回改不会直接视为当前段已通过**。

### 回改授权边界

- `grilling` 可直接识别“需要回改前文”，但不得把前文回改视为当前段默认授权的一部分
- 涉及前文时，先输出受影响前提、推荐方案与数字选项，再等待用户选择
- 只有用户明确选择后，才执行前文回改
- 前文一旦被改，当前段立即 `reopened`，并按本流程重新 grill

---

## 段落状态

```mermaid
stateDiagram-v2
    [*] --> selected: 选定当前段
    selected --> draft: 生成当前段到终稿
    draft --> grilling: 进入自动 grilling
    grilling --> revised: 自动修订当前段
    revised --> grilling: 继续自动收口
    grilling --> reopened: 前文被回改
    reopened --> draft: 基于新前提重写当前段
    grilling --> grilled: 当前段已收敛
    grilled --> confirmed: C 确认当前段
    grilled --> revised: M 修改当前段
    grilled --> grilling: G 继续深挖当前段
    grilled --> [*]: F 进入批量补齐
    confirmed --> [*]
```

状态含义：

- `draft`：当前段已写入终稿，但仍是初稿
- `grilling`：当前段处于自动收口中
- `revised`：当前段刚被自动或人工修改，待继续收口
- `reopened`：因前文改动，当前段重新打开
- `grilled`：当前段已自动收敛，可等待用户动作
- `confirmed`：用户确认通过

---

## 阶段四：批量补齐与整体验证

当全部目标段落已完成，或用户选择 `F` 进入全部生成时，进入收尾阶段。

### `F` 的执行方式

- 保留已确认或已收敛的前文
- 从当前段之后开始批量生成剩余章节
- 每个剩余章节写入后都要自动 `grilling` 到收敛
- 中途若遇到语义性问题或前文回改，立即停下等待用户确认

### 验证目标

- 章节完整性
- 术语一致性
- 编号连续性（`FR-n` / `BR-n` / `UC-n` / `US-n` / `EX-n` / `AC-n` / `NAC-n`）
- 跨段无未解释矛盾
- 文首 frontmatter 完整
- 正文保持产品/业务可读，不混入实现级接口、DDL、选型细节

### 质量基线

终检对齐 [quality-checklist.md](quality-checklist.md)。
