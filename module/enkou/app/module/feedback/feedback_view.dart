import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:enkou/enkou/app/widget/app_toast.dart';
import 'package:enkou/enkou/app/widget/voice_to_text_control.dart';
import 'feedback_logic.dart';

// Lunar Whisper（雾感渐变）统一配色
const Color _bg = Color(0xFFF6F4FB);
const Color _surface = Color(0xFFFDFBFF);
const Color _separator = Color(0xFFE6E0EF);
const Color _titleColor = Color(0xFF242129);
const Color _mutedColor = Color(0xFF7C7785);
const Color _accent = Color(0xFF8F6AD8);
const Color _accentDeep = Color(0xFF6F4AD0);

// Feedback 背景渐变：与其他页面统一的粉紫蓝雾感
const Color _lunarPink = Color(0xFFEED0F2);
const Color _lunarLavender = Color(0xFF9EBAEB);
const Color _lunarSky = Color(0xFF96DFF5);
const LinearGradient _pageBgGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  // 顶部粉紫 → 中段淡蓝 → 底部回落到雾白 _bg
  stops: [0.0, 0.3, 0.7, 1.0],
  colors: [_lunarPink, _lunarLavender, _lunarSky, _bg],
);

class FeedbackPage extends StatelessWidget {
  FeedbackPage({Key? key}) : super(key: key);

  final FeedbackLogic logic = Get.put(FeedbackLogic());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: const BoxDecoration(gradient: _pageBgGradient),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              _buildHeader(theme, topPadding),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GradientCard(theme: theme),
                      const SizedBox(height: 24),
                      _FeedbackForm(theme: theme, logic: logic),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, double topPadding) {
    return Column(
      children: [
        SizedBox(height: topPadding + 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // 与充值页面统一的圆形返回按钮
              GestureDetector(
                onTap: Get.back,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _separator, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: _titleColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Feedback',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _titleColor,
                      ) ??
                      const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _titleColor,
                      ),
                ),
              ),
              const SizedBox(width: 44), // 占位，使标题居中
            ],
          ),
        ),
      ],
    );
  }
}

class _GradientCard extends StatelessWidget {
  const _GradientCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _accent,
            _accentDeep,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A8F6AD8),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.16),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Tell us what feels right or wrong',
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ) ??
                    const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'We read every message. Your feedback helps shape the next version of Enkou.',
            style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xDFFFFFFF),
                ) ??
                const TextStyle(
                  fontSize: 12,
                  color: Color(0xDFFFFFFF),
                ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackForm extends StatefulWidget {
  const _FeedbackForm({required this.theme, required this.logic});

  final ThemeData theme;
  final FeedbackLogic logic;

  @override
  State<_FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<_FeedbackForm> {
  late final TextEditingController _textCtrl;
  final List<String> _types = const [
    'Feature request',
    'Bug report',
    'UI improvement',
    'Other',
  ];
  String _selectedType = 'Feature request';

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Feedback type 标题
        Text(
          'Feedback type',
          style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _titleColor,
                decoration: TextDecoration.none,
              ) ??
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _titleColor,
                decoration: TextDecoration.none,
              ),
        ),
        const SizedBox(height: 10),
        // 2x2 反馈类型卡片
        LayoutBuilder(
          builder: (context, constraints) {
            final double spacing = 12;
            final double itemWidth =
                (constraints.maxWidth - spacing) / 2; // 两列布局

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _types.map((label) {
                final bool selected = _selectedType == label;
                return SizedBox(
                  width: itemWidth,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = label;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: selected ? _accent.withValues(alpha: 0.12) : _surface,
                        border: Border.all(
                          color: selected ? _accentDeep : _separator,
                          width: 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: _accent.withValues(alpha: 0.24),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : const [],
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 15,
                                fontWeight:
                                    selected ? FontWeight.w700 : FontWeight.w500,
                                color: selected ? _accentDeep : _titleColor,
                                decoration: TextDecoration.none,
                              ) ??
                              TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    selected ? FontWeight.w700 : FontWeight.w500,
                                color: selected ? _accentDeep : _titleColor,
                                decoration: TextDecoration.none,
                              ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        // Description 标题
        Text(
          'Description',
          style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _titleColor,
                decoration: TextDecoration.none,
              ) ??
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _titleColor,
                decoration: TextDecoration.none,
              ),
        ),
        const SizedBox(height: 10),
        Material(
          color: _surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _separator, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 60),
                      child: SizedBox(
                        height: 180,
                        child: TextField(
                          controller: _textCtrl,
                          maxLines: null,
                          expands: true,
                          style: const TextStyle(
                            fontSize: 16,
                            color: _titleColor,
                            height: 1.4,
                            decoration: TextDecoration.none,
                          ),
                          decoration: const InputDecoration(
                            hintText:
                                'Describe what happened and what you expected...',
                            hintMaxLines: 3,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: VoiceToTextControl(
                        controller: _textCtrl,
                        iconColor: _accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: _GradientButton(
            onTap: () {
              if (_textCtrl.text.trim().isEmpty) {
                AppToast.short('Please enter your feedback first.');
                return;
              }
              AppToast.show(
                'Thanks',
                'Your feedback has been recorded (placeholder).',
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              _accentDeep,
              _accent,
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.send_rounded, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Send',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
