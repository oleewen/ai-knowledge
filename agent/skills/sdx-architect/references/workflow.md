# sdx-architect 工作流

主干：[SKILL.md](../SKILL.md)。推进 binding：[gates.md](gates.md)。

## 目标

通过**参数向导 + 分段「澄清 → 生成 → 烤干」**，逐步形成可评审的 `ASD-{IDEA-ID}-{N}.md`（`§1-§3`）。  
单段收敛；不先攒整篇再集中收口。

契约分工：

- 写前意图澄清：[intent-clarify.md](../../../references/intent-clarify.md)
- 段落推进环 / `C·M·G·F` / 重开 / 前文回改：[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)（**无 `S`**）
- 写后烤干：[grilling-skill.md](../../../references/grilling-skill.md)

**公司库 / 系统库**（`KNOWLEDGE_TYPE=system|company`）：输出联邦概要架构，重点是能力归属、服务边界、变更方向与规约摘要；应用级实现级详设留给应用库 `/sdx-design`。粒度见 [knowledge-type-modes.md](knowledge-type-modes.md)。

---

## 参数向导

### 模式

1. **逐项模式**：一次只确认一个参数。
2. **快捷组合模式**：先选预设，再按需改单项。

### 最小可写条件

- 上游 `PRD-{IDEA-ID}-{N}.md` 已明确，或已有等价需求基线
- `IDEA-ID` 与 `N` 已给出或可按规则生成
- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 可写
- 至少能确定本轮起始章节，或默认从 `§1` 开始
- `KNOWLEDGE_TYPE` 若已给出，则按对应模式约束输出粒度

### 推荐参数顺序

1. `IDEA-ID`
2. `N` / `MVP-Phase-{N}`
3. `KNOWLEDGE_TYPE`
4. 标题 / 主题
5. `depth`：`quick | standard | deep`
6. 本轮起始章节 / 范围
7. 是否需要联邦概要或 `spec-asd-*` 指针

### 快捷组合

- `标准全篇`：`depth=standard`，从 `§1` 开始，默认完整 `§1-§3`
- `快速补段`：`depth=quick`，只处理用户指定章节、`DD`、服务变更项或规约摘要行
- `联邦概要`：`KNOWLEDGE_TYPE=system|company`，聚焦服务边界、能力归属、下游承接
- `深度规约`：`depth=deep`，强化 `§2` 服务交互与 `§3` 规约摘要的完整度

参数未收口时留在向导，不进入 Section Cycle。

---

## 终稿骨架初始化

参数达标后立即创建：

- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ASD-{IDEA-ID}-{N}.md`

初始化：文档标题、`§1-§3` 标题与必要表头、文首 frontmatter 占位、未写章节占位说明。  
骨架创建**不**替代各章写入前的意图澄清。

---

## 产物路径

| 项 | 路径 |
| --- | --- |
| 终稿 | `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ASD-{IDEA-ID}-{N}.md` |
| 结构校验 | `../scripts/validate-asd.sh` |

---

## 写后默认表

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 各 § / `DD` / 变更项 / 规约行 | **必须** | 未确认决策写入；边界·服务归属·联邦模式变更；规约口径变更 |

启发式只可升级为必须，不可降级跳过。

---

## Section Cycle（指针）

选定当前段后，严格按 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) + [intent-clarify.md](../../../references/intent-clarify.md) 执行。

本技能附加：

- `§1.3 / §2 / §3` 可细化到单个 `DD`、服务变更项、交互链路、规约摘要行
- 当前段存在 `>=2` 条真实架构路径时，先段内比选再收敛
- 动作字母仅 `C/M/G/F`（无 `S`）
- grilling fallback 见 [grilling-skill.md](../../../references/grilling-skill.md)

---

## 整体验证与质量基线

至少检查：章节完整性、术语一致、编号连续（`DD-n`、服务变更项、规约摘要行）、跨段无未解释矛盾、frontmatter 完整、架构摘要可读且不混入实现级 API/DDL 细节。

终检对齐 [quality-checklist.md](quality-checklist.md)；收口前跑 `validate-asd.sh`。
