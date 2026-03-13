# Java开发规范指南

> Java开发规范，涵盖编码风格、架构模式、最佳实践

## 技术栈规范

### 核心框架
- **Java版本**: Java 17+ (使用最新LTS版本特性)
- **Spring Boot**: 2.7.10+ (使用自动配置和启动器机制)
- **构建工具**: Maven 3.6+
- **ORM框架**: MyBatis + tk.mybatis
- **RPC框架**: Dubbo 2.7.x
- **数据库**: MySQL 8.0+

### 辅助工具
- **对象映射**: MapStruct 1.5+
- **代码简化**: Lombok 1.18+
- **测试框架**: JUnit 5 + Mockito
- **API文档**: Swagger 3.0+
- **验证框架**: Bean Validation 2.0+

## 编码规范

### 1. 命名规范
- **类名**: PascalCase（例：`OrderService`）
- **方法名**: camelCase（例：`createOrder()`）
- **变量名**: camelCase（例：`orderAmount`）
- **常量名**: UPPER_CASE_WITH_UNDERSCORES（例：`MAX_ORDER_AMOUNT`）
- **包名**: 全小写，域名反写（例：`com.ai.master.order.domain`）

### 2. 类设计规范
```java
// 领域模型示例
package com.ai.master.order.domain.model;

import lombok.Data;
import javax.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单聚合根
 * 
 * 负责管理订单的生命周期和业务规则
 */
@Data
public class Order {
    private OrderId id;
    private UserId buyerId;
    private OrderStatus status;
    
    @NotNull(message = "订单金额不能为空")
    @DecimalMin(value = "0.01", message = "订单金额必须大于0")
    private BigDecimal totalAmount;
    
    @NotEmpty(message = "订单项不能为空")
    private List<OrderItem> items;
    
    // 领域行为
    public void confirm() {
        if (this.status != OrderStatus.PENDING) {
            throw new IllegalStateException("只有待确认状态的订单才能确认");
        }
        this.status = OrderStatus.CONFIRMED;
        this.updatedAt = LocalDateTime.now();
    }
}
```

### 3. 接口设计规范
```java
// API接口示例
package com.ai.master.order.api.service;

import com.ai.master.order.api.request.OrderCreateRequest;
import com.ai.master.order.api.response.OrderCreateResponse;
import javax.validation.Valid;

/**
 * 订单服务接口
 */
public interface OrderService {
    
    /**
     * 创建订单
     * 
     * @param request 订单创建请求
     * @return 订单创建响应，包含生成的订单ID
     * @throws ValidationException 当请求参数无效时
     * @throws BusinessException 当业务规则不满足时
     */
    OrderCreateResponse createOrder(@Valid OrderCreateRequest request);
}
```

### 4. 异常处理规范

#### 异常分类
- **业务异常**: `BusinessException` - 业务规则不满足
- **系统异常**: `SystemException` - 系统级错误
- **参数异常**: `ValidationException` - 参数验证失败
- **数据异常**: `DataNotFoundException` - 数据不存在

#### 异常处理层级
```java
// 全局异常处理器
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ErrorResponse> handleValidation(ValidationException e) {
        return ResponseEntity.badRequest()
            .body(ErrorResponse.of("INVALID_PARAMETER", e.getMessage()));
    }
    
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusiness(BusinessException e) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
            .body(ErrorResponse.of("BUSINESS_ERROR", e.getMessage()));
    }
}
```

### 5. 数据访问规范

#### Repository模式
```java
// 领域仓储接口
package com.ai.master.order.domain.repository;

import com.ai.master.order.domain.model.Order;
import com.ai.master.order.domain.model.OrderId;
import java.util.Optional;

public interface OrderRepository {
    Order save(Order order);
    Optional<Order> findById(OrderId id);
    List<Order> findByUserId(UserId userId);
    boolean exists(OrderId id);
}
```

#### MyBatis使用规范
```java
// Mapper接口示例
@Mapper
public interface OrderMapper extends Mapper<OrderEntity> {
    
    @Select("SELECT * FROM t_order WHERE user_id = #{userId}")
    List<OrderEntity> findByUserId(@Param("userId") Long userId);
    
    @Update("UPDATE t_order SET status = #{status} WHERE id = #{id}")
    int updateStatus(@Param("id") Long id, @Param("status") String status);
}
```

## 日志规范

### 1. 日志级别使用
- **ERROR**: 系统异常、需要立即处理的问题
- **WARN**: 潜在问题、业务异常
- **INFO**: 业务关键路径、重要状态变更
- **DEBUG**: 调试信息、详细执行流程
- **TRACE**: 最详细信息，通常不开启

### 2. 日志格式
```java
@Slf4j
public class OrderApplicationService {
    public void createOrder(OrderCreateCommand command) {    
        try {
            // 业务逻辑
            log.info("订单创建成功, orderId: {}", order.getId());
        } catch (Exception e) {
            log.error("订单创建失败, userId: {}", command.getUserId(), e);
            throw e;
        }
    }
}
```
