# docs-agent 易错点

## 意图

- **跳过写前意图澄清**：不得在未输出六项清单、未获写前 `C` 时写入；见 [intent-clarify.md](../../references/intent-clarify.md)、[gates.md](references/gates.md)。
- **把写前澄清当 grilling**：写前只收口意图，不写后深挖；烤干在写入后。
- 模糊仍直接生成 → 走 gates 澄清；确认前不落盘。快速路径仅当参数可唯一推断且仍须六项清单 + 写前 `C`。

## Index

- **磁盘优先**：有落盘路径则不用对话粘贴。
- **四路径皆无** → 停，提示 `/docs-indexing`，不猜结构。
- **REPO_ROOT 先于 DOC_ROOT**；两 Index 并存时按序命中即停；AGENTS 链用实测相对路径。

## 探索

- 不以 INDEX 为地图却通读全仓。
- AGENTS **不**粘贴 INDEX §3；只写一句指向 §3。
- INDEX §6 未索引：不写死结论；必要时只读指定路径。

## 生成

- **先 README 后 AGENTS**。
- README 目录树仅从 INDEX §2，勿另树。
- AGENTS 概述 ≤3 行。
- `--mode update`：合并，不全量抹掉 README。

## 验收

- 跑 `validate-guide.sh`；核对 AGENTS 首条 INDEX 与实际一致。

## 职责

索引缺失或过时：**不要在本 Skill 内自动跑 docs-indexing**；让用户单独 `/docs-indexing`。

## 自查

- [ ] 写前意图澄清六项 + 写前 C；烤干阶段横幅；无横幅裸发 C/M/G/S/F
- [ ] Index 磁盘版；未命中已停；查找顺序 REPO→DOC
- [ ] 最小阅读；§3 §6 合规；先读后顺；树一源；overview≤3；update 合并
- [ ] 校验脚本；首链可点；未内调 docs-indexing
