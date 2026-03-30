# knowledge — 应用知识库主体

**应用知识库**（联邦单元内 `knowledge/`）：**宪法层** + **业务 / 产品 / 技术 / 数据** 四视角，与中央库 `system/knowledge/` 同构。中央库阶段文档（solutions、analysis）见 `../../system/`；本应用 requirements 以本树及中央库为事实源；归档时可回写。

---

## 四视角实体 ID（SSOT）

- **链上实体 ID 登记表**：[KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md) — **仅** business / product / technical / data 四视角（**不含** `DIR-*` 联邦/阶段、**不含** constitution）。`system/` 入口见 [../README.md](../README.md)；仓库根 Index Guide 见 [INDEX_GUIDE.md](../../INDEX_GUIDE.md) **§1.2**。
- **knowledge-extract 中间产物（机器 JSON，与物化锚点 `.md` 分离）**：各视角根目录 `technical_knowledge.json`、`business_knowledge.json`、`product_knowledge.json`、`data_knowledge.json`（字段约定见 [../../.ai/skills/knowledge-extract/SKILL.md](../../.ai/skills/knowledge-extract/SKILL.md)）。
- **机器契约（SSOT）**：[../../.ai/skills/knowledge-extract/SKILL.md](../../.ai/skills/knowledge-extract/SKILL.md)（ssot、symmetry、meta_read_order）；[knowledge_meta.yaml](knowledge_meta.yaml) 仅保留联邦/目录元数据。

## 子目录

| 路径 | 说明 | 视角元数据（YAML） |
|------|------|------------------|
| [constitution](constitution) | 术语、原则、标准、ADR | [constitution/constitution_meta.yaml](constitution/constitution_meta.yaml)（子树见该目录 README） |
| [business](business) | BD → BSD → BC → AGG | [business/business_meta.yaml](business/business_meta.yaml) |
| [product](product) | PL → PM → FT → UC | [product/product_meta.yaml](product/product_meta.yaml) |
| [technical](technical) | SYS → APP → MS | [technical/technical_meta.yaml](technical/technical_meta.yaml) |
| [data](data) | DS → ENT | [data/data_meta.yaml](data/data_meta.yaml) |

---

## 维护（三步）

1. 改前读 **机器契约**（见上）、本目录 [knowledge_meta.yaml](knowledge_meta.yaml)（目录元数据）与目标视角 `README.md`、相关 `*_meta.yaml`  
2. 只增删改 **ID** 与 YAML/Markdown 约定字段；跨视角不写重复叙述  
3. 更新 [INDEX_GUIDE.md](../../INDEX_GUIDE.md)（第三节 · 3.1 实现侧或联邦指针）、[KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md)（各视角实体 ID）或该视角 README 中的登记 / 示例（若影响导航）  

**索引指针**：各视角实体 ID [KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md)；仓库根 [INDEX_GUIDE.md](../../INDEX_GUIDE.md)；中央库导航 [../SYSTEM_INDEX.md](../SYSTEM_INDEX.md)。

**实现侧（与 YAML 分层 ID 独立）**：网关 `@GatewayApi` 对外路径、调度模块 Job 类清单见 [INDEX_GUIDE.md](../../INDEX_GUIDE.md) **第三节 · 3.1**、**第三节 · 3.3**（与 `billing-appeal-service` / `billing-appeal-schedule` 源码一致）。

---

## 约定（最小集）

- 文内路径优先可解析的相对路径（如自 `knowledge/` 起）  
- PL/PM/FT、SYS、DS/ENT 等元数据 **集中在各视角根目录**，细则见各 `README.md` 与 DESIGN §2  
