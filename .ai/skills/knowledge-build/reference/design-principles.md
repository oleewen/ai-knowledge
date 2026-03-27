# 设计原则与反模式

knowledge-build 技能的完整设计约束。主文件 SKILL.md 中的「核心约束」为精简版，本文件为完整规范。

## 设计原则

### 1. 内置优先（契约内置）

以 [builtin-config.md](builtin-config.md) 中的内置配置（ssot、symmetry、evidence、phases、meta_shapes 等）为硬约束。外部 `{Doc Root}/knowledge/knowledge_meta.yaml` 的 `knowledge` 块存在时可补充或覆盖非核心字段，但不改变核心语义。无外部 YAML 时技能仍可正常执行。

### 2. 现状优先（入口三件套）

在配置中解析出 Doc Root 后，以当前仓库已落盘的根 `README.md`、`AGENTS.md`、主 Index Guide 为导航基线。禁止在未读这三者（存在则读）的情况下臆测 Doc Root、索引结构或与知识库无关的全仓细节。

### 3. 按需加载

`meta_read_order.paths`、各视角 `*_meta.yaml`、配置 `evidence` 所列工程/文档路径、实现代码：仅在本轮任务需要时打开。如仅物化 product 则优先读 `product_meta.yaml` 与 `knowledge/KNOWLEDGE_INDEX.md` 相关段。禁止为「完整性」通读 `docs/**` 或全模块源码。

### 4. 单一流程

固定四阶段（见内置配置 `phases`）；阶段一、二可跳过（见 SKILL.md 阶段入口判定），阶段三、四语义不变。

### 5. 上游 Skill 引用

`document-indexing`、`agent-guide` 由内置配置 `phases` 声明：作为阶段一、二的规范实现，不得被本技能改写语义；不在本轮默认自动执行。

### 6. 链上 ID 与 knowledge-extract

阶段三物化依赖 `knowledge/KNOWLEDGE_INDEX.md` 中的链上实体 ID。若需从工程与主 INDEX 抽取并归并 ID，宜先执行 knowledge-extract（技术→数据→业务→产品），再进入本技能阶段三。INDEX 已由人工或其它流程维护完整时可跳过。

技术视角 `MS-*` 与 knowledge-extract 对齐：仅入口宿主类聚类，任意 Maven 模块不映射为 MS。

### 7. 零重复 SSOT

- 四视角链上实体 ID **只**维护在 `knowledge/KNOWLEDGE_INDEX.md`
- 联邦 `DIR-*` 在主 `INDEX_GUIDE.md`（见内置配置 `ssot.federal_index_pointer`）

### 8. 可审计

变更写入 `changelogs/CHANGELOG.md`（路径由配置 `phases[].changelog` 约定）。

## SSOT 规则详解

| 实体类型 | 唯一维护位置 | 其他文件的引用方式 |
|----------|-------------|-------------------|
| 四视角链上 ID（SYS-/APP-/MS-/BD-/BC-/PL- 等） | `knowledge/KNOWLEDGE_INDEX.md` | 一行指针引用 |
| 联邦 DIR-* | 主 `INDEX_GUIDE.md` | 按 `ssot.federal_index_pointer` |
| 视角元数据 | 各 `*_meta.yaml` | 不在子目录重复 |

## 对称规则

遵守配置 `symmetry.rules`：

1. **同轮四段**：`KNOWLEDGE_INDEX.md` 的 §1～§4 同一轮维护
2. **无模板唯一**：`forbid_foreign_template_rows` 为 true 时，禁止以非本应用模板 ID 作为唯一内容
3. **INDEX 优先**：可登记 ID 时优先主 INDEX 与工程事实，不臆测
4. **BC/AGG 联动**：§1 已登记 BC/AGG 时，§3 或 §4 至少一类有证据行，或显式待补充与原因

## 跨视角规则

使用 `business_meta.integration.cross_perspective` 等配置；锚点未填字段时从 `evidence` 补证。

## 外部覆盖规则

| 场景 | 行为 |
|------|------|
| 无外部 YAML | 完全使用内置默认 |
| 外部 YAML 存在、含 `knowledge` 块 | 逐字段合并覆盖内置默认 |
| 外部新增字段（如自定义 `meta_read_order.paths`） | 正常生效 |
| 外部试图改变核心语义（phases 顺序、SSOT 路径） | 不生效，以内置为准 |

## 反模式清单（禁止）

| 反模式 | 说明 |
|--------|------|
| 双 Doc Root | 同一仓库声明多个文档根 |
| 无 INDEX 盲写 | 无主 INDEX（且未跑阶段入口判定补救）时盲写知识库 |
| 跳过三件套 | 跳过步骤 0.1 直接全仓摸索 |
| 通读全库 | 一次性通读 `meta_read_order` 全部文件而无论本轮是否用到 |
| 只加不索引 | 只加文件不更新 KNOWLEDGE_INDEX |
| 重复 SSOT | 子目录重复 `*_meta.yaml` 内容 |
| 默认替选 | 阶段四默认替用户选择未索引项处理方式 |
| 冗余征求 | 在已有可用三件套时仍默认征求重做阶段一/二 |
| 编造 ID | 从未读路径提取或凭空发明实体 ID |
| 破坏引用 | 更改已有 ID 或断裂已有交叉引用 |

## 执行节奏建议

默认节奏：**配置加载 → 三件套 → 判定是否跑一/二 → 阶段三按需打开 meta 与证据 → 阶段四**。

阶段间若缺模板，请用户指定或采用仓库默认；重大变更后可简短确认再进入下一阶段。避免「为跑流程而读完全库」。
