# docs-tag 工作流（步骤 2–4）

[SKILL.md](../SKILL.md)；步骤 1 [gates.md](gates.md)。

## 参数

| 参数 | 必需 | 默认 | 说明 |
|------|------|------|------|
| `--file` | 是 | — | 目标 MD |
| `--phase` | 是 | — | `1`/交互、`2`、`3`/`excerpt`、`all`；Skill 用 `1-scan`/`1-write`/`2`/`3` |
| `--keywords` | 1/all 时 | — | 种子词，空格分隔 |
| `--scan-dir` | 否 | `docs/architecture/` | 扫目录；公司 `ea` overview 场景用 `company/ea/` |
| `--top-n` | 否 | `30` | Top 候选数 |

Skill：`1-scan` → 列表/JSON → 用户选 → `1-write` → `2` → `3`。勿用 `--phase 1` 的 `input()`（gotchas §7）。

---

## 步骤 2：执行扫描（phase 1 或 all 时）

在仓库根 `{REPO_ROOT}` 执行：

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py \
  --file FILE --phase 1-scan \
  --keywords KW1 KW2 ... \
  --scan-dir SCAN_DIR \
  --top-n TOP_N
```

解析 stdout JSON，以编号列表展示候选词：

```
=== 候选关键词列表（按共现频率排序，Top 30）===

   1. [██████] (42次)  费用类型
   2. [█████ ] (31次)  计费规则
   3. [███   ] (18次)  PolicyType
   ...

输入编号选择（逗号分隔，如 1,3,5），输入 all 全选，输入 q 退出：
```

条形：最高频=6 格，其余按比例，最少 1 格。

---

## 步骤 3：用户选择（phase 1 或 all）

| 输入 | 行为 |
|------|------|
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

---

## 步骤 4：标记（phase 2 或 all）

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py --file FILE --phase 2
```

汇报脚本统计（✅ 行数、跳过行数）。判定章节相关性时**忽略 HTML 注释**（`<!-- … -->`），见 gotchas §6b。

---

## 步骤 5：架构摘录（phase 3 或 excerpt）

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py --file FILE --phase 3
```

从五视角表（`## [业务架构](…)` 等 H2）中副标题列含 ✅ 的行，按固定顺序写入 `## 架构摘录` 三列表。无 ✅ 时写入 `<!-- excerpt:empty -->` 占位行。

汇报摘录行数；**勿手改**摘录表数据行（gotchas §9）。

| 场景 | 要点 |
|------|------|
| 仅 phase 3 | gates → `--phase 3`（或 `excerpt`）；不需 keywords |
| 完整 Skill | `1-scan`→选→`1-write`→`2`→`3` |

## 示例摘要

| 场景 | 要点 |
|------|------|
| 仅 phase 1 | gates → `1-scan` → 选词 → `1-write` |
| 仅 phase 2 | gates → `--phase 2` → 汇报 N✅ / M skip |
| all | gates → `1-scan`→选→`1-write`→`2`→`3`，默认 scan-dir/top-n 已复述 |
