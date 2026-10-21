# docs-upgrade 工作流

## 参数向导

整树且目标 `DESIGN.md` 有 `version` 时，在元库所选 ref 的可达历史中解析当前版本和最新 `docs-publish` 发布提交，输出 `from..to` 与两个 commit。缺基线、非 Git 源或当前点不是目标祖先即停止，不猜测、不降级全量；无版本号的旧库保留整树模式。文件模式仍强制对齐指定路径，不以版本差异缩小名单、不推进整库版本。

按序收口；用户已明确时可跳过对应项：

1. 当前工程（含 `.docsconfig`；通常即 cwd 所属工程）
2. meta 源：默认读 `{文档目录}/knowledge-links.yaml` 的唯一 `type: meta`；可选 `--meta-path`
3. 可选 `--ref`（**不传则默认不按 main 对齐**；见「源解析」）
4. 模式：有 ≥1 个可解析的真实文件/目录路径 → 指定路径强制对齐；无 → 整树（默认先 dry-run）

参数未收口前，不进入执行。同一次单元不混两模式。

## 当前单元

**一次升级计划** = 一个当前单元（单个 `文档目录`）。

一次只推进一个工程；不并行多仓。

## 源解析

优先级：**`--ref`（若传）> 有效 path > clone**。YAML `path` 只接受 `${WORK_SPACE}/…`；`--meta-path` 也可传本机路径，但必须位于所属库工作区内。

1. `docsconfig_bootstrap_validate`（或等价）读 `.docsconfig`
2. 缺 config → 硬停，提示 `/docs-install`
3. 读 links；缺唯一 `type: meta` 且无 `--meta-path` → 硬停，列修复选项（补 meta / `--meta-path` / 重跑 install upsert）
4. 展开 `path`（或 `--meta-path`）：
   - 为 git 仓：`git status --porcelain` 非空 → **硬停**（含已传 `--ref`）
   - 已传 `--ref`：`fetch` 后 `git archive origin/$ref`，否则本地 `$ref`，都无 → 硬停
   - 未传 `--ref`：**不 fetch**；以当前 HEAD 作为历史边界。无版本模式读取 HEAD；增量模式读取该历史内最新发布提交快照
   - path 非 git 但含 `application|system|solution|company` → 直接用该目录
   - path 无效 → 有 `repository` 则临时 clone 完整历史（`--ref` 或默认 `main`）；指定分支不存在即停止，不回退其他分支
5. 结构源根 = `{meta_root}/{dir}/`，其中 `dir` 优先 meta 条，否则 `KNOWLEDGE_TYPE`
6. 整树增量：当前/目标提交均来自元库所选 ref 的可达历史，所有模板读取固定到目标发布提交（含显式 `--ref`）；按 `{dir}/相对路径` 的差异筛选动作。`README-s.md` 先按元库源路径过滤，再映射到本库 `README.md`。不得改用目标工程的 Git diff 或未发布的 HEAD 内容

## 执行循环：整树

### 1 准备

- Bash 5+、Git
- 元库可调用本技能 `scripts/docs-upgrade.sh`

### 2 dry-run 清单

```bash
bash agent/skills/docs-upgrade/scripts/docs-upgrade.sh --dry-run [--meta-path PATH] [--ref REF]
```

脚本输出清单桶（新增骨架 / 跳过 / 结构重填 / 整文件覆盖 / 本库独有）+「忽略遗留槽位」+「跳过软链」摘要（见 [merge-rules.md](merge-rules.md)）。展示后立即校核，停等 `C/M/S/F`。

### 3 实跑（用户 `C` 后）

1. **备份 + 新增骨架**（机械）：

   ```bash
   bash agent/skills/docs-upgrade/scripts/docs-upgrade.sh --apply-scaffold [--meta-path PATH] [--ref REF]
   ```

   将改路径 mirror 到 `{仓库路径}/.docs-init/upgrade-{stamp}/`，再写入元库新增且本库缺失的允许文件。
   脚本收尾：与 `/docs-install` 同契约，对整棵 `文档目录` 将裸 `agent/`、多层上跳 `../agent/` 与已知 IDE Agent 路径重写为 `~/.agents/`，并更新 README Agent 路径注记（空骨架桶亦跑；`--dry-run` 不做）。

