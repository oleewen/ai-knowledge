# docs-agent 工作流

[SKILL.md](../SKILL.md) 为主干；步骤 0 与参数确认书见 [gates.md](gates.md)。

---

## 输入与输出

| 类型   | 内容                                                |
| ------ | --------------------------------------------------- |
| 硬输入  | 落盘 INDEX（§1 解析）；无落盘 Index 不编造                     |
| 可选输入 | 用户目标（新建/增量）、`--output` 范围（readme / agents / both） |
| 固定输出 | `{REPO_ROOT}` 下 `README.md`、`AGENTS.md`           |
| 不产出  | 不替代 Index Guide；不把 Index 全文合并进 AGENTS             |

---

## 参数

| 参数         | 必需 | 默认值      | 说明                            |
| ------------ | ---- | ----------- | ------------------------------- |
| `--output`   | 否   | `both`      | `readme` / `agents` / `both`    |
| `--mode`     | 否   | `update`    | `create`（初始化）或 `update`（增量合并） |

---

## 步骤 1：Index 解析

先 `source` `agent/scripts/config-bootstrap.sh` 并执行 `validate_bootstrap_docsconfig`（传入本技能 `scripts/` 目录），从 `.docsconfig` 得到 **`REPO_ROOT`**、**`DOC_ROOT`**，以及可选的 **`AGENT_ROOT`** / **`AGENT_DIRS`**。

```bash
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
source "$REPO_ROOT/agent/scripts/config-bootstrap.sh"
validate_bootstrap_docsconfig "$REPO_ROOT/agent/skills/docs-agent/scripts"
DOC_ROOT="$(resolve_repo_doc_root)"
```

按优先级查找落盘 Index Guide，命中即停，记录实际相对路径：

1. `REPO_ROOT` 下 `INDEX_GUIDE.md`、`INDEX-GUIDE.md`
2. `DOC_ROOT` 下 `INDEX_GUIDE.md`、`INDEX-GUIDE.md`

未命中 → 终止，提示用户先运行 `/docs-indexing`。详细规则与降级例外见 [execution-spec.md](execution-spec.md)。

---

## 步骤 2：最小阅读集探索

以 INDEX 为地图，只打开与「README 首屏 / AGENTS 契约」直接相关的文件。各章节用途：

| INDEX 章节 | 用途          | 写入去向                                     |
| ---------- | ------------- | -------------------------------------------- |
| §1 元信息  | 技术栈、入口、命令 | README 简介 + Quick start；AGENTS ≤3 行 + 指针 |
| §2 拓扑    | 目录边界、依赖方向 | README 目录树（唯一详写处）；AGENTS 短列表   |
| §3 API 入口 | 按需打开 ⭐⭐⭐ 条目 | 不粘贴进 AGENTS；一句指向 INDEX §3          |
| §6 未索引  | 盲区          | 须描述某路径时只补读该路径；否则「详见 INDEX §6」 |

禁止为写 AGENTS 通读全仓。

---

## 步骤 3：生成 README

按 [../assets/readme-skeleton.md](../assets/readme-skeleton.md) 骨架生成。合格线：新读者 30 秒内知道「是什么、下一步点哪」；相对路径可点、表格不空洞；目录树与 INDEX §2 一致。

---

## 步骤 4：生成 AGENTS

按 [../assets/agents-skeleton.md](../assets/agents-skeleton.md) 骨架生成。三文件去重规则见 [three-file-spec.md](three-file-spec.md)。AGENTS 项目概述 ≤3 行，命令块只在 README，AGENTS 用指针。

---

## 步骤 5：验证

```bash
bash agent/skills/docs-agent/scripts/validate-guide.sh --root .
```

完整验收清单与反模式见 [quality-standards.md](quality-standards.md)。

---

## 核心约束（摘要）

| 约束                | 说明                                         |
| ------------------- | -------------------------------------------- |
| 零幻觉               | 无落盘 INDEX 不编造结构；未读路径不写成已核实结论 |
| 意图未清不落盘       | 符合 [gates.md](gates.md) 澄清路径时，确认前不写 README/AGENTS |
| 单一事实源           | 命令块只在 README；AGENTS 概述 ≤3 行；不复制 INDEX §3 表 |
| 先 README 后 AGENTS | 避免命令块在两处重复                         |
| INDEX 只读          | 禁止在本 Skill 内调用 docs-indexing 或重做索引 |
| 合并优先             | `--mode update` 时合并重复段落，保留有效表格/命令块 |
