import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimiu/gen_a/A.dart';
import 'package:mimiu/mimiu/app/widgets/page_header.dart';

import 'profile_logic.dart';
import '../../routes/app_routes.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileLogic logic = Get.put(ProfileLogic());

  @override
  Widget build(BuildContext context) {
    logic;
    return Stack(
      children: [
        Column(
          children: [
            const _Header(),
            Expanded(child: _Body(logic: logic)),
          ],
        ),
        Obx(() {
          if (!logic.accountActionInProgress.value) {
            return const SizedBox.shrink();
          }
          return Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    logic.accountActionText.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PageHeader(
          title: 'My Profile',
          titleSize: 30,
          subtitle: 'Manage your Kooya account',
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

class _Avatar extends StatefulWidget {
  const _Avatar();

  @override
  State<_Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<_Avatar> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            return Container(
              width: 124 + 10 * _pulse.value,
              height: 124 + 10 * _pulse.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
              ),
            );
          },
        ),
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
            ),
            border: Border.all(
              color: const Color(0xFFFDE68A).withValues(alpha: 0.30),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF78350F).withValues(alpha: 0.60),
                blurRadius: 44,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              A.assets_mimiu_logo,
              width: 112,
              height: 112,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

// Subtitle is handled by PageHeader now.

class _Body extends StatelessWidget {
  const _Body({required this.logic});

  final ProfileLogic logic;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final disabled = logic.accountActionInProgress.value;
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
        children: [
          const _Avatar(),
          const SizedBox(height: 22),
          _FeaturedButton(
            title: 'Top Up',
            subtitle: 'Add credits to your account',
            icon: Icons.credit_card_rounded,
            onTap: disabled ? () {} : () => Get.toNamed(AppRoutes.coins),
          ),
          const SizedBox(height: 12),
          _SettingButton(
            title: 'Feedback',
            icon: Icons.feedback_outlined,
            onTap: disabled ? () {} : () => Get.toNamed(AppRoutes.feedback),
          ),
          const SizedBox(height: 12),
          _SettingButton(
            title: 'Privacy Policy',
            icon: Icons.shield_outlined,
            onTap: disabled ? () {} : () => Get.toNamed(AppRoutes.privacyPolicy),
          ),
          const SizedBox(height: 12),
          _SettingButton(
            title: 'Terms of Use',
            icon: Icons.description_outlined,
            onTap: disabled ? () {} : () => Get.toNamed(AppRoutes.termsOfService),
            delayMs: 50,
          ),
          const SizedBox(height: 12),
          _SettingButton(
            title: 'Log Out',
            icon: Icons.logout_rounded,
            onTap: disabled ? () {} : logic.logOut,
            delayMs: 100,
          ),
          const SizedBox(height: 12),
          _DangerButton(
            title: 'Delete Account',
            icon: Icons.person_off_rounded,
            onTap: disabled ? () {} : logic.deleteAccount,
            delayMs: 150,
          ),
          const SizedBox(height: 26),
        ],
      );
    });
  }

}

class _FeaturedButton extends StatefulWidget {
  const _FeaturedButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_FeaturedButton> createState() => _FeaturedButtonState();
}

class _FeaturedButtonState extends State<_FeaturedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: _pressed ? 0.98 : 1,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFFDE68A).withValues(alpha: 0.40),
              width: 2,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF78350F).withValues(alpha: 0.55),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.white.withValues(alpha: 0.25),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFFFF7ED),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.85),
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingButton extends StatelessWidget {
  const _SettingButton({
    required this.title,
    required this.icon,
    required this.onTap,
    this.delayMs = 0,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return _SlideIn(
      delayMs: delayMs,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFF78350F).withValues(alpha: 0.30),
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade900.withValues(alpha: 0.80),
                Colors.black.withValues(alpha: 0.80),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF422006).withValues(alpha: 0.50),
                  border: Border.all(
                    color: const Color(0xFF92400E).withValues(alpha: 0.40),
                  ),
                ),
                child: Icon(icon, size: 28, color: const Color(0xFFFBBF24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF6B7280).withValues(alpha: 0.95),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.title,
    required this.icon,
    required this.onTap,
    this.delayMs = 0,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return _SlideIn(
      delayMs: delayMs,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFF7F1D1D).withValues(alpha: 0.40),
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade900.withValues(alpha: 0.80),
                Colors.black.withValues(alpha: 0.80),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF7F1D1D).withValues(alpha: 0.25),
                  border: Border.all(
                    color: const Color(0xFF7F1D1D).withValues(alpha: 0.50),
                  ),
                ),
                child: Icon(icon, size: 28, color: const Color(0xFFF87171)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF87171),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFEF4444).withValues(alpha: 0.85),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideIn extends StatefulWidget {
  const _SlideIn({required this.child, required this.delayMs});

  final Widget child;
  final int delayMs;

  @override
  State<_SlideIn> createState() => _SlideInState();
}

class _SlideInState extends State<_SlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        return Opacity(
          opacity: _t.value,
          child: Transform.translate(
            offset: Offset(-16 * (1 - _t.value), 0),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
