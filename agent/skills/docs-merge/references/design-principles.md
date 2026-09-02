# docs-merge 设计原则

互补：[anti-patterns.md](anti-patterns.md)。易错：[../gotchas.md](../gotchas.md)。细节：[merge-spec.md](merge-spec.md)。

1. 目标为锚；源迁就落位  
2. 先计划后写；**先出变更清单（项数）再逐项提问**；落位不明则停  
3. **确认完一条再流转下一条**；冲突同法逐条提问；一次落盘、失败回滚  
4. 源只读；高风险先 `--dry-run`  
5. knowledge 合入不破引用边界  
