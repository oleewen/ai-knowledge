# 文档规范

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
