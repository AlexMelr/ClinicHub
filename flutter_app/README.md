# ClinicHub Flutter App

这是 ClinicHub 的 Flutter 前端项目，支持 Web、macOS 桌面 App，以及 Flutter 默认生成的移动端和多平台工程。

## 目录

```text
lib/
├── main.dart
├── models/
├── screens/
├── services/
└── widgets/
```

## 启动

```bash
flutter pub get
flutter run -d macos
```

或运行 Web：

```bash
flutter run -d chrome
```

## 后端地址

前端默认连接：

```text
http://localhost:8090/api
```

配置位于：

```text
lib/services/api_service.dart
```

## 测试

```bash
flutter analyze
flutter test
```

## 构建 macOS App

```bash
flutter build macos
```

输出位置：

```text
build/macos/Build/Products/Release/clinichub_app.app
```
