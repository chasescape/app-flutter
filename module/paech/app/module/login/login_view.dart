import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paech/gen_a/A.dart';
import 'package:paech/gen_a/B.dart';
import 'package:rive/rive.dart' show RiveAnimation, Artboard, StateMachineController, SMITrigger;

import '../../../env/app_env.dart';
import '../../components/bubble_particle_animation.dart';
import '../protocol/protocol_view.dart';
import 'login_logic.dart';

/// ============================================
/// Start 按钮切换开关
/// ============================================
/// true = 使用 Rive start 动画按钮
/// false = 使用原始普通按钮
const bool _useRiveStartButton = false;
/// ============================================

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late final LoginLogic logic;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    logic = Get.put(LoginLogic());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          _LoginErrorSnackbar(logic: logic),
          Positioned.fill(
            child: Image.asset(
              A.assets_paech_open,
              fit: BoxFit.cover,
            ),
          ),
          // 气泡粒子效果
          const Positioned.fill(
            child: BubbleParticleAnimation(
              particleCount: 20,
            ),
          ),
          // 内容层
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              child: Column(
                children: [
                  const Spacer(),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          _StartButton(
                            logic: logic,
                            theme: theme,
                            onShowAgreement: _showAgreementDialog,
                          ),
                          const SizedBox(height: 14),
                          _AgreementRow(logic: logic, theme: theme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Rive Loading 遮罩层
          _RiveLoadingOverlay(logic: logic),
        ],
      ),
    );
  }

  void _showAgreementDialog() {
    if (!mounted) return;
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black26,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 22),
              const Text(
                'Agreement Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2A26),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please agree to our Terms and Privacy Policy before continuing.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: const Color(0xFF2D2A26).withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2D2A26),
                        side: const BorderSide(color: Color(0xFFE8E0D7)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        logic.togglePrivacy(true);
                        Get.back();
                        logic.onStartPressed();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFffc8ff)
                            .withValues(alpha: 0.85),
                        foregroundColor: const Color(0xff130e14),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Agree'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

/// ============================================
/// Start 按钮实现 - 原始普通按钮版本
/// ============================================
class _OriginalStartButton extends StatefulWidget {
  const _OriginalStartButton({
    required this.logic,
    required this.theme,
    required this.onShowAgreement,
  });

  final LoginLogic logic;
  final ThemeData theme;
  final VoidCallback onShowAgreement;

  @override
  State<_OriginalStartButton> createState() => _OriginalStartButtonState();
}

class _OriginalStartButtonState extends State<_OriginalStartButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final logic = widget.logic;
    final theme = widget.theme;

    return GestureDetector(
      onTapDown: (_) {
        if (!logic.isLoading.value) setState(() => _pressed = true);
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        if (logic.isLoading.value) return;
        if (!logic.agreedPrivacy.value) {
          widget.onShowAgreement();
          return;
        }
        logic.onStartPressed();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Center(
          child: SizedBox(
            width: 320,
            height: 54,
            child: Obx(() {
              final isLoading = logic.isLoading.value;
              return ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  disabledBackgroundColor:
                      Colors.white.withValues(alpha: 0.65),
                  foregroundColor: const Color(0xFF6F5BFF),
                  disabledForegroundColor: const Color(0xFF6F5BFF).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6F5BFF)),
                        ),
                      )
                    : const Text(
                        'Start',
                        style: TextStyle(color: Colors.black),
                      ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// ============================================
/// Start 按钮实现 - Rive start 动画版本
/// ============================================
class _RiveStartButton extends StatefulWidget {
  const _RiveStartButton({
    required this.logic,
    required this.theme,
    required this.onShowAgreement,
  });

  final LoginLogic logic;
  final ThemeData theme;
  final VoidCallback onShowAgreement;

  @override
  State<_RiveStartButton> createState() => _RiveStartButtonState();
}

class _RiveStartButtonState extends State<_RiveStartButton> {
  SMITrigger? _pressTrigger;
  SMITrigger? _releaseTrigger;

  void _onRiveInit(Artboard artboard) {
    debugPrint('[_RiveStartButton] Rive artboard name: ${artboard.name}');

    // 获取所有动画名称
    final animationNames = artboard.animations.map((a) => a.name).toList();
    debugPrint('[_RiveStartButton] Animations: $animationNames');

    // 尝试不同的状态机名称
    StateMachineController? controller;

    for (final name in ['State Machine 1', 'State Machine', 'Button', 'Default']) {
      controller = StateMachineController.fromArtboard(artboard, name);
      if (controller != null) {
        debugPrint('[_RiveStartButton] Found state machine: $name');
        break;
      }
    }

    if (controller != null) {
      artboard.addController(controller);

      // 打印所有输入
      final inputs = controller.inputs;
      debugPrint('[_RiveStartButton] Inputs: ${inputs.map((i) => '${i.name} (${i.runtimeType})').toList()}');

      // 尝试查找触发器
      _pressTrigger = controller.findInput<bool>('press') as SMITrigger?;
      _releaseTrigger = controller.findInput<bool>('release') as SMITrigger?;
      if (_pressTrigger == null) {
        _pressTrigger = controller.findInput<bool>('Hover') as SMITrigger?;
      }
      if (_pressTrigger == null) {
        _pressTrigger = controller.findInput<bool>('Click') as SMITrigger?;
      }
      if (_pressTrigger == null) {
        _pressTrigger = controller.findInput<bool>('tap') as SMITrigger?;
      }

      debugPrint('[_RiveStartButton] press trigger: ${_pressTrigger?.name}');
      debugPrint('[_RiveStartButton] release trigger: ${_releaseTrigger?.name}');
    } else {
      debugPrint('[_RiveStartButton] No state machine found');
    }
  }

  void _handleTap() {
    final logic = widget.logic;
    if (logic.isLoading.value) return;
    if (!logic.agreedPrivacy.value) {
      widget.onShowAgreement();
      return;
    }
    logic.onStartPressed();
  }

  @override
  Widget build(BuildContext context) {
    final logic = widget.logic;

    return GestureDetector(
      onTapDown: (_) {
        if (!logic.isLoading.value) {
          debugPrint('[_RiveStartButton] onTapDown');
          _pressTrigger?.fire();
        }
      },
      onTapUp: (_) {
        if (!logic.isLoading.value) {
          debugPrint('[_RiveStartButton] onTapUp');
          _releaseTrigger?.fire();
        }
      },
      onTapCancel: () {
        if (!logic.isLoading.value) {
          debugPrint('[_RiveStartButton] onTapCancel');
          _releaseTrigger?.fire();
        }
      },
      onTap: () {
        debugPrint('[_RiveStartButton] onTap');
        _handleTap();
      },
      child: Opacity(
        opacity: logic.isLoading.value ? 0.6 : 1.0,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              width: 320,
              height: 54,
              // child: RepaintBoundary(
              //   child: RiveAnimation.asset(
              //     B.assets_rive_start,
              //     fit: BoxFit.cover,
              //     onInit: _onRiveInit,
              //   ),
              // ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================
/// Start 按钮路由 - 根据开关选择使用哪个实现
/// ============================================
class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.logic,
    required this.theme,
    required this.onShowAgreement,
  });

  final LoginLogic logic;
  final ThemeData theme;
  final VoidCallback onShowAgreement;

  @override
  Widget build(BuildContext context) {
    return _useRiveStartButton
        ? _RiveStartButton(
            logic: logic,
            theme: theme,
            onShowAgreement: onShowAgreement,
          )
        : _OriginalStartButton(
            logic: logic,
            theme: theme,
            onShowAgreement: onShowAgreement,
          );
  }
}

/// 协议勾选行
class _AgreementRow extends StatelessWidget {
  const _AgreementRow({required this.logic, required this.theme});

  final LoginLogic logic;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final agreed = logic.agreedPrivacy.value;
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Radio<bool>(
                  value: true,
                  groupValue: agreed ? true : null,
                  toggleable: true,
                  onChanged: (_) => logic.togglePrivacy(!agreed),
                  activeColor: const Color(0xFF2D2A26),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF2D2A26),
                      height: 1.35,
                    ),
                    children: [
                      const TextSpan(
                        text: 'By tapping Start, you agree to our ',
                      ),
                      TextSpan(
                        text: 'Terms',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF2D2A26),
                          height: 1.35,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w800,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            final env = Aquaria255AppEnv();
                            if (env.h5User.isNotEmpty) {
                              Get.to(() => ProtocolPage(
                                    url: env.h5User,
                                    title: 'Terms of Service',
                                  ));
                            }
                          },
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF2D2A26),
                          height: 1.35,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w800,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            final env = Aquaria255AppEnv();
                            if (env.h5Privacy.isNotEmpty) {
                              Get.to(() => ProtocolPage(
                                    url: env.h5Privacy,
                                    title: 'Privacy Policy',
                                  ));
                            }
                          },
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// 监听 logic.errorMessage，在 view 内用统一样式显示 snackbar
class _LoginErrorSnackbar extends StatefulWidget {
  const _LoginErrorSnackbar({required this.logic});

  final LoginLogic logic;

  @override
  State<_LoginErrorSnackbar> createState() => _LoginErrorSnackbarState();
}

class _LoginErrorSnackbarState extends State<_LoginErrorSnackbar> {
  @override
  void initState() {
    super.initState();
    ever(widget.logic.errorMessage, (String msg) {
      if (msg.isEmpty) return;
      Get.snackbar(
        'Login Failed',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF2D2A26),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      widget.logic.errorMessage.value = '';
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Rive Loading 全局遮罩层
class _RiveLoadingOverlay extends StatelessWidget {
  const _RiveLoadingOverlay({required this.logic});

  final LoginLogic logic;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = logic.isLoading.value;
      if (!isLoading) return const SizedBox.shrink();

      return Positioned.fill(
        child: Container(
          color: Colors.black.withValues(alpha: 0.4),
          child: Center(
            child: RepaintBoundary(
              child: SizedBox(
                width: 200,
                height: 200,
                child: RiveAnimation.asset(
                  B.assets_rive_loading,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
