# 测试规范指南

> 测试规范，涵盖单元测试、集成测试、质量门禁要求

## 质量门禁标准

### 测试覆盖率要求
| 指标 | 阈值 | 检查工具 | 说明 |
|------|------|----------|------|
| **单元测试覆盖率** | ≥80% | Jacoco | 核心业务逻辑必须覆盖 |
| **代码重复率** | ≤5% | PMD/CPD | 避免代码重复 |
| **严重漏洞** | 0 | SonarQube | 安全漏洞零容忍 |
| **编译警告** | 0 | Maven/Compiler | 保持代码清洁 |
| **代码风格违规** | ≤10 | Checkstyle | 统一编码风格 |

### 测试分层策略
- **单元测试**: 覆盖领域模型、领域服务
- **集成测试**: 覆盖应用服务、仓储实现
- **端到端测试**: 覆盖API接口、业务流程
- **性能测试**: 覆盖关键业务路径

## 单元测试规范

### 1. 测试框架配置
```xml
<!-- pom.xml 测试依赖 -->
<dependency>
    <groupId>junit</groupId>
    <artifactId>junit</artifactId>
    <version>4.13.2</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-core</artifactId>
    <version>4.11.0</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

### 2. 测试命名规范
- **测试类**: `{ClassName}Test`
- **测试方法**: `should{ExpectedBehavior}When{Condition}`
- **测试包**: 与被测试类相同的包结构

### 3. 领域模型测试
```java
package com.ai.master.order.domain.model;

import org.junit.Test;
import static org.junit.Assert.*;

public class OrderTest {
    
    @Test
    public void shouldCreateOrderWithValidData() {
        // Given
        OrderId orderId = OrderId.generate();
        UserId userId = UserId.of(123L);
        
        // When
        Order order = Order.create(orderId, userId);
        
        // Then
        assertNotNull(order);
        assertEquals(orderId, order.getId());
        assertEquals(OrderStatus.CREATED, order.getStatus());
    }
    
    @Test(expected = IllegalStateException.class)
    public void shouldThrowExceptionWhenConfirmingNonPendingOrder() {
        // Given
        Order order = Order.create(OrderId.generate(), UserId.of(123L));
        order.cancel(); // 先取消订单
        
        // When & Then
        order.confirm(); // 尝试确认已取消的订单
    }
}
```

### 4. 领域服务测试
```java
package com.ai.master.order.domain.service;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnitRunner;

import java.math.BigDecimal;
import java.util.Arrays;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

@RunWith(MockitoJUnitRunner.class)
public class OrderDomainServiceTest {
    
    @Mock
    private OrderRepository orderRepository;
    
    @InjectMocks
    private OrderDomainService orderDomainService;
    
    @Test
    public void shouldCalculateTotalAmountCorrectly() {
        // Given
        OrderItem item1 = new OrderItem("商品1", new BigDecimal("100.00"), 2);
        OrderItem item2 = new OrderItem("商品2", new BigDecimal("50.00"), 1);
        
        // When
        BigDecimal total = orderDomainService.calculateTotalAmount(
            Arrays.asList(item1, item2)
        );
        
        // Then
        assertEquals(new BigDecimal("250.00"), total);
    }
    
    @Test
    public void shouldValidateOrderSuccessfully() {
        // Given
        Order order = Order.create(OrderId.generate(), UserId.of(123L));
        order.addItem(new OrderItem("商品1", new BigDecimal("100.00"), 1));
        
        // When
        ValidationResult result = orderDomainService.validateOrderCreation(order);
        
        // Then
        assertTrue(result.isSuccess());
    }
}
```

### 5. 仓储接口测试
```java
package com.ai.master.order.domain.repository;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.Assert.*;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class OrderRepositoryTest {
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Test
    public void shouldSaveAndRetrieveOrder() {
        // Given
        Order order = Order.create(OrderId.generate(), UserId.of(123L));
        
        // When
        Order savedOrder = orderRepository.save(order);
        Order retrievedOrder = orderRepository.findById(savedOrder.getId()).orElse(null);
        
        // Then
        assertNotNull(retrievedOrder);
        assertEquals(savedOrder.getId(), retrievedOrder.getId());
    }
}
```

## 集成测试规范

### 1. 应用服务测试
```java
package com.ai.master.order.application.service;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.Assert.*;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class OrderApplicationServiceTest {
    
    @Autowired
    private OrderApplicationService orderApplicationService;
    
    @Test
    public void shouldCreateOrderSuccessfully() {
        // Given
        OrderCreateCommand command = new OrderCreateCommand();
        command.setUserId(123L);
        command.setItems(createTestItems());
        
        // When
        OrderCreateResult result = orderApplicationService.createOrder(command);
        
        // Then
        assertNotNull(result);
        assertNotNull(result.getOrderId());
        assertEquals("CREATED", result.getStatus());
    }
    
    private List<OrderItemCommand> createTestItems() {
        return Arrays.asList(
            new OrderItemCommand("PROD-001", "商品1", new BigDecimal("100.00"), 1),
            new OrderItemCommand("PROD-002", "商品2", new BigDecimal("200.00"), 2)
        );
    }
}
```

### 2. API接口测试
```java
package com.ai.master.order.provider.rpc;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import static org.junit.Assert.*;

