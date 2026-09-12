# 设计原则

反模式：[anti-patterns.md](anti-patterns.md)；操作：[gotchas.md](../gotchas.md)。

1. **单行上行**：可晋升知识只进 overview **第三列**；不以槽位原文为终态。  
2. **仅全量**：无 DISTILL-LOG / 无 `--since`；全量覆盖须确认，高风险先 dry-run。  
3. **先读后写**：federation-spec 去重后仅写 delta / A/U/D。  
4. **槽位边界**：只蒸联邦槽位；空槽停；非槽位源走 docs-extract。  
5. **正文无出处脚注**：追溯槽位与 spec，不写 `(来源…)`。  
6. **联邦消解冲突**：按 [federation-spec.md](federation-spec.md)，勿硬盖目标层权威。  
7. **风险先预览**：高风险场景默认先 `--dry-run`，再按会话内确认推进。  
8. **双边同契约**：app→system 与 system→company 共用流程；表行随目标层切换。
