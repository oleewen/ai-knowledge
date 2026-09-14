# GRILL-LOG

> 仅未闭合烤干代办。契约见 [grilling-skill.md § GRILL-LOG](../agent/references/grilling-skill.md#grill-log)。勾销即删；无代办时保留本空壳。不替代 git 变更溯源 / `INDEXING-LOG`。

---

## 烤干结论摘要（PD/SYS/BU + 4A + 释义修订）

> 执行以本摘要为准。主线 SSOT / 三层 DESIGN·meta·样例·index 已落盘；下列为剩余收尾。

### 实体与层级（已落地）

| 域 | 约定 |
| --- | --- |
| BU / CAP / BD | 公司；CAP→BU；**CAP 由 BD 支撑**（`maps_to_bd_id`）；BD 平铺 + `maps_to_pl_id` 必填（**BD 由 PL 提供产品支撑**） |
| PL | **产品线（支持 BD）**；公司产品；零 PD |
| SLN | **解决方案（对应 PL）**；公司 AA（`application/SLN-*.md`；`maps_to_pl_id`） |
| PD | **产品服务**（别名：业务服务）；系统首次定义；`maps_to_sys_id` |
| SYS | **系统**（别名：应用服务）；系统首次定义；`parent_id→SLN` |
| 三元组 | 首层 BSD `maps_to_pd_id` 与 PD/SYS 同建 |
| 4A 边 | AA implements BA；AA uses DA/TA |

### 正式释义（2026-09-14 烤干锁定）

| 实体 | 释义 |
| --- | --- |
| CAP | 由 BD 支撑（属 BU） |
| PL | 产品线（支持 BD） |
| SLN | 解决方案（对应 PL） |
| PD | 产品服务（别名：业务服务） |
| SYS | 系统（别名：应用服务） |

字段策略：释义可改口，**不翻** `BD.maps_to_pl_id` / `CAP.maps_to_bd_id` 挂载侧。

---

## 开放代办

- [ ] 补齐系统/应用 data·technical meta 中「AA uses_* / 过渡镜像」措辞
- [ ] 章节叙事扫尾：仍写「公司 PD/SYS」「CAP 挂 BD」「PL=解决方案集合」「产品能力」等旧句处按摘要改
- [ ] fixtures / `knowledge-schema-template` 旧首次定义层细项
- [ ] 公司 `knowledge/README`、overview 导航若仍列 SYS/PD 作公司实体则改
- [ ] （未决）`AB.apis` 是否迁 AA `implements_*`
