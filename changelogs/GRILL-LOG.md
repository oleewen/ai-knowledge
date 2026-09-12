# GRILL-LOG

> 仅未闭合烤干代办。契约见 [grilling-skill.md § GRILL-LOG](../agent/references/grilling-skill.md#grill-log)。勾销即删；无代办时保留本空壳。不替代 git 变更溯源 / `INDEXING-LOG`。

---

## 烤干结论摘要（PD/SYS/BU + 4A 回烤）

> 执行以本摘要为准。主线 SSOT / 三层 DESIGN·meta·样例·index 已落盘；下列为剩余收尾。

### 实体与层级（已落地）

| 域 | 约定 |
| --- | --- |
| BU / CAP / BD | 公司；CAP→BU + `maps_to_bd_id`；BD 平铺 + `maps_to_pl_id` 必填 |
| PL / SLN | PL 公司产品；**SLN 公司 AA**（`application/SLN-*.md` 平铺，`maps_to_pl_id`）；公司零 PD |
| PD / SYS | 系统首次定义；`PD.maps_to_sys_id`；`SYS.parent_id→SLN` |
| 三元组 | 首层 BSD `maps_to_pd_id` 与 PD/SYS 同建（样例已齐） |
| 4A 边 | AA implements BA；AA uses DA/TA（meta/APP 样例已起步） |

---

## 开放代办

- [ ] 补齐系统/应用 data·technical meta 中「AA uses_* / 过渡镜像」措辞；MS 样例补 `implements_agg_ids` / `uses_ent_ids`
- [ ] 章节叙事扫尾：`company`/`system` product·business·application chapters 仍可能写「公司 PD/SYS」「CAP 挂 BD」——按摘要改
- [ ] fixtures / okf 测试 / `knowledge-schema-template` 中写死旧首次定义层处
- [ ] 公司 `knowledge/README`、application overview 等导航句若仍列 SYS/PD 作公司实体则改
