import 'package:get/get.dart';
import '../../../services/global_service.dart';
import '../../../services/coins/coins_manager.dart';
import '../../../data/mock/thingtale_mock_data.dart';
import '../../../data/models/thingtale_item.dart';

/// Home Controller
/// Manages content feed and user navigation
class HomeController extends GetxController {
  final RxList<ThingTaleItem> contentItems = <ThingTaleItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasReachedEnd = true.obs;

  final GlobalService _globalService = GlobalService.to;
  final CoinsManager _coinsManager = CoinsManager.instance;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    contentItems.addAll(allThingTaleMockData);
  }

  void onItemTap(ThingTaleItem item) {
    Get.toNamed('/detail', arguments: item);
  }

  void onProfileTap() {
    Get.toNamed('/profile');
  }

  void onCreateTap() {
    Get.toNamed('/create');
  }

  void onHistoryTap() {
    Get.toNamed('/history');
  }

  String get userName => _globalService.userName.value ?? 'Artist';
  String get coinBalance => _coinsManager.balanceString;
}
