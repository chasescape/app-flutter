# Core Network 服务层使用说明

本目录集中放置 **可复用的网络服务层**，与具体业务 UI 解耦，方便在其他项目中接入：

- `AppConfigApi`：获取 `encryptKey` / `authToken`，负责配置接口多层加解密
- `AuthApi`：登录、登出、注销账号
- `CoinApi`：金币商品列表、创建充值订单
- `AiService`：AI 图生图、AI Story 文案
- `AppServiceConfig`（在 `../core/app_service_config.dart`）：服务配置协议
- `CryptoHelper`（在 `../crypto_helper.dart`）：AES 加解密工具
- `AppEnvConfigAdapter`（在 `../core/app_env_config_adapter.dart`）：Kissmi 项目的配置适配器实现

> 在其它项目中，仅需实现自己的 `AppServiceConfig` 适配器，就可以直接复用这些服务。

---

## 1. 实现 AppServiceConfig 适配器

```dart
// 例：MyAppServiceAdapter
class MyAppServiceAdapter implements AppServiceConfig {
  String? _encryptKey;
  String? _authToken;
  String? _deviceId;

  @override
  String? get encryptKey => _encryptKey;

  @override
  set encryptKey(String? value) => _encryptKey = value;

  @override
  String? get authToken => _authToken;

  @override
  set authToken(String? value) => _authToken = value;

  @override
  String? get deviceId => _deviceId;

  @override
  String get hostApi => 'https://api.example.com';

  @override
  Future<void> saveString(String key, String value) async {
    // 如：SharedPreferences / 本地存储
  }

  @override
  Future<String?> getString(String key) async {
    // 读取本地存储
    return null;
  }
}
```

在 Kissmi 项目中已经有一个实现：`AppEnvConfigAdapter`，可以直接参考。

---

## 2. 初始化 Dio

所有服务都接受外部注入的 `Dio`，只要设置好 `baseUrl` 和超时即可：

```dart
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  baseUrl: AppEnv().hostApi, // 或你的 hostApi
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 30),
));
```

---

## 3. AppConfigApi：获取 encryptKey / authToken

```dart
final core = CoreServices.instance;
final appConfigApi = core.appConfigApi;

final result = await appConfigApi.getAppConfig();
final encryptKey = result['encryptKey'];    // 会自动写入 network.config.encryptKey
final authToken = result['authToken'];      // 如接口有返回则一并带出
```

> 注意：`getAppConfig()` 内部会处理 k2/k3/k4 的多层解密逻辑，并把最新的 `ver` / `encryptKey` 持久化到 `AppServiceConfig.saveString`。

---

## 4. AuthApi：登录 / 登出 / 注销账号

```dart
final core = CoreServices.instance;
final authApi = core.authApi;

// 1）登录（前提：config.encryptKey 已经通过 AppConfigApi 拿到）
final loginResult = await authApi.signIn(core.config.deviceId ?? '');
final token = loginResult['token'] as String?;
core.config.authToken = token; // 建议同时持久化

// 2）登出
final logoutOk = await authApi.logout();

// 3）注销账号
try {
  final ok = await authApi.deleteAccount();
  if (ok) {
    // 清空本地数据 / 跳转登录页
  }
} catch (e) {
  // 业务侧处理错误提示
}
```

在当前项目中：

- 登录页 `LoginLogic` 使用 `AppConfigApi + AuthApi` 完成「getConfig → 登录」。
- 个人中心 `ProfileLogic` 通过 `AuthApi` 做「登出 / 注销账户」。

---

## 5. CoinApi：金币商品 / 充值订单

```dart
final core = CoreServices.instance;
final coinApi = core.coinApi;

// 1）获取商品列表
final goodsList = await coinApi.getGoodsList(
  payChannel: Platform.isAndroid ? 'GP' : 'IAP',
  isIncludeSubscription: false,
);

// 2）创建充值订单
final order = await coinApi.createRechargeOrder(
  goodsCode: '264308',
  payChannel: Platform.isAndroid ? 'GP' : 'IAP',
  entry: 'coins_page',
);
```

Yapo 中的 `CoinsLogic` 就是通过 `CoinApi` 完成服务端商品映射和下单的。

---

## 6. AiService：AI 图生图 & Story 文案

### 6.1 初始化（可选：通过 CoreServices 复用）

```dart
final env = AppEnv();
final aiDio = Dio(BaseOptions(
  baseUrl: env.aiApiBaseUrl,
  connectTimeout: const Duration(seconds: 60),
  receiveTimeout: const Duration(seconds: 120),
  headers: {
    'Authorization': 'Bearer ${env.aiApiKey}',
  },
));

final core = CoreServices.instance;
core.setAiDio(aiDio);
final aiService = core.aiService;
```

### 6.2 调用图生图

```dart
final prompt = AIPromptConfig.generateEnhancedPrompt(
  location: location,
  date: date,
  description: description,
);

final imageUrl = await aiService.generateEditedImage(
  imagePath: localImagePath,
  prompt: prompt,
);
// 上层根据 imageUrl 决定是下载到本地还是直接展示
```

### 6.3 生成 Story 文案

```dart
final prompt = AIPromptConfig.generateStoryPrompt(
  location: location,
  date: date,
  userDescription: userDescription,
);

final story = await aiService.generateStory(
  prompt: prompt,
  model: AppEnv().aiModel,
  temperature: 0.7,
  maxTokens: 200,
);
```

当前项目中：

- `PublishLogic` 负责拼装表单字段和 Prompt，然后调用 `AiService`，再把图片落盘、更新 UI。
- AI 接口的所有 HTTP 细节都在 `AiService` 中实现。

---

## 7. 复用建议

如果要在 **新项目** 使用这套 core：

1. 拷贝（或抽成 package）`lib/yapo/core` 整个目录。
2. 在新项目实现一个自己的 `AppServiceConfig` 适配器。
3. 在需要的地方：
   - 用 `AppConfigApi` 获取并缓存 `encryptKey`。
   - 用 `AuthApi` 完成登录 / 登出 / 注销。
   - 用 `CoinApi` 做金币商品和充值订单。
   - 用 `AiService` 调 AI 图生图和 Story。
4. 业务 UI 层只关心「何时调用」「拿到结果后怎么展示」，完全不需要关心加解密、设备头、业务码校验等细节。
