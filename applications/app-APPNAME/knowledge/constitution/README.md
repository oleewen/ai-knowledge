# constitution — 宪法与治理层

使命：决策 **透明、一致、可追溯**，避免架构随口语漂移。

---

## 组件

| 组件 | 路径与元数据 |
|------|----------------|
| 本层 | [applications/app-APPNAME/knowledge/constitution/constitution_meta.yaml](constitution_meta.yaml) |
| 术语表 | [applications/app-APPNAME/knowledge/constitution/GLOSSARY.md](GLOSSARY.md) |
| 架构原则 | [applications/app-APPNAME/knowledge/constitution/principles/](principles) · [applications/app-APPNAME/knowledge/constitution/principles/principles_meta.yaml](principles/principles_meta.yaml) |
| 标准与模板 | [applications/app-APPNAME/knowledge/constitution/standards/](standards) · [applications/app-APPNAME/knowledge/constitution/standards/standards_meta.yaml](standards/standards_meta.yaml) |
| ADR | [applications/app-APPNAME/knowledge/constitution/adr/](adr) · [applications/app-APPNAME/knowledge/constitution/adr/adr_meta.yaml](adr/adr_meta.yaml) · [applications/app-APPNAME/knowledge/constitution/adr/adr-template.md](adr/adr-template.md)；正文 `ADR-{序号}-{短标题}.md` |

---

## 使用顺序

1. 新词 / 歧义 → 先查或补 **GLOSSARY**  
2. 新实体 / 文件 → 遵守 **standards/NAMING-CONVENTIONS.md**  
3. 跨域或长期后果的决策 → 新增 **adr/**，按 **adr/adr-template.md**  

---

## 索引指针

- 本知识树入口：[applications/app-APPNAME/knowledge/README.md](../README.md)  
- 仓库根 Index Guide：[INDEX_GUIDE.md](../../../../INDEX_GUIDE.md)  
