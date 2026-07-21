# 意图澄清契约（Agent SSOT）

> **定位**：跨 skill 复用的**写前意图澄清**唯一真源。  
> **分工**：推进环 / 用户动作 / 重开 / 前文回改见 [unit-cycle-protocol.md](unit-cycle-protocol.md)；写后提问能力见 [grilling-skill.md](grilling-skill.md)。  
> **主线口令**：`澄清 → 生成 → 烤干`。

**最后更新**: 2026-07-20

**落地状态**：全部 `/sdx-*` 与语义族 docs-*（`docs-agent` / `docs-extract` / `docs-distill` / `docs-archive` / `docs-upgrade` / `docs-simplify` / `docs-indexing` / `docs-build`）已绑定。**未绑定（轻流程）**：`docs-okf` / `docs-change` / `docs-pull` / `docs-push` / `docs-tag`。

---

## 与grilling / 推进环的边界

| 能力 | 时机 | 目的 | SSOT |
| --- | --- | --- | --- |
| **意图澄清**（本文） | 写入前 | 挡臆测、收口目标/范围/路径 | 本文 |
| **单元推进** | 生成后全程 | 烤干授权、动作字母、重开 | [unit-cycle-protocol.md](unit-cycle-protocol.md) |
| **grilling / 烤干** | 写入后 | 成品缺口、冲突、可评审性 | [grilling-skill.md](grilling-skill.md) |

禁止：把写前步骤称作「写前 grilling」；用 `G` 表示意图澄清（`G` 仅写后深挖，见推进协议）。

---

## 适用范围

与上文「落地状态」名单一致。未启用技能维持既有轻流程。

---

## 公共六项清单

写前必须输出（技能可追加字段，不可删减公共项）：

1. **本段/单元目标** — 本轮要写清什么  
2. **范围 / 非范围** — 写什么、明确不写什么  
3. **已知缺口** — 未知/冲突；无则写「无」  
4. **禁止臆测项** — 不得编造的事实、数字、路径、ID、承诺  
5. **写后烤干预判** — 按下文「写后触发」给出默认或强制升级说明  
6. **写入路径/容器** — 仓库根相对路径或终稿锚点  

输出时须标明：**当前阶段：意图澄清**。

---

## 收口到「可以写」

1. **无缺口**（第 3 项为「无」，且无未决冲突）：一屏列出六项（含推荐填空）→ 用户 `C` 后写入。  
2. **有缺口/冲突**：按 [grilling-skill.md](grilling-skill.md) fallback **一次一问**填缺口 → 再一屏确认 → 写前 `C` 后写入。  
3. 未获写前 `C`，**不得**写入当前段/单元正文。

`C` 在写前与写后同符异义，阶段横幅与动作细则见 [unit-cycle-protocol.md](unit-cycle-protocol.md)。

---

## 写后「烤干」触发（默认表 + 启发式升级）

1. 各 skill 在本地 **workflow** 维护**写后默认表**（是否默认 grilling）。  
2. 出现以下任一情况时，**强制升级为必须烤干**（不可降级跳过）：  
   - 未确认决策写入正文  
   - 跨段/跨单元依赖或前文前提变更  
   - 实体 ID、导航路径、索引路径变更  
   - 冲突消解、范围/目标/承诺口径变更  
3. 启发式只可升级为必须，不可把默认「必须」降为跳过。  
4. 烤干阶段输出须标明：**当前阶段：烤干（grilling）**。

语义族默认：各章节/当前单元**默认必须烤干**（analysis 含单个 `FR`；design 含 §2 内 API/DDL 等块；prd 含 US/UC/AC；indexing 含 INDEX-GUIDE+LOG 输出组；build 含视角/实体批次）。细则以各 skill workflow 默认表为准。

---

## 技能 Binding 要求

启用本契约的 skill 须在本地 `workflow.md` / `gates.md`：

1. 引用本文与 [unit-cycle-protocol.md](unit-cycle-protocol.md)，**不复制**二者全文  
2. 声明写后默认表（建议仅 `workflow.md`）  
3. Section/Unit Cycle 遵循 `澄清 → 生成 → 烤干`  
4. 只补技能特有字段、路径、高风险与原子性  
5. 更新 SKILL.md / evals 中推进协议断言（若有）

---

## 非目标

- 不取代参数向导（参数向导在首轮容器创建前；意图澄清在每段/单元写入前）  
- 不定义用户动作字母与状态机全文（见推进协议）  
- 不取代 [grilling-skill.md](grilling-skill.md)  
- 不规定具体业务模板章节内容  
