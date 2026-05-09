# 设计原则

反模式：[anti-patterns.md](anti-patterns.md)；实操：[gotchas.md](../gotchas.md)。

1. **登记真源**：无 manifest / 无 `repo_url` → **不拉**；不靠目录猜仓。  
2. **保护登记与日志**：manifest、`changelogs/` 不因 rsync **丢**；可 `git checkout` 救 manifest。  
3. **分支不静默漂**：clone 失败不擅自换分支，除非用户明示。  
4. **可预览**：拿不准先 `--dry-run`。  
5. **可审计**：每次实跑**追加** `pull-log`，0 变更也一条。  
6. **范围克制**：只镜像；不顶替 distill/extract/SDD。  
7. **与 CONVENTIONS 一致**：低风险路径不捏造 spec/HTML gate。
