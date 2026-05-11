import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rova/rova/app/modules/coins/coins_logic.dart';
import 'package:rova/rova/app/modules/home/home_logic.dart';
import 'package:rova/rova/app/modules/profile/profile_logic.dart';
import 'package:rova/rova/app/services/openai_image_service.dart';
import 'package:rova/rova/app/widgets/glass_card.dart';
import 'package:rova/rova/app/widgets/rova_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';
import 'generate_logic.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  static const String _kBalanceKey = 'rova.coins.balance';
  static const int _kInitialBalance = 100;
  static const int _kGenerateCost = 100;

  final TextEditingController _colorsController = TextEditingController();
  final TextEditingController _styleController = TextEditingController();
  final TextEditingController _elementsController = TextEditingController();
  final TextEditingController _customPromptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final logic = Get.find<GenerateLogic>();
    _colorsController.text = logic.preferredColors.value;
    _styleController.text = logic.preferredStyle.value;
    _elementsController.text = logic.preferredElements.value;
    _customPromptController.text = logic.customPrompt.value;
  }

  Future<void> _pickReferenceImage(GenerateLogic logic) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Choose from Photos'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return;
    final permitted = await _requestMediaPermission(source);
    if (!permitted) return;

    final picker = ImagePicker();
    final x = await picker.pickImage(source: source);
    if (x == null) return;
    logic.pickedImage.value = File(x.path);
  }

  Future<bool> _requestMediaPermission(ImageSource source) async {
    final isCamera = source == ImageSource.camera;
    final permission = isCamera ? Permission.camera : Permission.photos;
    final status = await permission.request();
    if (status.isGranted || status.isLimited) {
      return true;
    }

    final shouldOpenSettings = status.isPermanentlyDenied || status.isRestricted;
    if (!mounted) return false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text('Permission Needed'),
          content: Text(
            isCamera
                ? 'Please allow camera access in Settings to take photos in Rova.'
                : 'Please allow photo library access in Settings to choose photos in Rova.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            if (shouldOpenSettings)
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
          ],
        );
      },
    );

    return false;
  }

  Future<bool> _ensureEnoughCoins() async {
    final prefs = await SharedPreferences.getInstance();
    var balance = prefs.getInt(_kBalanceKey);
    if (balance == null) {
      balance = _kInitialBalance;
      await prefs.setInt(_kBalanceKey, balance);
    }
    if (balance < _kGenerateCost) {
      Get.snackbar(
        'Not enough coins',
        'Generating requires $_kGenerateCost coins.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }

  Future<void> _consumeCoins() async {
    final prefs = await SharedPreferences.getInstance();
    var balance = prefs.getInt(_kBalanceKey);
    balance ??= _kInitialBalance;
    final next = (balance - _kGenerateCost).clamp(0, 1 << 30);
    await prefs.setInt(_kBalanceKey, next);

    if (Get.isRegistered<ProfileLogic>()) {
      await Get.find<ProfileLogic>().refreshCoins();
    }
    if (Get.isRegistered<CoinsLogic>()) {
      await Get.find<CoinsLogic>().refreshBalance();
    }
  }

  @override
  void dispose() {
    _colorsController.dispose();
    _styleController.dispose();
    _elementsController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GenerateLogic logic = Get.find<GenerateLogic>();
    final OpenAIImageService ai = Get.find<OpenAIImageService>();
    final HomeLogic homeLogic = Get.find<HomeLogic>();

    const Color pink = Color(0xFFE84B7B);
    const Color cardBg = Color(0x66FFFFFF);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RovaBackground(
        blurSigma: 4,
        overlayColor: const Color(0x22FFFFFF),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x33FFE7EF),
            Color(0x22FFFFFF),
          ],
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 120),
            children: [
              const Text(
                'Today Outfit Photo',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 40),
              Obx(() {
                final File? image = logic.pickedImage.value;
                return GlassCard(
                  borderRadius: 22,
                  blurSigma: 22,
                  backgroundColor: cardBg,
                  borderColor: const Color(0x55FFFFFF),
                  shadowColor: const Color(0x14000000),
                  highlight: false,
                  padding: EdgeInsets.zero,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () async => _pickReferenceImage(logic),
                    child: SizedBox(
                      height: 480,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (image != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.file(
                                image,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFFFF3F7)
                                        .withValues(alpha: 0.26),
                                    const Color(0xFFFFE9F0)
                                        .withValues(alpha: 0.18),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 22),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 62,
                                        height: 62,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              pink.withValues(alpha: 0.95),
                                              const Color(0xFFFFA1BE),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.10),
                                              blurRadius: 16,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.file_upload_outlined,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      const Text(
                                        'Upload today outfit photo',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'We will match nail colors & vibe to your outfit style.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          height: 1.25,
                                          color: Colors.black
                                              .withValues(alpha: 0.55),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (image != null)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Material(
                                color: Colors.white.withValues(alpha: 0.86),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () => logic.pickedImage.value = null,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),
              Obx(() {
                final generating = logic.isGenerating.value;
                return SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFFFF4FA1),
                          Color(0xFFE84B7B),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: pink.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      onPressed: generating
                          ? null
                          : () async {
                              final hasPhoto = logic.pickedImage.value != null;
                              if (!hasPhoto) {
                                Get.snackbar(
                                  'Photo required',
                                  'Please upload your outfit photo first.',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                return;
                              }
                              final enoughCoins = await _ensureEnoughCoins();
                              if (!enoughCoins) return;
                              logic.isGenerating.value = true;
                                  try {
                                    final outfitImagePath =
                                        logic.pickedImage.value?.path;
                                    final path = await ai.generateNailImage(
                                      outfitNotes: logic.outfitNotes.value,
                                      preferredColors: logic.preferredColors.value,
                                      preferredStyle: logic.preferredStyle.value,
                                      preferredElements:
                                          logic.preferredElements.value,
                                      customPrompt: logic.customPrompt.value,
                                      referenceImage: logic.pickedImage.value,
                                    );
                                    String aiCopy = '';
                                    try {
                                      final copy = await ai.generateNailCopy(
                                        outfitNotes: logic.outfitNotes.value,
                                        preferredColors:
                                            logic.preferredColors.value,
                                        preferredStyle:
                                            logic.preferredStyle.value,
                                        preferredElements:
                                            logic.preferredElements.value,
                                        customPrompt: logic.customPrompt.value,
                                      );
                                      aiCopy = copy.description.trim();
                                    } catch (_) {
                                      aiCopy = '';
                                    }
                                    logic.generatedImagePath.value = path;
                                    await homeLogic.addGeneratedImage(
                                      path,
                                      aiCopy: aiCopy,
                                    );
                                    await _consumeCoins();
                                    logic.pickedImage.value = null;
                                    logic.generatedImagePath.value = null;
                                    Get.toNamed(
                                      AppRoutes.details,
                                      arguments: {
                                        'generatedImagePath': path,
                                        'outfitImagePath': outfitImagePath,
                                        'aiCopy': aiCopy,
                                        'outfitNotes': logic.outfitNotes.value,
                                        'preferredColors':
                                            logic.preferredColors.value,
                                        'preferredStyle':
                                            logic.preferredStyle.value,
                                        'preferredElements':
                                            logic.preferredElements.value,
                                        'customPrompt':
                                            logic.customPrompt.value,
                                      },
                                    );
                              } catch (e) {
                                Get.snackbar(
                                  'Generate failed',
                                  e.toString(),
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } finally {
                                logic.isGenerating.value = false;
                              }
                            },
                      child: generating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Recommend Nails',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              GlassCard(
                borderRadius: 22,
                blurSigma: 20,
                backgroundColor: cardBg,
                borderColor: const Color(0x44FFFFFF),
                shadowColor: const Color(0x12000000),
                highlight: false,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: pink.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: pink,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Photography Tips',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const _TipBullet(
                      text: 'Clear lighting: Use natural or bright indoor light',
                    ),
                    const SizedBox(height: 6),
                    const _TipBullet(
                      text: 'Keep steady: Avoid motion blur and keep focus sharp',
                    ),
                    const SizedBox(height: 6),
                    const _TipBullet(
                      text: 'Frame well: Keep the hand centered and fully visible',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipBullet extends StatelessWidget {
  const _TipBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              height: 1.2,
              color: Colors.black.withValues(alpha: 0.72),
            ),
          ),
        ),
      ],
    );
  }
}
