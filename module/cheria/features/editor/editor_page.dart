import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/theme/theme.dart';
import '../../app/state/app_state.dart';
import '../../app/state/app_state_provider.dart';
import '../../models/novel.dart';
import '../../router/app_router.dart';
import '../../widgets/visuals/sunny_visuals.dart';

/// Editor Page
/// Create or edit novel records
class EditorPage extends StatefulWidget {
  final String? novelId;

  const EditorPage({super.key, this.novelId});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _plotSummaryController = TextEditingController();
  final _charactersController = TextEditingController();
  final _imagePicker = ImagePicker();

  NovelStatus _selectedStatus = NovelStatus.reading;
  NovelGenre _selectedGenre = NovelGenre.fantasy;
  DateTime? _startDate;
  DateTime? _finishDate;
  int? _readingMinutes;
  String? _coverImagePath;
  final List<Character> _characters = [];

  bool _isEditing = false;
  bool _isSaving = false;
  Novel? _loadedNovel;

  @override
  void initState() {
    super.initState();
    if (widget.novelId != null) {
      _isEditing = true;
      _loadNovel();
    }
  }

  void _loadNovel() {
    final appState = AppStateProvider.of(context);
    final novel = appState.getNovelById(widget.novelId!);

    if (novel != null) {
      _loadedNovel = novel;
      _titleController.text = novel.title;
      _authorController.text = novel.author;
      _plotSummaryController.text = novel.plotSummary ?? '';
      _selectedStatus = novel.status;
      _selectedGenre = novel.genre;
      _coverImagePath = novel.coverImagePath;
      _startDate = novel.startDate;
      _finishDate = novel.finishDate;
      _readingMinutes = novel.readingMinutes;
      _characters.addAll(novel.characters);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _plotSummaryController.dispose();
    _charactersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Novel' : 'New Novel'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context),
            ),
        ],
      ),
      body: SunnyPage(
        showTopDecoration: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditing && _loadedNovel != null)
                  _DetailCoverHero(novel: _loadedNovel!),
                if (_isEditing && _loadedNovel != null)
                  const SizedBox(height: AppSpacing.lg),
                if (!_isEditing) _CostWarning(appState: appState),
                if (!_isEditing) const SizedBox(height: AppSpacing.md),
                _FormSection(
                  title: 'Basic Information',
                  child: Column(
                    children: [
                      _CoverUploadField(),
                      const SizedBox(height: AppSpacing.md),
                      _TitleField(),
                      const SizedBox(height: AppSpacing.md),
                      _AuthorField(),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _FormSection(
                  title: 'Characters',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CharactersList(),
                      const SizedBox(height: AppSpacing.md),
                      _AddCharacterField(),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _FormSection(
                  title: 'Plot Summary',
                  child: _PlotSummaryField(),
                ),
                const SizedBox(height: AppSpacing.md),
                _FormSection(
                  title: 'Reading Timeline',
                  child: Column(
                    children: [
                      _DateFields(),
                      const SizedBox(height: AppSpacing.md),
                      _ReadingTimeField(),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _SaveButton(appState: appState),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _DetailCoverHero({required Novel novel}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SunnyCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          color: const Color(AppColors.cardElevated),
          child: Center(
            child: NovelCoverArt(
              novel: novel,
              width: 232,
              height: 318,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SunnyCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                novel.title,
                style: AppTypography.getH2TextStyle(
                  const Color(AppColors.textPrimary),
                ).copyWith(fontWeight: AppTypography.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                novel.author,
                style: AppTypography.getCaptionTextStyle(
                  const Color(AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _DetailPill(label: novel.status.label),
                  const SizedBox(width: AppSpacing.sm),
                  _DetailPill(label: novel.genre.label),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _CostWarning({required AppState appState}) {
    final cost = appState.getRecordCost();
    final canCreate = appState.canCreateRecord();
    final statusColor = canCreate
        ? const Color(AppColors.primaryMain)
        : const Color(AppColors.error);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(AppColors.cardElevated),
        borderRadius: AppBorderRadius.allMD,
        border: Border.all(
          color: statusColor,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: AppBorderRadius.allFull,
            ),
            child: Icon(
              canCreate ? Icons.check : Icons.info_outline,
              color: statusColor,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              canCreate
                  ? appState.freeCount > 0
                      ? 'Free record available (1 left)'
                      : 'Cost: $cost coins'
                  : 'Insufficient coins (need $cost)',
              style: AppTypography.getCaptionTextStyle(
                const Color(AppColors.textPrimary),
              ).copyWith(fontWeight: AppTypography.semibold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _TitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Title *',
        hintText: 'Enter novel title',
      ),
      style: AppTypography.getBodyTextStyle(
        const Color(AppColors.textPrimary),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _AuthorField() {
    return TextFormField(
      controller: _authorController,
      decoration: const InputDecoration(
        labelText: 'Author *',
        hintText: 'Enter author name',
      ),
      style: AppTypography.getBodyTextStyle(
        const Color(AppColors.textPrimary),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an author';
        }
        return null;
      },
    );
  }

  Widget _CoverUploadField() {
    final hasCover = _coverImagePath != null && _coverImagePath!.isNotEmpty;

    return GestureDetector(
      onTap: _pickCoverImage,
      child: Container(
        width: double.infinity,
        height: 286,
        decoration: BoxDecoration(
          color: hasCover
              ? const Color(AppColors.textPrimary).withOpacity(0.06)
              : const Color(AppColors.backgroundTertiary),
          borderRadius: AppBorderRadius.allMD,
          border: Border.all(
            color: const Color(AppColors.divider),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: AppBorderRadius.allMD,
          child: hasCover
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(_coverImagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _CoverUploadPlaceholder(),
                    ),
                    Positioned(
                      right: AppSpacing.sm,
                      top: AppSpacing.sm,
                      child: _CoverActionButton(
                        icon: Icons.edit,
                        onTap: _pickCoverImage,
                      ),
                    ),
                    Positioned(
                      right: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                      child: _CoverActionButton(
                        icon: Icons.close,
                        onTap: () {
                          setState(() {
                            _coverImagePath = null;
                          });
                        },
                      ),
                    ),
                  ],
                )
              : _CoverUploadPlaceholder(),
        ),
      ),
    );
  }

  Future<void> _pickCoverImage() async {
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );

    if (pickedImage == null || !mounted) {
      return;
    }

    setState(() {
      _coverImagePath = pickedImage.path;
    });
  }

  Widget _CharactersList() {
    if (_characters.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: const Color(AppColors.backgroundTertiary),
          borderRadius: AppBorderRadius.allMD,
        ),
        child: Text(
          'No characters added yet',
          style: AppTypography.getCaptionTextStyle(
            const Color(AppColors.textSecondary),
          ).copyWith(fontWeight: AppTypography.medium),
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _characters.asMap().entries.map((entry) {
        final index = entry.key;
        final character = entry.value;
        return Chip(
          label: Text(character.name),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () {
            setState(() {
              _characters.removeAt(index);
            });
          },
          backgroundColor: const Color(AppColors.cardElevated),
          labelStyle: AppTypography.getCaptionTextStyle(
            const Color(AppColors.textPrimary),
          ),
        );
      }).toList(),
    );
  }

  Widget _AddCharacterField() {
    return TextFormField(
      controller: _charactersController,
      decoration: InputDecoration(
        labelText: 'Add Character',
        hintText: 'Character name',
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xs),
          child: IconButton(
            icon: const Icon(Icons.person_add),
            color: const Color(AppColors.primaryMain),
            onPressed: _addCharacter,
          ),
        ),
      ),
      style: AppTypography.getBodyTextStyle(
        const Color(AppColors.textPrimary),
      ),
      onFieldSubmitted: (_) => _addCharacter(),
    );
  }

  void _addCharacter() {
    final name = _charactersController.text.trim();
    if (name.isEmpty) {
      return;
    }

    setState(() {
      _characters.add(Character(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
      ));
      _charactersController.clear();
    });
  }

  Widget _PlotSummaryField() {
    return TextFormField(
      controller: _plotSummaryController,
      decoration: const InputDecoration(
        labelText: 'Plot Summary',
        hintText: 'Brief summary of the plot...',
      ),
      style: AppTypography.getBodyTextStyle(
        const Color(AppColors.textPrimary),
      ),
      maxLines: 4,
    );
  }

  Widget _DateFields() {
    return Row(
      children: [
        Expanded(
          child: _DateField(
            label: 'Start Date',
            date: _startDate,
            onTap: () => _selectStartDate(),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _DateField(
            label: 'Finish Date',
            date: _finishDate,
            onTap: () => _selectFinishDate(),
          ),
        ),
      ],
    );
  }

  Widget _DateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.allMD,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(AppColors.cardElevated),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Not set',
              style: AppTypography.getBodyTextStyle(
                date != null
                    ? const Color(AppColors.textPrimary)
                    : const Color(AppColors.textSecondary),
              ),
            ),
            Icon(
              Icons.calendar_today,
              size: 20,
              color: const Color(AppColors.primaryMain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ReadingTimeField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Reading Time',
        hintText: 'Estimated reading time (minutes)',
        suffixIcon: Icon(Icons.schedule),
      ),
      style: AppTypography.getBodyTextStyle(
        const Color(AppColors.textPrimary),
      ),
      keyboardType: TextInputType.number,
      initialValue: _readingMinutes?.toString(),
      onChanged: (value) {
        _readingMinutes = int.tryParse(value);
      },
    );
  }

  Widget _SaveButton({required AppState appState}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : () => _saveNovel(appState),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.buttonPrimary),
          foregroundColor: const Color(AppColors.textInverse),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.allMD,
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(AppColors.textInverse),
                  ),
                ),
              )
            : Text(
                _isEditing ? 'Update Novel' : 'Save Novel',
                style: AppTypography.getBodyTextStyle(
                  const Color(AppColors.textInverse),
                ).copyWith(
                  fontWeight: AppTypography.semibold,
                ),
              ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_finishDate != null && _finishDate!.isBefore(_startDate!)) {
          _finishDate = null;
        }
      });
    }
  }

  Future<void> _selectFinishDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _finishDate ?? _startDate ?? now,
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        _finishDate = picked;
        if (_finishDate!.isBefore(_startDate ?? _finishDate!)) {
          _startDate = _finishDate;
        }
      });
    }
  }

  Future<void> _saveNovel(AppState appState) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if can create
    if (!_isEditing && !appState.canCreateRecord()) {
      _showInsufficientCoinsDialog();
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Simulate save delay
    await Future.delayed(const Duration(milliseconds: 500));

    final novel = Novel(
      id: widget.novelId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      genre: _selectedGenre,
      status: _selectedStatus,
      characters: List.from(_characters),
      coverImagePath: _coverImagePath,
      plotSummary: _plotSummaryController.text.trim().isEmpty
          ? null
          : _plotSummaryController.text.trim(),
      startDate: _startDate,
      finishDate: _finishDate,
      readingMinutes: _readingMinutes,
    );

    if (_isEditing) {
      appState.updateNovel(novel);
    } else {
      appState.consumeCoinsForRecord();
      appState.addNovel(novel);
    }

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      context.pop();
    }
  }

  void _showInsufficientCoinsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insufficient Coins'),
        content: Text(
          'You need ${AppStateProvider.of(context).getRecordCost()} coins to create a record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate in next frame after dialog is closed
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.push(AppRoutes.coinStore);
                }
              });
            },
            child: const Text('Get Coins'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Novel'),
        content: const Text('Are you sure you want to delete this novel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final appState = AppStateProvider.of(context);
              appState.deleteNovel(widget.novelId!);
              Navigator.pop(context);
              // Navigate to library after deletion
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.go(AppRoutes.library);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.error),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FormSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SunnyCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: const Color(AppColors.cardBackground),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.getH3TextStyle(
              const Color(AppColors.textPrimary),
            ).copyWith(fontWeight: AppTypography.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _CoverUploadPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(AppColors.primaryMain).withOpacity(0.12),
              borderRadius: AppBorderRadius.allFull,
            ),
            child: const Icon(
              Icons.add_photo_alternate,
              color: Color(AppColors.primaryMain),
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Upload Cover',
            style: AppTypography.getCaptionTextStyle(
              const Color(AppColors.textPrimary),
            ).copyWith(fontWeight: AppTypography.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose from Photos',
            style: AppTypography.getSmallTextStyle(
              const Color(AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CoverActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(AppColors.cardElevated).withOpacity(0.92),
          borderRadius: AppBorderRadius.allFull,
          border: Border.all(
            color: const Color(AppColors.divider),
          ),
        ),
        child: Icon(
          icon,
          color: const Color(AppColors.primaryMain),
          size: 18,
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  final String label;

  const _DetailPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: const Color(AppColors.backgroundTertiary),
        borderRadius: AppBorderRadius.allFull,
        border: Border.all(
          color: const Color(AppColors.cardElevated),
          width: 2,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.getSmallTextStyle(
          const Color(AppColors.textPrimary),
        ).copyWith(fontWeight: AppTypography.bold),
      ),
    );
  }
}
