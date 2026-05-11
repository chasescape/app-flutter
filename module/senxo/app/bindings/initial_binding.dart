import 'package:get/get.dart';
import '../core/services/auth_service.dart';
import '../core/services/coin_service.dart';
import '../core/services/purchase_service.dart';
import '../core/services/encrypt_service.dart';
import '../core/storage/local_storage.dart';
import '../core/network/dio_client.dart';
import '../data/repositories/auth_repository.dart';
import '../data/providers/api_provider.dart';

/// 全局依赖注入绑定
/// 在应用启动时注册全局服务，这些服务在整个应用生命周期中都可用
class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    // 核心服务 - permanent: true 表示这些服务不会被自动回收
    // 先初始化 LocalStorage
    final localStorage = LocalStorage();
    await localStorage.onInit();
    Get.put(localStorage, permanent: true);
    
    Get.put(DioClient(), permanent: true);
    Get.put(EncryptService(), permanent: true);
    Get.put(ApiProvider(), permanent: true);
    Get.put(AuthRepository(), permanent: true);
    
    // 初始化 AuthService 并加载认证状态
    final authService = Get.put(AuthService(), permanent: true);
    await authService.init();
    
    Get.put(PurchaseService(), permanent: true);
    Get.put(CoinService(), permanent: true);
    
    // 其他全局服务可以在这里添加
    // Get.put(DeviceService(), permanent: true);
    // Get.put(LogService(), permanent: true);
  }
}