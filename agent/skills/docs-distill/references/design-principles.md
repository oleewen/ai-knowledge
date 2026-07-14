# 设计原则

反模式：[anti-patterns.md](anti-patterns.md)；操作：[gotchas.md](../gotchas.md)。

1. **单行上行**：可晋升知识只进 overview **第三列**；不以应用原文为终态。  
2. **默认可重入增量**：DISTILL + 应用日志定区间；`--full` 须确认。  
3. **先读后写**：先看现有第三列再 A/U/D。  
4. **日志原子**：4.3 成后再 4.4；失败不前移锚点。  
5. **正文无出处脚注**：追溯 CHANGE-LOG / DISTILL / spec。  
6. **联邦消解冲突**：按 [federation-spec.md](federation-spec.md)，勿硬盖系统权威。  
7. **风险先预览**：高风险场景默认先 `--dry-run`，再按会话内确认推进。
