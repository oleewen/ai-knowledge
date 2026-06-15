# knowledge — 应用知识库主体

**应用知识库**（联邦单元内 `knowledge/`）：**业务 / 产品 / 应用 / 数据 / 技术** 五视角；治理与命名 SSOT 见 [`../../agent/knowledge/knowledge-governance.md`](../../agent/knowledge/knowledge-governance.md)。与中央库 `application/knowledge/` 同构。中央库阶段文档（solutions、analysis）见 [`../solutions`](../solutions/README.md)、[`../analysis`](../analysis/README.md)；本应用 requirements 以本树及中央库为事实源；归档时可回写。

---

## 五视角实体 ID（SSOT）

- **链上实体 ID 登记表**：[KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md) — business / product / application / data / technical 五视角（**不含** `DIR-*` 联邦/阶段）。`application/` 入口见 [../README.md](../README.md)；仓库根 Index Guide 见 [INDEX_GUIDE.md](../../INDEX_GUIDE.md) **§1.2**。
- **视角实例索引**：各视角根目录 `{perspective}-entities.md`（字段约定见 [../../agent/skills/docs-build/SKILL.md](../../agent/skills/docs-build/SKILL.md) 与对应 `{perspective}-meta.md`）。
- **机器契约（SSOT）**：[../../agent/skills/docs-build/SKILL.md](../../agent/skills/docs-build/SKILL.md)（ssot、symmetry、meta_read_order）；[knowledge-meta.md](knowledge-meta.md) 保留联邦/目录元数据。

## 子目录

| 路径 | 说明 | 视角元数据 |
|------|------|----------|
| [business](business) | BD → BSD → BC → AGG | [business/business-meta.md](business/business-meta.md) |
| [product](product) | PL → PM → FT → UC | [product/product-meta.md](product/product-meta.md) |
| [application](application) | SYS → APP → MS | [application/application-meta.md](application/application-meta.md) |
| [data](data) | DS → ENT | [data/data-meta.md](data/data-meta.md) |
| [technical](technical) | MW → CMP | [technical/technical-meta.md](technical/technical-meta.md) |

公司级 **TPL-***、系统级 **TSD-*** 分别在 `company/ea/technical/`、`system/architecture/technical/` 登记；本树技术视角登记 **MW/CMP**。

---

## 维护（三步）

1. 改前读 **机器契约**（见上）、本目录 [knowledge-meta.md](knowledge-meta.md)（目录元数据）与目标视角 `README.md`、相关 `{perspective}-meta.md`
2. 只增删改 **ID** 与 Markdown 约定字段；跨视角不写重复叙述
3. 更新 [INDEX_GUIDE.md](../../INDEX_GUIDE.md)（第三节 · 3.1 实现侧或联邦指针）、[KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md)（各视角实体 ID）或该视角 README 中的登记 / 示例（若影响导航）

**索引指针**：各视角实体 ID [KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md)；仓库根 [INDEX_GUIDE.md](../../INDEX_GUIDE.md)；`application/` 九章索引与中央知识库挂载建联登记 [../INDEX_GUIDE.md](../INDEX_GUIDE.md)。

**实现侧（与分层 ID 独立）**：网关 `@GatewayApi` 对外路径、调度模块 Job 类清单见 [INDEX_GUIDE.md](../../INDEX_GUIDE.md) **第三节 · 3.1**、**第三节 · 3.3**（与 `billing-appeal-service` / `billing-appeal-schedule` 源码一致）。

---

## 约定（最小集）

- 文内路径优先可解析的相对路径（如自 `knowledge/` 起）
- PL/PM/FT、SYS、DS/ENT、MW/CMP 等元数据 **集中在各视角根目录**，细则见各 `README.md` 与 DESIGN §2
