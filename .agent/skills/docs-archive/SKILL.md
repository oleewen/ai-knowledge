---

## name: docs-archive

description: >
  将应用知识库（system/application-{name}）已核实内容归档到系统知识库（system/architecture/）。
  当用户执行 /docs-archive，或提到「归档」「同步应用知识到系统」「同步一下」
  「把应用侧内容推上去」「更新主库」时必须触发本技能。
  支持 --app --since --full --dry-run，默认按增量锚点归档。

# 应用知识归档到系统库（docs-archive）

> 目标：把 `system/application-{name}/` 的可晋升内容，归档到 `system/architecture/` 受管区块，并形成可追溯日志链路。

## 三日志职责（必须区分）


| 日志文件                                                  | 职责                    | 写入时机             |
| ----------------------------------------------------- | --------------------- | ---------------- |
| `system/application-{name}/changelogs/CHANGE-LOG.md`  | 应用侧变更来源，定义可归档增量候选区间   | 步骤 0 读取，不在本技能内写入 |
| `system/application-{name}/changelogs/ARCHIVE-LOG.md` | 应用侧归档锚点，记录已归档到哪个变更位置  | 归档成功后更新          |
| `system/changelogs/CHANGE-LOG.md`                     | 系统侧归档批次总账，记录本次归档结果与范围 | 每次归档先写           |


## 参数契约


| 参数          | 默认                        | 说明                                                    |
| ----------- | ------------------------- | ----------------------------------------------------- |
| `--app`     | 全部已登记应用                   | 仅处理指定应用，如 `billing`（对应 `system/application-billing/`） |
| `--since`   | 从应用 `ARCHIVE-LOG.md` 锚点继续 | 手动指定起始变更点，覆盖自动锚点                                      |
| `--full`    | `false`                   | 全量重建归档内容，但**仅覆盖目标文件中的受管区块**，区块外内容保持不变                 |
| `--dry-run` | `false`                   | 仅预览不落盘，输出三层预览：候选变更区间、受影响目标文件/区块、将写入三日志的条目摘要           |


## 原子顺序（严格执行）

1. 读取应用 `CHANGE-LOG.md`，结合 `--since/--full` 计算归档范围。
2. 写入系统归档目标（仅受管区块）。
3. **先写** `system/changelogs/CHANGE-LOG.md`（系统总账）。
4. **再写** `system/application-{name}/changelogs/ARCHIVE-LOG.md`（应用锚点前移）。

若步骤 3 失败，禁止执行步骤 4，确保“系统总账先于应用锚点”。

## 工作流（执行版）

### 步骤 0：计算范围

- 默认从 `system/application-{name}/changelogs/ARCHIVE-LOG.md` 最近锚点继续。
- 若传 `--since`，以 `--since` 为准。
- 若传 `--full`，忽略锚点并执行全量归档（仍只写受管区块）。

### 步骤 1：提取与映射

- 从 `system/application-{name}/` 提取本次区间内可晋升内容。
- 按规则映射到 `system/architecture/` 目标文件。

### 步骤 2：写入系统目标

- 仅更新受管区块（`BEGIN/END MANAGED BLOCK`）。
- 不改动区块外人工维护内容。

### 步骤 3：日志写入（原子）

- 先追加 `system/changelogs/CHANGE-LOG.md`。
- 再追加 `system/application-{name}/changelogs/ARCHIVE-LOG.md`。

## 命令示例（新命名）

```bash
/docs-archive --app billing --dry-run
/docs-archive --app billing --since v1.2.0
/docs-archive --app billing --full
/docs-archive --app billing --since "2026-04-01T00:00:00Z" --dry-run
```

## 约束

- 默认增量，不重复归档已锚定区间。
- `--full` 仅覆盖受管区块，不做全文件覆盖。
- 禁止修改已有实体 ID；新增 ID 必须全局唯一。

## 参考

- [reference/archive-spec.md](reference/archive-spec.md)
- [reference/archive-log-spec.md](reference/archive-log-spec.md)
- [reference/federation-spec.md](reference/federation-spec.md)
- [gotchas.md](gotchas.md)

