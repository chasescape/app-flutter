import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/app_constants.dart';
import '../../models/tone_record.dart';
import '../../providers/app_state.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glido_ui.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  File? _beforeImage;
  File? _afterImage;
  final _presetNameController = TextEditingController();
  final _detailNotesController = TextEditingController();
  final _sceneController = TextEditingController(text: 'Portrait');
  final _moodController = TextEditingController(text: 'Warm');

  String _selectedTool = 'Lightroom';
  final Map<String, TextEditingController> _parameterControllers = {};

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    for (var key in AppConstants.parameterKeys) {
      _parameterControllers[key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _presetNameController.dispose();
    _detailNotesController.dispose();
    _sceneController.dispose();
    _moodController.dispose();
    for (var controller in _parameterControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickBeforeImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _beforeImage = File(picked.path));
    }
  }

  Future<void> _pickAfterImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _afterImage = File(picked.path));
    }
  }

  void _showInsufficientCoinsDialog() {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Not enough coins'),
        content: Text(
          'You need ${AppConstants.costPerRecord} coins to save a new card. Current balance: ${appState.coinBalance}.',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    if (!context.mounted) return;
                    context.push(AppRoutes.coinStore);
                  },
                  child: const Text('Get coins'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = context.read<AppState>();

    if (!appState.canCreateRecord()) {
      _showInsufficientCoinsDialog();
      return;
    }

    setState(() => _isSaving = true);

    final consumed = await appState.consumeForRecord();

    if (!consumed) {
      _showInsufficientCoinsDialog();
      setState(() => _isSaving = false);
      return;
    }

    final parameters = <String, dynamic>{};
    for (final entry in _parameterControllers.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty) {
        parameters[entry.key] = value;
      }
    }

    final record = ToneRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      presetName: _presetNameController.text.trim(),
      sceneTag: _sceneController.text.trim(),
      mainMood: _moodController.text.trim(),
      toolUsed: _selectedTool,
      lastUpdated: DateTime.now(),
      beforeImagePath: _beforeImage?.path,
      afterImagePath: _afterImage?.path,
      parameters: parameters,
      detailNotes: _detailNotesController.text.trim(),
    );

    appState.addRecord(record);

    if (mounted) {
      setState(() => _isSaving = false);
      AppRoutes.toDetailReplacingCurrent(context, record.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Create Card'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingMd),
            child: _isSaving
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton.icon(
                    onPressed: _saveRecord,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Save'),
                  ),
          ),
        ],
      ),
      body: GlidoPageBackground(
        topSafeArea: true,
        padding: const EdgeInsets.only(top: kToolbarHeight),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingMd,
              AppTheme.spacingSm,
              AppTheme.spacingMd,
              120,
            ),
            children: [
              GlidoSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlidoSectionHeader(
                      title: 'Lead with the image',
                      subtitle:
                          'The card design is built around the image first, with the metadata stepping back.',
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Wrap(
                      spacing: AppTheme.spacingSm,
                      runSpacing: AppTheme.spacingSm,
                      children: [
                        const GlidoPill(
                          label: '${AppConstants.costPerRecord} coins to save',
                          gradient: AppTheme.highlightGradient,
                        ),
                        if (appState.freeCredits > 0)
                          GlidoPill(
                            label: '${appState.freeCredits} free credits left',
                            gradient: AppTheme.limeGradient,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              GlidoSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlidoSectionHeader(
                      title: 'Images',
                      subtitle:
                          'Use large preview panels so you can judge the card composition before saving.',
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Row(
                      children: [
                        Expanded(
                          child: _ImageUploadCard(
                            label: 'Before',
                            image: _beforeImage,
                            onTap: _pickBeforeImage,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: _ImageUploadCard(
                            label: 'After',
                            image: _afterImage,
                            onTap: _pickAfterImage,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              GlidoSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlidoSectionHeader(
                      title: 'Card title',
                      subtitle:
                          'Keep the naming short and visual so it stays elegant on image cards.',
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    TextFormField(
                      controller: _presetNameController,
                      decoration: const InputDecoration(
                        hintText: 'Warm Neon Street',
                        labelText: 'Preset name',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a preset name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              GlidoSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlidoSectionHeader(
                      title: 'Scene and mood',
                      subtitle:
                          'These labels stay visible on the card, so keep them clear and lightweight.',
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    _ChoiceSection(
                      title: 'Scene',
                      controller: _sceneController,
                      hintText: 'Portrait',
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    _ChoiceSection(
                      title: 'Mood',
                      controller: _moodController,
                      hintText: 'Warm',
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    Text(
                      'Tool',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    DropdownButtonFormField<String>(
                      value: _selectedTool,
                      decoration: const InputDecoration(
                        hintText: 'Select tool',
                      ),
                      items: AppConstants.tools
                          .map(
                            (tool) => DropdownMenuItem<String>(
                              value: tool,
                              child: Text(tool),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedTool = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              GlidoSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlidoSectionHeader(
                      title: 'Optional adjustments',
                      subtitle:
                          'Technical settings stay beneath the visual content, so only add the ones worth remembering.',
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    ...AppConstants.parameterKeys.map(
                      (key) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppTheme.spacingMd),
                        child: TextFormField(
                          controller: _parameterControllers[key],
                          decoration: InputDecoration(
                            labelText: key,
                            hintText: 'e.g. +12, -5, 0.4',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              GlidoSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlidoSectionHeader(
                      title: 'Notes',
                      subtitle:
                          'Keep extra notes out of the hero image and save them here instead.',
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    TextFormField(
                      controller: _detailNotesController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText:
                            'What made this look work? Light, contrast, color temperature, or crop choices.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveRecord,
                  child: Text(
                    _isSaving ? 'Saving...' : 'Save card',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageUploadCard extends StatelessWidget {
  final String label;
  final File? image;
  final VoidCallback onTap;

  const _ImageUploadCard({
    required this.label,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: AppTheme.ink.withValues(alpha: 0.08),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: image != null
                  ? Image.file(
                      image!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFF7B0),
                            Color(0xFFFFFDE8),
                            Color(0xFFE6FF8B),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 42,
                              color: AppTheme.textPrimary,
                            ),
                            const SizedBox(height: AppTheme.spacingSm),
                            Text(
                              'Add $label image',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _ChoiceSection extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String hintText;

  const _ChoiceSection({
    required this.title,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter $title';
            }
            return null;
          },
        ),
      ],
    );
  }
}
