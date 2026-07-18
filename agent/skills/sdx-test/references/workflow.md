# sdx-test 工作流

主干：[SKILL.md](../SKILL.md)。推进 binding：[gates.md](gates.md)。

## 目标

通过**参数向导 + 分段「澄清 → 生成 → 烤干」**，逐步形成可评审的 `TDD-{IDEA-ID}-{N}.md`（六章）。  
单段收敛；不先攒整篇再集中收口。不产出自动化代码与执行报告。

契约分工：

- 写前意图澄清：[intent-clarify.md](../../../references/intent-clarify.md)
- 段落推进环 / `C·M·G·F` / 重开 / 前文回改：[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)（**无 `S`**）
- 写后烤干：[grilling-skill.md](../../../references/grilling-skill.md)

---

## 参数向导

### 模式

1. **逐项模式**：一次只确认一个参数。
2. **快捷组合模式**：先选预设，再按需改单项。

### 最小可写条件

- 上游 `PRD-{IDEA-ID}-{N}.md` 已明确
- `IDEA-ID` 与 `N` 已给出或可按规则生成
- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 可写
- 至少能确定本轮起始章节，或默认从 `§1` 开始
- 若缺 `DSD`，需显式声明范围收窄或技术基线盲区

### 推荐参数顺序

1. `IDEA-ID`
2. `N` / `MVP-Phase-{N}`
3. 上游输入：`PRD`、`DSD`、`ASD`
4. 标题 / 主题
5. `depth`：`quick | standard | deep`
6. 本轮起始章节 / 范围
7. 是否优先展开 `功能 / 接口 / 业务规则 / 异常 / 性能 / 回归`

### 快捷组合

- `标准全篇`：`depth=standard`，从 `§1` 开始，默认完整六章
- `用例补段`：`depth=quick`，只处理单个用例组、接口异常组或回归范围块
- `回归收口`：`depth=quick`，只处理 `§1.2` 影响面、`§2.6` 和 `§5`
- `深度测试`：`depth=deep`，强化并发、性能、安全和异常覆盖

参数未收口时留在向导，不进入 Section Cycle。

---

## 终稿骨架初始化

参数达标后立即创建：

- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md`

初始化：文档标题、六章标题与必要表头、文首 frontmatter 占位、未写章节占位说明。  
骨架创建**不**替代各章写入前的意图澄清。

---

## 产物路径

| 项 | 路径 |
| --- | --- |
| 终稿 | `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md` |
| 结构校验 | `../scripts/validate-test.sh` |

---

## 写后默认表

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 各章节 / 用例组 / 异常组 / 回归块 / 进出标准 / 数据环境块 | **必须** | 未确认决策写入；测试范围·回归边界·进出标准变更；上游追溯变更 |

启发式只可升级为必须，不可降级跳过。

---

## Section Cycle（指针）

选定当前段后，严格按 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) + [intent-clarify.md](../../../references/intent-clarify.md) 执行。

本技能附加：

- 可细化到单个用例组 / 异常组 / 业务规则组 / 数据·环境·进出标准·回归块
- 当前段存在 `>=2` 条真实测试策略路径时，先段内比选再收敛
- 动作字母仅 `C/M/G/F`（无 `S`）
- grilling fallback 见 [grilling-skill.md](../../../references/grilling-skill.md)

---

## 整体验证与质量基线

至少检查：章节完整性、术语一致、编号连续（`TC-*` / `TC-API-*` / `TC-BR-*` / `TC-EX-*` / `TC-REG-*`）、跨段无未解释矛盾、frontmatter 完整、TDD 保持测试设计正文（不混入自动化代码与执行报告）。

终检对齐 [quality-checklist.md](quality-checklist.md)；收口前跑 `validate-test.sh`。
