# docs-tag 工作流

[SKILL.md](../SKILL.md)；风险控制与动作协议 [gates.md](gates.md)。  
动作字母：[light-flow-actions.md](../../../references/light-flow-actions.md)（`C/M/S/F`，无 `G`）。

## 前置

- `--file` 须存在（系统/公司 overview，见 [knowledge-layout.md](../../../references/knowledge-layout.md)）
- phase 含 1 时 keywords 齐备；Skill 用 `1-scan`+`1-write`+`2`+`3`
- 脚本路径：`agent/skills/docs-tag/scripts/keyword_tag.py`（仓库根执行）

## 参数

| 参数 | 必需 | 默认 | 说明 |
| ---- | ---- | ---- | ---- |
| `--file` | 是 | — | 目标 MD |
| `--phase` | 是 | — | `1`/交互、`2`、`3`/`excerpt`、`all`；Skill 用 `1-scan`/`1-write`/`2`/`3` |
| `--keywords` | 1/all 时 | — | 种子词，空格分隔 |
| `--scan-dir` | 否 | `system/knowledge/` | 扫目录；公司 overview 用 `company/knowledge/` |
| `--top-n` | 否 | `30` | Top 候选数 |

## 参数向导

按以下顺序收口参数；用户已明确时可跳过对应项：

1. `--file`
2. `--phase`
3. `--keywords`（phase 含 `1` 或 `all` 时）
4. `--scan-dir`
5. `--top-n`

参数未收口前，不进入执行。

## 当前单元

一个当前单元就是单个 overview 文件。

一次只处理一个当前单元，不并行推进多个 overview 文件。phase 只是当前单元内部子阶段，不是独立当前单元。

## 轻量校核（非 grilling）

每个 phase 结果后，用短摘要做检查点即可，**不**调用 grilling Skill / unit-cycle 烤干：

- 汇报脚本关键统计（候选数、✅ 行数、摘录行数等）
- 对照 [gates.md](gates.md) 风险项：明显越义、缺附录、参数是否仍合适
- 若触及语义风险：给结论、推荐与数字选项，确认后再继续

## 执行循环

### 1 选定当前单元

基于 `--file` 确定本轮只处理一个 overview 文件。

### 2 执行 phase 1-scan（phase 1 或 all 时）

在仓库根 `{REPO_ROOT}` 执行：

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py \
  --file FILE --phase 1-scan \
  --keywords KW1 KW2 ... \
  --scan-dir SCAN_DIR \
  --top-n TOP_N
```

解析 stdout JSON，以编号列表展示候选词：

```text
=== 候选关键词列表（按共现频率排序，Top 30）===

   1. [██████] (42次)  费用类型
   2. [█████ ] (31次)  计费规则
   3. [███   ] (18次)  PolicyType
   ...
```

**轻量校核**：种子词是否够用；候选是否需缩窄/扩展；`scan-dir`、`top-n` 是否仍合适。

### 3 用户选择并执行 phase 1-write（phase 1 或 all 时）

| 输入 | 行为 |
| ---- | ---- |
| `1,3,5` 等 | 对应词 → `1-write` |
| `all` | 全选 → `1-write` |
| `q` | 退出，不写 |
| 越界 | 重输 |
| 空列表 | 提示调种子词 |

写入命令（在 `{REPO_ROOT}` 执行）：

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py \
  --file FILE --phase 1-write \
  --keywords KW1 KW2 ... \
  --selected TERM1,TERM2,...
```

**轻量校核**：附录是否幂等；候选是否明显越义；是否继续 phase 2 或回调参数。

### 4 执行 phase 2（phase 2 或 all 时）

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py --file FILE --phase 2
```

汇报脚本统计（✅ 行数、跳过行数）。判定章节相关性时**忽略 HTML 注释**（`<!-- … -->`），见 gotchas §6b。

**轻量校核**：✅ 是否过宽/过窄；无附录是否应先回 phase 1；是否适合继续 phase 3。

### 5 执行 phase 3（phase 3 / excerpt 或 all 时）

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py --file FILE --phase 3
```

从五视角表（`## [业务架构](…)` 等 H2）中副标题列含 ✅ 的行，按固定顺序写入 `## 架构摘录` 三列表。无 ✅ 时写入 `<!-- excerpt:empty -->` 占位行。

汇报摘录行数；**勿手改**摘录表数据行（gotchas §9）。

**轻量校核**：摘录是否与 ✅ 一致；无 ✅ 时是否正确空占位；当前单元是否可视为收敛。

### 6 输出与动作停顿

当前单元收敛后，停下等待 `C/M/S/F`：

- `C`：确认当前单元并结束或进入下一 overview 文件
- `M`：修改参数或 phase 策略后重跑
- `S`：跳过当前单元写入，或保留当前结果但不继续后续 phase
- `F`：按已确认参数补齐剩余 overview 文件

加深候选词/表行/摘录：`M` 或口述下一 phase；**无 `G`**。

## 示例摘要

| 场景 | 要点 |
| ---- | ---- |
| 仅 phase 1 | 参数向导 → `1-scan` → 轻量校核 → 选词 → `1-write` → 轻量校核 |
| 仅 phase 2 | 参数向导 → `--phase 2` → 轻量校核 → 汇报 N✅ / M skip |
| all | 参数向导 → `1-scan` → 校核 → `1-write` → 校核 → `2` → 校核 → `3` → 校核 → `C/M/S/F` |
