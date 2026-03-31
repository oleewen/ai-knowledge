# 质量验证清单

knowledge-build 提取完毕后的自查清单。阶段 3 归并完成后逐项核对。

---

## 初始化

- [ ] 主 Index Guide 已落盘且可用

## 提取顺序与结构

- [ ] 四视角按技术 → 数据 → 业务 → 产品顺序执行
- [ ] 技术视角 `entities` 为分类对象，其余三视角为扁平数组

## API 四类入口覆盖

- [ ] API 层级覆盖 Dubbo、HTTP、MQ Consumer、Job 四类入口
- [ ] 每条 API 含 `api_type`（`DUBBO` / `HTTP` / `MQ_CONSUMER` / `JOB`）
- [ ] 仅提取 Dubbo Provider 端，未混入 Consumer 引用
- [ ] MQ Consumer 按 Tag 拆分为独立 API（多 Tag 场景）
- [ ] Job 含 `job_handler` 名称
- [ ] MQ/Job 入口均关联到 MS-ID

## 实体质量

- [ ] 每个实体含完整 `evidence_chain`，无无证据写入
- [ ] MS-ID 按宿主类聚类，非 Maven 模块名
- [ ] 同一物理表只有一个 ENT-ID
- [ ] AGG-ID 均有对应 MS-* 服务
- [ ] FT/UC-ID 均绑定至少一个 API-ID

## 归并与索引

- [ ] 所有 ID 前缀在 `contains_prefixes` 范围内
- [ ] `KNOWLEDGE_INDEX.md` §1～§4 同轮维护，无模板占位行
- [ ] 已有 ID 未被单独改名（跨视角引用完整）

## metadata 完整性

- [ ] 每个 `*_knowledge.json` 含完整 `metadata` 节
- [ ] 增量提取已填写 `changes_from_previous`
