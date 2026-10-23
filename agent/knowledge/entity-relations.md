# 实体关系模型

> **定位**：六组关系动词、允许边、反向同步、例外与废弃关系的唯一真源。实体类型见 [术语表](glossary.md#实体缩写登记)；首次定义与基数见 [治理规则](knowledge-governance.md)；字段必填性见五视角 meta；链接形态见 [引用规范](knowledge-reference-rules.md)。

## 动词与双向要求

关系可以没有；一侧存在时，对端必须填写反向关系，含跨层。树根省略 `parent`；SYS 的两条上游边按下节例外处理。混列目标用 ID 前缀辨型，不设单侧关系真源。

| 动词对 | 含义与方向 |
| --- | --- |
| `parent` / `children` | 同类树：子指父、父列子 |
| `implements_to` / `implemented_by` | 异类组成：实现者指向被实现对象，对端列实现者；允许边包括跨视角的 BP→SLN |
| `maps_to` / `mapped_by` | 对标：映射方指目标，对端列映射方 |
| `supports_to` / `supported_by` | 支撑方指被支撑对象，对端列支撑方 |
| `uses_to` / `used_by` | 使用方指被使用对象，对端列使用方 |
| `depends_to` / `depended_by` | PM 之间依赖：依赖方指被依赖方，对端列依赖方 |

## 允许边

本表只定允许目标；是否必填由实体所属视角 meta 定义。反向边按上节生成，不维护第二份完整边表。

| 出边 | 宿主 → 目标 |
| --- | --- |
| `parent` | BSD-L1→BD；BSD-L2→BSD-L1；BSD-L3→BSD-L2；BSP→BP |
| `children` | `parent` 的对端 |
| `implements_to` | CAP→VC；BC→BSD-L3；AGG→BC；AB→AGG；PD→PL；PM→PD；FT→PM；FR→FT；UC/BR→FR；BP→SLN；BSP→PD；SYS→SLN；APP→SYS；MS→APP；API→MS；DS→MDG；ENT→DS；TBL→ENT；TS→TPL；MW→TS；CMP→MW |
| `implemented_by` | `implements_to` 的对端，SYS→SLN 例外 |
| `maps_to` | BL→BSD-L1；BSD-L1→CAP；PL→BL；SLN→PL；PD→BS；BS→BSD-L2；SYS→PD；PM→BC；API→UC；UC→AB；MS→AGG；ENT→AGG |
| `mapped_by` | `maps_to` 的对端，SYS→PD 例外 |
| `supports_to` | BD→VC；APP→BC；API→FT |
| `supported_by` | `supports_to` 的对端 |
| `uses_to` | PD→MDG/TS；APP→DS/MW；MS→ENT；MW→DS |
| `used_by` | `uses_to` 的对端 |
| `depends_to` / `depended_by` | PM↔PM |

## 例外与禁止

- 系统侧 `SYS.implements_to`→SLN、`SYS.maps_to`→PD 只写纯 ID；解决方案不回写 `SLN.implemented_by` SYS 或 `PD.mapped_by` SYS。
- SYS 不 `uses_to` MDG/TS，由 PD 声明使用；禁止 SYS 绕过 PD 对标 PL。
- 禁止跨系统 PM→PD；`SYS.maps_to` PD 与该 `PD.maps_to` BS 成对填写。
- 禁止 APP/SYS↔TPL、APP↔CMP、FT↔UC 直连；MW 不替代 MS/API。
- 上层指向下层的目标只写纯 ID，其他引用形态见 [引用规范](knowledge-reference-rules.md)。

## 已废（勿再用）

`implements_*_ids`、`implements_to_vc`、`implemented_by_cap`、`implemented_by_app_id`、`implemented_by_service_ids`、`supports_to_vc`、`supported_by_bd`、带后缀的 `maps_to_*`、`uses_*_ids`、`apis`、`aggregates`、`abilities`、`persisted_as_*`、`owned_by_app_id`、`bound_app_id`、`parent_tsd_id` / `parent_tpl_id` / `parent_mw_id` / `parent_app_id`、`relies_on_context_ids`、`invokes_api_ids`、`depends_pm_ids`、`map_to_api_id`、`maps_to_cap_ids`、`authoritative_mdg_id`、`root_entity` / `entities`、`strategic_classification`。

旧 `parent_*_id` 组成关系改用 `implements_to`；其他旧名按本文件允许边迁移，不保留平行字段。路径父级提取见 [知识布局](../references/knowledge-layout.md)。
