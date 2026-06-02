# sdx-test 门禁

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

## 写入 `TDD-*.md`

- **默认**：总确认完成前，禁止写入 `{DOC_DIR}/requirements/**/TDD-*.md`。
- **例外**（须留痕）：（1）用户同轮明示跳过门禁 / 只要草稿 / 紧急直写终稿；（2）`SDX_TEST_ALLOW_TDD_WRITE=1`。

## Spec 标记

- 路径：符合 `{DOC_DIR}/superpower/specs/`（见 [session-spec-path.md](../../../references/session-spec-path.md)）。

- 文末：`<!-- sdx-test-gate: PENDING -->` → 总确认后 `CONFIRMED`。
- 正文至少一次与目标一致的 `TDD-{IDEA-ID}-{N}.md`。

## 与 `/brainstorming`

主产物为 `…-sdx-test.md` + `TDD-*.md`；默认不以 `*-design.md` + `writing-plans` 为终态。见 [brainstorming-integration.md](brainstorming-integration.md)。

## 四选项（阶段二与 Qclose-1）

```
C：确认，进入下一步
M：修改，格式 "M 旧内容 - 新内容"
S：跳过本门禁，按默认推进
F：跳过全部门禁，直接拟稿/写终稿
```

**F** 写终稿须符合上文「例外」。

## Qclose-1

> 是否同意以当前草稿为唯一素材生成 `TDD-{IDEA-ID}-{N}.md`？（附四选项）

- **C / S**：`PENDING` → `CONFIRMED`，进阶段三。
- **M**：回修 spec。
- **F**：直写须合法例外。

**确认人**：`$HOME` 末级目录名（用户名）。
