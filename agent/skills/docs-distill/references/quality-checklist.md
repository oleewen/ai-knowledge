# 质量核对（阶段 4 末 / CLOSE）

原则 [design-principles.md](design-principles.md)。

## 参数与范围

- [ ] `--app`、增量范围、`--full`/`--dry-run` 已收口
- [ ] 当前单元目标 `{APPNAME}-overview.md` 已明确
- [ ] 高风险场景已给出推荐方案与确认结论（若适用）

## overview / 第三列

- [ ] 锚与区间已定（或全量已授权）  
- [ ] 文件名 **且** 文内标题已 `NAME`→`APPNAME`  
- [ ] 五行视角各行已处理（`—` 或 delta）
- [ ] federation-spec 自检（去重、delta、A/U/D）
- [ ] 无 OpenAPI 全文 / 整段 DDL 侵占；无 `(来源…)` 堆链

## 日志与导航

- [ ] **4.3 成功后**才追加 DISTILL-LOG；新行**最前**  
- [ ] 若影响 `system/knowledge/index.md` 或视角 README → 评估同步（gotchas）
- [ ] 已按 [audience-and-language.md](../../../references/audience-and-language.md) + 本地 [audience-and-language.md](audience-and-language.md) 通过烤干受众维 A/B/C/E
