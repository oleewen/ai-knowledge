# 设计原则（sdx-design）

[SKILL.md](../SKILL.md) 主干；验收勾选项见 [quality-checklist.md](quality-checklist.md)。

## 设计原则

### 1. 模板驱动

- 遵循 [dsd-template.md](../assets/dsd-template.md)。**§1**：有 ASD → 对齐 ASD §1/`asd-template`；仅有 **`spec-asd-*`** → 以其 §1–2 与 `refs` 为 SSOT。**§2** 详设。**§3**：有 ASD → 对齐并扩写 ASD §3；仅有 spec-asd → 以其中需求条目为表行基础并标 SSOT。**§4** 附录。不重排章节；空节保留标题，注「不适用/待补充」。
- **应用全量**：另写 **`requirements/.../specs/spec-dsd-*.md`**（[dsd-spec-template.md](../assets/dsd-spec-template.md)）；不要求 `specs/{service}/…` 分文件 YAML。

### 2. 证据优先

| 类型 | 格式 | 例 |
|------|------|-----|
| 产品需求 | `PRD-{…} US-{N}` | `PRD-260403-xxx US-003` |
| 功能 | `FR-{NNN}` | `FR-001 …` |
| 知识实体 | `{视角}-{ID}` | `BC-001 …` |
| 文档 | `{文件} §{节}` | `INDEX_GUIDE.md §3.2` |
| 代码 | `{类}:{方法}` | `FooApi:create` |
| ADR | `ADR-{NNN}` | `ADR-001 …` |

### 3. 按需加载

起手 **ASD 与/或 `spec-asd-*` + PRD + ANALYSIS** + 相关 knowledge；按需代码/ADR。勿为「完整性」通读 `knowledge/**` 或全仓。**spec-dsd** 按需维护互指。

### 4. 歧义标注

技术实现不明确处标待澄清并在文档记录；勿自行补全后继续。

### 5. 范围

本技能只产 **DSD** 与 **`spec-dsd-*.md`**。不测设、不写实现代码 → `sdx-test` / dev。

### 6. 可追溯

DD-n→PRD；API→用例；表变更→FR；规约条目→DSD（常为 §2）；非功能→分析中的非功能需求。

### 7. ID 前缀

| 前缀 | 用途 |
|------|------|
| `ASD-*` / `DSD-*` | 文档，与 REQUIREMENT/MVP 对齐 |
| `DD-{NNN}` | 设计决策 |
| `API-{NNN}` | 接口 |
| `LOGIC-{NNN}` | 业务逻辑 |
| `TBL-{NNN}` | 数据表 |

## 反模式清单（禁止）

| 表现 | 说明 |
|------|------|
| 过度设计 | 超 MVP 的抽象/中间件 |
| 臆测架构 | 无 knowledge/事实即定结构 |
| 吞没歧义 | 不标待澄清自行补全 |
| 范围蔓延 | DSD 内写测试/代码 |
| 模板跳章 | 改变 `dsd-template` 结构 |
| 通读全库 | 无视任务范围读完 knowledge |
| 无编号引用 | DD/API/TBL 不可追溯 |
| 接口不完整 | 缺错误码、幂等或容错 |
| DDL 无索引 | 缺策略与查询分析 |
| 忽略非功能 | 安全、可观测、性能空话 |
| 规约脱钩 | spec-dsd 与 DSD 不一致 |
| 循环中 RPC | 循环内 RPC/DB |

## 常见错误处置

| 场景 | 处理 |
|------|------|
| 无 PRD | 停；先 `sdx-prd` |
| PRD 结构缺 | 警告；列缺失；标风险后继续 |
| 无 ANALYSIS | 警告；仅 PRD；标缺基线 |
| 无 knowledge | 警告；标缺基线 |
| 模板缺失 | 停；核对 `assets/dsd-template.md`、`sdx-architect` asd-template |
| 架构冲突 | DD-n 记录化解 |
| 输出目录不存在 | 创建 `{DOC_DIR}/requirements/.../MVP-Phase-{N}/` |
