# knowledge — 知识库主体

**应用级知识库**：**宪法层** + **业务 / 产品 / 技术 / 数据** 四视角。事实源以**中央库 `system/knowledge/`** 为治理基线；本树补充本应用实现与映射，可经归档回写主库（参见 [system/DESIGN.md](../../../system/DESIGN.md)）。

---

## 子目录

| 路径 | 说明 | 视角元数据（YAML） |
|------|------|------------------|
| [constitution/](./constitution/) | 术语、原则、标准、ADR | [constitution_meta.yaml](./constitution/constitution_meta.yaml)（子树见该目录 README） |
| [business/](./business/) | BD → BSD → BC → AGG | [business_meta.yaml](./business/business_meta.yaml) |
| [product/](./product/) | PL → PM → FT → UC | [product_meta.yaml](./product/product_meta.yaml) |
| [technical/](./technical/) | SYS → APP → MS | [technical_meta.yaml](./technical/technical_meta.yaml) |
| [data/](./data/) | DS → ENT | [data_meta.yaml](./data/data_meta.yaml) |

---

## 维护（三步）

1. 改前读 [../../../system/DESIGN.md](../../../system/DESIGN.md)、[../../../system/CONTRIBUTING.md](../../../system/CONTRIBUTING.md)、本目录 [knowledge_meta.yaml](./knowledge_meta.yaml) 与目标视角 `README.md`、相关 `*_meta.yaml`  
2. 只增删改 **ID** 与 YAML/Markdown 约定字段；跨视角不写重复叙述  
3. 更新 [../INDEX.md](../INDEX.md) 或该视角 README 中的登记 / 示例（若影响导航）  

**索引指针**：本应用导航 [../INDEX.md](../INDEX.md)；仓库根 Index Guide [../../../INDEX.md](../../../INDEX.md)；applications 聚合索引 [../../INDEX.md](../../INDEX.md)。

---

## 约定（最小集）

- 文内路径优先可解析的相对路径（如自 `knowledge/` 起）  
- PL/PM/FT、SYS、DS/ENT 等元数据 **集中在各视角根目录**，细则见各 `README.md` 与 DESIGN §2  
