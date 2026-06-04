import 'package:get/get.dart';
import 'package:pliro/pliro/core/managers/coins_manager.dart';
import 'package:pliro/pliro/core/services/purchase_service.dart';
import 'package:pliro/pliro/features/coins/presentation/pages/contact_coins.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

/// Coin store controller
class CoinStoreController extends GetxController {
  final CoinsManager _coinsManager = CoinsManager.instance;
  final PurchaseService _purchaseService = PurchaseService.instance;

  bool isPurchasing = false;
  List<Contact575CoinProduct> packages = [];

  /// Add coins callback - set by purchase service
  Function(int)? onCoinsAdded;

  @override
  void onInit() {
    super.onInit();
    _initPackages();
    _initializeServices();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// Initialize services
  Future<void> _initializeServices() async {
    // Initialize coins manager
    await _coinsManager.init();

    // Initialize purchase service
    await _purchaseService.initialize();
  }

  void _initPackages() {
    packages = Privatised236CoinProductData.allProductsGrouped;
  }

  /// Purchase a coin package
  Future<void> purchasePackage(Contact575CoinProduct package) async {
    // Prevent double-click
    if (isPurchasing) return;

    isPurchasing = true;
    update();

    Get.log(
      'Start purchase: code=${package.code}, goodsId=${package.goodsId}, coins=${package.exchangeCoin}',
    );

    await _purchaseService.executePurchase(
      productId: package.goodsId,
      fallbackProductIds: [package.code],
      coins: package.exchangeCoin,
      onResult: (bool success, bool canceled, String? message) {
        isPurchasing = false;
        update();

        // Show result dialog
        if (success) {
          _showSuccessDialog(package.exchangeCoin, message);
        } else if (canceled) {
          Get.log('Purchase canceled: ${message ?? ''}');
          // _showCanceledDialog(message);
        } else {
          Get.log('Purchase failed: ${message ?? ''}');
          // _showErrorDialog(message);
        }
      },
    );
  }

  /// Show success dialog
  void _showSuccessDialog(int coins, String? message) {
    AwesomeDialog(
      context: Get.overlayContext!,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Purchase Successful!',
      desc: message ?? 'You have received $coins coins.',
      btnOkOnPress: () {},
    ).show();
  }

  // /// Show canceled dialog
  // void _showCanceledDialog(String? message) {
  //   AwesomeDialog(
  //     context: Get.overlayContext!,
  //     dialogType: DialogType.info,
  //     animType: AnimType.scale,
  //     title: 'Purchase Canceled',
  //     desc: message ?? 'The purchase was canceled.',
  //     btnOkOnPress: () {},
  //   ).show();
  // }

  // /// Show error dialog
  // void _showErrorDialog(String? message) {
  //   AwesomeDialog(
  //     context: Get.overlayContext!,
  //     dialogType: DialogType.error,
  //     animType: AnimType.scale,
  //     title: 'Purchase Failed',
  //     desc: message ?? 'Failed to complete purchase. Please try again.',
  //     btnOkOnPress: () {},
  //   ).show();
  // }
}
