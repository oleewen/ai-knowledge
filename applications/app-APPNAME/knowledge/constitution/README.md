# constitution — 宪法与治理层

使命：决策 **透明、一致、可追溯**，避免架构随口语漂移。

---

## 组件

| 组件 | 路径与元数据 |
|------|----------------|
| 本层 | [constitution_meta.yaml](./constitution_meta.yaml) |
| 术语表 | [GLOSSARY.md](./GLOSSARY.md) |
| 架构原则 | [principles/](./principles/) · [principles_meta.yaml](./principles/principles_meta.yaml) |
| 标准与模板 | [standards/](./standards/) · [standards_meta.yaml](./standards/standards_meta.yaml)；ADR 约定 · [adr_meta.yaml](./standards/adr_meta.yaml) |
| ADR 文集 | [adr/](./adr/) · [adr_corpus_meta.yaml](./adr/adr_corpus_meta.yaml) |

---

## 使用顺序

1. 新词 / 歧义 → 先查或补 **GLOSSARY**  
2. 新实体 / 文件 → 遵守 **standards/naming-conventions.md**  
3. 跨域或长期后果的决策 → 新增 **adr/**，按 **standards/adr-template.md**  

---

## 索引指针

- 本应用：[../../INDEX.md](../../INDEX.md)
- applications 聚合：[../../../INDEX.md](../../../INDEX.md)
- 仓库根 Index Guide：[../../../../INDEX.md](../../../../INDEX.md)
