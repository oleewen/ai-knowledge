# 质量与验收

落盘后记 [workflow.md](workflow.md) 步骤 5。

## 清单

- [ ] README 与 AGENTS 无大段重复
- [ ] AGENTS **无** INDEX §3 级 API 入口表堆砌
- [ ] README / AGENTS / INDEX 链路径一致、可点
- [ ] AGENTS 首条参考为真实 Index 路径
- [ ] 命令可在 README 执行或明确链到有命令的文档
- [ ] AGENTS/README 表里规范路径在磁盘存在
- [ ] README 树与 INDEX §2 一致
- [ ] AGENTS 概述 ≤3 行；未索引区未写死为已读
- [ ] Index 来自磁盘，非粘贴

```bash
bash agent/skills/docs-agent/scripts/validate-guide.sh --root .
```

## 反模式

| 反模式 | 说明 |
| ------ | ---- |
| AGENTS 重写文档索引表 | 再造完整索引 |
| Skill 内调 docs-indexing | 混淆职责 |
| 无 Index 编细节 | 未授权且无例外 |
| 树矛盾 | README 与 INDEX §2 不一致 |
| 未索引当已读 | |
| 先 AGENTS 后 README | 命令重复 |
| 概述超长 | AGENTS >3 行 |
| update 全覆盖 | `update` 应合并 |
