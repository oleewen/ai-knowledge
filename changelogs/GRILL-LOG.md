# GRILL-LOG

> 仅未闭合烤干代办。契约见 [grilling-skill.md § GRILL-LOG](../agent/references/grilling-skill.md#grill-log)。勾销即删；无代办时保留本空壳。不替代 git 变更溯源 / `INDEXING-LOG`。

---

## 烤干结论摘要（MDG 下沉 + DESIGN 并入 governance）

> 执行以本摘要与 [knowledge-governance.md](../agent/knowledge/knowledge-governance.md) 为准。

### 层设计 SSOT

- **唯一语义设计**：`agent/knowledge/knowledge-governance.md`（职责、首次定义、各层聚焦、5A 方向、引用边界）
- **路径/槽位/流水线**：`agent/references/knowledge-layout.md`
- **已删除**：`company|system|application/DESIGN.md`；引用改链 governance
- **install/upgrade**：不再种/特殊批 `DESIGN.md`；保留 `CONTRIBUTING.md`

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
