# docs-extract 质量验收清单

阶段 4 落盘前与 CLOSE 前逐项核对；**禁止**未核对即宣称完成。

原则与反模式见 [design-principles.md](design-principles.md)、[anti-patterns.md](anti-patterns.md)。

---

## 门禁与范围

- [ ] 会话 spec 已 `CONFIRMED`（或已记录合法例外依据）
- [ ] 目标 `XX-overview.md` basename 已在 spec 正文出现
- [ ] `--sources` 均存在；`--overview` 存在且含 `## 文档关键词` 附录
- [ ] 已 `dry-run`（若适用 HARD-GATE）且结论已写入 spec

---

## 命中与写入

- [ ] 阶段 4.1 有命中才进入 4.2 / 4.3
- [ ] 未将 overview 自身纳入扫描
- [ ] 命中数量合理；代码块未当业务知识写入
- [ ] 仅更新有命中的章节；无命中章节原样保留
- [ ] 每节写入前已读「应填内容 + 产出建议」
- [ ] 第三列为提炼摘要；A/U/D 正确
- [ ] 写入失败时已整体回滚，无部分落盘
- [ ] 第三列无来源脚注堆叠
