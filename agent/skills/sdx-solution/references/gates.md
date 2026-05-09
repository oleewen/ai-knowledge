# sdx-solution 门禁

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

## 写入 `SOLUTION-*.md`

- **默认**：总确认完成前，禁止写入 `{DOC_DIR}/solutions/SOLUTION-*.md`。
- **例外**（须在对话留痕）：（1）用户同轮明示跳过门禁 / 只要草稿 / 紧急直写终稿；（2）`SDX_SOLUTION_ALLOW_SOLUTION_WRITE=1`。

## Spec 标记

- 文末：`<!-- sdx-solution-gate: PENDING -->`，总确认后改为 `CONFIRMED`。
- 正文至少出现一次与 IDEA-ID 一致的 `SOLUTION-{IDEA-ID}.md`。

## 与独立 `/brainstorming`

主产物仍为 `…-sdx-solution.md` + `SOLUTION-*.md`；不以 `*-design.md` + `writing-plans` 为默认终态。嵌入方式见 [brainstorming-integration.md](brainstorming-integration.md)。

## 四选项（阶段二门禁末与 Qclose-1）

```
C：确认，进入下一步
M：修改，格式 "M 旧内容 - 新内容"
S：跳过本门禁，按默认推进
F：跳过全部门禁，直接拟稿/写终稿
```

**F** 写终稿须符合上文「例外」，否则违规。

## Qclose-1

全部门禁收口后：

> 是否同意以当前草稿为唯一素材生成 `SOLUTION-{IDEA-ID}.md`？（附四选项）

- **C / S**：`PENDING` → `CONFIRMED`，进入阶段三。
- **M**：回修 spec。
- **F**：直写草稿须合法例外。

**确认人**：`$HOME` 末级目录名（用户名），勿用显示名或占位词。
