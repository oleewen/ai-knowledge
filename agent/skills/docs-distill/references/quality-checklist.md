# 质量核对（阶段 4 末 / CLOSE）

原则 [design-principles.md](design-principles.md)。

## 参数与范围

- [ ] `DOC_DIR`（`system|company`）、`--name`、`--dry-run` 已收口
- [ ] 当前单元目标 `{NAME}-overview.md` 与边（槽位→overview）已明确
- [ ] 槽位存在且非空
- [ ] 高风险场景已给出推荐方案与确认结论（若适用）

## overview / 第三列

- [ ] 模式为全量（无增量锚点）
- [ ] 文件名 **且** 文内标题已替换为 `{NAME}`
- [ ] 目标层五行视角各行已处理（`—` 或 delta）
- [ ] federation-spec 自检（去重、delta、A/U/D；表行正确）
- [ ] 无 OpenAPI 全文 / 整段 DDL 侵占；无 `(来源…)` 堆链

## 日志与导航

- [ ] **未**写入 DISTILL-LOG
- [ ] 若影响目标层 `knowledge/index.md` 或视角 README → 评估同步（gotchas）
- [ ] 已按 [audience-and-language.md](../../../references/audience-and-language.md) + 本地 [audience-and-language.md](audience-and-language.md) 通过烤干受众维 A/B/C/E
