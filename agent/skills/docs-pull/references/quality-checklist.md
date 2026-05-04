# docs-pull 质量验收清单

实跑前、实跑后对照；与 [gates.md](gates.md) 写盘 HARD-GATE 叠加使用。

---

## 实跑前

- [ ] `--app` 已锁定或已从多应用中选定
- [ ] 分支已锁定或探测成功
- [ ] `repo_url`、`docs_root` 已从 manifest 读取并向用户复述
- [ ] 若 `--force` 或大范围覆盖语义，已取得显式确认
- [ ] 已选择是否先 `--dry-run`

---

## 实跑后

- [ ] `pull-log.md` 已追加（含分支、提交号或失败说明、统计）
- [ ] `changelogs/` 已恢复备份语义（与脚本行为一致）
- [ ] `{APPNAME}_manifest.yaml` 未被覆盖或已恢复
- [ ] `last_pulled_*` 已更新（若脚本负责）
- [ ] 目录结构完整；已输出摘要
