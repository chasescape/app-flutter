# Flira Network 服务层说明

本目录放置可复用的网络服务层，和业务 UI 解耦：

- `AppConfigApi`：获取 `encryptKey` / `authToken`，处理配置接口多层解密
- `AuthApi`：登录、登出、注销账号
- `AiService`：AI 图生图、AI Story 文案
- `AppServiceConfig`：服务配置协议
- `CryptoHelper`：AES 加解密工具
- `AppEnvConfigAdapter`：Flira 项目的配置适配器
- `CoreServices`：统一服务入口

---

## 1. 初始化 CoreServices

```dart
final core = CoreServices.instance;

// 可选：启动时加载本地 token / encryptKey
await (core.config as AppEnvConfigAdapter).loadAuthToken();
await (core.config as AppEnvConfigAdapter).loadEncryptKey();
```

---

## 2. 获取 AppConfig（encryptKey）

```dart
final result = await CoreServices.instance.appConfigApi.getAppConfig();
final encryptKey = result['encryptKey'];
final authToken = result['authToken']; // 可能为空
```

`getAppConfig()` 内部会把 `encryptKey` 写入 `config.encryptKey`，并执行本地缓存。

---

## 3. 登录 / 登出 / 注销

```dart
final core = CoreServices.instance;

// 登录（先确保已经调用 getAppConfig）
final loginResult = await core.authApi.signIn(core.config.deviceId ?? '');
final token = loginResult['token'] as String?;
core.config.authToken = token;

// 登出
final logoutOk = await core.authApi.logout();

// 注销账号
final deleteOk = await core.authApi.deleteAccount();
```

---

## 4. AI 接口

```dart
final aiService = CoreServices.instance.aiService;

final imageUrl = await aiService.generateEditedImage(
  imagePath: localImagePath,
  prompt: prompt,
);

final story = await aiService.generateStory(
  prompt: storyPrompt,
  model: 'gpt-4o-mini',
);
```

如果 AI 需要单独域名，可以注入独立 Dio：

```dart
final aiDio = Dio(BaseOptions(
  baseUrl: 'https://your-ai-api-host',
  connectTimeout: const Duration(seconds: 60),
  receiveTimeout: const Duration(seconds: 120),
  headers: {
    'Authorization': 'Bearer xxx',
  },
));
CoreServices.instance.setAiDio(aiDio);
```
