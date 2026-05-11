import 'package:get/get.dart';
import '../interface.dart';
import '../data/models/user_data.dart';
import '../data/services/storage_service.dart';

/// Main controller managing global app state
class MainController extends GetxController {
  final StorageService _storage = StorageService.to;

  // User data observables
  final Rxn<UserData> userData = Rxn<UserData>();
  final RxBool isLoggedIn = false.obs;
  final RxInt currentIndex = 0.obs;
  final RxInt dataVersion = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _checkLoginStatus();
  }

  Future<void> _loadUserData() async {
    userData.value = await _storage.getUserData();
  }

  void _checkLoginStatus() {
    isLoggedIn.value = Interface().authToken != null;
  }

  Future<void> refreshUserData() async {
    await _loadUserData();
  }

  Future<void> updateCoins(int amount) async {
    await _storage.updateCoins(amount);
    await _loadUserData();
  }

  Future<void> useFreeUse() async {
    await _storage.useFreeUse();
    await _loadUserData();
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void notifyDataChanged() {
    dataVersion.value++;
  }

  bool get hasFreeUses => userData.value?.hasFreeUses ?? false;
  int get currentCoins => userData.value?.coins ?? 0;
}