2. **结构重填**（Agent）：对「结构重填」桶中每个 `.md`，按 [merge-rules.md](merge-rules.md) §5（H2至H6 元库结构、同标题不比层级、正文相对元库标题级平移且封顶 H6）；产出**未落位节清单**（本库有、元库无同标题）。本步**不**自动再跑路径重写。
   - 清单 `C`：处理全部可处理重填项；对齐节按 §5 写入；有未落位则随后出策略三档（见 [gates.md](gates.md)）
   - `M`：下钻单文件；该文件 `C` 与清单 `C` 同语义（范围=该文件）

3. **未落位**：`C` 之后选策略——批量文件并入 / 单文件批量并入 / 逐项并入。并入=原父级（同标题并入、层级递增；父消失→追加文末）。仅已确认策略下的写入才落盘（见 [gates.md](gates.md)、[merge-rules.md](merge-rules.md) §5）。

失败则整单停，不静默改桶策略重试。

### 4 写后停顿

1. 校核：`文档目录` 仍在、links 未丢、备份目录存在（若有写入）
2. 受众维 **A/B**
3. 增量整单全部可处理项完成、未落位处理闭合且校核通过后，才将本库 `DESIGN.md` 的 `version` 更新为清单中的目标版本；再次核对落盘值。`--apply-scaffold` 只保留当前基线；失败、中断或跳过待处理项时不得推进版本，后续重试继续使用原区间。重填必须读取本次已固定的目标发布 commit
4. 停下等待 `C/M/S/F`

未过 A/B → 不得宣称单元完成。

## 执行循环：指定路径强制对齐

### 1 解析指定路径

1. 收集会话/附件中的文件与目录；文件路径入名单，目录路径取**本库与元库同相对路径并集**（必须反向扫描元库，防漏 `BD/BD-EXAMPLE/**` 这类 `meta-only` scaffold）
2. 校验：`文档目录` 内路径规范化为相对路径；软链 / 顶层遗留槽位名拒绝；`文档目录` 外路径拒绝；`*-slots` 根真文件允许
3. 去重后分类：`meta-only` → scaffold 候选、`local-only` → 元缺拒绝候选、`both` → 按 [merge-rules.md](merge-rules.md) §7 判定动作；动作数断言须覆盖并集总数
4. fetch/解析 meta（与整树同源规则）

### 2 总览闸门

展示解析后 N 条及动作类型，并显式列出 `meta-only` scaffold 文件。停等总览 `C`（可处理项；有未落位则随后出策略三档）/ `M`（改路径名单或下钻）/ `S`（取消整单）/ `F`（不扩到整树）。

总览未 `C` 前不得写任一文件（除非已 `M` 进入单文件并对该文件 `C`）。

### 3 执行（总览 `C` 或单文件 `C` 后）

**总览 `C`**：对名单中全部**可处理**项写盘（强制重填契约同 [merge-rules.md](merge-rules.md) §5；有未落位则随后出策略三档；拒绝项只报告）。

**`M` 下钻单文件**后：

1. 展示该文件预览（将 scaffold / 强制重填摘要；`.md` 可含未落位预告）
2. 该文件 `C`：与总览 `C` 同语义（范围=该文件；有未落位则出策略三档）；`S` 跳过本文件；`M` 改本文件参数或预览；已写盘不回滚
3. `.md` 强制重填：契约同整树结构重填与未落位策略
4. 本缺元有：Agent 复制元库该相对路径到目标
5. 非 md 两边都有：不覆盖（总览已标跳过则本步可略）
6. **不**写 `{仓库路径}/.docs-init/`（依赖 git）

### 4 写后停顿

全部预定项处理完（含 S）后：产物校核 → 整单一次 **A/B** → 停等 `C/M/S/F`。未过 A/B → 不得宣称单元完成。

## 禁止路径

- `docs-install.sh --scope=knowledge`（会备份清空 DOC_DIR）
- 静默删除本库独有文件
- 用元库覆盖 `knowledge-links.yaml`
- 文件模式与整树混在同一单元
- 文件模式指定 `文档目录` 外路径（非允许范围）
