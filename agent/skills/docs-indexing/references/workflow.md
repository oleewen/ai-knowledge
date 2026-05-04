# docs-indexing 工作流

[SKILL.md](../SKILL.md) 为主干；门禁与路径证据见 [gates.md](gates.md)。

---

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 代码库根目录、用户确认的扫描模式（full/incremental）、用户确认的扫描深度（1/2/3） |
| 可选输入 | 输出路径、增量起始时间；候选基线可从 `changelogs/INDEXING-LOG.md` **主表第一行** `indexing_finished_ms` 读取（仅作展示；迁移期可提及 HTML 回退，见 [indexing-log-spec.md](indexing-log-spec.md)） |
| 固定输出 | `DOC_ROOT/INDEX_GUIDE.md`（九章结构）、`changelogs/INDEXING-LOG.md`（主表插入一行，**最新在上**） |
| 不产出 | 不生成知识实体 ID、不修改 README/AGENTS、不产出 CHANGELOG |

---

## 参数

| 参数 | 必需 | 说明 |
|------|------|------|
| `--mode` | 是 | 用户确认：`f`/`full` 或 `i`/`incremental` |
| `--depth` | 是 | 用户确认：`1`（拓扑）、`2`（结构）、`3`（精读） |
| `--output` | 否 | 输出路径；若使用默认值须向用户展示并确认 |
| `--since` | 增量时视情况 | 增量起始时间（epoch ms）；可从日志读取候选值展示，以用户确认为准 |

深度级别与模式的详细定义见 [scan-spec.md](scan-spec.md)。

---

## 六步流程

### 步骤 1：环境准备

读取 `changelogs/INDEXING-LOG.md`（若存在）主表第一行，或回退为文内旧 HTML 注释，提取**候选** `indexing_finished_ms`——仅作展示，不能据此自动锁定模式。验证输出路径可写。

建议按 [scan-config-onboarding.md](scan-config-onboarding.md) 的「上下文探索」核对仓库事实（DOC_ROOT 位置、是否有有效基线），以便步骤 2 给出准确建议。

### 步骤 2：扫描配置（HARD-GATE：参数 Qclose-1）

**在进入步骤 3 之前，必须获得用户对以下参数的明确确认（Qclose-1）：**

- `mode`：`full` 或 `incremental`
- `depth`：`1`、`2` 或 `3`
- `--output`（若使用默认值，须展示路径请用户确认）
- `--since`（增量时，须展示候选值请用户确认，或用户显式给出）

**参数确认书格式**（会话内）：

```text
即将执行 /docs-indexing，参数如下：
- mode: <full|incremental>
- depth: <1|2|3>
- output: <路径>
- since: <时间或 N/A>

C 确认执行 / M 修改参数 / S 跳过
```

收到 **C** 后方可继续编排步骤 3～6；**S** 表示跳过本轮写入。在收到 **C** 后、执行任何受管路径 `Write` / `StrReplace` 之前，须完成 [gates.md](gates.md) 所述**落盘会话 spec**（`…-docs-indexing.md`）及 `docs-indexing-gate` **CONFIRMED**，且 spec 正文须列出本轮将写入的**完整仓库根相对路径**（供钩子校验）。

**推荐做法**：一条消息列出待确认项并附便捷预设（如 full+1、incremental+2）；用户选定预设后仍须复述完整参数。话术见 [scan-config-onboarding.md](scan-config-onboarding.md)。

**增量前提不满足时**（`INDEXING-LOG.md` 主表/回退均无法得到有效 `indexing_finished_ms` 且用户未给 `--since`）：说明情况，请用户确认改走全量或中止，**不得**静默自动全量；`scripts/indexing.sh` 在 incremental 且无基线时**非 0 退出**。

### 步骤 3：变更分析

调用 `docs-change` 技能生成变更索引；解析变更文件列表，建立扫描路径集。全量模式跳过变更过滤。

### 步骤 4：执行扫描

按用户确认的深度扫描。规则见 [scan-spec.md](scan-spec.md)。

**深度 3**：在排除规则内系统遍历可读文件，尽量读全；未读路径归 §八。不能以「仓库过大」为由抽样跳读。

辅助脚本（参数须与用户确认值一致）：

```bash
agent/skills/docs-indexing/scripts/indexing.sh --mode <mode> --depth <depth>
```

（从仓库根执行时路径以实际为准。）

### 步骤 5：质量验证

按 [quality-standards.md](quality-standards.md) 验证：结构完整性、信息密度、准确度、交叉引用。

### 步骤 6：输出生成

按 [nine-chapter-spec.md](nine-chapter-spec.md) 生成；模板见 [../assets/index-guide-template.md](../assets/index-guide-template.md)；`INDEX_GUIDE` 成功落盘后，向 `changelogs/INDEXING-LOG.md` 主表**插入**一行（**最新在上**；见 `scripts/indexing_log.py` 与 [indexing-log-spec.md](indexing-log-spec.md)）。

---

## 核心约束（执行摘要）

| 约束 | 原因 |
|------|------|
| 参数 + 写入双层门禁 | 成本/范围与受管产物完整性 |
| 零幻觉 | 只索引实际读取的内容；未读路径标注 `[未索引]` 归 §八 |
| 路径精确 | 使用项目根相对路径，确保链接可点击 |
| 幂等性 | 相同输入产出一致结果 |
| 增量一致性 | 增量与全量结构一致；只合并变更条目 |
| MECE | 每文件归入一个最匹配章节，交叉引用用超链接 |

---

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 前置 | `docs-change` | `CHANGE-LOG.md`；增量依赖变更文件列表 |
| 下游 | `docs-build` | 以主 INDEX 为提取证据来源 |
| 关联 | `docs-agent` | README / AGENTS 与 INDEX 交叉引用 |
