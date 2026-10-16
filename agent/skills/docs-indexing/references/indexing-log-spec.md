# 索引增量锚点（INDEX-GUIDE HTML）

每次成功索引后更新目标 `INDEX-GUIDE.md` 内 HTML 注释；**下次 incremental 时间锚**取自该注释。不再落盘 `INDEXING-LOG.md` 或任何 `changelogs/*-LOG.md`。

节：位置 · 格式 · 基线优先级 · 写入时机 · dry-run

---

## 锚点位置

与本次写出的索引指南同一文件：

```
${OUTPUT}   # 通常 ${DOC_DIR}/INDEX-GUIDE.md 或仓库根 INDEX-GUIDE.md
```

无有效锚点 = 无基线：增量时须让用户确认改走 full **或中止**，或显式 `--since`；勿静默降级。

---

## 锚点格式

```html
<!-- sdx-indexing:indexing_finished_ms=1714108800000 -->
```

- 文内可出现多处时以**第一处**为读写主锚；写入时规范为单处。
- `indexing_finished_ms`：本次运行结束 epoch 毫秒，纯数字。

> **Agent 对人**：展示时用 `yyyy-MM-dd HH:mm:ss +08`（`{ms}`），时区 Asia/Shanghai。见 [scan-config-onboarding.md §2.0](scan-config-onboarding.md)。**写入仍只用纯数字。**

---

## 增量基线确定逻辑（优先级）

1. **`--full`（或用户显式确认全量）** — 不读锚点。  
2. **显式 `--since`（epoch ms）** — 以该值为基线。  
3. **`INDEX-GUIDE` 内 HTML 锚点** — 默认增量。  
4. **皆无** — 无有效基线 → 停下确认；**不**自动全量。

```
if full:
    基线 = 全量
elif --since:
    基线 = since
elif INDEX-GUIDE 锚点可解析:
    基线 = 该 ms
else:
    停下
```

变更文件列表由 Agent 按基线跑 git；本契约只管**索引成功结束时间**落盘形态。

---

## 写入时机

INDEX **成功落盘后**（或 scan-only 扫描成功后）再写/更新锚点。失败则不更新锚点，避免假进度。

脚本：`indexing_log.py write-anchor <guide> --finished-ms <ms>`；`read-baseline <guide>`。

---

## dry-run

dry-run 不写锚点、不改 INDEX-GUIDE。
