# GRILL-LOG

> 仅未闭合烤干代办。契约见 [grilling-skill.md § GRILL-LOG](../agent/references/grilling-skill.md#grill-log)。勾销即删；无代办时保留本空壳。不替代 git 变更溯源 / `INDEXING-LOG`。
> **已烤条目内的表与路径 = 落地必遵**。未烤条目不得按本文件臆造切分。

审查口径（已用于公司 product/application，下条审查同用）：实体本层 SSOT / stub / 删；视角留或整删；按文件、按章、按节切「本层标准 vs 上收 vs 下移」；同名章合并时冲突停问；改 README / `*-meta` / INDEX / governance / layout。

## 开放代办

- [ ] **烤 + 落盘** 解决方案 `knowledge/` 五视角（未烤；依赖公司审查口径）
  - [ ] business：章重设已落盘。本条不重开章切分。BSD(L2) 与 BS 仍方案 SSOT
  - [ ] product：`PL/PL-EXAMPLE`、`PL/PD-EXAMPLE`、`BP/BP-EXAMPLE`、`BP/BSP-EXAMPLE`；章含已迁入的 `product-line`。度量与体验留在公司
  - [ ] application：`SLN-EXAMPLE`；章九份（含公司并入的 overview 与 architecture 三节）
  - [ ] data：章重设已落盘。本条不重开章切分。MDG 仍方案 SSOT，不在本条重开层
  - [ ] technical：`TSD-EXAMPLE`；章六份
  - [ ] 各 README / `*-meta` / overview 缓冲的「本层 SSOT」是否仍对

- [ ] **烤 + 落盘** 系统 `knowledge/` 五视角（未烤；上层实体应为 reference）
  - [ ] business：本层 SSOT BC/AGG/AB。`BSD-EXAMPLE` 已是公司 L1 reference；`BSD-EXAMPLE-SUB` 只在解决方案，系统不落文件。章仍未烤
  - [ ] product：本层 SSOT PM→FT→FR→UC/BR。`PD-EXAMPLE`、`BP-EXAMPLE` 只在解决方案，系统不落文件。章仍未烤
  - [ ] application：本层 SSOT SYS/APP/MS；九章是否与方案双源
  - [ ] data：本层 SSOT DS/ENT。`MDG-EXAMPLE` 只在解决方案，系统不落文件。章 overview、model、flow、storage、analytics 仍未烤
  - [ ] technical：`TSD-EXAMPLE` 只在解决方案，系统不落文件。六章是否与方案双源仍未烤

- [ ] **烤 + 落盘** 应用 `knowledge/` 五视角（未烤；本层 SSOT 仅 API/TBL/MW/CMP）
  - [ ] business：无本层实体；六章删或改实现映射
  - [ ] product：八章是否与系统/方案双源
  - [ ] application：`MS-EXAMPLE`、`API-EXAMPLE`；九章是否与系统双源
  - [ ] data：`DS-EXAMPLE`/`TBL-EXAMPLE`；四章是否与系统双源
  - [ ] technical：`MW-EXAMPLE`、`CMP-EXAMPLE`；六章是否与系统双源；根 `technical-debt.md`
