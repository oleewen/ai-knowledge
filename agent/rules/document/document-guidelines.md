# 文档规范

## Markdown 文档分类规范

### 先判类，再写结构

- 新增或修改 Markdown 文档前，先判断该文件属于
  `A 人类入口类`、`B 机器规约类`、`C 元数据/混合类`
  中的哪一类，再决定是否保留 `frontmatter title`、
  可见 `# H1` 与 `MD025` 豁免。

### A 类：人类入口类

- 典型文件：`README.md`、`AGENTS.md`、`INDEX-GUIDE.md`、
  `index.md`、导航型 `README.md`
- 默认保留可见 `# H1` 作为读者首标题。
- `frontmatter title` 仅在已有生成链或读取约束明确需要时保留。

### B 类：机器规约类

- 典型文件：per-entity `{ID}.md`、`SOLUTION-*`、`ANALYSIS-*`、
  `PRD-*`、`ASD-*`、`DSD-*`、`TDD-*`、模板/样例/规约文档
- 默认保留 `frontmatter title` 作为机器消费字段。
- 不得只为消除 `MD025` 而删除 `title`。

### C 类：元数据/混合类

- 典型文件：`docs-meta.md`、`knowledge-meta.md`、`CHANGE-LOG.md`
  及兼具阅读与规则消费的说明文件
- 在边界未完全拆清前，允许阶段性保留
  `frontmatter title` + 可见 `# H1` +
  `<!-- markdownlint-disable-next-line MD025 -->`。

### `MD025` 使用规则

- 若文件同时依赖 `frontmatter title` 与可见 `# H1`，
  则 `MD025` 单行豁免属于必要豁免。
- 若文件已经只保留其中一种标题机制，则不得继续保留该豁免。
- 新文档创建时，必须先判类；禁止先复制旧文件再事后补判断。

## 代码文档规范

### Java文档注释

- 所有公共API必须有JavaDoc注释
- 包含参数说明、返回值、异常信息
- 示例：

```java
/**
 * 创建订单
 *
 * @param orderDTO 订单创建请求
 * @return 订单ID
 * @throws IllegalArgumentException 当订单参数无效时
 * @throws OrderException 当订单创建失败时
 */
public String createOrder(OrderDTO orderDTO);
```

### 类文档

- 说明类的用途和职责
- 描述重要的设计决策
- 说明使用注意事项
- 示例：

```java
/**
 * 订单领域服务
 * 
 * 负责处理订单相关的核心业务逻辑，包括：
 * 1. 订单创建
 * 2. 订单状态管理
 * 3. 订单金额计算
 * 
 * 注意：本服务是线程安全的
 */
public class OrderDomainService {
```

### 包文档

- 在package-info.java中说明包的用途
- 描述包内的主要组件
- 说明包级别的约束

## 注释规范

### 代码注释

- 解释复杂的业务逻辑
- 说明重要的算法实现
- 标注代码的局限性
- 示例：

```java
// 使用二分查找优化性能，要求列表已排序
private int findOptimalPosition(List<Integer> sortedList, int target) {
```

### TODO注释

- 明确说明待完成的工作
- 标注优先级和负责人
- 示例：

```java
// TODO(high): 需要添加缓存机制提高性能 - @张三
```
