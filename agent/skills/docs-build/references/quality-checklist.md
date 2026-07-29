# 质量验证清单

阶段 4 后与阶段 3 README 对照自检。

## 初始化

- [ ] 主 Index Guide 可用

## 顺序与结构

- [ ] 技术→数据→业务→产品
- [ ] 技术 `entities` 分类；他视角扁平

## API

- [ ] Dubbo、HTTP、MQ Consumer、Job 全覆盖
- [ ] 每条 `api_type`：`DUBBO`/`HTTP`/`MQ_CONSUMER`/`JOB`
- [ ] Dubbo 仅 Provider
- [ ] MQ 多 Tag → 多条 API
- [ ] Job 含 `job_handler`
- [ ] MQ/Job 归 MS-ID

## 实体

- [ ] `evidence_chain` 完整
- [ ] MS 按宿主聚类 ≠ Maven 模块
- [ ] 一物理表一 ENT
- [ ] AGG 有 MS
- [ ] FT/UC 各有 API

## README（阶段 3）

- [ ] 沿用各视角 README 表头/章节，不臆造列
- [ ] 索引行与 JSON 一致；无示例冒充（无实体则标待补充）
- [ ] 静态说明段（层级、字段、跨视角、INDEX 链接）保留

## 归并（阶段 4）

- [ ] 前缀 ∈ `contains_prefixes`
- [ ] `KNOWLEDGE_INDEX.md` §1–§4 同轮且无纯模板行
- [ ] 旧 ID 无单独更名（引用完整）

## metadata

- [ ] 每 JSON 完整 `metadata`
- [ ] 增量填 `changes_from_previous`
- [ ] 已按 [audience-and-language.md](../../../references/audience-and-language.md) + 本地 [audience-and-language.md](audience-and-language.md) 通过烤干受众维 A/B/C/E
