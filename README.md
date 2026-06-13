# ClinicHub

ClinicHub 是一个面向中医诊所的本地管理系统，包含 Spring Boot 后端和 Flutter 前端。它支持患者管理、就诊记录、中药库存、处方创建、发药扣库存、库存流水和低库存提醒等基础业务。

## 功能概览

- 患者档案：创建、查询、编辑、软删除
- 就诊记录：记录主诉、现病史、诊断、医嘱和医生备注
- 中药管理：维护药材名称、别名、拼音、库存、单位和预警阈值
- 处方管理：按就诊创建处方，支持多味药材和多付药
- 发药扣库存：发药时自动扣减库存，并生成库存流水
- 库存流水：记录入库、出库、剩余库存和备注
- 低库存提醒：按预警阈值查询库存不足药材
- 桌面体验：Flutter 支持 macOS 桌面 App，也支持 Web 运行

## 技术栈

- 后端：Java 23、Spring Boot 3.4、Spring Data JPA、MySQL
- 前端：Flutter、Dart、Material 3
- 测试：JUnit、Spring MockMvc、H2 测试数据库、Flutter Test

## 项目结构

```text
ClinicHub/
├── pom.xml
├── src/
│   ├── main/java/com/clinichub/
│   │   ├── controller/
│   │   ├── service/
│   │   ├── repository/
│   │   ├── entity/
│   │   └── config/
│   ├── main/resources/application.yml
│   └── test/
└── flutter_app/
    ├── lib/
    │   ├── models/
    │   ├── screens/
    │   ├── services/
    │   └── widgets/
    ├── macos/
    ├── web/
    ├── android/
    ├── ios/
    ├── windows/
    └── linux/
```

## 环境要求

- JDK 23
- Maven 3.9+
- Flutter SDK
- MySQL 8+
- macOS 桌面端构建需要 Xcode

## 数据库配置

默认后端连接：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3307/clinic?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai&characterEncoding=UTF-8
    username: clinic
    password: clinicpass
```

启动正式后端前，需要确认 MySQL 正在监听 `localhost:3307`，并且已经创建数据库和用户：

```sql
CREATE DATABASE clinic CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'clinic'@'%' IDENTIFIED BY 'clinicpass';
GRANT ALL PRIVILEGES ON clinic.* TO 'clinic'@'%';
FLUSH PRIVILEGES;
```

当前 `application.yml` 使用 `ddl-auto: validate`，因此正式环境需要先准备好数据库表结构。

## 启动后端

在项目根目录执行：

```bash
mvn spring-boot:run
```

后端默认地址：

```text
http://localhost:8090
```

主要接口前缀：

```text
/api/patients
/api/visits
/api/herbs
/api/prescriptions
/api/stock
```

## 启动前端

进入 Flutter 项目目录：

```bash
cd flutter_app
flutter pub get
```

Web 调试：

```bash
flutter run -d chrome
```

macOS 桌面 App 调试：

```bash
flutter run -d macos
```

前端默认请求后端：

```text
http://localhost:8090/api
```

## 构建桌面 App

```bash
cd flutter_app
flutter build macos
```

构建完成后 App 位于：

```text
flutter_app/build/macos/Build/Products/Release/clinichub_app.app
```

## 测试

后端测试：

```bash
mvn test
```

测试环境使用 H2 内存数据库，不依赖本机 MySQL。集成测试覆盖患者、药材、入库、就诊、处方、发药扣库存、重复发药拦截、低库存和库存流水。

前端检查：

```bash
cd flutter_app
flutter analyze
flutter test
```

## 常见问题

### 后端启动失败：Connection refused

如果看到类似：

```text
Communications link failure
Connection refused
```

通常是 MySQL 没启动，或者端口不是 `3307`。请先检查：

```bash
lsof -i :3307
```

### 前端打开后没有数据

前端依赖后端接口。请先确认后端已经启动，并能访问：

```text
http://localhost:8090/api/patients
```

### GitHub 上没有 build 目录

这是正常的。`target/`、`flutter_app/build/`、`.dart_tool/` 都是构建产物，已经通过 `.gitignore` 排除，不应该提交到仓库。

## 开发建议

- 后端业务逻辑优先补 MockMvc 集成测试
- 前端新增页面时复用 `flutter_app/lib/widgets/app_ui.dart`
- 修改接口字段时同时更新 Flutter `models/` 和 `services/api_service.dart`
- 正式发布前建议补充数据库迁移工具，例如 Flyway 或 Liquibase
