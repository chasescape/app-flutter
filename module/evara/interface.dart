// *** [do change classname] ***
import 'env/app_env.dart';
import 'core/singletons/storage_service.dart';
import 'light_handle.dart';

// interface 相当于协议，约定。不要随意增加方法和修改参数!!!。
class Interface {
  Interface._();

  static Interface? _instance;

  factory Interface() {
    _instance ??= Interface._();
    return _instance!;
  }

  // A面的home页面
  String lightHome = '/home';
  // 登录页面路由
  String loginPage = '/login';

  // prod | test
  String? env;
  // 用户登录态，在登录后或者开始从持久化读取。接口登录态处理直接读取这值
  String? authToken;

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

    // TODO B面的配置
  }



  /// 初始化
  Future<void> prevInitialize() async {
    await StorageService.ensureInitialized();

    // TODO B面初始化

  }

  /// 恢复登录态 - App启动时从持久化存储读取
  Future<void> restoreAuthToken() async {
    final token = await StorageService.instance.loadString(StorageKeys.authToken);
    authToken = token;
  }

  /// 登录操作
  Future<void> doSignInAction() async {
    // A面登录逻辑
    await LightHandle.login();
  }



  /// B面进入A面前的处理
  Future<void> setHomeEntranceForSideA() async {
    // A面时期无需处理，
    // TODO 合B阶段进行处理

  }


  /// 删除登录信息
  Future<void> onAuthTokenRemoved() async {
    // TODO 合B阶段补充B面删除逻辑
    authToken = null;
    await StorageService.instance.remove(StorageKeys.authToken);

    _doShuffleActions();
  }

  _doShuffleActions(){}

}
