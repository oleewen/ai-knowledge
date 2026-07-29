# docs-extract 验收清单

阶段 4 末与 CLOSE 前核对。原则见 [design-principles.md](design-principles.md)、[anti-patterns.md](anti-patterns.md)。

## 参数与范围

- [ ] `--sources`、`--overview`、关键词口径、`--dry-run` 已收口
- [ ] 当前单元目标 `XX-overview.md` 已明确
- [ ] `--sources` 可解析（路径或文本）；`--overview` 存在且含 `## 文档关键词`
- [ ] 高风险场景已给出推荐方案与确认结论（若适用）

## 命中与写入

- [ ] 4.1 有命中才进 4.2/4.3
- [ ] 未把 overview 当源扫描
- [ ] 命中量合理；代码块未当业务知识写入
- [ ] 仅更新有命中章节；无命中保持原样
- [ ] 写入前已读「应填内容 + 产出建议」
- [ ] 第三列为提炼摘要；A/U/D 正确；无脚注堆叠
- [ ] 失败已整体回滚
- [ ] 已按 [audience-and-language.md](../../../references/audience-and-language.md) + 本地 [audience-and-language.md](audience-and-language.md) 通过烤干受众维 A/B/C/E
