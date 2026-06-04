import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../models/perfume_record.dart';
import '../../services/coins_manager.dart';
import '../../services/record_service.dart';
import '../../widgets/glace_ui.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  static const _defaultScentFamily = 'Unsorted';
  static const _defaultOccasion = 'Daily';
  static const _saveCost = 12;

  final _brandController = TextEditingController();
  final _perfumeController = TextEditingController();
  final _noteController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _photoPath;

  bool _submitting = false;

  @override
  void dispose() {
    _brandController.dispose();
    _perfumeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _brandController.text.isNotEmpty &&
      _perfumeController.text.isNotEmpty;

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );
    if (!mounted || file == null) return;
    setState(() => _photoPath = file.path);
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      SmartDialog.showToast('Please fill in all required fields');
      return;
    }

    CoinsManager.instance.init();
    if (!CoinsManager.instance.canSpend(_saveCost)) {
      SmartDialog.showToast('Not enough coins. Save costs $_saveCost coins.');
      return;
    }

    setState(() => _submitting = true);

    try {
      RecordService().saveRecord(
        PerfumeRecord(
          id: const Uuid().v4(),
          brandName: _brandController.text.trim(),
          perfumeName: _perfumeController.text.trim(),
          scentFamily: _defaultScentFamily,
          occasion: _defaultOccasion,
          mood: null,
          rating: 0,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
          photoPath: _photoPath,
          createdAt: DateTime.now(),
        ),
      );
      CoinsManager.instance.spendCoins(_saveCost);

      if (!mounted) return;
      SmartDialog.showToast('Saved - $_saveCost coins used');
      _resetForm();
      setState(() => _submitting = false);
    } catch (_) {
      if (!mounted) return;
      SmartDialog.showToast('Something went wrong. Please try again.');
      setState(() => _submitting = false);
    }
  }

  void _resetForm() {
    _brandController.clear();
    _perfumeController.clear();
    _noteController.clear();
    setState(() {
      _photoPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlaceScaffold(
      appBar: AppBar(
        title: const Text(
          'New entry',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        foregroundColor: AppColors.textPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      safeArea: false,
      child: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlaceGlassCard(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(34),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            _photoPath == null
                                ? _EmptyHeroPlaceholder(
                                    borderRadius: BorderRadius.circular(26),
                                  )
                                : GlaceHeroImage(
                                    imagePath: _photoPath,
                                    height: 400,
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlaceSurfaceCard(
                  color: Colors.white.withValues(alpha: 0.80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(_brandController, 'Brand name'),
                      const SizedBox(height: 12),
                      _buildTextField(_perfumeController, 'Perfume name'),
                      const SizedBox(height: 18),
                      _buildLabel('Note'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        maxLines: 4,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          hintText: 'Short note',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: const Text('Save entry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hint),
      onChanged: (_) => setState(() {}),
    );
  }
}

class _EmptyHeroPlaceholder extends StatelessWidget {
  final BorderRadius borderRadius;

  const _EmptyHeroPlaceholder({required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.24),
            Colors.white.withValues(alpha: 0.10),
            AppColors.primary.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.26),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.add_photo_alternate_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Add photo',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Library',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
