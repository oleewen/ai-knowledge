# specs — 需求规约

服务 / 接口 / 契约等**规格**目录：供 **solutions**、**analysis**、**requirements** 引用，与 `knowledge/technical` 中的应用与接口信息互补。

---

## 怎么用

1. 按服务或规约类型建子目录（示例：[example-service/](./example-service/)）  
2. 文内用 **ID** 与路径引用，不在多份 PRD 里重复粘贴同一段 OpenAPI  
3. 变更时同步依赖该规约的阶段文档或 ADR  

---

## 约定

- 格式（YAML / Markdown 等）由项目约定；元数据说明见 [specs_meta.yaml](./specs_meta.yaml)  
- 子目录（如 [example-service/](./example-service/)）为规约实例锚点，**不**要求每层单独 `*_meta.yaml`；细则以 `specs_meta.yaml` 为准  
- 设计背景：[../DESIGN.md](../DESIGN.md) §2.10  
