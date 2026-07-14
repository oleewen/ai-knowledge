# docs-indexing 工作流

[SKILL.md](../SKILL.md)；风险控制与动作协议 [gates.md](gates.md)。

## I/O

- 必需：仓库根、`mode`、`depth`（用户确认）
- 可选：`output`、`since`；基线候选为 LOG **主表首行** `indexing_finished_ms`（只展示；HTML 回退见 [indexing-log-spec.md](indexing-log-spec.md)）
- 产出：索引指南（仓库根或各 DOC_DIR 的 `index.md`）、`changelogs/INDEXING-LOG.md`（新行在表顶）
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

参数未收口前，不进入执行。

## 当前单元

一个当前单元就是单个索引输出组，例如：

- 根 `index.md`
- 某个 `DOC_DIR/index.md`
- 单次 `INDEXING-LOG.md` 插入

一次只处理一个当前单元，不并行推进多个输出组。

## 执行循环

### 1 环境与基线

读 `INDEXING-LOG` 主表首行或旧 HTML → **候选** `indexing_finished_ms`（不自动定 mode）。输出可写。[scan-config-onboarding.md](scan-config-onboarding.md) 对齐 DOC_ROOT、基线与输出路径。

### 2 选定当前单元

基于 `output` 与当前批次策略，确定当前只处理一个输出组。

无基线且无 `--since`：请 **full 或中止**；勿静默 full；incremental 无基线脚本 **exit≠0**。

### 3 变更

增量：`docs-change` + 变更列表；full：跳过。

### 4 扫描

[scan-spec.md](scan-spec.md)。depth=3：应读尽读；未读→§八。

```bash
agent/skills/docs-indexing/scripts/indexing.sh --mode <mode> --depth <depth>
```

### 5 质量与自动 grilling

[quality-standards.md](quality-standards.md)。

当前单元写入后，立即做自动 `grilling`：

- 检查覆盖面是否与 `mode/depth` 一致
- 检查路径是否仍正确
- 检查增量基线是否解释充分
- 检查 `INDEXING-LOG` 是否只在索引指南成功后追加

### 6 输出与动作停顿

[nine-chapter-spec.md](nine-chapter-spec.md)，[index-guide-template.md](../assets/index-guide-template.md)。INDEX 落盘后再插 LOG（[indexing-log-spec.md](indexing-log-spec.md)、`indexing_log.py`）。

当前单元收敛后，停下等待 `C/M/G/S/F`：

- `C`：确认当前单元并进入下一个输出组或结束
- `M`：修改参数或路径，再重新 grill
- `G`：继续深挖当前单元
- `S`：暂存当前单元，跳过写入
- `F`：按已确认策略补齐剩余输出组

**OKF 索引（建议，非阻断）**：索引指南落盘后运行：

```bash
python3 agent/skills/docs-okf/scripts/generate_index.py --bundle application --recursive
bash agent/skills/docs-okf/scripts/okf-validate.sh --bundle application
```

九章索引指南（仓库根或各 DOC_DIR 的 `index.md`）与各级 OKF `index.md`（渐进披露）职责分离；见 [docs-okf/references/workflow.md](../../docs-okf/references/workflow.md)。

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
