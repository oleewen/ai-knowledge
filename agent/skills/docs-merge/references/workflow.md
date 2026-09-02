# docs-merge 工作流

主干：[SKILL.md](../SKILL.md)。binding：[gates.md](gates.md)。算法：[merge-spec.md](merge-spec.md)。

契约链： [intent-clarify.md](../../../references/intent-clarify.md) · [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) · [grilling-skill.md](../../../references/grilling-skill.md) · [docs-simplify.md](../../../references/docs-simplify.md)

## 目标

`<source>` → 按 target H2/H3 落位合入；新增/更新逐项确认、冲突 grilling；一次落盘。

## 与 docs-extract

| 维度 | docs-extract | docs-merge |
| --- | --- | --- |
| 目标 | overview 第三列 | 任意已存在 md 章节 |
| 过滤 | 关键词附录 | 章节落位 + 类似判定 |
| 产物 | A/U/D delta | 新增 / 更新 / 冲突决议 |
| 确认 | 关键词命中即写 delta | **每项变更以提问逐项确认**；冲突逐条提问 |

「提炼 / 第三列 / A/U/D」→ extract；「合并 / 合入章节」→ merge。

## 参数向导

未收口不执行。歧义停问。

1. `<source>`
2. `<target>`（已存在 `.md`）
3. 是否 `--dry-run`

仅一个参且像已存在 md → candidate target，补收 source。

## 当前单元

见 [gates.md](gates.md)。

## 写后默认表

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 单个合入单元（含 dry-run 预览） | **必须** | 首次实质改 target；新增/更新项多；冲突多；knowledge 路径；未确认决策写入 |

只可升级，不可降为跳过。

## 技能步骤

推进环见 unit-cycle-protocol；本技能补：

1. 收口 `<source>` / `<target>` / `--dry-run`
2. 出合入计划 + **变更清单**（待新增 A / 待更新 U / 合计 N；merge-spec §5）
3. 意图澄清 + **未落位收口** → 写前 `C`（dry-run 可展示含未落位计划；正式写入前须清零）
4. `--dry-run` → 计划 + 变更清单 → 烤干 → 停等（此 C **不**授权落盘）
5. 正式：未落位已空 → **重新**写前 `C` → 公布变更清单 → **逐项提问**（`i/N`；更新内冲突 `k/M`；**确认完一条再下一条**）→ 仅已确认项一次落盘；失败回滚；不改源
6. knowledge 目标校验引用边界
7. 烤干 → `C/M/G/S/F`

## 命令示例

```bash
/docs-merge ./notes/snippet.md ./docs/guide.md --dry-run
/docs-merge ./notes/snippet.md ./docs/guide.md
/docs-merge "支持用户下单、支付、退款三个流程" ./docs/guide.md
/docs-merge ./docs/guide.md
```
