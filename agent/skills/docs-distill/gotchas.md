# 易错点

正文：[SKILL.md](SKILL.md)；索引：[references/README.md](references/README.md)。

## DOC_DIR 与边

- **跳过写前意图澄清**：不得在未输出六项清单、未获写前 `C` 时写入或输出正式预览；见 [intent-clarify.md](../../references/intent-clarify.md)、[gates.md](references/gates.md)。
- **dry-run 仍须澄清**：预览前也要意图澄清；烤干可针对预览结果。
- **DOC_DIR 非 system/company**（含 monorepo 根、`.docsconfig` 为其它值）→ 向导或 `--doc-dir`，勿猜。
- **槽位空/缺失**→ 停；先 docs-link / docs-pull，勿直读源仓替代。
- **误走 extract 源**：design/Wiki 等非槽位 → docs-extract，不是本技能。

## 模式

- **仅全量**；`--since` / DISTILL-LOG 锚点已废止。历史 DISTILL-LOG 文件可留作考古，本技能不读写。
- 全量易盖第三列 → 可先 `dry-run`。

## overview

- 新建：文件名 **`{NAME}-overview.md`** 与 `# {NAME} 架构概览` **同时**替换。  
- 第三列 / A/U/D：[federation-spec.md](references/federation-spec.md)；**表行随目标层**。
- **模板表全行扫描**（README 表行）；无证写 `—`
- 不写槽位超长原文或 `(来源…)` 脚注

## 联邦

- 唯一上行目标：**overview 第三列**；不把 knowledge/SDD 当目标层终稿段落。  
- 冲突：**代码/manifest** 或标待定，勿硬盖目标层权威。  
- 动到全局导航：**index** / 视角 **README** 须评估同步。

## 多源

- 无 `--name`：轻量列槽位目录名，**不深读全库**；收口单源后再蒸。

## 自查

- [ ] 写前意图澄清六项 + 写前 C；dry-run 亦同；烤干阶段横幅
- [ ] 边与 DOC_DIR 正确；槽位非空  
- [ ] 文件名与标题 `{NAME}`  
- [ ] 模板表每行：`—` 或内容  
- [ ] 摘要+A/U/D；无大段侵占  
- [ ] **未**写 DISTILL-LOG
