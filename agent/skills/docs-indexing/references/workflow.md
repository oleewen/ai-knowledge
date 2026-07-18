# docs-indexing 工作流

[SKILL.md](../SKILL.md)；推进 binding [gates.md](gates.md)。

契约：

- 写前澄清：[intent-clarify.md](../../../references/intent-clarify.md)
- 单元推进 / `C/M/G/S/F`：[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)
- 写后烤干：[grilling-skill.md](../../../references/grilling-skill.md)

## I/O

- 必需：仓库根、`mode`、`depth`（用户确认）
- 可选：`output`、`since`；基线候选为 LOG **主表首行** `indexing_finished_ms`（只展示；HTML 回退见 [indexing-log-spec.md](indexing-log-spec.md)）
- 产出：索引指南（仓库根或各 DOC_DIR 的 `INDEX-GUIDE.md`）、`changelogs/INDEXING-LOG.md`（新行在表顶）
- 不产出：知识实体；不改 README/AGENTS；无 CHANGELOG

## 参数

- `--mode`：必需；`full` / `incremental`
- `--depth`：必需；`1` / `2` / `3`
- `--output`：可选；默认值也须展示确认
- `--since`：增量按需；epoch ms

详 [scan-spec.md](scan-spec.md)。

## 参数向导

按序收口；用户已明确时可跳过对应项：

1. `mode`
2. `depth`
3. `output`
4. `since` 或基线策略

**输出根 `{DOC_DIR}`**：优先 `.docsconfig` 的 `DOC_DIR=`；无配置或无效时默认为 `docs`（见 [session-spec-path.md](../../../references/session-spec-path.md)）。

参数未收口前，不进入单元推进。

## 当前单元

单个索引输出组（INDEX-GUIDE + 对应 INDEXING-LOG）。一次只处理一个。定义与路径约束见 [gates.md](gates.md)。

## 写后默认表

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 单个索引输出组（INDEX-GUIDE + INDEXING-LOG） | **必须** | 导航路径/索引路径变更；未确认决策写入；跨单元依赖变更 |

启发式只可升级为必须，不可把默认「必须」降为跳过。

## 技能步骤

推进环（澄清 → 生成 → 烤干 → 用户动作）见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)；本技能只补索引特有步骤：

1. 选定当前单元（单个输出组）
2. **意图澄清**：公共六项 + [gates.md](gates.md) 追加字段；第 6 项须列出本轮 `INDEX-GUIDE.md` 与 `*/changelogs/INDEXING-LOG.md` 的**完整仓库根相对路径**；写前 `C` 后方可写入
3. 环境与基线：读 `INDEXING-LOG` 主表首行或旧 HTML → 候选 `indexing_finished_ms`。[scan-config-onboarding.md](scan-config-onboarding.md) 对齐 DOC_ROOT、基线与输出路径
4. 增量：`docs-change` + 变更列表；full：跳过
5. 扫描：[scan-spec.md](scan-spec.md)；depth=3：应读尽读；未读→§八

```bash
agent/skills/docs-indexing/scripts/indexing.sh --mode <mode> --depth <depth>
```

6. 生成并写入：按 [nine-chapter-spec.md](nine-chapter-spec.md)、[index-guide-template.md](../assets/index-guide-template.md) 写入 `INDEX-GUIDE.md`；成功后插 LOG（[indexing-log-spec.md](indexing-log-spec.md)、`indexing_log.py`）
7. **烤干**：按写后默认表；检查覆盖面与 `mode/depth`、路径、增量基线解释、`INDEXING-LOG` 是否仅在指南成功后追加
8. 用户动作：`C/M/G/S/F` 见 unit-cycle-protocol

**OKF 索引（建议，非阻断）**：索引指南落盘后：

```bash
python3 agent/skills/docs-okf/scripts/generate_index.py --bundle application --recursive
bash agent/skills/docs-okf/scripts/okf-validate.sh --bundle application
```

九章索引指南与各级 OKF `index.md` 职责分离；见 [docs-okf/references/workflow.md](../../docs-okf/references/workflow.md)。

## 核心约束

- 单单元推进：一次只处理一个输出组
- 零幻觉：只写已读；未读→§八
- 相对路径：根相对
- 幂等：同入同出
- 增量：结构同 full，合并变更
- MECE：一文件一章

## 依赖

- 前置：docs-change（增量）
- 下游：docs-build
- 关联：docs-agent
