# 质量验证标准

agent-guide 技能的产出质量验证清单与反模式。步骤 5（验证）时逐项核对。

---

## 验收清单

### 发布前勾选

- [ ] README 与 AGENTS **无大段重复**
- [ ] AGENTS **未**堆叠 INDEX §3 级 API 入口表
- [ ] README 文档表、AGENTS「参考」、当前 INDEX 内路径 **一致、可跳转**
- [ ] AGENTS 首条参考 **非**误写路径
- [ ] 命令在 README 中 **可复制执行**（或明确链到含命令的子文档）
- [ ] 规范/模板路径在磁盘上 **存在**
- [ ] README 目录树与 INDEX §2 **一致**，无矛盾
- [ ] AGENTS 项目概述 **≤3 行**
- [ ] 未索引区域未写成已核实事实
- [ ] Index 来自磁盘落盘文件，非对话粘贴

### 辅助验证

可运行 [../scripts/validate-guide.sh](../scripts/validate-guide.sh) 进行路径一致性自动检查：

```bash
scripts/validate-guide.sh --root .
```

---

## 反模式（禁止）

| 反模式 | 说明 |
|--------|------|
| AGENTS 重写文档索引表 | 在 AGENTS 里重写一份「完整文档索引表」 |
| Skill 内调用 document-indexing | 在本 Skill 执行流程内调用 document-indexing 或等待用户选择是否重做索引 |
| 无 Index 编造细节 | 无落盘 Index 且用户未授权例外时编造目录/模块细节 |
| 目录树矛盾 | README 与 INDEX §2 目录树互相矛盾 |
| 未索引写成已读 | 把「未索引」区域写死为已读事实 |
| 先 AGENTS 后 README | 先完成 AGENTS 再写 README，导致命令块重复 |
| AGENTS 概述冗长 | AGENTS 项目概述超过 3 行，堆砌业务背景 |
| 更新时全覆盖 | `--mode update` 时直接覆盖已有 README，丢失有效内容 |
