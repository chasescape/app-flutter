import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:enkou/enkou/app/widget/voice_to_text_control.dart';
import 'package:enkou/enkou/app/data/journal_store.dart';

import 'day_journal_logic.dart';

// Lunar Whisper（雾感渐变）统一配色
const Color _bg = Color(0xFFF6F4FB);
const Color _surface = Color(0xFFFDFBFF);
const Color _separator = Color(0xFFE6E0EF);
const Color _titleColor = Color(0xFF242129);
const Color _mutedColor = Color(0xFF7C7785);
const Color _accent = Color(0xFF8F6AD8);
const Color _accentDeep = Color(0xFF6F4AD0);
const Color _chipText = Color(0xFF4B4458);

// 使用不透明的柔和渐变，避免背景“透”出底层内容
const Color _lunarPink = Color(0xFFEED0F2);
const Color _lunarLavender = Color(0xFF9EBAEB);
const Color _lunarSky = Color(0xFF96DFF5);
const LinearGradient _pageBgGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  stops: [0.0, 0.28, 0.6, 1.0],
  colors: [_lunarPink, _lunarLavender, _lunarSky, _bg],
);

class DayJournalPage extends GetView<DayJournalLogic> {
  const DayJournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = controller.date;
    final hasLocation = controller.locationTag.isNotEmpty;

    final dateLabel = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final subtitle = hasLocation ? controller.locationTag : 'Journal Editor';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        controller.exitToHome();
      },
      child: GestureDetector(
        // 点击空白处收起键盘
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
        // 让背景渐变从屏幕最顶端贯穿到 AppBar 区域
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: controller.exitToHome,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _titleColor,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                    ) ??
                    const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                      color: _mutedColor,
                    ) ??
                    const TextStyle(
                      fontSize: 12,
                      color: _mutedColor,
                    ),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: _pageBgGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DayRecordsChips(logic: controller),
                  const SizedBox(height: 12),
                  _MediaPreviewCard(logic: controller),
                  const SizedBox(height: 16),

                  Text(
                    'Journal',
                    style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _titleColor,
                        ) ??
                        const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _titleColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _separator, width: 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x11000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Stack(
                      children: [
                        // 文本输入区域
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 40, // 给语音按钮预留一点空间
                            bottom: 4,
                          ),
                          child: TextField(
                            controller: controller.textCtrl,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'Write text for this date...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        // 右下角语音转文字小按键
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: VoiceToTextControl(
                            controller: controller.textCtrl,
                            iconColor: _accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: JournalStore.topicTags
                          .map(
                            (tag) => ChoiceChip(
                              label: Text(tag),
                              selected: controller.tags.contains(tag),
                              onSelected: (_) => controller.toggleTag(tag),
                              selectedColor: _accent,
                              labelStyle: TextStyle(
                                color: controller.tags.contains(tag)
                                    ? Colors.white
                                    : _chipText,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                                side: const BorderSide(color: _separator),
                              ),
                              backgroundColor: _surface,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        // 保存前先收起键盘
                        FocusScope.of(context).unfocus();
                        controller.saveJournal();
                      },
                      child: const Text(
                        'Save Journal',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

class _DayRecordsChips extends StatelessWidget {
  const _DayRecordsChips({required this.logic});

  final DayJournalLogic logic;

  String _timeLabel(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = logic.journalStore.entriesForDate(logic.date);
      if (records.isEmpty) return const SizedBox.shrink();

      final selectedId = logic.entryId.value;
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: _surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _separator),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text(
              'Records',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _mutedColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('New'),
                      selected: selectedId == null,
                      onSelected: (_) => logic.startNewRecord(),
                      selectedColor: _accent,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: selectedId == null ? Colors.white : _chipText,
                      ),
                      side: BorderSide(
                        color: selectedId == null
                            ? _accentDeep.withValues(alpha: 0.18)
                            : _separator,
                      ),
                      backgroundColor: _surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    ...records.map((e) {
                      final t = e.lastEditedAt ?? e.createdAt;
                      final isSelected = selectedId != null && selectedId == e.id;
                      return ChoiceChip(
                        label: Text(_timeLabel(t)),
                        selected: isSelected,
                        onSelected: (_) => logic.switchToRecord(e.id),
                        selectedColor: _accent,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : _chipText,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? _accentDeep.withValues(alpha: 0.18)
                              : _separator,
                        ),
                        backgroundColor: _surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MediaPreviewCard extends StatelessWidget {
  const _MediaPreviewCard({required this.logic});

  final DayJournalLogic logic;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final medias = logic.medias;
      final hasMedia = medias.isNotEmpty;

      String? imageSrc;
      String? label;
      int imageCount = 0;

      // 只关心真正选中的图片：按时间顺序找到最后一张 image
      final imageMedias =
          medias.where((m) => m.type.toLowerCase() == 'image').toList();
      imageCount = imageMedias.length;
      if (imageMedias.isNotEmpty) {
        final last = imageMedias.last;
        imageSrc = last.source;
        label = last.label;
      }

      Widget content;
      if (imageSrc != null) {
        final src = imageSrc;
        final isAsset = src.startsWith('assets/');
        final imageWidget = isAsset
            ? Image.asset(
                src,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _PlaceholderContent(
                    icon: Icons.image_not_supported_rounded,
                    title: 'Image preview',
                    subtitle: label ?? 'Tap to upload image',
                  );
                },
              )
            : Image.file(
                File(src),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _PlaceholderContent(
                    icon: Icons.image_not_supported_rounded,
                    title: 'Image preview',
                    subtitle: label ?? 'Tap to upload image',
                  );
                },
              );

        content = ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageWidget,
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.40),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        label ?? 'Image preview',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (imageCount > 1)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$imageCount images',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (hasMedia) {
        content = _PlaceholderContent(
          icon: Icons.collections_rounded,
          title: 'Media attached',
          subtitle: label ?? 'You have attached media for this day',
        );
      } else {
        content = const _PlaceholderContent(
          icon: Icons.image_rounded,
          title: 'Add photos',
          subtitle:
              'Upload images for this day, then write your journal below.',
        );
      }

      return GestureDetector(
        onTap: logic.addImageFromGallery,
        child: Container(
          height: 480,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _separator, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: content,
        ),
      );
    });
  }
}

class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _lunarPink.withValues(alpha: 0.3),
            _lunarLavender.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40,
            color: _accentDeep,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _titleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: _mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}
