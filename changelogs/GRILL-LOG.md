# GRILL-LOG

> 仅未闭合烤干代办。契约见 [grilling-skill.md § GRILL-LOG](../agent/references/grilling-skill.md#grill-log)。勾销即删；无代办时保留本空壳。不替代 git 变更溯源 / `INDEXING-LOG`。

---

## 烤干结论摘要（恢复三层 DESIGN 门面）

> 执行以本摘要、三层 `DESIGN.md` 与 [knowledge-governance.md](../agent/knowledge/knowledge-governance.md) 为准。

### 层设计入口与 SSOT

- **层根人类入口**：`company|system|application/DESIGN.md`（入口 + 本层契约短表 + 引用；同构五 H2）
- **语义设计 SSOT**：`agent/knowledge/knowledge-governance.md`（职责、首次定义、各层聚焦、5A、引用边界）
- **路径/槽位/流水线**：`agent/references/knowledge-layout.md`
- **元库模板**：本仓三层 `DESIGN.md` = install/upgrade 源；短表改模板再 upgrade
- **install**：种根级 `DESIGN.md`（整文件覆盖；central 子集亦种；源无则不造）
- **upgrade**：根级 `DESIGN.md` **整文件覆盖**特例（不走 H2 结构重填）；`CONTRIBUTING.md` 仍普通 md

### 实体与层级

| 域 | 约定 |
| --- | --- |
| BU / CAP / BD | 公司；CAP→BU；`maps_to_bd_id`；BD `maps_to_pl_id` |
| PL / SLN / TPL | 公司；SLN 无 `uses_mdg_ids` |
| PD / SYS / MDG | 系统；SYS `uses_mdg_ids` |
| API / TBL / MW / CMP | 应用 |

---

## 开放代办

- [ ] 三层 `viz.html` 按 `/docs-okf` 再生（现盘可能仍嵌旧 DESIGN / 旧实体归属文案）
- [ ] （未决）`AB.apis` 是否迁 AA `implements_*`
