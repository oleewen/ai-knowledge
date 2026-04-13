# 联邦原则与映射规范

docs-archive 的联邦层级约定、各目录归档规则与质量自检标准。

---

## 归档目标目录根目录的范围

下文中的**归档目标目录根目录**指 **`system/architecture/` 下参与联邦与导航的完整目录集合**（constitution、knowledge、solutions、analysis、requirements、specs、changelogs 子树及必要的根级契约/索引文件），**不是** `system/architecture/knowledge/` 的同义词。各子目录规则不同（knowledge 提炼 vs SDD 直接归档），但都属于向系统侧上行的目标。

### 归档目标目录根目录（`system/architecture/`）区域角色一览

归档时在下列区域中**按本次变更择需**写入或更新（与 [archive-spec.md](archive-spec.md)「系统侧范围」一致）：

| 区域 | 典型路径 | 归档方式 |
|------|----------|----------|
| 四视角架构文档 | `system/architecture/BUSINESS-ARCHITECTURE.md`、`TECHNICAL-ARCHITECTURE.md`、`DATA-ARCHITECTURE.md`、`PRODUCT-ARCHITECTURE.md` | 按模板受管区块提炼写入 |
| 上行批次留痕 | `system/changelogs/CHANGE-LOG.md` | 每批次向总日志追加记录 |
| 导航与契约（按需） | `system/architecture/README.md`、`system/docs_meta.yaml` 等 | 增量维护（仅当本次变更影响导航或契约时） |

### 应用侧顶层目录 → 归档目标目录根目录路径（联邦入口）

| 系统侧目录 | 应用侧来源 | 说明 |
|-----------|-----------|------|
| `system/architecture/knowledge/` | 应用知识库根目录下 `system/application-{name}/knowledge/` | 四视角实体 |
| `system/architecture/constitution/` | 应用侧 `system/application-{name}/constitution/` | 宪法层（与 knowledge/ 平级） |
| `system/architecture/solutions/` | `solutions/` 或 `requirements/` 内 `SOLUTION-*.md` | 方案文档 |
| `system/architecture/analysis/` | `requirements/` 或 `analysis/` 内 `ANALYSIS-*.md` | 分析文档 |
| `system/architecture/requirements/` | `requirements/REQUIREMENT-*/` | 需求包目录 |
| `system/architecture/specs/` | `requirements/.../specs/` 等 | 规约（随需求包或按需） |

---

## 联邦层级约定

| 层级 | 适合放什么 | 不适合 |
|------|-----------|--------|
| **应用知识库** | 接口细节、本仓 Schema、部署参数、manifest、应用内四视角实例、应用级 SDD 文档 | 把全系统业务域在应用里当唯一权威重复定义 |
| **系统知识库**（`system/`） | 跨应用映射、系统边界、应用注册（`technical/{SYS}/{APP}.yaml`）、聚合与实体 ID 契约、产品/API 关联字段、系统级 SDD 文档 | 大段复制应用内 OpenAPI 全文（应保留 `docs_manifest_path` 与 ID 引用） |

---

## 一、knowledge/ 归档规则

knowledge 归档遵循**提炼原则**：从应用侧提取有效信息，改写为系统文件要求的字段与结构，禁止整段复制。

### 应用侧 → 系统侧映射表

| 应用侧信息 | 系统侧落点 |
|-----------|-----------|
| 应用身份、仓库、manifest 路径 | `knowledge/technical/{SYS}/{APP-ID}.yaml`：`repo_url`、`docs_manifest_path`、`service_ids` |
| 新 MS-*（入口簇）、API 清单（摘要级） | 更新 `{APP-ID}.yaml` 的 `service_ids`；MS-* 须按 APIs 宿主聚类（非 Maven 模块名）；API 细节以 manifest 为 SSOT |
| 限界上下文由本应用实现 | `knowledge/business/business_meta.yaml` → `layers[key=bc].fields.implemented_by_app_id` |
| 数据实体归属应用 | `knowledge/data/data_meta.yaml` → `layers[key=ds/ent]` 中 `owned_by_app_id`；与聚合的 `persisted_as_entity_ids` |
| 产品功能调用本应用 API | `knowledge/product/product_meta.yaml` → `layers[key=ft].invokes_api_ids` |
| 跨域架构决策 | 必要时新增 `constitution/adr/ADR-*.md`（联邦单元内与系统知识库 `system/architecture/constitution/` 同构） |

