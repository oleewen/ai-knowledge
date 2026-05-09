# 易错点

## 前置

- **未注册就拉**：无 `applications/app-{APPNAME}/` 或 `_manifest.yaml` → 停；先建联。勿从目录名猜远端。  
- **`repo_url` 空**：读完 manifest 立刻校验。

## 分支

- clone **失败**：说明原因；列举远端分支；**勿**静默换分支（除非用户授权）。  
- 无 **`--branch`**：`main` 再 `master`；都无 → **停**，请指定。

## 覆盖

- **changelog**：同步前备份 `changelogs/`，结束**恢复**，勿让远端盖住本地同步史。  
- **manifest**：被盖 → `git checkout -- applications/app-{APP}/{APP}_manifest.yaml`。  
- **`docs_root`**：只信 manifest；勿硬编码 `docs/`。

## 记录

- **未完成步骤 3 不说完成**：**即使 0 diff** 也在 `pull-log.md` **追加**。  
- **提交号拿不到**：写「提交号获取失败」，勿编。

## 自查

- [ ] `repo_url` 非空  
- [ ] 分支已定或探测 OK  
- [ ] changelog 备份/恢复  
- [ ] manifest OK  
- [ ] 结构：`knowledge/`、`requirements/`、`changelogs/`  
- [ ] `pull-log` 已追加（分支、提交或失败说明、统计）
