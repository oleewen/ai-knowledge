# docs-build 工作流

主干：[SKILL.md](../SKILL.md)。推进 binding：[gates.md](gates.md)。

契约：

- 写前澄清：[intent-clarify.md](../../../references/intent-clarify.md)
- 单元推进 / `C/M/G/S/F`：[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)
- 写后烤干：[grilling-skill.md](../../../references/grilling-skill.md)

## 前置

- 主 Index Guide 可用（否则先 `/docs-indexing`）
- `{DOC_DIR}/knowledge/` 可写
- 若环境未安装 `grilling` Skill，则按 [grilling-skill.md](../../../references/grilling-skill.md) fallback

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

参数未收口前，不进入单元推进。

## 当前单元

视角批次 / 路径组 / 实体批次；一次一个。定义见 [gates.md](gates.md)。

### 视角顺序

| 序 | 视角 | 前缀 | 输入概要 |
| --- | --- | --- | --- |
| 1 | 技术 | SYS/APP/MS/API | INDEX、源码、接口 |
| 2 | 数据 | DS、ENT | INDEX、数据源、实体、Mapper XML |
| 3 | 业务 | BD→AB | INDEX、FQCN、MS-* |
| 4 | 产品 | PL→UC | INDEX、README、PRD、前述 ID |

API：**Dubbo / HTTP / MQ Consumer / Job**，`api_type` 必填。

## 写后默认表

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 单个视角批次 / 路径组 / 实体批次 | **必须** | 实体 ID 变更或重命名；未确认决策写入；跨批次依赖变更 |

启发式只可升级为必须，不可把默认「必须」降为跳过。

## 技能步骤

推进环见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)；本技能只补提取特有步骤：

1. 选定当前单元
2. **意图澄清**：公共六项 + [gates.md](gates.md) 追加字段；第 6 项写明批次类型与 `{DOC_DIR}/knowledge/` 下仓库根相对路径；写前 `C` 后方可写入
3. 按 [extraction-rules.md](extraction-rules.md) 提取实体
4. 按 [readme-fill-spec.md](readme-fill-spec.md) 更新 README
5. 按 [consolidation-spec.md](consolidation-spec.md) 归并 KNOWLEDGE_INDEX
6. 运行校验：

```bash
agent/skills/docs-build/scripts/validate-extraction.sh
```

7. **烤干**：按写后默认表；校验失败则当前单元停止，不得继续后续批次，须先澄清修复策略或改参数
8. 用户动作：`C/M/G/S/F` 见 unit-cycle-protocol

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
