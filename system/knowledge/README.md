# knowledge — 知识库主体

SSOT：**宪法层** + **业务 / 产品 / 技术 / 数据** 四视角。阶段文档（solutions、analysis、requirements）以本树为事实源；归档时可回写知识条目。

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

1. 改前读 [../DESIGN.md](../DESIGN.md)、本目录 [knowledge_meta.yaml](./knowledge_meta.yaml) 与目标视角 `README.md`、相关 `*_meta.yaml`  
2. 只增删改 **ID** 与 YAML/Markdown 约定字段；跨视角不写重复叙述  
3. 更新 [../INDEX.md](../INDEX.md) 或该视角 README 中的登记 / 示例（若影响导航）  

**索引指针**：本树导航 [../INDEX.md](../INDEX.md)；全库 Index Guide [../../INDEX.md](../../INDEX.md)。

---

## 约定（最小集）

- 文内路径优先可解析的相对路径（如自 `knowledge/` 起）  
- PL/PM/FT、SYS、DS/ENT 等元数据 **集中在各视角根目录**，细则见各 `README.md` 与 DESIGN §2  
