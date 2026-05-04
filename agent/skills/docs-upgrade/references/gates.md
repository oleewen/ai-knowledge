# docs-upgrade 门禁与边界

与 [workflow.md](workflow.md)、[brainstorming-integration.md](brainstorming-integration.md) 互补；**操作层易错点**见上级 [gotchas.md](../gotchas.md)。

---

## 适用边界

- **本技能负责**：定向增改 Markdown、注释与配置文本；默认链式同步（引用链 + 关键词/语义检索）；替换简写 `a - b` / `a > b` / `a 2 b`。
- **本技能不负责**：变更聚合 `CHANGE-LOG.md`（**docs-change**）、全量/增量 `INDEX_GUIDE`（**docs-indexing**）、overview 按视角归档（**docs-archive**）、实体与 `KNOWLEDGE_INDEX`（**docs-build**），除非用户明确把这些列为附加任务。
- **分流**：用户只要上述下游产物时，以对应技能为主路径，不把「仅术语/文档对齐」当作替代。

---

## HARD-GATE（范围确认书）

**在执行任何写入前**，须先完成会话内**范围确认书**并得到用户明确同意（`C` / `S`；`M` 表示先改范围再确认）。

**触发条件**：多文件同步、全库或大目录术语替换、意图不明确时**必须**触发。单文件小改且路径与改动已明确时，可走**快路径**：一句话复述「将修改 X，改动：Y」，用户确认后执行。

**禁止**：未收到 `C` 或 `S` 前**批量写入多个文件**；不得在范围未界定时开始步骤 3 的大范围同步。

可复制模板见 [../assets/docs-upgrade-scope-ack-template.md](../assets/docs-upgrade-scope-ack-template.md)。

**范围确认书（会话内，可不落盘文件）**：

```
即将执行 /docs-upgrade，范围如下：
- 主目标文件: <路径>
- 改动摘要: <替换/增改内容>
- 关联同步范围: <引用链 N 个文件 / 关键词检索 N 处 / 仅本文件>

C 确认执行 / M 修改范围 / S 跳过关联同步仅改主文件
```

收到 **C** 或 **S** 后方可写入（`S` 仅改主文件，不扩展关联）。

---

## 与其它门禁的关系

- **不是** superpowers「先写设计 spec 到 `docs/superpowers/specs/` 再实现」的完整 brainstorming；嵌入节奏见 [brainstorming-integration.md](brainstorming-integration.md)。
- 本仓库 **未** 为 `docs-upgrade` 注册 `preToolUse` 钩子；合规依赖执行模型遵守上文 HARD-GATE。