### knowledge 撰写规则

- **先读再写**：打开拟修改的系统文件与相邻 `*_meta.yaml`，确认现有 ID
- **只增不改 ID**：已有实体禁止改 id；新增实体 ID 须全局唯一且符合命名规范
- **交叉引用仅 ID**：正文与 YAML 关联字段只写 ID，不写重复长描述
- **更新索引**：变更影响全局导航时，同步 `system/architecture/INDEX_GUIDE.md` 或对应视角 `README.md`

---

## 二、solutions/ 归档规则

solutions 归档遵循**直接归档原则**：应用侧的解决方案文档直接复制到系统库，保持文档完整性。

### 归档条件

- 文档状态为 `approved` 或 `review`（草稿 `draft` 通常不归档，除非用户明确要求）
- 文档 `id` 格式符合 `SOLUTION-{IDEA-ID}`

### 归档操作

1. 将 `SOLUTION-{IDEA-ID}.md` 复制到 `system/architecture/solutions/SOLUTION-{IDEA-ID}.md`
2. 在 `system/architecture/solutions/README.md` 的方案索引表中追加一行：

```markdown
| SOLUTION-{IDEA-ID} | {标题} | {关联 ANALYSIS-ID（如有）} | {状态} | {更新时间} |
```

3. 若文档已存在于系统库，比较内容差异，以应用侧最新版本为准（覆盖更新）

---

## 三、analysis/ 归档规则

analysis 归档遵循**直接归档原则**，与 solutions 类似。

### 归档条件

- 文档状态为 `approved` 或 `review`
- 文档 `parent` 字段指向的 `SOLUTION-{IDEA-ID}` 已存在于系统库（或同批次归档）

### 归档操作

1. 将 `ANALYSIS-{IDEA-ID}.md` 复制到 `system/architecture/analysis/ANALYSIS-{IDEA-ID}.md`
2. 在 `system/architecture/analysis/README.md` 的分析索引表中追加一行：

```markdown
| ANALYSIS-{IDEA-ID}.md | {标题} | {关联 SOLUTION-ID} | {简要说明} |
```

3. 若文档已存在于系统库，以应用侧最新版本为准（覆盖更新）

---

## 四、requirements/ 归档规则

requirements 归档遵循**整包归档原则**：以需求包（`REQUIREMENT-{IDEA-ID}/`）为单位归档。

### 归档条件

- 需求包目录存在且含至少一个 MVP 阶段目录（`MVP-Phase-*/`）
- 需求包内文档的 `parent` 字段可追溯到已归档的 `ANALYSIS-{IDEA-ID}.md`

### 归档操作

1. 将 `REQUIREMENT-{IDEA-ID}/` 整个目录复制到 `system/architecture/requirements/REQUIREMENT-{IDEA-ID}/`
2. 若目录已存在于系统库，合并更新（新增 MVP 阶段目录，已有阶段以应用侧最新版本为准）
3. 规约文件（`specs/`）随需求包一并归档

---

## 五、归档顺序约束

同一批次归档多类型内容时，须按以下顺序执行，保证上下游引用完整：

```
BUSINESS-ARCHITECTURE.md → TECHNICAL-ARCHITECTURE.md → DATA-ARCHITECTURE.md → PRODUCT-ARCHITECTURE.md
```

原因：四视角按“业务语义 → 技术实现 → 数据落点 → 产品映射”逐步收敛，先落业务/技术语义，再补数据与产品映射，可减少同批次字段回填冲突。

---

## 六、质量自检

### knowledge 归档

- 新增/修改的 YAML 可被解析；无断链 ID
- 应用独有细节仍保留在应用库；系统库无大段与 manifest 重复的冗余正文
- 若应用侧与系统侧冲突，以代码与 manifest 为准，或标为待人工确认

### SDD 文档归档

- 归档文档的 `id` 字段与文件名一致
- `parent` 字段指向的上游文档已存在于系统库
- solutions/analysis 索引表已更新
- requirements 需求包目录结构完整（含 `requirements_meta.yaml`）
