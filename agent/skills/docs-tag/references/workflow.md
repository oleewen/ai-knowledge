# docs-tag 工作流（步骤 2～4）

[SKILL.md](../SKILL.md) 为主干；步骤 1 见 [gates.md](gates.md)。

---

## 参数表

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--file` | 是 | — | 目标文件路径（待标记的 Markdown 文档） |
| `--phase` | 是 | — | 执行阶段：`1`=关键词扩展（终端交互）、`2`=表格标记、`all`=两阶段连续执行 |
| `--keywords` | phase 1/all 时是 | — | 种子关键词（空格分隔，可多个） |
| `--scan-dir` | 否 | `docs/architecture/` | 候选词扫描目录 |
| `--top-n` | 否 | `30` | 候选词展示数量上限（正整数） |

**Skill 自动化路径**：使用 `1-scan` → 展示 JSON/列表 → 用户选择 → `1-write` → `2`。不要使用 `--phase 1` 的 `input()` 交互（见 `gotchas.md` §7）。

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

条形图归一化规则：最高频次对应 6 格，其余按比例取整（最少 1 格）。

---

## 步骤 3：用户选择（phase 1 或 all 时）

| 输入 | 行为 |
|------|------|
| 编号（如 `1,3,5`） | 收集对应词语，调用 `1-write` 写入 |
| `all` | 选中全部候选词，调用 `1-write` 写入 |
| `q` | 告知已退出，不写入任何关键词 |
| 编号超出范围 | 提示错误，要求重新输入 |
| 候选词列表为空 | 告知未找到相关候选词，建议调整种子关键词 |

写入命令（在 `{REPO_ROOT}` 执行）：

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py \
  --file FILE --phase 1-write \
  --keywords KW1 KW2 ... \
  --selected TERM1,TERM2,...
```

---

## 步骤 4：执行标记（phase 2 或 all 时）

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py \
  --file FILE --phase 2
```

汇报脚本输出的统计信息（标记行数、跳过行数）。

---

## 使用示例

**示例 1：仅执行阶段 1（扫描关键词并写入）**

```
用户：帮我标记 docs/architecture/overview/spec-overview.md，关键词是计费和费用类型
```

Skill 确认 `--phase` 为 `1`，`--scan-dir` 和 `--top-n` 使用默认值后，调用 `1-scan` 展示候选词列表，用户选择后调用 `1-write` 写入 YAML 附录。

---

**示例 2：仅执行阶段 2（根据已有关键词标记表格）**

```
用户：对 docs/architecture/overview/spec-overview.md 执行阶段2标记
```

Skill 确认 `--phase` 为 `2`，直接调用脚本执行标记，汇报「标记 N 行 ✅，跳过 M 行」。

---

**示例 3：两阶段连续执行**

```
用户：/docs-tag --file docs/architecture/overview/spec-overview.md --phase all --keywords 计费 结算
```

Skill 确认 `--scan-dir` 和 `--top-n` 默认值后，依次执行扫描 → 用户选择 → 写入 → 标记，全程无需再次询问文件路径和关键词。
