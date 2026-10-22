# sdx-test 核心约定

## 库类型与落点

`.docsconfig` 及 [knowledge-layout.md](../../../references/knowledge-layout.md) 决定文档根。

| `KNOWLEDGE_TYPE` | TDD 落点 |
| --- | --- |
| `system` | 系统库 `requirements/`；按本系统需求、集成与影响面设计测试 |
| `application` 或未设置 | 应用库 `requirements/`；按本应用需求与实现契约设计测试 |
| `solution` / `company` | 本层无 `requirements/`；先定位承接的系统或应用库，不新建错误阶段目录 |

用户目标与配置冲突时确认实际库，不静默改配置。只读校验点名文件不改变其落点。

## IDEA-ID 与路径

沿用 PRD 的 IDEA-ID 和 MVP；命名语法见 [naming-conventions.md](../../../knowledge/naming-conventions.md#2-idea-id)。

`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md`

文首元数据以 [模板](../assets/tdd-template.md) 为准；`id` 与文件名一致，`parent` 指同链 PRD，`mvp_phase` 与 N 一致。DSD/ASD 在 §1.1 引用实际位置，不要求伪造缺失文档或新增元数据字段。

## TC 编号

| 前缀 | 用途 |
| --- | --- |
| `TC-{NNN}` | 功能 |
| `TC-API-{NNN}` | 接口 |
| `TC-BR-{NNN}` | 业务规则 |
| `TC-EX-{NNN}` | 异常 |
| `TC-PERF-{NNN}` | 性能 |
| `TC-REG-{NNN}` | 回归 |

保留已有 ID；新增按各序列分配。检查重复、引用与连续性，历史空号说明原因；编号数量不是覆盖率。

## depth

这是写作深度参数，不是校验脚本选项。

| 值 | 含义 |
| --- | --- |
| `quick` | 聚焦已选范围与关键风险；用例补段可用此值并在摘要说明 |
| `standard` | 默认；按变更需要检查六类用例，不适用项写理由 |
| `deep` | 对适用的性能、安全、并发和异常风险加细 |

深度不改变已确认范围、验收条件或必需风险覆盖；六章结构见模板，当前段粒度见 [gates.md](gates.md)。
