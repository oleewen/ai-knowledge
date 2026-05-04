# docs-distill 质量验收清单

阶段 4 落盘前与 CLOSE 前：对照下列项逐项落实；**已满足**方可写入 DISTILL-LOG 并结束会话。**禁止**未核对即宣称完成。

原则与反模式见 [design-principles.md](design-principles.md)、[anti-patterns.md](anti-patterns.md)。

---

## 门禁与范围

- [ ] 会话 spec 已 `CONFIRMED`（或已记录合法例外依据）
- [ ] 目标 `{APPNAME}-overview.md` basename 已在 spec 正文出现
- [ ] 增量区间或 `--full` 影响面已说明；`--full` / 多应用 / 锚点异常等已走 HARD-GATE 与 `dry-run`（若适用）

---

## overview 与第三列

- [ ] 蒸馏锚点已读取，增量范围已确认（或全量已明确授权）
- [ ] 文件名与文内标题均已正确替换（`NAME` → `APPNAME`）
- [ ] 五架构视角全部章节行均已处理（有内容或明确 `—`）
- [ ] 每节写入前已读对应章节「应填内容 + 产出建议」
- [ ] 第三列为提炼摘要，非整段复制原始文档
- [ ] 变动标识（A/U/D）准确标注，无遗漏
- [ ] 应用侧细节（接口 DDL、OpenAPI 全文等）未不当挤占第三列
- [ ] 第三列无 `(来源：…)` 及多余参见链接

---

## 日志与一致

- [ ] overview 第三列写入成功后，才追加 `DISTILL-LOG.md` 记录
- [ ] DISTILL-LOG 新记录位置符合「最新在前」约定
- [ ] 若影响全局导航或视角 README，已评估是否需同步索引（见 gotchas）
