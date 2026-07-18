# sdx-design 工作流

主干：[SKILL.md](../SKILL.md)。推进 binding：[gates.md](gates.md)。

## 目标

通过**参数向导 + 分段「澄清 → 生成 → 烤干」**，逐步形成可评审的 `DSD-{IDEA-ID}-{N}.md`（`§1-§3`）。  
单段收敛；不先攒整篇再集中收口。

契约分工：

- 写前意图澄清：[intent-clarify.md](../../../references/intent-clarify.md)
- 段落推进环 / `C·M·G·F` / 重开 / 前文回改：[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)（**无 `S`**）
- 写后烤干：[grilling-skill.md](../../../references/grilling-skill.md)

**公司库**（`KNOWLEDGE_TYPE=company`）：上游为 `company/requirements/` 下已共识 PRD/ASD；详设须明确跨系统接口契约、协作依赖与实现归属；交付物落在 `company/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/`；`system/company` 层原则上由应用库承接 DSD，见 [knowledge-type-modes.md](knowledge-type-modes.md)。

---

## 参数向导

### 模式

1. **逐项模式**：一次只确认一个参数。
2. **快捷组合模式**：先选预设，再按需改单项。

### 最小可写条件

- 上游 `PRD-{IDEA-ID}-{N}.md` 已明确
- 至少具备 `ASD-{IDEA-ID}-{N}.md` 或 `spec-asd-{IDEA-ID}-{N}-{app-name}.md` 其一；若缺失需显式标注基线盲区或先回 `sdx-architect`
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

参数未收口时留在向导，不进入 Section Cycle。

---

## 终稿骨架初始化

参数达标后立即创建：

- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/DSD-{IDEA-ID}-{N}.md`

初始化：文档标题、`§1-§3` 标题与必要表头、文首 frontmatter 占位、未写章节占位说明。  
骨架创建**不**替代各章写入前的意图澄清。

---

## 产物路径

| 项 | 路径 |
| --- | --- |
| 终稿 | `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/DSD-{IDEA-ID}-{N}.md` |
| 结构校验 | `../scripts/validate-dsd.sh`（见 [schemas.md](schemas.md)） |

---

## 写后默认表

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 各 §；`§2` 内 API/DDL/LOGIC/错误码/时序块 | **必须** | 未确认决策写入；接口语义·数据模型·事务/幂等口径变更；上游追溯变更 |

启发式只可升级为必须，不可降级跳过。

---

## Section Cycle（指针）

选定当前段后，严格按 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) + [intent-clarify.md](../../../references/intent-clarify.md) 执行。

本技能附加：

- `§2` 可细化到单个 `API` / `LOGIC` / `TBL/DDL` / 错误码组 / 幂等·事务·时序·安全策略块
- 当前段存在 `>=2` 条真实实现路径时，先段内比选再收敛
- 动作字母仅 `C/M/G/F`（无 `S`）
- grilling fallback 见 [grilling-skill.md](../../../references/grilling-skill.md)

---

## 整体验证与质量基线

至少检查：章节完整性、术语一致、编号连续（`DD-n`、`API-n`、`LOGIC-n`、`TBL-n`）、跨段无未解释矛盾、frontmatter 完整、实现级设计集中在 `DSD §2`（不产生第二正文源）。

终检对齐 [quality-checklist.md](quality-checklist.md)；收口前跑 `validate-dsd.sh`。
