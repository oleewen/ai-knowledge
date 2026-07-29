# 轻流程用户动作（Agent SSOT）

> **定位**：未绑定意图澄清 / 单元推进环的 docs 技能共用动作字母。  
> **适用**：`docs-change` / `docs-pull` / `docs-push` / `docs-tag`（及同类参数确认型技能）。  
> **不适用**：语义族（见 [unit-cycle-protocol.md](unit-cycle-protocol.md) 的 `C/M/G/S/F`）；`docs-okf` 无当前单元循环、不强制本字母表（自有 workflow 推进）。  
> **受众**：写后 **A/B** 见 [audience-and-language.md](audience-and-language.md)（轻流程默认读者表；okf 在结果摘要出口）。

**最后更新**: 2026-07-29

---

## 动作字母：`C/M/S/F`

| 动作 | 含义 |
| --- | --- |
| **C** | 确认当前单元（或当前参数集），授权执行 / 推进 |
| **M** | 修改参数或范围后重跑本单元 |
| **S** | 跳过当前单元（或后续 phase），不写入 |
| **F** | 在已确认前提下补齐剩余同类单元 |

**无 `G`**。需要加深分析时：改参数后 `M` 重跑，或用户口述再执行下一 phase——不占用字母。

---

## 会话模板（推荐）

```text
即将执行 /<skill>，当前参数如下：
- <关键参数行...>
- 当前单元: <路径或槽位>

C 确认当前单元 / M 修改参数 / S 跳过当前单元 / F 补齐剩余单元
```

各 skill 只替换参数行与「单元」名词（输出目录 / 槽位 / overview / 目标组等），不另造字母。

---

## 写后完成条件（受众 A/B）

宣称当前单元完成前至少：

1. 已执行本技能写入或脚本步骤（或用户确认的 dry-run）
2. 已按 [audience-and-language.md](audience-and-language.md) 跑 **A/B**（对照轻流程默认读者表）
3. A/B 已通过，或违例已按该契约分流处理完毕  
   - 全过静默；违例才报短表  
   - `docs-okf`：在结果摘要交用户前检 A/B；纯机器校验输出可跳过

未过 A/B → 不得宣称单元完成。不新增动作字母。

---

## 与语义族边界

| | 轻流程（本文） | 语义族 |
| --- | --- | --- |
| 写前 | 参数确认 / 风险校核 | [intent-clarify.md](intent-clarify.md) |
| 写后 | 轻量校核或脚本结果摘要 + **A/B** | [unit-cycle-protocol.md](unit-cycle-protocol.md) + grilling（含 **A/B/C/E**） |
| 动作 | `C/M/S/F` | `C/M/G/F`（docs 另有 `S`） |
