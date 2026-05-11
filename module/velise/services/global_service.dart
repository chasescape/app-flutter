import 'package:get/get.dart';
import '../services/storage/storage_service.dart';
import '../services/storage/history_storage_service.dart';
import '../services/api/api_service.dart';
import '../services/ai/thingtale_ai_service.dart';

/// Global Service Manager - GetX Service Pattern
/// Manages all global services that persist throughout the app lifecycle
class GlobalService extends GetxService {
  static GlobalService get to => Get.find();

  final StorageService storageService;
  late ApiService apiService;
  late ThingTaleAIService aiService;
  late HistoryStorageService historyService;

  GlobalService(this.storageService) {
    _initApiService();
    _initAIServices();
  }

  void _initApiService() {
    final dio = ApiConfig.createDio();
    apiService = ApiService(dio);
  }

  void _initAIServices() {
    aiService = ThingTaleAIService();
    historyService = HistoryStorageService();
  }

  // Auth state
  final RxnString authToken = RxnString();
  final RxnString userId = RxnString();
  final RxnString userName = RxnString();
  final RxString coinBalance = '100'.obs;

  // Check if user is logged in
  bool get isLoggedIn => authToken.value != null && authToken.value!.isNotEmpty;

  // Load auth state from storage
  Future<void> loadAuthState() async {
    authToken.value = await storageService.getString(StorageKeys.authToken);
    userId.value = await storageService.getString(StorageKeys.userId);
    userName.value = await storageService.getString(StorageKeys.userName);
    coinBalance.value =
        await storageService.getString(StorageKeys.coinBalance) ?? '100';
  }

  // Save auth state
  Future<void> saveAuthToken(String token) async {
    authToken.value = token;
    await storageService.setString(StorageKeys.authToken, token);
  }

  // Clear auth state
  Future<void> clearAuthState() async {
    authToken.value = null;
    userId.value = null;
    userName.value = null;
    coinBalance.value = '0';

    await storageService.remove(StorageKeys.authToken);
    await storageService.remove(StorageKeys.userId);
    await storageService.remove(StorageKeys.userName);
    await storageService.remove(StorageKeys.coinBalance);
  }

  // Update coin balance
  Future<void> updateCoinBalance(String balance) async {
    coinBalance.value = balance;
    await storageService.setString(StorageKeys.coinBalance, balance);
  }

  // Initialize global bindings
  static Future<void> init() async {
    // Initialize storage service
    final storageService = StorageService.instance;
    await storageService.init();

    // Register global service
    Get.put(GlobalService(storageService), permanent: true);
    Get.put(storageService, permanent: true);

    // Load auth state
    await GlobalService.to.loadAuthState();
  }
}
