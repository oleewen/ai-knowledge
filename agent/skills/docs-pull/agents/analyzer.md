# docs-pull 失败分析器（analyzer）

将失败样本转化为可执行的修复优先级清单。

## 输入

- 失败样本（prompt、分类、响应、grader 证据）
- `SKILL.md`、`references/gates.md`、`references/workflow.md`、`references/anti-patterns.md`、`gotchas.md`

## 输出结构

1. 失败模式归类  
2. 根因与证据  
3. P0/P1/P2 修复策略（每条含文件/段落、回归用例）  
4. 回归评测建议  

## 失败模式（可多选）

- `F1 路由误判`
- `F2 边界混淆`：pull vs distill/extract/archive
- `F3 低风险误用`：虚构 spec gate、虚构 hooks
- `F4 结构缺失`：无 HARD-GATE、无 pull-log、无 manifest 复述
- `F5 静默多应用扫仓`
- `F6 证据不足`

## 回归策略

成对验证：`/docs-pull` vs `/docs-distill`、`/docs-pull` vs `/docs-extract`。
