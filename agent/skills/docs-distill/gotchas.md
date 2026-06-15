# 易错点

正文：[SKILL.md](SKILL.md)；索引：[references/README.md](references/README.md)。

## 锚点与日志

- 无 **`ARCHIVE-LOG.md`** 不是「跳过」——通常等价**从未蒸馏**，应全量首轮，之后建锚。  
- `changelog_id` 在 CHANGE-LOG **不存在**→ 勿静默全量；警告并请用户修正/`--since`/授权全量（防重复蒸馏）。  
- **4.3 败不写 DISTILL**，防锚前移、漏蒸馏。  
- **`--full`** 忽略锚→ 可先 `dry-run`，防盖系统库既有摘要。

## overview

- 新建：文件名 **`{APPNAME}-overview.md`** 与 `# {APPNAME} 架构概览` **同时**替换 `NAME`。  
- 第三列：**提炼**，非整帖；事前读对应章「应填 + 产出建议」。  
- **A/U/D**：空/`—`→新写标 `[A]`；改→ `[U]`；删→ `[D]`+清空；无变→保持不标（与 federation 一致）。  
- **模板表全行扫描**（`NAME-overview.md` 中 🔑 + ADR 行），非只写有 PR 的行；无证写 `—`。  
- 第三列不写应用侧超长原文，不写 `(来源…)` 脚注。

## 联邦

- 唯一上行目标：**overview 第三列**；不把 knowledge/SDD 当系统终稿段落。  
- 冲突：**代码/manifest** 或标待定，勿硬盖系统权威。  
- 动到全局导航：**INDEX_GUIDE** / 视角 **README** 须评估同步。

## 多应用

- 无 `--app`：轻量扫 `system/application-*/`，只读 CHANGE/ARCHIVE，**不深读全库**。  
- DISTILL：**按 app 过滤**最新行锚，勿取文件末行 blindly。

## 自查

- [ ] 锚/增量或全量授权  
- [ ] 文件名与标题 APPNAME  
- [ ] 模板表每行：`—` 或内容  
- [ ] 节前读规范  
- [ ] 摘要+A/U/D  
- [ ] 无 OpenAPI 全文等大段侵占  
- [ ] DISTILL **仅成功写 overview 后**
