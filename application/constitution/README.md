# constitution — 宪法与治理层

使命：决策 **透明、一致、可追溯**，避免架构随口语漂移。

---

## 组件


| 组件    | 路径与元数据                                                                                                                  |
| ----- | ----------------------------------------------------------------------------------------------------------------------- |
| 本层    | [constitution_meta.yaml](constitution_meta.yaml)                                                                        |
| 术语表   | [GLOSSARY.md](GLOSSARY.md)                                                                                              |
| 架构原则  | [principles](principles) · [principles/principles_meta.yaml](principles/principles_meta.yaml)                           |
| 标准与模板 | [standards](standards) · [standards/standards_meta.yaml](standards/standards_meta.yaml)                                 |
| ADR   | [adr](adr) · [adr/adr_meta.yaml](adr/adr_meta.yaml) · [adr/adr-template.md](adr/adr-template.md)；正文 `ADR-{序号}-{短标题}.md` |


---

## 使用顺序

1. 新词 / 歧义 → 先查或补 **GLOSSARY**
2. 新实体 / 文件 → 遵守 **standards/naming-conventions.md**
3. 跨域或长期后果的决策 → 新增 **adr/**，按 **adr/adr-template.md**

---

## 索引指针

- `application/` 入口：[../README.md](../README.md)  
- 仓库根 Index Guide：[INDEX_GUIDE.md](../../INDEX_GUIDE.md)