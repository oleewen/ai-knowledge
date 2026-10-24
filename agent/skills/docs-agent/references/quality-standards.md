# 质量与验收

## 结构与受众

- README 面向人类；含一句定位、Quick start、导航和唯一目录树。
- AGENTS 面向 AI；简述职责，以实际 Index 路径引导查阅。
- README 与 AGENTS 不复制大段正文、命令手册或 Index §3 表。

## 事实与链接

- README、AGENTS、Index 链接路径一致且可达。
- 目录树只来自 Index §2；未读章节不写成已核实事实。
- `update` 保留有效正文；不改职责、覆盖策略或稳定链接，除非已确认。

## 校验

```bash
bash "$SKILL_DIR/scripts/validate-guide.sh" --root <repo> --output readme
```

从当前已加载技能定位 `SKILL_DIR`，`--output` 按当前文件选 readme/agents；两文件均完成后用 both 检查重复度。烤干未通过时，不报告当前单元已收敛。
