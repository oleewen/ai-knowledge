# docs-build 工作流

主干：[SKILL.md](../SKILL.md)；门禁：[gates.md](gates.md)。

## 术语

**应用知识库**：`.docsconfig` 的 `DOC_DIR` → `{DOC_DIR}/`。

## I/O

| 类型 | 内容 |
|------|------|
| 必需 | 主 Index Guide（否则停，先 `/docs-indexing`） |
| 可选 | README、AGENTS、PRD、源码 |
| 固定输出 | `{DOC_DIR}/knowledge/{p}/{p}_knowledge.json`、`README`、`KNOWLEDGE_INDEX.md` |
| `--emit-report` | `{DOC_DIR}/knowledge/{p}/extraction_report.md` |
| 不产出 | 锚点文档、CHANGELOG、目录树 |

## 参数

| 参数 | 默认 | 说明 |
|------|------|------|
| `--perspectives` | `application,data,business,product` | 逗号分隔 |
| `--skip-existing` | `true` | 未变跳过；变更文件仍重提 |
| `--confidence-threshold` | `medium` | high / medium / low |
| `--emit-report` | `false` | 提取报告 |

## 何时暂停提问

默认不逐项问。仅在：用户改参数或视角、`DOC_DIR` 不明、校验失败要选策略、规则未覆盖 — **每次只澄清一点**。

## 四阶段与 HARD-GATE

| 阶段 | 名称 | 摘要 | 详见 |
|------|------|------|------|
| 1 | 初始化 | INDEX、可写、`builtin-config`；**末 Qclose-1** | [builtin-config.md](builtin-config.md) |
| — | HARD-GATE | [gates.md](gates.md)；`CONFIRMED` 后进 2 | [interaction-gate.md](interaction-gate.md) |
| 2 | 提取 | 四视角固定序；后序只读前序 ID | [extraction-rules.md](extraction-rules.md) |
| 3 | README | 沿用版式，JSON→表行 | [readme-fill-spec.md](readme-fill-spec.md) |
| 4 | 归并 | 四 JSON → 校验 → `KNOWLEDGE_INDEX` | [consolidation-spec.md](consolidation-spec.md) |

### 阶段 2 顺序

| 序 | 视角 | 前缀 | 输入概要 |
|---|------|------|----------|
| 1 | 技术 | SYS/APP/MS/API | INDEX、源码、接口 |
| 2 | 数据 | DS、ENT | INDEX、数据源、实体、Mapper XML |
| 3 | 业务 | BD→AB | INDEX、FQCN、MS-* |
| 4 | 产品 | PL→UC | INDEX、README、PRD、前述 ID |

API：**Dubbo / HTTP / MQ Consumer / Job**，`api_type` 必填。

### 阶段 4 校验

```bash
agent/skills/docs-build/scripts/validate-extraction.sh
```

（仓库根。）

## 核心约束（摘要）

| 约束 | 含义 |
|------|------|
| 证据优先 | ID 有可核来源 |
| 零幻觉 | 仅已读文件 |
| 前缀唯一 | 层级+ID、层级+别名 |
| 对称 | INDEX §1–§4 同轮；README 与 JSON 一致 |
| 幂等 | 可断点续跑 |
| API 四类 | 见上 |
| 边界 | 无锚点/CHANGELOG |

全文：[builtin-config.md](builtin-config.md)。

---

## 命令示例

```bash
/docs-build
/docs-build --perspectives application,data
/docs-build --skip-existing false
/docs-build --confidence-threshold high --emit-report
```
