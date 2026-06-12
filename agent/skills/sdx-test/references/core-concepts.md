# sdx-test 核心概念

## IDEA-ID

与 PRD/ASD/DSD 同链：`{YYMMDD}-{主题}`。

| 产物 | 路径示例 |
|------|-----------|
| 会话 spec | `{DOC_DIR}/superpowers/specs/2026-04-12-审批提效-sdx-test.md` |
| TDD | `{DOC_DIR}/requirements/REQUIREMENT-260412-审批提效/MVP-Phase-1/TDD-260412-审批提效-1.md` |
| PRD/ASD/DSD | 同目录 `PRD-*`、`ASD-*`、`DSD-*` |

## TC 编号（与模板一致）

| 前缀 | 含义 |
|------|------|
| `TC-{NNN}` | 功能 |
| `TC-API-{NNN}` | 接口 |
| `TC-BR-{NNN}` | 业务规则 |
| `TC-EX-{NNN}` | 异常 |
| `TC-PERF-{NNN}` | 性能 |
| `TC-REG-{NNN}` | 回归 |

文档 `id` 形态以 **tdd-template** 文末 yaml 与落盘文件名为准（如 `TDD-{IDEA-ID}-{N}`）。

## `--depth`

| 值 | 含义 |
|----|------|
| `quick` | P0 功能 + 核心接口；异常/回归从简 |
| `standard` | 六类用例（默认） |
| `deep` | 性能、安全、并发加细 |

## TDD 六章

对齐 [tdd-template.md](../assets/tdd-template.md)：

| 章 | 内容 |
|---|------|
| §1 | 目标、范围、策略 |
| §2 | §2.1–§2.6 用例 |
| §3 | 测试数据 |
| §4 | 环境 |
| §5 | 进出标准、回归顺序 |
| §6 | 变更历史、§6.2 自查 |

元数据：**仅**文末 fenced `yaml`；**禁止**文首 `---`。
