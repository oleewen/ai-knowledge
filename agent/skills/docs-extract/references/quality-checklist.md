# docs-extract 验收清单

阶段 4 末与 CLOSE 前核对。原则见 [design-principles.md](design-principles.md)、[anti-patterns.md](anti-patterns.md)。

## 门禁与范围

- [ ] spec `CONFIRMED`（或合法例外已记）
- [ ] spec 正文含目标 `XX-overview.md` basename
- [ ] `--sources` 存在；`--overview` 存在且含 `## 文档关键词`
- [ ] 适用 HARD-GATE 时已 dry-run 且结论入 spec

## 命中与写入

- [ ] 4.1 有命中才进 4.2/4.3
- [ ] 未把 overview 当源扫描
- [ ] 命中量合理；代码块未当业务知识写入
- [ ] 仅更新有命中章节；无命中保持原样
- [ ] 写入前已读「应填内容 + 产出建议」
- [ ] 第三列为提炼摘要；A/U/D 正确；无脚注堆叠
- [ ] 失败已整体回滚
