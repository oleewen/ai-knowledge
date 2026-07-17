---
type: Documentation
---
# business（业务视角）

索引入口见 [../../INDEX-GUIDE.md](../../INDEX-GUIDE.md) 与 [index.md](index.md)。前者负责 `application/` 九章地图，后者负责当前视角目录索引。

本目录描述业务版图与领域规则（DDD），不依赖具体技术实现。本树承接业务实体登记与实现映射；元数据与实例索引见 [business-meta.md](business-meta.md)、[../index.md](../index.md)（§1）。

---

## 层级结构

```text
业务域 (BD) → 业务子域 (BSD) → 限界上下文 (BC) → 聚合 (AGG) → 能力 (AB)
```

|层级|代码|物理形态|说明|
|-----|-----|----|-------------------|
|业务域|`BD`|Markdown 实体表|顶层业务边界|
|业务子域|`BSD`|Markdown 实体表|BD 下 0-N 个子域|
|限界上下文|`BC`|Markdown 实体表|BSD 下 1-N 个上下文|
|聚合|`AGG`|Markdown 实体表|BC 下多个聚合，每个含业务规则|
|能力|`AB`|Markdown 实体表|AGG 下多个能力（含 API 列表）|

**关键设计决策**：各级实体以实体文件 `{ID}.md` 为 SSOT；全库扫描索引见 [../index.md](../index.md)（§1）。

---

## 目录树（示例）

```text
business/
├── README.md              # 本文件（人类导航）
├── business-meta.md       # 视角元数据（元模型、层级约定、跨视角映射）
├── index.md               # OKF 浏览入口
├── BD-EXAMPLE.md          # 示例业务域（实体文件 SSOT）
└── BSD-EXAMPLE/           # 示例子域树（BC/AGG/AB）
```

---

## AI 检索指南

|检索需求|推荐入口|
|---------------|----|
|快速枚举全部业务实体 ID|[../index.md](../index.md) §1（扫描生成）|
|了解某聚合的业务规则与能力|对应 `{ID}.md`（如 [BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md](BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md)）|
|了解上下文边界与通用语言|对应 `{ID}.md`（如 [BSD-EXAMPLE/BC-EXAMPLE/BC-EXAMPLE.md](BSD-EXAMPLE/BC-EXAMPLE/BC-EXAMPLE.md)）|
|跨视角映射（业务→技术/数据）|[business-meta.md](business-meta.md) → §5 跨视角引用|
|全库五视角索引|[../index.md](../index.md)|

---

## 业务索引表（示例）

本目录仅保留**示例**，用于演示 BD→AB 的层级与字段形状。完整 ID 清单以 [../index.md](../index.md) §1 为准。

|链序|层级|ID（示例）|名称（示例）|文件|
|---|-----|-----------|-------|---|
|L1|业务域|BD-EXAMPLE|示例业务域|[BD-EXAMPLE.md](BD-EXAMPLE.md)|
|L2|业务子域|BSD-EXAMPLE|示例业务子域|[BSD-EXAMPLE/BSD-EXAMPLE.md](BSD-EXAMPLE/BSD-EXAMPLE.md)|
|L3|限界上下文|BC-EXAMPLE|示例限界上下文|[BSD-EXAMPLE/BC-EXAMPLE/BC-EXAMPLE.md](BSD-EXAMPLE/BC-EXAMPLE/BC-EXAMPLE.md)|
|L4|聚合|AGG-EXAMPLE|示例聚合|[BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md](BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md)|
|L5|能力|AB-EXAMPLE|示例能力|[BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AB-EXAMPLE.md](BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AB-EXAMPLE.md)|

---

## 关键字段（用于映射）

- **BC（限界上下文）**：`implemented_by_app_id`（→ application APP）
- **AGG（聚合）**：`persisted_as_entity_ids`（→ data ENT）
- **AB（能力）**：`apis`（含 API-ID，→ application API）

（字段细则以实体文件 `{ID}.md` 为准；映射见 [business-meta.md](business-meta.md)。）

---

## 与其他视角的映射

- **业务 → 技术**：BC/AGG/AB → APP/MS/API（见 business-meta.md §5）。
- **业务 → 数据**：AGG → ENT，见 [../data/DS-EXAMPLE/ENT-EXAMPLE.md](../data/DS-EXAMPLE/ENT-EXAMPLE.md) 或 [../index.md](../index.md) §4。

仓库根 Index Guide：[../../../INDEX-GUIDE.md](../../../INDEX-GUIDE.md)。
