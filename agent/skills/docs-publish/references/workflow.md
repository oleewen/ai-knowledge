# 发布流程

一次发布只处理当前 Git 工作树和本次 dry-run 列出的文件。流程分为预览、授权、执行、校核四段。

## 1. 预览

从目标仓库工作树运行：

```bash
bash agent/skills/docs-publish/scripts/docs-publish.sh --dry-run
```

预览必须能让人核对：当前分支、主分支识别、四层 `DESIGN.md` 的旧版本和新版本、白名单外改动、是否列出根级或层内 `TODO-LIST.md`，以及后续 Git 操作计划。预览阶段不改文件、不提交、不推送。

## 2. 授权

先完成可审阅预览；已有明确授权覆盖同一具体计划时沿用，否则取得确认后才可运行 `--publish --expect-plan <plan-id>`。确认失效条件包括：版本字段变化、工作树范围变化、分支变化、远端状态变化或预览失败后重新执行。

项目 Git 约定要求 commit/push 前获得用户确认；笼统发布请求不自动覆盖尚未展示的文件、版本和 Git 操作，计划标识本身不能证明授权。

预览输出的 `plan-id` 绑定分支/HEAD、主分支与远端跟踪提交、origin 读写地址、目标版本、四层内容、TODO 范围及暂存/未暂存差异。不绑定 FETCH_HEAD、index mtime 等易变元数据。

## 3. 执行

用户确认后运行：

```bash
bash agent/skills/docs-publish/scripts/docs-publish.sh --publish --expect-plan <预览的plan-id>
```

正式流程由脚本按以下顺序完成：

1. 在 fetch 前核对 plan-id；获取远端主分支后再次核对。内容、暂存状态、日期或 Git 基线变化均停止，重新预览。
2. rebase 当前 feature 分支；即使退出为零，也检查未合并索引（autostash 恢复可能冲突）。有冲突保留现场并停止。核对分支、工作区与版本基线未变后，更新四层版本并暂存允许文件。
3. 再次独立核对暂存区白名单，创建固定 subject 的 `docs-publish` 提交。
4. 推送当前 feature 分支。
5. 快进合并到主分支并推送主分支。
6. 创建并切换到下一 `feature-YYYY.MMdd.patch` 分支。

脚本或远端在任一步失败时立即停止并保留现场；不要把冲突解决、重试、回滚或强推当成默认动作。

## 4. 完成校核

完成后核对：发布提交 subject、四层版本一致性、主分支是否快进到该提交、当前分支是否为下一 feature 分支。任一项无法核实时，只报告已完成的阶段和阻塞点，不宣称发布完成。
