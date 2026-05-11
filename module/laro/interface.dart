// *** [do change classname] ***
import 'env/app_env.dart';
import 'light_handle.dart';

// interface 相当于协议，约定。不要随意增加方法和修改参数。
class Interface {
  Interface._();

  static Interface? _instance;

  factory Interface() {
    _instance ??= Interface._();
    return _instance!;
  }

  // A面登录态入口页面 确保是A面的home页面
  String lightHome = 'AppRoutes.main';
  String loginPage = 'AppRoutes.login';

  // prod | test
  String? env;
  // 用户登录态，在登录后或者开始从持久化读取。接口登录态处理直接读取这值
  String? authToken;
  // 从appConfig获取，接口加解密直接读取这值
  String? encryptKey;
  // 用于A面，处理
  String? userId;
  String? deviceId;

  /// 设置环境变量
  void setRunEnv({
    required String runEnv,
    required String apiUrl,
    required String h5Url,
    required String imUrl,
    required String logUrl,
    required String h5User,
    required String h5Privacy,
    String? geApiKey,
    String? aiApiUrl,
  }) {
    env = runEnv;

    // TODO A面配置
    final config = AppEnv();
    config.env = runEnv == 'prod' ? AppEnvType.product : AppEnvType.test;
    config.hostApi = apiUrl;
    config.hostH5 = h5Url;
    config.hostIM = imUrl;
    config.hostLog = logUrl;
    config.h5User = '$h5Url/$h5User';
    config.h5Privacy = '$h5Url/$h5Privacy';
    config.geApiKey = geApiKey ?? '';
    config.hostAiApi = aiApiUrl ?? 'https://api.gpt.ge';

    // TODO B面的配置
  }



  /// 初始化
  Future<void> prevInitialize() async {
    // TODO A面初始化，一般只需初始持久化（登录页使用）
    // A面业务初始化
    await LightHandle.readyToInit();


    // TODO B面初始化

  }

  /// 登录操作
  Future<void> doSignInAction() async {
    // TODO A阶段逻辑或B阶段逻辑，interface内只做调用，不要有实现代码。例如
    // A阶段逻辑 A面的登录逻辑
    await LightHandle.login();

    // 合B阶段使用B面逻辑
  }



  /// B面进入A面前的处理
  Future<void> setHomeEntranceForSideA() async {
    // A面时期无需处理，
    // TODO 合B阶段进行处理

  }


  /// 删除登录信息
  Future<void> onAuthTokenRemoved() async {
    // A面时期无需处理，
    // TODO 合B阶段补充B面删除逻辑

    _doShuffleActions();
  }

  _doShuffleActions(){}

}