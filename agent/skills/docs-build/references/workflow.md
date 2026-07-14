# docs-build 工作流

主干：[SKILL.md](../SKILL.md)。风险控制与动作协议：[gates.md](gates.md)。

## 前置

- 主 Index Guide 可用（否则先 `/docs-indexing`）
- `{DOC_DIR}/knowledge/` 可写
- 若环境未安装 `grilling` Skill，则按 [grilling-skill.md](../../../references/grilling-skill.md) 的 fallback 协议执行

## 术语

**应用知识库**：`.docsconfig` 的 `DOC_DIR` → `{DOC_DIR}/`。

## I/O

| 类型 | 内容 |
| --- | --- |
| 必需 | 主 Index Guide（否则停，先 `/docs-indexing`） |
| 可选 | README、AGENTS、PRD、源码 |
| 固定输出 | `{DOC_DIR}/knowledge/{p}/` 下 per-entity `{ID}.md`、`README`、`KNOWLEDGE_INDEX.md`（扫描生成） |
| `--emit-report` | `{DOC_DIR}/knowledge/{p}/extraction_report.md` |
| 不产出 | 锚点文档、CHANGELOG、目录树 |

## 参数向导

| 参数 | 默认 | 说明 |
| --- | --- | --- |
| `--perspectives` | `application,data,business,product` | 逗号分隔 |
| `--skip-existing` | `true` | 未变跳过；变更文件仍重提 |
| `--confidence-threshold` | `medium` | high / medium / low |
| `--emit-report` | `false` | 提取报告 |

默认不逐项问。仅在：用户改参数或视角、`DOC_DIR` 不明、校验失败要选策略、规则未覆盖 — **每次只澄清一点**。

参数未收口前，不进入执行。

## 当前单元

一个当前单元可以是：

- 单个视角批次
- 单个路径组
- 单批实体集合

一次只处理一个当前单元，不并行推进多个批次。

### 阶段 2 顺序

| 序 | 视角 | 前缀 | 输入概要 |
| --- | --- | --- | --- |
| 1 | 技术 | SYS/APP/MS/API | INDEX、源码、接口 |
| 2 | 数据 | DS、ENT | INDEX、数据源、实体、Mapper XML |
| 3 | 业务 | BD→AB | INDEX、FQCN、MS-* |
| 4 | 产品 | PL→UC | INDEX、README、PRD、前述 ID |

API：**Dubbo / HTTP / MQ Consumer / Job**，`api_type` 必填。

## 执行循环

```mermaid
flowchart TD
    A["参数向导收口"] --> B["选定当前单元"]
    B --> C["按 extraction-rules 提取实体"]
    C --> D["按 readme-fill-spec 更新 README"]
    D --> E["按 consolidation-spec 归并 KNOWLEDGE_INDEX"]
    E --> F["运行 validate-extraction.sh"]
    F --> G{"校验是否通过"}
    G -->|否| H["停止并澄清策略"]
    G -->|是| I["自动 grilling"]
    H --> I
    I --> J["等待 C/M/G/S/F"]
```

## 校验

```bash
agent/skills/docs-build/scripts/validate-extraction.sh
```

若校验失败：

- 当前单元停止
- 不得继续写后续批次
- 必须先澄清修复策略或改参数

## 核心约束（摘要）

| 约束 | 含义 |
| --- | --- |
| 证据优先 | ID 有可核来源 |
| 零幻觉 | 仅已读文件 |
| 前缀唯一 | 层级+ID、层级+别名 |
| 对称 | INDEX §1–§4 同轮；README 与 per-entity 一致 |
| 幂等 | 可断点续跑 |
| API 四类 | 见上 |
| 边界 | 无锚点/CHANGELOG |

全文：[builtin-config.md](builtin-config.md)。

## 命令示例

```bash
/docs-build
/docs-build --perspectives application,data
/docs-build --skip-existing false
/docs-build --confidence-threshold high --emit-report
```
