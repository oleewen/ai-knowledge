# 阶段三：知识写入规范

阶段三是 knowledge-build 的核心算法阶段。以下步骤与内置配置（[builtin-config.md](builtin-config.md)）中 `ssot`、`symmetry`、`cross_perspective`、`meta_shapes` 一致。

## 前提

- `knowledge/KNOWLEDGE_INDEX.md` 应已列出本轮要物化的链上 ID（及证据）
- 若尚未建立或缺口大，先执行 **knowledge-extract** 再进入本阶段

## 3.0 按需加载

在 3.1～3.3 之前执行。已读基线：步骤 0 配置 + 步骤 0.1 三件套 + 主 INDEX 路径。

| 需求 | 加载内容 |
|------|---------|
| 登记/核对四视角 ID | `knowledge/KNOWLEDGE_INDEX.md`（全文或相关段）、配置 `ssot` / `symmetry` |
| 物化某一视角目录 | 该视角 `{perspective}_meta.yaml`（如 `business_meta.yaml`）、配置 `meta_shapes` 匹配规则 |
| 取证链 | 配置 `evidence`：主 INDEX §2（项目结构）、§3（对外接口）、§7（配置）、§8（索引边界）按需打开对应小节；`pom.xml` / `AGENTS.md` 仅在填 ID 或核对事实时读 |
| 联邦与变更 | `application_meta.yaml`、`changelogs_meta.yaml` 等：按 `meta_read_order.paths` 仅打开本轮会改动的项 |
| 实现细节 | 仅在三件套或主 INDEX 已指向的路径内定点阅读（类名、Mapper、表名）；禁止漫无目的扫 `src/**` |

## 3.1 维护 KNOWLEDGE_INDEX.md

1. **前缀过滤**：仅登记配置 `ssot.four_perspective_index.contains_prefixes` 所列前缀的链上 ID；排除 `ssot.four_perspective_index.excludes.items`
2. **应用策略**：若 `application_only_policy.forbid_foreign_template_rows: true`，禁止在 INDEX 与各视角 README 以非本应用模板 ID 作为唯一内容；缺口用 `allowed_gap_marker`
3. **证据填写**：按配置 `evidence`（主 Index §2～§3、§7～§8，`pom.xml`、当前 `AGENTS.md` 等）按需打开并逐行填写证据路径；不要求未参与本轮 ID 的章节全部精读
4. **对称检查**：遵守配置 `symmetry.rules`（同轮四段、BC/AGG 联动、主 Index 优先于臆测）
5. **跨视角引用**：使用 `business_meta.integration.cross_perspective` 等；锚点未填字段时从 `evidence` 补证

## 3.2 meta × Index 物化

1. 按配置 `meta_shapes` 判定各文件形态，读取 `schema_version: "1.1"` 的 `repository` + `layers`
2. 仅从 `knowledge/KNOWLEDGE_INDEX.md` / 用户输入 / §3.0 按需加载且已读的文档或代码提取 ID；禁止 invent
3. 将 ID 代入 `directory_patterns`、`child_directory_glob`，创建目录与 `layers.artifacts` 规定的文件
4. 部分链缺失时只生成已覆盖层，并在视角 `README.md` 标注 `[需补链：…]`
5. 无匹配 ID 时记 `[需补 ID：…]`，不批量 `PLACEHOLDER`，除非用户显式要求示例脚手架

## 3.3 落盘四步

### 第一步：写入 INDEX + 物化 + 实体正文

- 不改已有 ID
- 不断裂已有引用

### 第二步：更新导航

- 更新 `{Doc Root}/INDEX_GUIDE.md`（或主 Index Guide 实际路径）
- 更新子 README
- 联邦实体一行指向 `knowledge/KNOWLEDGE_INDEX.md`

### 第三步：写入 CHANGELOG

- 按 `changelogs_meta.yaml` 格式
- 人类可读 `CHANGELOG.md` 同步更新

### 第四步：自检

- 链接可点
- 无冲突子树 `*_meta.yaml`
- `knowledge/KNOWLEDGE_INDEX.md` 已覆盖本轮视角

## 物化文件形态决策

```
meta_shapes 匹配流程：
1. 读取视角 *_meta.yaml 的 repository + layers
2. 从 KNOWLEDGE_INDEX.md 获取本视角 ID 列表
3. 按 directory_patterns 生成目标路径
4. 检查 layers.artifacts 确定要创建的文件列表
5. 只生成有 ID 支撑的文件，缺失 ID 标记 gap
```

## 证据链填写规范

每个 ID 的证据链应包含至少一个可验证来源：

| 证据类型 | 格式 | 示例 |
|----------|------|------|
| 文档章节 | `{文件} §{章节}` | `INDEX_GUIDE.md §3.2` |
| 代码位置 | `{类}#{行号}` 或 `{类}:{方法}` | `BillingAppealApi:create` |
| 配置文件 | `{路径}:{键}` | `application.yml:spring.datasource` |
| 工程事实 | `{文件}` | `pom.xml`、`AGENTS.md` |
