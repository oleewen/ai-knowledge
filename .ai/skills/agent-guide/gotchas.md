# agent-guide 常见陷阱（Gotchas）

本文记录执行 `agent-guide` Skill 时高频踩坑点，供 Agent 与人类开发者参考。

---

## 1. Index 解析阶段

### 1.1 用对话粘贴的 Index 替代落盘文件
**陷阱**：用户在对话中粘贴了 Index 全文，Agent 直接用该内容生成文档。  
**后果**：磁盘版本可能已更新，生成结果与仓库实际状态不一致。  
**正确做法**：仓库存在 §1.1 路径时，一律以磁盘落盘文件为准，忽略对话粘贴内容。

### 1.2 未命中 Index 仍继续生成
**陷阱**：四个候选路径均不存在，Agent 仍凭印象或目录猜测生成 README/AGENTS。  
**后果**：编造模块结构，产出与实际仓库严重偏差。  
**正确做法**：未命中时立即终止，提示用户先运行 `/docs-indexing`。

### 1.3 把 `INDEX_GUIDE.md` 根目录版本与 `system/` 版本混淆
**陷阱**：仓库同时存在根目录 `INDEX_GUIDE.md` 与 `system/INDEX_GUIDE.md`，Agent 随机选一个。  
**后果**：引用路径错误，AGENTS 首条参考指向不存在的文件。  
**正确做法**：严格按 [reference/execution-spec.md](reference/execution-spec.md) 优先级（根目录 `INDEX_GUIDE.md` 等先于 `system/`）命中即停，记录**磁盘上实际相对路径**（相对仓库根，写入 AGENTS 链接时再从 `AGENTS.md` 所在目录换算为可点击的相对路径）。

---

## 2. 探索与阅读阶段

### 2.1 通读全仓后再写 AGENTS
**陷阱**：为求「全面」，打开所有模块文件再动笔。  
**后果**：上下文爆炸、耗时过长，且 AGENTS 容易堆砌无关细节。  
**正确做法**：以 INDEX 为地图，只打开与「README 首屏 / AGENTS 契约」直接相关的文件（最小阅读集）。

### 2.2 把 INDEX §3 API 入口表复制进 AGENTS
**陷阱**：将 INDEX §3 的接口列表整段粘贴到 AGENTS。  
**后果**：三文件重复，维护时需同步三处，极易失步。  
**正确做法**：AGENTS 只写一句「详见当前 INDEX §3」，不粘贴原表。

### 2.3 把「未索引区域」写成已核实事实
**陷阱**：INDEX §6 标注为未索引的路径，Agent 仍在 AGENTS 中描述其内容。  
**后果**：产出含幻觉信息，误导后续 Agent 或开发者。  
**正确做法**：未索引区域只写「详见 INDEX §6」或标注「待核实」，需要时只补读该具体路径。

---

## 3. 生成阶段

### 3.1 先写 AGENTS 再写 README，导致命令重复
**陷阱**：先完成 AGENTS，把命令块写进去；再写 README 时又复制一遍。  
**后果**：两文件命令不同步，维护成本翻倍。  
**正确做法**：严格遵循「先 README 后 AGENTS」顺序；AGENTS 内命令只保留最常用一条示例，其余指向 README。

### 3.2 README 目录树与 INDEX §2 矛盾
**陷阱**：README 自行整理了一套目录树，与 INDEX §2 描述不一致。  
**后果**：新读者与 Agent 获得矛盾的项目结构认知。  
**正确做法**：README 目录树直接从 INDEX §2 提取，禁止另起一套。

### 3.3 AGENTS 项目概述超过 3 行
**陷阱**：在 AGENTS 中写了详细的项目背景、业务说明。  
**后果**：AGENTS 臃肿，Agent 读取时上下文浪费。  
**正确做法**：AGENTS 项目概述 ≤3 行，细节链到 README 与 INDEX §1。

### 3.4 更新模式下覆盖已有有效内容
**陷阱**：`--mode update` 时直接覆盖已有 README，丢失有效命令块或表格。  
**后果**：历史积累的有效文档内容丢失。  
**正确做法**：diff 比较后合并，保留已有有效段落，只更新过时或缺失部分。

---

## 4. 验收阶段

### 4.1 跳过路径一致性校验
**陷阱**：生成后未验证 AGENTS 中的路径引用是否在磁盘上存在。  
**后果**：Agent 按 AGENTS 指引打开文件时报 404，工作流中断。  
**正确做法**：发布前执行验收清单，或运行 `scripts/validate-guide.sh --root .`。

### 4.2 AGENTS 首条参考路径写错
**陷阱**：AGENTS「先读什么」表格中 INDEX 路径与 §1 解析到的实际路径不符。  
**后果**：Agent 启动时找不到地图，退化为无 Index 状态。  
**正确做法**：AGENTS 首条参考路径必须与 §1 记录的实际落盘路径完全一致。

---

## 5. 禁止在本 Skill 内调用 docs-indexing

**陷阱**：发现 Index 过时或缺失，在 agent-guide 执行流程内自动触发 docs-indexing。  
**后果**：职责混淆，执行链不可预期，可能覆盖用户未提交的 Index 变更。  
**正确做法**：agent-guide 只读 Index，不写 Index；需要更新 Index 时，单独运行 `/docs-indexing`。

---

## 快速检查清单

完整验收清单与反模式见 [reference/quality-standards.md](reference/quality-standards.md)。以下为本文所列陷阱的快速自查：

- [ ] Index 来自磁盘落盘文件，非对话粘贴（§1.1）
- [ ] 未命中 Index 时已终止，未编造结构（§1.2）
- [ ] 以 INDEX 为地图最小阅读，未通读全仓（§2.1）
- [ ] AGENTS 未粘贴 INDEX §3 API 入口表（§2.2）
- [ ] 未索引区域未写成已核实事实（§2.3）
- [ ] 先 README 后 AGENTS，命令块未重复（§3.1）
- [ ] README 目录树与 INDEX §2 一致（§3.2）
- [ ] AGENTS 项目概述 ≤3 行（§3.3）
- [ ] 更新模式下合并而非覆盖（§3.4）
- [ ] AGENTS 首条参考路径可跳转（§4.2）
- [ ] 未在本 Skill 内调用 docs-indexing（§5）
