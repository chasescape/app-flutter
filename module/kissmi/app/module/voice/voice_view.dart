import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widget/glass_effect.dart';
import '../../widget/kissmi_background.dart';

class VoicePage extends StatelessWidget {
  const VoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: KissmiBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _CircleButton(
                      icon: Icons.arrow_back,
                      onTap: () => Get.back(),
                    ),
                    const Spacer(),
                    Text(
                      'Voice Chat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const Spacer(),
                    _CircleButton(
                      icon: Icons.more_horiz,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                GlassEffect(
                  settings: const GlassEffectSettings(
                    radius: 140,
                    backgroundOpacity: 0.12,
                    borderOpacity: 0.2,
                    shadowOpacity: 0.25,
                    highlightOpacity: 0.4,
                  ),
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Center(
                      child: Icon(
                        Icons.graphic_eq,
                        size: 60,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Listening...',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Speak your thoughts freely and get personalized guidance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _GlassIconButton(
                      icon: Icons.chat_bubble,
                      onTap: () => Get.back(),
                    ),
                    const SizedBox(width: 20),
                    _MicButton(
                      onTap: () {},
                    ),
                    const SizedBox(width: 20),
                    _GlassIconButton(
                      icon: Icons.close,
                      onTap: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassEffect(
      settings: const GlassEffectSettings(
        radius: 22,
        backgroundOpacity: 0.12,
        borderOpacity: 0.2,
        shadowOpacity: 0.18,
        highlightOpacity: 0.3,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
        ),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassEffect(
      settings: const GlassEffectSettings(
        radius: 40,
        backgroundOpacity: 0.18,
        borderOpacity: 0.25,
        shadowOpacity: 0.3,
        highlightOpacity: 0.45,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: const SizedBox(
          width: 72,
          height: 72,
          child: Icon(
            Icons.mic,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassEffect(
      settings: const GlassEffectSettings(
        radius: 24,
        backgroundOpacity: 0.12,
        borderOpacity: 0.2,
        shadowOpacity: 0.18,
        highlightOpacity: 0.3,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
        ),
      ),
    );
  }
}
