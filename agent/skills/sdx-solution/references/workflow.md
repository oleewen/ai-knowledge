# sdx-solution 工作流

主干：[SKILL.md](../SKILL.md)。推进 binding：[gates.md](gates.md)。

## 目标

通过**参数向导 + 分段「澄清 → 生成 → 烤干」**，逐步形成可评审的 `SOLUTION-{IDEA-ID}.md`（七章）。  
单段收敛；不先攒整篇再集中收口。

契约分工：

- 写前意图澄清：[intent-clarify.md](../../../references/intent-clarify.md)
- 段落推进环 / `C·M·G·F` / 重开 / 前文回改：[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)（**无 `S`**）
- 写后烤干：[grilling-skill.md](../../../references/grilling-skill.md)
- 技术决策落 ADR / CONTEXT：[sdx-adr-protocol.md](../../../references/sdx-adr-protocol.md)

**公司库**（`KNOWLEDGE_TYPE=company`）：输入含 [`company/knowledge/`](../../../../company/knowledge/README.md) 五视角；方案须明确跨系统需求下**各系统负责的功能边界**；交付物落在 `company/solutions/`，下游 `company/analysis/` 衔接各 `system/` 侧 requirements。

---

## 参数向导

### 模式

1. **逐项模式**：一次只确认一个参数。
2. **快捷组合模式**：先选预设，再按需改单项。

### 最小可写条件

- 主题已明确，或可从材料中归纳出标题
- `IDEA-ID` 已给出或可按规则生成
- `{DOC_DIR}/solutions/` 可写
- 至少能确定本轮起始章节或默认从 `§1` 开始

### 推荐参数顺序

1. `IDEA-ID`
2. 标题 / 主题
3. `depth`：`quick | standard | deep`
4. 本轮起始章节 / 范围
5. 表达粒度与语言风格

### 快捷组合

- `标准全篇`：`depth=standard`，从 `§1` 开始，默认完整七章
- `快速补段`：`depth=quick`，只处理用户指定章节
- `深度评审`：`depth=deep`，强化影响、冲突、风险与里程碑

参数未收口时留在向导，不进入 Section Cycle。

---

## 终稿骨架初始化

参数达标后立即创建：

- `{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md`

初始化：文档标题、七章标题与必要表头、文首 frontmatter 占位、未写章节占位说明。  
骨架创建**不**替代各章写入前的意图澄清。

---

## 产物路径

| 项 | 路径 |
| --- | --- |
| 终稿 | `{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md` |
| 公司库终稿 | `company/solutions/SOLUTION-{IDEA-ID}.md` |
| 技术决策 | `{DOC_DIR}/adr/ADR-*.md` + `CONTEXT.md`（见 [sdx-adr-protocol.md](../../../references/sdx-adr-protocol.md)） |
| 结构校验 | `../scripts/validate-solution.sh`（见 [SKILL.md](../SKILL.md)） |

---

## 写后默认表

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 各章节 | **必须** | 未确认决策写入；跨段依赖 / 前文前提变更；范围·目标·承诺口径变更 |

启发式只可升级为必须，不可降级跳过。

---

## Section Cycle（指针）

选定当前段后，严格按 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) + [intent-clarify.md](../../../references/intent-clarify.md) 执行：`澄清 → 生成 → 烤干 → 用户动作`。

本技能附加：

- 当前段存在 `>=2` 条真实业务路径时，先在段内完成方案比选再收敛
- **业务**多方案取舍写入 §5.2 Q-n；**技术/架构**选型按 [sdx-adr-protocol.md](../../../references/sdx-adr-protocol.md) 落 ADR + CONTEXT，不入 Q-n；表后须链 CONTEXT
- 烤干收敛后、选 **C** 前：本段新技术决策须已落盘且占位已清（可先写 `ADR-待定`，推进前清除）
- `grilling` 默认只烤当前段；fallback 见 [grilling-skill.md](../../../references/grilling-skill.md)
- 动作字母仅 `C/M/G/F`（无 `S`）

---

## 整体验证与质量基线

`F` 或全部段完成后，至少检查：章节完整性、术语一致、编号连续（`G-n` / `C-n` / `R-n` / `Q-n`）、跨段无未解释矛盾、frontmatter 完整、正文业务可读且不混入实现级细节。§6.1 为阶段骨架（覆盖范围可落到能力）；`MVP-n` 编号与 FR 拆解归 ANALYSIS（1:1 映射，不另起阶段）。

终检对齐 [quality-checklist.md](quality-checklist.md)；收口前跑 `validate-solution.sh`。
