# Maven规范指南

> **按需启用**：目标工程为 Maven 时使用；**非本仓默认约束**。

**结论**：多模块骨架与依赖方向以 [project-structure.md](project-structure.md) 为 SSOT；本文只管父 POM、依赖/版本、构建与质量门禁。

## 与模块结构的关系

- 八模块目录与依赖图 → [project-structure.md](project-structure.md)
- Maven 侧补充：仓库根保留**父 `pom.xml`**；各模块自有 `pom.xml`；版本用父 POM `dependencyManagement` / revision 统一锁定

> 烤干待决：原文依赖图含 `service → api`，project-structure 图未画该边。本轮**未**改 structure。

## 依赖管理

| 规则 | 要求 |
| --- | --- |
| 最小依赖 | 只引入必要依赖 |
| 版本锁定 | 父 POM 统一管理 revision / BOM |
| 版本号 | 语义化 `主.次.修订`：主=不兼容；次=兼容新功能；修订=兼容修复 |
| 分析 | 定期 `mvn dependency:analyze` |
| 安全 | OWASP 依赖检查；高危须清零（见门禁） |

## 构建

| 手段 | 做法 |
| --- | --- |
| 并行 | `mvn -T 4 clean package`（线程数按机器调整） |
| 增量 | 用好 Maven 增量编译 |
| 缓存 | 合理配本地/远程仓库缓存与构建缓存 |

## 质量门禁

| 项 | 标准 |
| --- | --- |
| 编译警告 | 零警告 |
| 单测覆盖率 | ≥ 80% |
| 依赖漏洞 | 零高危 |
| 静态检查 | Checkstyle + PMD |
