# 知识库构建验收清单

阶段四验收模板。Agent 在执行步骤 4 时复制本清单并逐项勾选。

## 结构验证

- [ ] 目录结构与各 `*_meta.yaml` 的 `directory_patterns` 一致
- [ ] `knowledge/KNOWLEDGE_INDEX.md` 已维护，覆盖本轮涉及的全部视角
- [ ] 各视角 README.md 存在且链接可点

## 策略合规

- [ ] `application_only_policy` 满足（若 `forbid_foreign_template_rows: true`，无非本应用模板 ID 作为唯一内容）
- [ ] 所有 ID 前缀符合 YAML `contains_prefixes` 约定
- [ ] 排除项 `excludes.items` 中的前缀未出现在 INDEX

## 对称性

- [ ] KNOWLEDGE_INDEX 的 §1～§4 同轮维护
- [ ] BC/AGG 联动：已登记 BC/AGG 时，对应段至少有证据行或显式待补充
- [ ] 跨视角引用一致

## 证据链

- [ ] 每个新增 ID 至少有一个可验证证据来源
- [ ] 证据路径为已读文件，非臆测路径

## 未索引项处理

- [ ] 仍存在 `[未索引]` 或高相关未落盘项 → 已展示清单给用户
- [ ] 用户已选择处理方式（多选纳入 / 都不索引 / 混合规则）
- [ ] 处理结果与 CHANGELOG / 主 Index 声明一致

## 变更记录

- [ ] `changelogs/CHANGELOG.md` 包含本轮摘要
- [ ] CHANGELOG 格式与 `changelogs_meta.yaml` 一致

## 导航完整性

- [ ] 主 Index Guide 已更新（若有变更）
- [ ] 联邦实体一行指向 `knowledge/KNOWLEDGE_INDEX.md`
- [ ] 子 README 路径与实际目录匹配
- [ ] 无断裂的交叉引用