@RunWith(SpringRunner.class)
@SpringBootTest
public class OrderProviderTest {
    
    @Autowired
    private OrderProvider orderProvider;
    
    @Test
    public void shouldCreateOrderViaRpc() {
        // Given
        OrderCreateRequest request = new OrderCreateRequest();
        request.setUserId(123L);
        request.setItems(createTestItems());
        
        // When
        OrderCreateResponse response = orderProvider.createOrder(request);
        
        // Then
        assertNotNull(response);
        assertNotNull(response.getOrderId());
    }
}
```

## 测试数据准备

### 1. 测试数据工厂
```java
package com.ai.master.test.factory;

public class OrderTestFactory {
    
    public static Order createValidOrder() {
        return Order.create(OrderId.generate(), UserId.of(123L));
    }
    
    public static Order createOrderWithItems(int itemCount) {
        Order order = createValidOrder();
        for (int i = 0; i < itemCount; i++) {
            order.addItem(new OrderItem(
                "PROD-" + String.format("%03d", i),
                "商品" + i,
                new BigDecimal("100.00"),
                1
            ));
        }
        return order;
    }
}
```

### 2. 测试数据库配置
```yaml
# application-test.yml
spring:
  datasource:
    url: jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
    driver-class-name: org.h2.Driver
    username: sa
    password:
  
  jpa:
    hibernate:
      ddl-auto: create-drop
```

## 测试执行策略

### 1. 测试分层执行
```bash
# 单元测试
mvn test -Dtest=*Test

# 集成测试
mvn test -Dtest=*IT

# 所有测试
mvn test

# 指定包测试
mvn test -Dtest=com.ai.master.order.domain.*Test
```

### 2. 持续集成配置
```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      - name: Run tests
        run: mvn clean test
      - name: Generate test report
        run: mvn jacoco:report
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## 测试最佳实践

### 1. 测试原则
- **FIRST原则**: Fast, Independent, Repeatable, Self-validating, Timely
- **AAA模式**: Arrange, Act, Assert
- **单一断言**: 每个测试方法只验证一个行为
- **可读性优先**: 测试代码应易于理解

### 2. Mock策略
```java
// 领域服务测试 - 不Mock领域对象
@Test
public void shouldCalculateTotalPrice() {
    // 使用真实对象
    Order order = new Order(validData);
    
    // 验证计算结果
    assertEquals(expectedPrice, order.calculateTotalPrice());
}

// 应用服务测试 - Mock外部依赖
@Test
public void shouldProcessOrder() {
    // Mock外部服务
    when(paymentService.process(any())).thenReturn(successResult);
    
    // 执行测试
    Result result = orderApplicationService.process(command);
    
    // 验证结果
    assertTrue(result.isSuccess());
}
```

### 3. 测试覆盖检查
```xml
<!-- pom.xml 配置 -->
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.7</version>
    <configuration>
        <excludes>
            <exclude>**/*Application.class</exclude>
            <exclude>**/*Config.class</exclude>
            <exclude>**/*Entity.class</exclude>
        </excludes>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

## 测试工具集成

### 1. IDE配置
- **IntelliJ IDEA**: 启用代码覆盖率显示
- **Eclipse**: 安装EclEmma插件
- **VS Code**: 安装Java Test Runner扩展

### 2. Maven测试配置
```xml
<properties>
    <maven.surefire.version>3.0.0-M7</maven.surefire.version>
    <skip.unit.tests>false</skip.unit.tests>
    <skip.integration.tests>true</skip.integration.tests>
</properties>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-surefire-plugin</artifactId>
            <version>${maven.surefire.version}</version>
            <configuration>
                <skipTests>${skip.unit.tests}</skipTests>
                <includes>
                    <include>**/*Test.java</include>
                </includes>
            </configuration>
        </plugin>
    </plugins>
</build>
```
