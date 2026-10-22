# docs-build 工作流

每个当前单元依次完成：确认范围、提取实体、同步 README、预检、归并导航、终检、烤干。[gates.md](gates.md) 绑定共享推进协议。

## 前置与参数

从目标仓读取 `.docsconfig`，解析文档根、知识层及 Agent 树位置；主 `{DOC_DIR}/INDEX-GUIDE.md` 必须存在。元库 `KNOWLEDGE_TYPE=meta` 时仅以已选定的四层目录确定目标层；其他不明确情况先澄清。

以下是 **Agent 会话选项**，不是实体提取 CLI；仅校验器另支持 `--perspectives`：

| 选项 | 默认 | 行为 |
| --- | --- | --- |
| `--perspectives` | `application,data,business,product` | 可加 technical；按所选视角处理本层实体 |
| `--skip-existing` | `true` | 仅跳过已确认来源未变的实体；来源变更或无法判断时重新核实 |
| `--confidence-threshold` | `medium` | high / medium / low；证据处理见 [builtin-config.md](builtin-config.md) |
| `--emit-report` | `false` | 开启时写当前视角 `extraction_report.md` |

用户已明确的选项直接采用；默认值无需逐项追问。只有路径、范围或决策缺口影响结果时才问。技术视角未选中时不自动扩批；本层无实体的视角保留说明，不补造实体。

## 当前单元

1. **写前澄清**：按 gates 列公共六项、预期增删改 ID 与实际路径。当前单元可按视角、路径组或实体集合划分。
2. **提取**：按 [extraction-rules.md](extraction-rules.md) 查询当前视角。默认顺序为应用、数据、业务、产品、技术；仅引用其他批次已有 ID，需要修改其他批次时回到范围确认。
3. **同步 README**：遵 [readme-fill-spec.md](readme-fill-spec.md)，实体正文与台账同源。
4. **归并前预检**：执行下列结构校验，并人工核对证据、关系与授权范围。失败先修当前单元，不写导航。
5. **归并**：按 [consolidation-spec.md](consolidation-spec.md) 预览并更新层根 INDEX 导航块。
6. **终检与烤干**：运行完整模式结构校验，再按 [quality-checklist.md](quality-checklist.md) 核验语义与受众；收敛后停等共享协议的 `C/M/G/S/F`。

先将 `SKILL_DIR` 设为已核实的技能绝对目录，在目标仓执行；`application` 示例应替换为当前确认视角：

```bash
bash "$SKILL_DIR/scripts/validate-extraction.sh" --entities-only --perspectives application
# 按 consolidation-spec 生成导航后：
bash "$SKILL_DIR/scripts/validate-extraction.sh" --perspectives application
```

校验器路径来自 `.docsconfig`；`--entities-only` 跳过导航块检查，完整模式检查当前版标记。跨视角重复 ID 始终检查；其余结构检查限定所选视角。完整 OKF 引用校验可按现有 docs-okf 校验入口执行，勿因此自动迁移或刷新目录索引。

## 交付

报告当前单元实际变更、校验结果及未闭合依赖。未开报告时在会话说明增量，不创建强制日志或改共享 meta。需要跨库反向边更新但无授权时列待办，不擅自写上层库，也不宣称关系已闭环。
