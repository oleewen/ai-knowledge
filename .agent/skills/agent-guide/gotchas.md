# agent-guide 常见陷阱

---

## Index 解析

**用对话粘贴的 Index 替代落盘文件**：仓库存在 §1.1 路径时，一律以磁盘版本为准，忽略对话粘贴内容。磁盘版本可能已更新，用粘贴内容会导致产出与实际仓库不一致。

**未命中 Index 仍继续生成**：四个候选路径均不存在时，立即终止并提示用户运行 `/docs-indexing`，不要凭印象或目录猜测生成文档。

**REPO_ROOT 与 DOC_ROOT 优先级混淆**：查找顺序是 REPO_ROOT 先、DOC_ROOT 后。仓库同时存在两个 Index 时，严格按此优先级命中即停，记录实际落盘相对路径，写入 AGENTS 链接时再换算为可点击的相对路径。

---

## 探索与阅读

**通读全仓后再写 AGENTS**：以 INDEX 为地图，只打开与「README 首屏 / AGENTS 契约」直接相关的文件。通读全仓会导致上下文爆炸，且 AGENTS 容易堆砌无关细节。

**把 INDEX §3 API 入口表复制进 AGENTS**：AGENTS 只写一句「详见当前 INDEX §3」，不粘贴原表。三处维护极易失步。

**把「未索引区域」写成已核实事实**：INDEX §6 标注为未索引的路径，在 AGENTS 中只写「详见 INDEX §6」或标注「待核实」，需要时只补读该具体路径。

---

## 生成阶段

**先写 AGENTS 再写 README**：严格遵循「先 README 后 AGENTS」顺序。先写 AGENTS 会导致命令块写进去，再写 README 时又复制一遍，两文件命令不同步。

**README 目录树与 INDEX §2 矛盾**：README 目录树直接从 INDEX §2 提取，禁止另起一套，否则新读者与 Agent 获得矛盾的项目结构认知。

**AGENTS 项目概述超过 3 行**：AGENTS 项目概述 ≤3 行，细节链到 README 与 INDEX §1。臃肿的概述浪费 Agent 上下文。

**`--mode update` 时直接覆盖已有 README**：diff 比较后合并，保留已有有效段落，只更新过时或缺失部分。

---

## 验收阶段

**跳过路径一致性校验**：生成后必须验证 AGENTS 中的路径引用在磁盘上存在，否则 Agent 按指引打开文件时报 404，工作流中断。运行 `bash .agent/skills/agent-guide/scripts/validate-guide.sh --root .` 可自动检查。

**AGENTS 首条参考路径写错**：AGENTS「先读什么」表格中 INDEX 路径必须与步骤 1 记录的实际落盘路径完全一致，否则 Agent 启动时找不到地图。

---

## 禁止在本 Skill 内调用 docs-indexing

发现 Index 过时或缺失时，不要在 agent-guide 执行流程内自动触发 docs-indexing。职责混淆会导致执行链不可预期，可能覆盖用户未提交的 Index 变更。需要更新 Index 时，单独运行 `/docs-indexing`。

---

## 快速自查清单

- [ ] Index 来自磁盘落盘文件，非对话粘贴
- [ ] 未命中 Index 时已终止，未编造结构
- [ ] Index 查找顺序：REPO_ROOT 先，DOC_ROOT 后
- [ ] 以 INDEX 为地图最小阅读，未通读全仓
- [ ] AGENTS 未粘贴 INDEX §3 API 入口表
- [ ] 未索引区域未写成已核实事实
- [ ] 先 README 后 AGENTS，命令块未重复
- [ ] README 目录树与 INDEX §2 一致
- [ ] AGENTS 项目概述 ≤3 行
- [ ] `--mode update` 时合并而非覆盖
- [ ] AGENTS 首条参考路径可跳转
- [ ] 未在本 Skill 内调用 docs-indexing
