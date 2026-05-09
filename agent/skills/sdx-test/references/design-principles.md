# sdx-test 设计原则

终检条目以 [tdd-template.md](../assets/tdd-template.md) **§6.2** 为准；摘要：[quality-checklist.md](quality-checklist.md)。

## 原则

| 原则 | 要求 |
|------|------|
| 模板驱动 | 六章顺序与 [tdd-template.md](../assets/tdd-template.md) 一致；无内容标「不适用/待补充」 |
| 证据优先 | TC 须锚 PRD（US、FR、BR）与 **DSD**/specs；禁空编 |
| 按需加载 | G1 读 PRD+影响面概要；G2 按类型开规约；禁通扫 `knowledge/**` |
| 歧义标注 | 缺口标待澄清并记录；禁自补后继续 |
| 范围 | 仅 TDD；无自动化脚本、无执行报告 |
| 可追溯 | TC→US/API/BR/影响面；编号连续可辨 |

### 引用格式（示例）

| 类型 | 格式 | 例 |
|------|------|-----|
| 用户故事 | `US-{NNN}` | `US-001` |
| 功能需求 | `FR-{NNN}` | `FR-001` |
| 业务规则 | `BR-{NNN}` | `BR-001` |
| API | `{Method} {Path}` | `POST /api/…` |

TC 前缀表见 [core-concepts.md](core-concepts.md)。

### 默认覆盖目标（可在 §1.3 调整）

| 层次 | 指标指向 |
|------|-----------|
| 单元 | 行覆盖 ≥80% |
| 集成 | 接口覆盖 100% |
| E2E | 核心场景 100% |

## 反模式（禁令摘要）

臆测用例｜吞没歧义｜范围蔓延（写代码/报告）｜跳章｜通读全库｜无编号｜孤立用例｜只测正常｜空章｜不做影响面回归。

## 错误处理

| 场景 | 处理 |
|------|------|
| 无 PRD | 终止 → `sdx-prd` |
| 无 DSD/specs | 警告；基于 PRD 收窄；§1 标缺技术基线 |
| PRD 验收不全 | 标待澄清；有限用例并注限制 |
| 无 knowledge/ | 警告；凭 PRD+ASD/DSD |
| 无模板文件 | 终止：需 `assets/tdd-template.md` |
| 无输出目录 | 可建 `…/REQUIREMENT-…/MVP-Phase-N/` |
