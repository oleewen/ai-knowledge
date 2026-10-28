# docs-build 工作流

每个当前单元依次完成：确认范围、提取实体、同步 README、预检、归并导航、终检、烤干。[gates.md](gates.md) 绑定共享推进协议。

验收以[统一校验规范](../../../knowledge/knowledge-validation.md)为准，结构、确定性关系和必需引用使用共同口径，事实真实性单列。当前工具尚未统一实现；现有命令结果与人工补核分别记录，未执行不当作通过。

## 前置与参数

从目标仓读取 `.docsconfig`，解析文档根、知识层及 Agent 树位置；主 `{DOC_DIR}/INDEX-GUIDE.md` 必须存在。元库 `KNOWLEDGE_TYPE=meta` 时仅以已选定的四层目录确定目标层；其他不明确情况先澄清。

以下是 **Agent 会话选项**，不是实体提取 CLI；仅校验器另支持 `--perspectives`：

| 选项 | 默认 | 行为 |
| --- | --- | --- |
| `--perspectives` | `application,data,business,product` | 可加 technical；按所选视角处理本层实体 |
| `--skip-existing` | `true` | 仅跳过已确认来源未变的实体；来源变更或无法判断时重新核实 |
| `--confidence-threshold` | `medium` | high / medium / low；证据处理见 [builtin-config.md](builtin-config.md) |
| `--emit-report` | `false` | 开启时写当前视角 `extraction_report.md`；关闭不免除持久证据登记 |

用户已明确的选项直接采用；默认值无需逐项追问。只有路径、范围或决策缺口影响结果时才问。技术视角未选中时不自动扩批；本层无实体的视角保留说明，不补造实体。

## 当前单元

1. **写前澄清**：按 gates 列公共六项、预期增删改完整身份、实际路径及 `{DOC_DIR}/governance/evidence/` 证据记录范围。当前单元可按视角、路径组或实体集合划分。
2. **提取与证据准备**：按 [extraction-rules.md](extraction-rules.md) 查询当前视角，默认顺序为应用、数据、业务、产品、技术；仅引用其他批次已有身份，需要修改其他批次时回到范围确认。按[证据规范](../../../knowledge/knowledge-evidence.md)核实来源、目标及已有证据；需要落盘的新版本先登记待落盘记录，不填造目标版本。来源、目标版本及状态均未变化时不重复建记录。
3. **写实体并核验证据**：写入前再次核对来源及待写文件的版本指纹，再保存实体。读取实际文件字节，补齐目标 SHA-256、核验状态及有效依赖承接；新增来源或目标版本按证据规范建立新记录，不能将旧记录直接改成新版本。经授权删除时保留最后核验版本、删除依据及依赖处置结果，不伪造删除后哈希。
4. **同步 README**：遵 [readme-fill-spec.md](readme-fill-spec.md)，实体正文与台账同源。
5. **归并前预检**：执行下列现有结构校验，按统一规范补核身份、逻辑层、确定性关系和必需引用，并独立核对事实证据与授权范围。实体与证据不一致或确认失败先修当前单元，不写导航；工具与现行规则不一致时先逐项核实，不改 ID 或降级规则来消除报错。
6. **归并**：按 [consolidation-spec.md](consolidation-spec.md) 预览并更新层根 INDEX 导航块；工具不能正确排除新治理元数据时停止受影响生成。
7. **终检与烤干**：运行完整模式结构校验，再按 [quality-checklist.md](quality-checklist.md) 核验语义、证据与受众；收敛后停等共享协议的 `C/M/G/S/F`。

任一步部分失败，记录实体、证据和台账的实际状态并停止推进；恢复只限能够证明未被后续编辑的本轮差异，具体遵[证据写入与完成状态](../../../knowledge/knowledge-evidence.md#写入与完成状态)。不假称跨文件事务，实体版本证据未核验一致不交付完成。

先将 `SKILL_DIR` 设为已核实的技能绝对目录，在目标仓执行；`application` 示例应替换为当前确认视角：

```bash
bash "$SKILL_DIR/scripts/validate-extraction.sh" --entities-only --perspectives application
# 按 consolidation-spec 生成导航后：
bash "$SKILL_DIR/scripts/validate-extraction.sh" --perspectives application
```

校验器路径来自 `.docsconfig`；`--entities-only` 跳过导航块检查，完整模式检查当前版标记。现有工具扫描跨视角 ID，但尚未统一支持 MS/API 宿主内身份；其余结构检查限定所选视角。按统一规范记录规则基线、源快照和范围完整性，局部扫描不证明全局唯一或跨库关系完整。可运行现有 docs-okf 与本地链接检查补充证据，仍须核对其覆盖缺口；勿因此自动迁移或刷新目录索引。

## 实体与章节交接

遵守 [实体事实与章节摘要](../../../knowledge/knowledge-governance.md#实体事实与章节摘要)。收到 archive 交接时，读取同一 TODO 的实体、依据、章节与 overview 行；独立核实证据、首次定义层和授权范围，不把 overview 候选直接当事实。按本技能流程更新实体、台账和导航；失败时续写依赖状态，原 overview delta 留给 archive 保持，不写章节或清理 overview。

无论由 archive 发起还是直接修改实体，均在确认范围内通过实体 ID/引用定位受影响章节摘要；范围外或无法核实的引用列为未闭合依赖，不声称全库已同步。成功后的接续：

| 摘要状态 | 交接 |
| --- | --- |
| 已有对应 overview 待归档项 | 交 archive 重读核对后接续章节归档 |
| 只有既有章节摘要需修正，无待归档 overview | 交 docs-revise 定向修订，不伪造 overview 条目 |
| 未发现受影响摘要 | 报告已检查范围与依据，不新增空交接 |

复用 [TODO 协议](../../../references/todo-protocol.md)：发起方登记，接手方续写同一项，记录实体及依据、受影响章节/overview 行、下一动作和依赖；已有项不重复创建。交接不扩展写入授权。实体批次可报告局部完成，但摘要未同步核验、用户未确认前不勾销整项，也不声称链路闭合。

## 交付

报告当前单元实际变更、实体版本证据、分项校验状态及未闭合依赖。未开提取报告时在会话说明增量，不创建全量运行日志或改共享 meta；持久证据登记仍须完成。需要跨库反向边更新但无授权时列待办；消费方 PD→SYS 为单边事实，反向派生不要求手工回写。外库不可读可报告「本地通过、跨库待核实」，相关删除、迁移、注销不得闭环；不擅自写上层库，也不宣称关系已闭环。模板/示例与业务实体分别验收，缺少规则兼容与业务快照核验依据时不宣称升级完成。
