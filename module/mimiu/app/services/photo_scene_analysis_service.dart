import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../ai/photo_scene/photo_scene_ai_service.dart';
import '../ai/photo_scene/photo_scene_models.dart';
import '../ai/photo_scene/photo_scene_storage.dart';
import '../modules/home/home_logic.dart';
import 'coin_wallet.dart';

class PhotoSceneAnalysisService extends GetxService {
  final PhotoSceneAiService _ai = PhotoSceneAiService();
  final PhotoSceneStorage _storage = PhotoSceneStorage();
  final CoinWallet _wallet = CoinWallet();

  final RxBool running = false.obs;
  final RxInt done = 0.obs;
  final RxInt total = 0.obs;
  final RxString lastError = ''.obs;

  bool get hasProgress => running.value && total.value > 0;

  Future<void> start(List<XFile> files) async {
    if (running.value) return;
    if (files.isEmpty) return;

    final requiredCoins = files.length;
    final currentBalance = await _wallet.getBalance();
    if (currentBalance < requiredCoins) {
      Get.snackbar(
        'Not enough coins',
        'Need $requiredCoins, you have $currentBalance.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    running.value = true;
    done.value = 0;
    total.value = files.length;
    lastError.value = '';

    Get.snackbar(
      'AI categorization',
      'Running in the background…',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );

    final now = DateTime.now().millisecondsSinceEpoch;
    final results = <AnalyzedPhoto>[];
    final errors = <Object>[];

    try {
      // Run with limited parallelism to speed up larger batches.
      // Keep concurrency conservative to avoid throttling/timeouts.
      const concurrency = 3;
      var cursor = 0;
      Future<void> spendLock = Future<void>.value();

      Future<void> spendOne() async {
        spendLock = spendLock.then((_) async {
          final ok = await _wallet.spend(1);
          if (!ok) throw Exception('Not enough coins.');
        });
        await spendLock;
      }

      Future<void> worker() async {
        while (true) {
          final int index;
          if (cursor >= files.length) return;
          index = cursor;
          cursor += 1;

          final f = files[index];
          try {
            final analysis = await _ai.analyzeImage(File(f.path));
            results.add(
              AnalyzedPhoto(
                path: f.path,
                analysis: analysis,
                createdAtMs: now,
              ),
            );
            await spendOne();
            done.value += 1;
          } catch (e) {
            errors.add(e);
            done.value += 1;
          }
        }
      }

      final workers = List<Future<void>>.generate(
        concurrency.clamp(1, files.length),
        (_) => worker(),
      );
      await Future.wait(workers);

      await _storage.upsertMany(results);

      // Refresh home if it's alive.
      if (Get.isRegistered<HomeLogic>()) {
        await Get.find<HomeLogic>().refreshFromStorage();
      }

      Get.snackbar(
        'Completed',
        errors.isEmpty
            ? 'Categorized ${files.length} photo(s).'
            : 'Categorized ${results.length} photo(s).',
        backgroundColor: const Color(0xFF0B0B0B).withValues(alpha: 0.80),
        colorText: const Color(0xFFFDE68A),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      lastError.value = '$e';
      Get.snackbar(
        'AI failed',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      running.value = false;
      total.value = 0;
    }
  }
}
