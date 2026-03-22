# knowledge — 应用知识库主体

**应用知识库**（联邦单元内 `knowledge/`）：**宪法层** + **业务 / 产品 / 技术 / 数据** 四视角，与中央库 `system/knowledge/` 同构。中央库阶段文档（solutions、analysis）见 `../../system/`；本应用 requirements 以本树及中央库为事实源；归档时可回写。

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

1. 改前读 [../../system/DESIGN.md](../../system/DESIGN.md)、本目录 [knowledge_meta.yaml](./knowledge_meta.yaml) 与目标视角 `README.md`、相关 `*_meta.yaml`  
2. 只增删改 **ID** 与 YAML/Markdown 约定字段；跨视角不写重复叙述  
3. 更新 [../INDEX.md](../INDEX.md) 或该视角 README 中的登记 / 示例（若影响导航）  

**索引指针**：本联邦单元 [../INDEX.md](../INDEX.md)；全库 Index Guide [../../../INDEX_GUIDE.md](../../../INDEX_GUIDE.md)；中央库 [../../system/SYSTEM_INDEX.md](../../system/SYSTEM_INDEX.md)。

---

## 约定（最小集）

- 文内路径优先可解析的相对路径（如自 `knowledge/` 起）  
- PL/PM/FT、SYS、DS/ENT 等元数据 **集中在各视角根目录**，细则见各 `README.md` 与 DESIGN §2  
