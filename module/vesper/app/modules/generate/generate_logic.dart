import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vesper/vesper/app/data/cheer_history_store.dart';
import 'package:vesper/vesper/app/data/coins_wallet_store.dart';
import 'package:vesper/vesper/app/network/cheer_ai_service.dart';
import 'package:vesper/vesper/app/routes/app_routes.dart';

class GenerateLogic extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final CheerAiService _service = CheerAiService(
    apiKey: 'sk-QaaY8MM8WwiS9eLfC31f0fB08742448bA75b6a7f1b75E61a',
  );
  final CheerHistoryStore _history = Get.isRegistered<CheerHistoryStore>()
      ? Get.find<CheerHistoryStore>()
      : Get.put(CheerHistoryStore(), permanent: true);
  final CoinsWalletStore _wallet = Get.isRegistered<CoinsWalletStore>()
      ? Get.find<CoinsWalletStore>()
      : Get.put(CoinsWalletStore(), permanent: true);

  File? selectedImage;
  CheerAnalysisResult? analysis;
  bool isLoading = false;
  String? errorMessage;

  Future<void> onPickPhoto() async {
    errorMessage = null;
    update();

    final granted = await _requestPhotoPermission();
    if (!granted) {
      errorMessage = 'Permission denied. Please allow photo access.';
      update();
      return;
    }

    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) {
      return;
    }

    selectedImage = File(picked.path);
    analysis = null;
    update();
  }

  void openDetails() {
    if (analysis == null) {
      return;
    }
    Get.toNamed(AppRoutes.details, arguments: analysis);
  }

  Future<bool> _requestPhotoPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (status.isGranted || status.isLimited) {
        return true;
      }
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    }
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    }
    return false;
  }

  Future<void> onAnalyze() async {
    errorMessage = null;
    if (selectedImage == null) {
      errorMessage = 'Please upload a photo first.';
      update();
      return;
    }
    if (_wallet.balance < 100) {
      errorMessage = 'Not enough coins. Please top up.';
      update();
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD56A), Color(0xFFFFA800)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    color: Color(0xFF2B1A2B),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Coins Needed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2B1A2B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Not enough coins. Please top up to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF6E5B6F),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFFF4FA5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
      );
      return;
    }

    isLoading = true;
    update();

    try {
      analysis = await _service.analyzePoseFile(selectedImage!);
      if (analysis != null) {
        _wallet.spend(100);
        final item = CheerHistoryItem(
          imagePath: selectedImage!.path,
          result: analysis!,
        );
        _history.addItem(item);
        selectedImage = null;
        update();
        Get.toNamed(AppRoutes.details, arguments: item);
      }
    } catch (e) {
      errorMessage = 'Analysis failed. Please try again.';
    } finally {
      isLoading = false;
      update();
    }
  }
}
