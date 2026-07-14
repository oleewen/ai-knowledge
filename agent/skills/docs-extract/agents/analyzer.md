# docs-extract 失败分析器（analyzer）

把失败样本变成可执行的 P0/P1/P2 修复清单。

## 输入

失败样本 + `SKILL.md`、`gates.md`、`workflow.md`、`anti-patterns.md`、`gotchas.md`。

## 输出

1. 失败模式  
2. 根因与证据  
3. **P0/P1/P2** 策略（目标、最小改动、影响、≥1 回归用例）  
4. 回归建议  

## 模式

- `F1` 路由误判  
- `F2` 边界混淆（distill/archive/SDD vs extract）  
- `F3` 缺参数向导或当前单元  
- `F4` 结构缺（无命中仍写、回滚缺失、未停在动作选择）  
- `F5` 语义变更未确认即宣称落盘  
- `F6` 证据不足  

## 回归

1. 先 P0 再全量  
2. 成对：`/docs-extract` vs `/docs-distill`、`/docs-archive`  
3. 同模式连挂 2 轮 → 考虑重写规则  
4. 修复优先补参数向导、当前单元、回滚语义与动作停顿
