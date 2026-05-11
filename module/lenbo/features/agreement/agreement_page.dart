import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lenbo/lenbo/app/routes/app_routes.dart';
import 'package:lenbo/lenbo/env/app_env.dart';
import 'package:lenbo/lenbo/core/theme/app_colors.dart';
import 'package:lenbo/lenbo/core/theme/app_spacing.dart';

enum AgreementType {
  user,
  privacy;

  String get displayName {
    switch (this) {
      case AgreementType.user:
        return 'Terms of Service';
      case AgreementType.privacy:
        return 'Privacy Policy';
    }
  }
}

class AgreementPage extends StatefulWidget {
  final String? title;
  final String? url;

  const AgreementPage({
    super.key,
    this.title,
    this.url,
  });

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  late final AgreementType _agreementType;
  bool _isLoading = true;
  String? _error;

  String get _title => _agreementType.displayName;

  String get _url {
    final passedUrl = widget.url ?? AppRoutes.getAgreementUrl();
    if (passedUrl != null && passedUrl.isNotEmpty) {
      return passedUrl;
    }

    final appEnv = AppEnv();
    switch (_agreementType) {
      case AgreementType.user:
        return appEnv.h5User;
      case AgreementType.privacy:
        return appEnv.h5Privacy;
    }
  }

  @override
  void initState() {
    super.initState();
    _agreementType = _parseAgreementType();
  }

  AgreementType _parseAgreementType() {
    final title = widget.title ?? AppRoutes.getAgreementTitle() ?? '';
    if (title.toLowerCase().contains('privacy')) {
      return AgreementType.privacy;
    }
    return AgreementType.user;
  }

  Color get _backgroundColor => AppColors.bgPrimary;

  Color get _appBarBackgroundColor => AppColors.bgPrimary;

  Color get _iconColor => AppColors.textPrimary;

  Color get _titleColor => AppColors.textPrimary;

  Color get _loadingColor => AppColors.secondaryMain;

  Color get _loadingTextColor => AppColors.textSecondary;

  Color get _errorIconColor => AppColors.textDisabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _appBarBackgroundColor,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _iconColor),
          onPressed: () => AppRoutes.back(),
        ),
        title: Text(
          _title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _titleColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(_url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
            ),
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
                _error = null;
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false;
              });
            },
            onLoadError: (controller, url, code, message) {
              setState(() {
                _isLoading = false;
                _error = message;
              });
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return NavigationActionPolicy.ALLOW;
            },
          ),
          if (_isLoading)
            Container(
              color: _backgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PulseLoadingIndicator(color: _loadingColor),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 15,
                        color: _loadingTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_error != null)
            Container(
              color: _backgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: _errorIconColor,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Unable to load',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: _loadingTextColor,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PulseLoadingIndicator extends StatefulWidget {
  final Color color;

  const _PulseLoadingIndicator({required this.color});

  @override
  State<_PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<_PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _easeInOut(double t) {
    return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: 2 - _scaleAnimation.value,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(
                      _opacityAnimation.value * 0.3,
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delayedValue = (_controller.value + 0.5) % 1.0;
              final curvedValue = _easeInOut(delayedValue);
              final delayedScale = 1.0 - (curvedValue * 0.5);
              final delayedOpacity = 1.0 - (curvedValue * 0.7);

              return Transform.scale(
                scale: 1.5 - (1.0 - delayedScale) * 0.5,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(
                      delayedOpacity * 0.2,
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
