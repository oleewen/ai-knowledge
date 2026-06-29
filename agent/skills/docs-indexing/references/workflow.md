# docs-indexing 工作流

[SKILL.md](../SKILL.md)；门禁 [gates.md](gates.md)。

## I/O

| 类型 | 内容 |
|------|------|
| 必需 | 仓库根、`mode`、`depth`（用户确认） |
| 可选 | `output`、`since`；基线候选：LOG **主表首行** `indexing_finished_ms`（只展示；HTML 回退 [indexing-log-spec.md](indexing-log-spec.md)） |
| 产出 | 索引指南（仓库根或各 DOC_DIR 的 `index.md`）、`changelogs/INDEXING-LOG.md`（新行在表顶） |
| 不产出 | 知识实体；不改 README/AGENTS；无 CHANGELOG |

## 参数

| 参数 | 必需 | 说明 |
|------|------|------|
| `--mode` | 是 | `full` / `incremental` |
| `--depth` | 是 | `1`/`2`/`3` |
| `--output` | 否 | 默认须展示确认 |
| `--since` | 增量按需 | epoch ms |

详 [scan-spec.md](scan-spec.md)。

---

## 六步

### 1 环境

路径契约：[session-spec-path.md](../../../references/session-spec-path.md)。读 `INDEXING-LOG` 主表首行或旧 HTML → **候选** `indexing_finished_ms`（不自动定 mode）。输出可写。[scan-config-onboarding.md](scan-config-onboarding.md) 对齐 DOC_ROOT/基线/`{DOC_DIR}/superpowers/specs/` 可写。

### 2 配置（HARD-GATE：Qclose-1）

须确认：`mode`、`depth`、`output`、`since`。

```text
参数：mode / depth / output / since — C · M · S
```

**C** 后进 3–6；**C** 后写盘前：spec + `CONFIRMED` + **路径清单**（[gates.md](gates.md)）。预设 [scan-config-onboarding.md](scan-config-onboarding.md)。

无基线且无 `--since`：请 **full 或中止**；勿静默 full；incremental 无基线脚本 **exit≠0**。

### 3 变更

增量：`docs-change` + 变更列表；full：跳过。

### 4 扫描

[scan-spec.md](scan-spec.md)。depth=3：应读尽读；未读→§八。

```bash
agent/skills/docs-indexing/scripts/indexing.sh --mode <mode> --depth <depth>
```

### 5 质量

[quality-standards.md](quality-standards.md)。

### 6 输出

[nine-chapter-spec.md](nine-chapter-spec.md)，[index-guide-template.md](../assets/index-guide-template.md)。INDEX 落盘后再插 LOG（[indexing-log-spec.md](indexing-log-spec.md)、`indexing_log.py`）。

**OKF 索引（建议，非阻断）**：索引指南落盘后运行：

```bash
python3 agent/skills/docs-okf/scripts/generate_index.py --bundle application --recursive
bash agent/skills/docs-okf/scripts/okf-validate.sh --bundle application
```

九章索引指南（仓库根或各 DOC_DIR 的 `index.md`）与各级 OKF `index.md`（渐进披露）职责分离；见 [docs-okf/references/workflow.md](../../docs-okf/references/workflow.md)。

---

## 核心约束

| 约束 | 含义 |
|------|------|
| 双层门禁 | 参数 + 写入 |
| 零幻觉 | 只写已读；未读→§八 |
| 相对路径 | 根相对 |
| 幂等 | 同入同出 |
| 增量 | 结构同 full，合并变更 |
| MECE | 一文件一章 |

---

## 依赖

| | |
|--|--|
| 前置 | docs-change（增量） |
| 下游 | docs-build |
| 关联 | docs-agent |
