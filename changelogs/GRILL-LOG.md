# GRILL-LOG2

> 仅未闭合烤干代办。契约见 [grilling-skill.md § GRILL-LOG](../agent/references/grilling-skill.md#grill-log)。勾销即删；无代办时保留本空壳。不替代 git 变更溯源 / `INDEXING-LOG`。
> **已烤条目内的表与路径 = 落地必遵**。未烤条目不得按本文件臆造切分。

审查口径（已用于公司 product/application，下条审查同用）：实体本层 SSOT / stub / 删；视角留或整删；按文件、按章、按节切「本层标准 vs 上收 vs 下移」；同名章合并时冲突停问；改 README / `*-meta` / INDEX / governance / layout。

## 开放代办

- [ ] 未决：各视角 `agent/knowledge/*-meta.md` §2 字段是否补 okf-spec §4.1 已有、表中缺失的同层选含（只记账，不改 meta）
  - [ ] `agent/knowledge/product-meta.md` §2 PD：`implemented_by` 可选 → BSP
  - [ ] 同文件 §2 PL：`implemented_by` 可选 → PD
  - [ ] 同文件 §2 BP：`children` 可选 → BSP
  - [ ] `agent/knowledge/application-meta.md` §2 SYS：`maps_to` 可选 → PD
  - [ ] `agent/knowledge/data-meta.md` §2 DS：`implemented_by` 可选 → ENT；`implements_to` → MDG
  - [ ] `agent/knowledge/technical-meta.md` §2 MW：`implemented_by` 可选 → CMP
- [ ] 未决：跨视角表未写、okf-spec §4.1 已点名的同层或上层目标（只记账，不改 meta）
  - [ ] `agent/knowledge/business-meta.md` §3 CAP：`mapped_by` → BSD-L1（同视角）
  - [ ] 同文件 §3 BSD-L1：`maps_to` → CAP；`mapped_by` → BL（同视角）
  - [ ] `agent/knowledge/application-meta.md` §3 补 `APP.uses_to` → DS
  - [ ] 同文件 §3 补 `MS.uses_to` → ENT
  - [ ] `agent/knowledge/product-meta.md` §3 补 `PL.mapped_by` → SLN
  - [ ] `agent/knowledge/business-meta.md` §3 补 `BS.mapped_by` → PD
- [ ] 未决：`agent/knowledge/technical-meta.md` §3 与 okf-spec §4.1 对齐（只记账，不改 meta）
  - [ ] 删 `MS.uses_to` → CMP（spec 中 MS 选含无 CMP）
  - [ ] `MW.used_by` → APP 保留；说明去掉「对端 APP.uses_to」（APP 的 `uses_to` 目标是 DS）
- [ ] 未决：SLN↔BP 跨视角两端补进跨视角表（只记账，不改 meta）
  - [ ] `agent/knowledge/application-meta.md` §3 补 `SLN.implemented_by` → BP
  - [ ] `agent/knowledge/product-meta.md` §3 补 `BP.implements_to` → SLN
- [ ] 未决：同视角边移出跨视角表（只记账，不改 meta）
  - [ ] `agent/knowledge/product-meta.md` §3 删 `PD.implements_to` → PL（同为 product；product 字段表已有）
  - [ ] `agent/knowledge/data-meta.md` §3 删 `DS.implements_to` → MDG（同为 data；目标改由 data 字段代办承接）
- [ ] 删 「docs-meta.md」「knowledge-meta.md」的内容表达
