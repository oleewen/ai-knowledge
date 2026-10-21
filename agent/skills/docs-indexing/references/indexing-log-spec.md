# 索引增量锚点

唯一持久化基线是目标 `INDEX-GUIDE.md` 中的 HTML 注释。不生成日志主表、`INDEXING-LOG.md` 或 `changelogs/`。

## 格式与读取

```html
<!-- sdx-indexing:indexing_finished_ms=1714108800000 -->
```

- 数值为索引完成时刻的正整数 epoch 毫秒。
- 读取正文中的第一处锚点，其值必须为正整数；frontmatter 和代码围栏中的示例不算基线。
- 更新时保留第一处位置并移除正文中其余重复锚点，保留其他内容。
- full 不读历史基线；incremental 依次使用显式 `--since`、目标指南锚点。两者都没有时停止，不自动 full。
- 时间对人展示见 [参数规范 §2.0](scan-config-onboarding.md#20-对人展示时间锚agent-输出)。

## 写入时机

只有 Agent 完成指南正文并验证成功后，才能写完成锚点。仅扫描候选、更新运行块、只读预览或失败都不推进基线。写入目标必须是已存在且非空的指南，不创建只有锚点的空文档。

```bash
# 在目标仓库运行；SKILL_DIR 指向实际加载的技能目录
python3 "$SKILL_DIR/scripts/indexing_log.py" read-baseline docs/INDEX-GUIDE.md
# FINISHED_MS 为指南成功后的 epoch 毫秒
python3 "$SKILL_DIR/scripts/indexing_log.py" write-anchor docs/INDEX-GUIDE.md --finished-ms "$FINISHED_MS"
```

`read-baseline` 在文件不存在或未找到正文锚点时输出 `0`；非法数值或读取错误报错。`write-anchor` 原子替换目标，失败不宣称完成。旧 `append` 子命令仅为兼容别名，附带表字段不再落盘。

## 时间基线的限制

时间戳不记录文件版本，也不代替 Git 变更集合。收尾前复查扫描期间的变更；若源文件继续变化，补读并验证，或保留旧锚点并报告未完成。第八章应说明增量依据及未覆盖范围。
