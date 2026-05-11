import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../cherish_ai/cherish_moment_storage.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/dialog_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/tavia_ui.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/models/content_model.dart';

/// Detail page with a large hero image and text kept below the media.
class DetailPage extends StatefulWidget {
  final String itemId;

  const DetailPage({
    super.key,
    required this.itemId,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  ContentModel? _content;
  List<ContentModel> _relatedGallery = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    await Future.delayed(const Duration(milliseconds: 260));

    if (!mounted) {
      return;
    }

    final inMemory = [
      ...AppState().history,
      ...AppState().homeFeed,
    ].where((item) => item.id == widget.itemId);

    ContentModel content;
    if (inMemory.isNotEmpty) {
      content = inMemory.first;
    } else {
      final storedHistory = await CherishMomentStorage.getContentHistory();
      final storedMatch = storedHistory.where((item) => item.id == widget.itemId);

      if (storedMatch.isNotEmpty) {
        content = storedMatch.first;
      } else {
        final match = RegExp(r'(\d+)$').firstMatch(widget.itemId);
        final index = int.tryParse(match?.group(1) ?? '0') ?? 0;
        content = ContentModel.mockByIndex(index);
      }
    }

    setState(() {
      _content = content;
      _relatedGallery = _buildRelatedGallery(content);
      _isLoading = false;
    });
  }

  List<ContentModel> _buildRelatedGallery(ContentModel currentContent) {
    final candidates = ContentModel.getMockList()
        .where((item) => item.id != currentContent.id)
        .where((item) => (item.imageUrl?.trim().isNotEmpty ?? false))
        .toList();

    candidates.shuffle(Random());
    return candidates.take(3).toList(growable: false);
  }

  Future<void> _copyCaption() async {
    if (_content == null) {
      return;
    }

    final text = (_content!.description?.trim().isNotEmpty ?? false)
        ? _content!.description!.trim()
        : _content!.title;

    await Clipboard.setData(ClipboardData(text: text));

    if (!mounted) {
      return;
    }

    AppDialog.showToast(
      context,
      message: 'Caption copied',
    );
  }

  Future<void> _shareContent() async {
    if (_content == null) {
      return;
    }

    final text = (_content!.description?.trim().isNotEmpty ?? false)
        ? _content!.description!.trim()
        : _content!.title;

    await Share.share(
      text,
      subject: _content!.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TaviaBackground(
        child: SafeArea(
          bottom: false,
          child: _isLoading
              ? const LoadingIndicator()
              : _content == null
                  ? const ErrorStateWidget(
                      title: 'Content not found',
                      message: 'We could not load this artwork right now.',
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.spacingLg,
                        AppConstants.spacingMd,
                        AppConstants.spacingLg,
                        AppConstants.spacingXxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopBar(),
                          const SizedBox(height: AppConstants.spacingLg),
                          _buildHeroImage(),
                          if ((_content!.tags?.isNotEmpty ?? false)) ...[
                            const SizedBox(height: AppConstants.spacingMd),
                            _buildTagStrip(),
                          ],
                          const SizedBox(height: AppConstants.spacingLg),
                          _buildSummaryPanel(),
                          const SizedBox(height: AppConstants.spacingLg),
                          _buildRelatedStrip(),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        TaviaIconButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.of(context).pop(),
        ),
        const Spacer(),
        TaviaIconButton(
          icon: Icons.share_outlined,
          onTap: _shareContent,
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaviaMedia(
          source: _content!.imageUrl,
          height: 460,
          width: double.infinity,
          borderRadius: BorderRadius.circular(34),
        ),
      ],
    );
  }

  Widget _buildSummaryPanel() {
    return TaviaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_content!.title, style: AppTextStyles.h2),
          const SizedBox(height: AppConstants.spacingLg),
          Text(
            _content!.description ?? '',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          SizedBox(
            width: double.infinity,
            child: TaviaPrimaryButton(
              label: 'Copy Caption',
              onPressed: _copyCaption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagStrip() {
    return Wrap(
      spacing: AppConstants.spacingSm,
      runSpacing: AppConstants.spacingSm,
      children: (_content!.tags ?? const []).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          ),
          child: Text(tag, style: AppTextStyles.captionMedium),
        );
      }).toList(),
    );
  }

  Widget _buildRelatedStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More visuals',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          'Extra image surfaces keep the page feeling visual, without letting text sit on top of the hero image.',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.white.withValues(alpha: 0.78),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_relatedGallery.length, (index) {
              final item = _relatedGallery[index];
              return Padding(
                padding: EdgeInsets.only(
                  right:
                      index == _relatedGallery.length - 1
                          ? 0
                          : AppConstants.spacingMd,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    width: 120,
                    height: 148,
                    child: TaviaMedia(source: item.imageUrl),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

}
