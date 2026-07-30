# sdx-analysis 工作流

主干：[SKILL.md](../SKILL.md)。推进 binding：[gates.md](gates.md)。

## 目标

通过**参数向导 + 分段「澄清 → 生成 → 烤干」**，逐步形成可评审的 `ANALYSIS-{IDEA-ID}.md`（六章）。  
单段收敛；不先攒整篇再集中收口。

契约分工：

- 写前意图澄清：[intent-clarify.md](../../../references/intent-clarify.md)
- 段落推进环 / `C·M·G·F` / 重开 / 前文回改：[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)（**无 `S`**）
- 写后烤干：[grilling-skill.md](../../../references/grilling-skill.md)
- 技术决策落 ADR / CONTEXT：[sdx-adr-protocol.md](../../../references/sdx-adr-protocol.md)

**公司库**（`KNOWLEDGE_TYPE=company`）：上游为 `company/solutions/SOLUTION-*.md`；分析须明确跨系统功能归属、协作依赖与残余风险；交付物落在 `company/analysis/`，下游 `company/requirements/` 再承接 PRD/ASD/DSD/TDD。

---

## 参数向导

### 模式

1. **逐项模式**：一次只确认一个参数。
2. **快捷组合模式**：先选预设，再按需改单项。

### 最小可写条件

- 上游 `SOLUTION-{IDEA-ID}.md` 已明确，或已有等价共识材料
- `IDEA-ID` 已给出或可按规则生成
- `{DOC_DIR}/analysis/` 可写
- 至少能确定本轮起始章节，或默认从 `§1` 开始

### 推荐参数顺序

1. `IDEA-ID`
2. 标题 / 主题
3. `depth`：`quick | standard | deep`
4. 本轮起始章节 / 范围
5. 表达粒度与语言风格

### 快捷组合

- `标准全篇`：`depth=standard`，从 `§1` 开始，默认完整六章
- `快速补段`：`depth=quick`，只处理用户指定章节
- `深度评审`：`depth=deep`，强化 `FR/MVP/依赖/风险` 的分析力度

参数未收口时留在向导，不进入 Section Cycle。

---

## 终稿骨架初始化

参数达标后立即创建：

- `{DOC_DIR}/analysis/ANALYSIS-{IDEA-ID}.md`

初始化：文档标题、六章标题与必要表头、文首 frontmatter 占位、未写章节占位说明。  
骨架创建**不**替代各章写入前的意图澄清。

---

## 产物路径

| 项 | 路径 |
| --- | --- |
| 终稿 | `{DOC_DIR}/analysis/ANALYSIS-{IDEA-ID}.md` |
| 公司库终稿 | `company/analysis/ANALYSIS-{IDEA-ID}.md` |
| 技术决策 | `{DOC_DIR}/adr/ADR-*.md` + `CONTEXT.md`（见 [sdx-adr-protocol.md](../../../references/sdx-adr-protocol.md)） |
| 结构校验 | `../scripts/validate-analysis.sh` |

---

## 写后默认表

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 各章节 / 单个 `FR` | **必须** | 未确认决策写入；跨段依赖 / 前文前提变更；MVP·优先级·范围口径变更 |

启发式只可升级为必须，不可降级跳过。

---

## Section Cycle（指针）

选定当前段后，严格按 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) + [intent-clarify.md](../../../references/intent-clarify.md) 执行。

本技能附加：

- `§2`：**`### 概览` 为独立当前段**（须写后 `C` 后才可写各 `### FR-xxx`）；之后可细化到单个 `FR`
- 概览生成：主料 = 上游 SOLUTION §6.1「覆盖范围」；§2.1 场景 / §2.3 In Scope 只补漏；粒度 = 可独立验收的用户可感知能力 → 1 FR
- 概览表列：`需求编号 | 需求名称 | 需求概要 | 优先级 | 所属 MVP | 关联目标`；所属 MVP = `MVP-n（{里程碑名}）`（与里程碑 1:1）
- 优先级按成功标准 / In Scope 关键性推导（与里程碑序解耦）；概览确认时可改
- 概览段选 `F`：只批确认并生成概览本身，**不得**跳过概览写后 `C` 去写后续 FR
- FR 段可同步改对应概览行；**§2 整章收口**须强制对齐概览与 FR 正文
- §4：继承上游里程碑骨架 + 挂 FR / 依赖；不另造阶段与验收口径
- 当前段存在 `>=2` 条真实分析路径时，先段内比选再收敛
- **技术/架构**选型按 [sdx-adr-protocol.md](../../../references/sdx-adr-protocol.md)：实现向可新建 ADR；改边界/集成硬停回 SOLUTION；引用落 §6.2
- 烤干收敛后、选 **C** 前：本段新技术决策须已落盘且占位已清
- 动作字母仅 `C/M/G/F`（无 `S`）
- grilling fallback 见 [grilling-skill.md](../../../references/grilling-skill.md)

---

## 整体验证与质量基线

至少检查：章节完整性、术语一致、编号连续（`G-n` / `FR-n` / `BR-n` / `R-n` / `MVP-n`）、跨段无未解释矛盾、frontmatter 完整、需求分析可读且不混入实现级细节。

终检对齐 [quality-checklist.md](quality-checklist.md)；收口前跑 `validate-analysis.sh`。
