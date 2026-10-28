# 提取策略与错误处理

## 真源分工

| 决策 | 真源 |
| --- | --- |
| 层职责、首次定义层 | [knowledge-governance.md](../../../knowledge/knowledge-governance.md) |
| 关系字段、允许边 | [entity-relations.md](../../../knowledge/entity-relations.md) |
| 引用边界与跨层链接 | [knowledge-reference-rules.md](../../../knowledge/knowledge-reference-rules.md) |
| 实体 ID 语法 | [naming-conventions.md](../../../knowledge/naming-conventions.md) |
| 实体缩写与别名 | [glossary.md](../../../knowledge/glossary.md) |
| 字段必填性与视角细则 | 当前视角 meta，入口见 [extraction-rules.md](extraction-rules.md) |
| 文件落点 | [knowledge-layout.md](../../../references/knowledge-layout.md)；生成函数 `okf_lib.entity_relpath` |
| frontmatter、正文分段 | [okf-spec.md](../../../knowledge/okf-spec.md) |
| 校验上下文、分项状态与兼容证据 | [knowledge-validation.md](../../../knowledge/knowledge-validation.md) |
| 持久来源、实际目标哈希与事实依赖 | [knowledge-evidence.md](../../../knowledge/knowledge-evidence.md) |

层职责、关系与引用分别按上表真源执行，视角 meta 补充本视角字段。资源使用关系包括 `PD.uses_to MDG|TS`；消费其他 SYS 由消费方 `PD.uses_to SYS` 单边声明，`SYS.used_by` 派生，不要求手工回写。SYS 归属映射仍按关系真源维护，不因多方消费增加 parent。遇到无法判定的冲突先澄清。

## 证据与置信度

| 等级 | 依据 | 落盘规则 |
| --- | --- | --- |
| high | 已读代码、配置或明确的主定义事实 | 达到阈值且必需关系可核实时落盘 |
| medium | 已读文档可支持的推导 | 达到阈值时注明推导依据 |
| low | 间接或不完整依据 | 仅在用户选择 low 且存在可核依据时保留不确定性；不写成已确认事实 |

未读路径、缺父级或无依据的候选，无论阈值均不生成正式实体；列待确认。协议、Topic、Cron 等可选细节缺失不自动判失败。业务正文「依据与证据」只写引用规范允许的链接、资产或本库证据编号；来源版本、实际目标哈希与事实依赖按证据规范登记在治理目录，不强制增加 JSON 或 frontmatter 证据数组。提取报告开关不控制持久证据登记。

## 增量与一致性

- ID 复用优先；按[命名规范](../../../knowledge/naming-conventions.md)核对完整身份：APP 在当前治理联邦内唯一、MS 在 APP 内唯一、API 在 MS 内唯一，其余实体全局唯一。别名不替代身份，宿主歧义先核实。
- 只跳过已核实来源未变的实体。重提时保留人工维护的有效内容，报告变化原因。
- 应维护的反向关系在当前授权范围内则同步；消费方 PD→SYS 的反向按规则派生。范围外核验列依赖，重新确认后处理，不静默改前序批次或上层库。
- README 行来自实体文件；INDEX 只写导航，不维护 §1–§4 实体扫描表。

## 失败处理

| 情形 | 处理 |
| --- | --- |
| 主 INDEX 缺失 | 停止提取，转 docs-indexing |
| 输出路径不明或不可写 | 停止并报告具体路径；不回退到技能安装仓 |
| 当前已确认目录尚不存在 | 在授权路径内创建 |
| ID/别名冲突、必需关系缺失 | 列候选与影响，停止受影响实体；不自动改名 |
| 当前单元部分成功 | 保留成功内容与失败清单，修复后重验，不推进下一批 |
| 旧聚合文件存在 | 仅提示迁移；删除需单独确认 |
