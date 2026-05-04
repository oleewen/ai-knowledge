# docs-build 失败分析器（analyzer）

将失败样本转化为 P0/P1/P2 修复清单。

## 输入

`SKILL.md`、`references/gates.md`、`references/workflow.md`、`references/anti-patterns.md`、`gotchas.md`

## 失败模式（可多选）

- `F1 路由误判`
- `F2 边界混淆`：build vs indexing / distill / extract
- `F3 门禁遗漏`：Qclose-1、`CONFIRMED`、合法例外
- `F4 结构缺失`：四阶段、视角顺序、validate 脚本
- `F5 虚构低风险`：错误描述为无 spec gate
- `F6 证据不足`

## 回归

成对验证：`/docs-build` vs `/docs-indexing`、`/docs-build` vs `sdx-*`。
