# docs-indexing 工作流

[SKILL.md](../SKILL.md)；推进协议 [gates.md](gates.md)。

契约分工：

- 写前**意图澄清**：[intent-clarify.md](../../../references/intent-clarify.md)
- 写后**烤干** `grilling`：[grilling-skill.md](../../../references/grilling-skill.md)

本文只定义二者在 `docs-indexing` Unit Cycle 中的 binding。

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

按以下顺序收口参数；用户已明确时可跳过对应项：

1. `mode`
2. `depth`
3. `output`
4. `since` 或基线策略

参数未收口前，不进入 Unit Cycle。

## 当前单元

一个当前单元就是单个索引输出组，例如：

- 根 `INDEX-GUIDE.md` + 根 `changelogs/INDEXING-LOG.md`
- 某个 `DOC_DIR/INDEX-GUIDE.md` + `{DOC_DIR}/changelogs/INDEXING-LOG.md`

一次只处理一个当前单元，不并行推进多个输出组。

## Unit Cycle（澄清 → 生成 → 烤干）

### 写后默认表

`docs-indexing`：**各索引输出组默认必须烤干**（启发式只可升级、不可降级跳过）。

强制升级（本就默认必须，仍须显式标注）：

- 本轮改导航路径、索引路径或 `output` 指向
- 实体 ID、跨单元依赖或前文前提变更（若索引内容牵涉）
- 未确认决策写入正文

### 固定循环

1. 选定当前单元（单个输出组）
2. **意图澄清**：输出公共六项清单，标明「当前阶段：意图澄清」
   - 第 6 项须列出本轮将写入的**仓库根相对路径**：`INDEX-GUIDE.md` 与 `changelogs/INDEXING-LOG.md`
   - 可追加技能字段：`mode/depth`、增量基线、扫描范围摘要
   - 有缺口则一问一答；用户写前 `C` 后方可写入
3. 环境与基线：读 `INDEXING-LOG` 主表首行或旧 HTML → 候选 `indexing_finished_ms`。[scan-config-onboarding.md](scan-config-onboarding.md) 对齐 DOC_ROOT、基线与输出路径
4. 增量：`docs-change` + 变更列表；full：跳过
5. 扫描：[scan-spec.md](scan-spec.md)；depth=3：应读尽读；未读→§八

```bash
agent/skills/docs-indexing/scripts/indexing.sh --mode <mode> --depth <depth>
```

6. 生成并写入：按 [nine-chapter-spec.md](nine-chapter-spec.md)、[index-guide-template.md](../assets/index-guide-template.md) 写入 `INDEX-GUIDE.md`；成功后插 LOG（[indexing-log-spec.md](indexing-log-spec.md)、`indexing_log.py`）
7. **烤干**：对当前单元执行自动 `grilling` 直到收敛；标明「当前阶段：烤干」
   - 检查覆盖面是否与 `mode/depth` 一致
   - 检查路径是否仍正确
   - 检查增量基线是否解释充分
   - 检查 `INDEXING-LOG` 是否只在索引指南成功后追加
8. 若打出语义性问题，暂停等待用户确认
9. 当前单元收敛后，用户用 `C/M/G/S/F` 做写后动作选择

**OKF 索引（建议，非阻断）**：索引指南落盘后运行：

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
