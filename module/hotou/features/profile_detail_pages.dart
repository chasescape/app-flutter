import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hotou/hotou/env/app_env.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as speech;

import 'coin_wallet.dart';
import 'contact_coins.dart';

class _BugImageAttachment {
  const _BugImageAttachment({
    required this.bytes,
    required this.name,
  });

  final Uint8List bytes;
  final String name;
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  speech.SpeechToText? _speechToText;

  String _voiceBaseText = '';
  final List<_BugImageAttachment> _bugImages = <_BugImageAttachment>[];
  bool _isSpeechReady = false;
  bool _isListening = false;
  bool _isInitializing = false;
  bool _isSubmitting = false;
  bool _isPickingImage = false;

  @override
  void dispose() {
    _speechToText?.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _ensureSpeechReady() async {
    final microphoneStatus = await Permission.microphone.request();
    final speechStatus = await Permission.speech.request();
    if (!microphoneStatus.isGranted || !speechStatus.isGranted) {
      _showMessage('Voice input needs microphone and speech permission.');
      return false;
    }

    if (_isSpeechReady) {
      return true;
    }

    _speechToText ??= speech.SpeechToText();
    final available = await _speechToText!.initialize(
      onError: (error) {
        if (!mounted) {
          return;
        }
        setState(() => _isListening = false);
        _showMessage('Voice input stopped. Please try again.');
      },
      onStatus: (status) {
        if (!mounted) {
          return;
        }
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    if (!available) {
      _showMessage('Speech recognition is not available on this device.');
      return false;
    }

    _isSpeechReady = true;
    return true;
  }

  Future<void> _toggleVoiceInput() async {
    HapticFeedback.selectionClick();
    if (_isListening) {
      await _speechToText?.stop();
      if (mounted) {
        setState(() => _isListening = false);
      }
      return;
    }

    if (_isInitializing) {
      return;
    }

    setState(() => _isInitializing = true);
    try {
      final ready = await _ensureSpeechReady();
      if (!ready) {
        return;
      }

      _voiceBaseText = _controller.text.trim();

      await _speechToText!.listen(
        listenMode: speech.ListenMode.dictation,
        partialResults: true,
        onResult: (result) {
          if (!mounted) {
            return;
          }
          setState(() {
            final spokenText = result.recognizedWords.trim();
            final separator =
                _voiceBaseText.isNotEmpty && spokenText.isNotEmpty ? ' ' : '';
            _controller.text = '$_voiceBaseText$separator$spokenText';
            _controller.selection = TextSelection.collapsed(
              offset: _controller.text.length,
            );
          });
        },
      );
      if (mounted) {
        setState(() => _isListening = true);
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _pickBugImages() async {
    HapticFeedback.selectionClick();
    if (_isPickingImage) {
      return;
    }

    setState(() => _isPickingImage = true);
    try {
      final images = await _imagePicker.pickMultiImage(
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (images.isEmpty) {
        return;
      }

      final pickedImages = <_BugImageAttachment>[];
      for (final image in images) {
        pickedImages.add(
          _BugImageAttachment(
            bytes: await image.readAsBytes(),
            name: image.name,
          ),
        );
      }
      if (!mounted) {
        return;
      }
      setState(() => _bugImages.addAll(pickedImages));
    } catch (_) {
      _showMessage('Unable to attach these images. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _removeBugImage(int index) {
    HapticFeedback.selectionClick();
    if (index < 0 || index >= _bugImages.length) {
      return;
    }
    setState(() => _bugImages.removeAt(index));
  }

  Future<void> _submitFeedback() async {
    HapticFeedback.lightImpact();
    if (_controller.text.trim().isEmpty && _bugImages.isEmpty) {
      _showMessage('Please enter feedback or attach bug screenshots first.');
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    _showMessage('Thanks for your feedback.');
    Navigator.of(context).pop();
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileDetailScaffold(
      title: 'Feedback',
      subtitle: 'Tell us what would make Stack Match better.',
      children: <_DetailFlowItem>[
        _DetailFlowItem.full(
          _DetailCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Your Message',
                  style: _DetailTextStyles.sectionTitle,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  cursorColor: const Color(0xFF355D4B),
                  minLines: 7,
                  maxLines: 9,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Write your feedback here...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF8A9B8F),
                      fontWeight: FontWeight.w700,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.62),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(
                        color: Color(0xFF355D4B),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _BugScreenshotPicker(
                  images: _bugImages,
                  isPickingImage: _isPickingImage,
                  onPickImages: _pickBugImages,
                  onRemoveImage: _removeBugImage,
                ),
                const SizedBox(height: 12),
                _VoiceButton(
                  isInitializing: _isInitializing,
                  isListening: _isListening,
                  onPressed: _toggleVoiceInput,
                ),
              ],
            ),
          ),
        ),
        _DetailFlowItem.full(
          _PrimaryActionButton(
            label: _isSubmitting ? 'Submitting...' : 'Submit Feedback',
            icon: Icons.send_rounded,
            onPressed: _isSubmitting ? null : _submitFeedback,
          ),
        ),
      ],
    );
  }
}

class CoinsPage extends StatefulWidget {
  const CoinsPage({super.key});

  @override
  State<CoinsPage> createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final Set<String> _busyProductIds = <String>{};
  final Set<String> _deliveredPurchaseIds = <String>{};
  final Map<String, ProductDetails> _storeProducts = <String, ProductDetails>{};

  late final StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;
  bool _isStoreAvailable = false;
  bool _isLoadingStore = true;

  @override
  void initState() {
    super.initState();
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error) {
        _setAllProductsIdle();
        _showMessage('Purchase update failed. Please try again.');
      },
    );
    _loadStoreProducts();
  }

  @override
  void dispose() {
    _purchaseSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadStoreProducts() async {
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!mounted) {
      return;
    }
    if (!isAvailable) {
      setState(() {
        _isStoreAvailable = false;
        _isLoadingStore = false;
      });
      _showMessage('In-app purchases are unavailable.');
      return;
    }

    final response = await _inAppPurchase.queryProductDetails(
      Privatised236CoinProductData.productIds,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _isStoreAvailable = true;
      _isLoadingStore = false;
      _storeProducts
        ..clear()
        ..addEntries(
          response.productDetails.map(
            (productDetails) => MapEntry<String, ProductDetails>(
                productDetails.id, productDetails),
          ),
        );
    });

    if (response.error != null) {
      _showMessage(response.error!.message);
    } else if (_storeProducts.isEmpty) {
      _showMessage('No coin products are available yet.');
    }
  }

  Future<void> _buyProduct(Contact575CoinProduct product) async {
    HapticFeedback.selectionClick();
    final storeProduct = _storeProducts[product.code];
    if (!_isStoreAvailable || _isLoadingStore || storeProduct == null) {
      _showMessage('This coin pack is not available yet.');
      return;
    }

    setState(() => _busyProductIds.add(product.code));
    try {
      final purchaseParam = PurchaseParam(productDetails: storeProduct);
      final sent = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
      if (!mounted) {
        return;
      }
      if (!sent) {
        setState(() => _busyProductIds.remove(product.code));
        _showMessage('Unable to start the purchase.');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _busyProductIds.remove(product.code));
      _showMessage('Unable to start the purchase.');
    }
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      final product = _productForId(purchaseDetails.productID);
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          if (product != null && mounted) {
            setState(() => _busyProductIds.add(product.code));
          }
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (product != null && await _verifyPurchase(purchaseDetails)) {
            await _deliverProduct(product, purchaseDetails);
          } else {
            _showMessage('Purchase verification failed.');
          }
          _setProductIdle(purchaseDetails.productID);
          break;
        case PurchaseStatus.error:
          _setProductIdle(purchaseDetails.productID);
          _showMessage(
            purchaseDetails.error?.message ??
                'Purchase failed. Please try again.',
          );
          break;
        case PurchaseStatus.canceled:
          _setProductIdle(purchaseDetails.productID);
          // _showMessage('Purchase canceled.');
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Contact575CoinProduct? _productForId(String productId) {
    for (final product in Privatised236CoinProductData.allProducts) {
      if (product.code == productId) {
        return product;
      }
    }
    return null;
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Replace this with server-side Apple receipt validation before release.
    return _productForId(purchaseDetails.productID) != null;
  }

  Future<void> _deliverProduct(
    Contact575CoinProduct product,
    PurchaseDetails purchaseDetails,
  ) async {
    final deliveryId = purchaseDetails.purchaseID ??
        purchaseDetails.transactionDate ??
        purchaseDetails.verificationData.localVerificationData;
    if (_deliveredPurchaseIds.contains(deliveryId)) {
      return;
    }
    _deliveredPurchaseIds.add(deliveryId);

    if (!mounted) {
      return;
    }
    CoinWallet.add(product.exchangeCoin);
    // _showMessage('${product.exchangeCoin} coins added.');
  }

  void _setProductIdle(String productId) {
    if (!mounted) {
      return;
    }
    setState(() => _busyProductIds.remove(productId));
  }

  void _setAllProductsIdle() {
    if (!mounted) {
      return;
    }
    setState(() => _busyProductIds.clear());
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileDetailScaffold(
      title: 'Coins',
      subtitle: 'Track your current balance and rewards.',
      children: <_DetailFlowItem>[
        _DetailFlowItem.full(
          ValueListenableBuilder<int>(
            valueListenable: CoinWallet.balance,
            builder: (context, currentCoins, child) {
              return _CoinBalanceCard(currentCoins: currentCoins);
            },
          ),
        ),
        for (final product in Privatised236CoinProductData.allProductsGrouped)
          _DetailFlowItem(
            _CoinProductCard(
              product: product,
              storeProduct: _storeProducts[product.code],
              isBuying: _busyProductIds.contains(product.code),
              isStoreLoading: _isLoadingStore,
              onBuy: () => _buyProduct(product),
            ),
          ),
      ],
    );
  }
}

class AgreementPage extends StatefulWidget {
  const AgreementPage({
    super.key,
    required this.type,
  });

  final AgreementType type;

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final String _title;
  late final String _subtitle;
  late final String _url;

  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _title = widget.type.title;
    _subtitle = widget.type.subtitle;
    _url = widget.type.url.trim();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 860),
    )..repeat(reverse: true);

    if (_url.isEmpty) {
      _isLoading = false;
      _error = 'Agreement link is unavailable.';
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    if (!mounted || _isLoading == value) {
      return;
    }
    setState(() => _isLoading = value);
  }

  void _setError(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = false;
      _error = message;
    });
  }

  Future<void> _reload() async {
    if (_url.isEmpty) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _webViewController?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAED7BF),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const Positioned.fill(child: _DetailBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const horizontalPadding = 20.0;
                final maxWidth = math.min(
                  720.0,
                  math.max(0.0, constraints.maxWidth - horizontalPadding * 2),
                );

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    24,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: maxWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _DetailTopBar(title: _title),
                          const SizedBox(height: 16),
                          Text(
                            _subtitle,
                            style: const TextStyle(
                              color: Color(0xFF5F7467),
                              fontSize: 14,
                              height: 1.35,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Expanded(
                            child: _AgreementWebPanel(
                              url: _url,
                              isLoading: _isLoading,
                              error: _error,
                              pulseAnimation: _pulseController,
                              onReload: _reload,
                              onWebViewCreated: (controller) {
                                _webViewController = controller;
                              },
                              onLoadStart: () {
                                if (!mounted) {
                                  return;
                                }
                                setState(() {
                                  _isLoading = true;
                                  _error = null;
                                });
                              },
                              onLoadStop: () => _setLoading(false),
                              onError: _setError,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreementWebPanel extends StatelessWidget {
  const _AgreementWebPanel({
    required this.url,
    required this.isLoading,
    required this.error,
    required this.pulseAnimation,
    required this.onReload,
    required this.onWebViewCreated,
    required this.onLoadStart,
    required this.onLoadStop,
    required this.onError,
  });

  final String url;
  final bool isLoading;
  final String? error;
  final Animation<double> pulseAnimation;
  final VoidCallback onReload;
  final ValueChanged<InAppWebViewController> onWebViewCreated;
  final VoidCallback onLoadStart;
  final VoidCallback onLoadStop;
  final ValueChanged<String> onError;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8).withOpacity(0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.7)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF526840).withOpacity(0.14),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: ColoredBox(
          color: const Color(0xFFFFFDF2),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (url.isNotEmpty)
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(url)),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    useShouldOverrideUrlLoading: false,
                    supportZoom: false,
                    transparentBackground: true,
                    disableHorizontalScroll: true,
                    allowsBackForwardNavigationGestures: true,
                  ),
                  onWebViewCreated: onWebViewCreated,
                  onLoadStart: (controller, url) => onLoadStart(),
                  onLoadStop: (controller, url) => onLoadStop(),
                  onProgressChanged: (controller, progress) {
                    if (progress >= 100) {
                      onLoadStop();
                    }
                  },
                  onReceivedError: (controller, request, webResourceError) {
                    if (request.isForMainFrame == false) {
                      return;
                    }
                    final description = webResourceError.description.trim();
                    onError(
                      description.isEmpty
                          ? 'Unable to load this agreement.'
                          : description,
                    );
                  },
                ),
              if (isLoading)
                _AgreementLoadingOverlay(animation: pulseAnimation),
              if (error != null)
                _AgreementErrorOverlay(
                  message: error!,
                  onReload: onReload,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgreementLoadingOverlay extends StatelessWidget {
  const _AgreementLoadingOverlay({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFFF8E8).withOpacity(0.92),
      child: Center(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final scale = 0.88 + animation.value * 0.18;
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: const _AgreementLoadingMark(),
        ),
      ),
    );
  }
}

class _AgreementLoadingMark extends StatelessWidget {
  const _AgreementLoadingMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF355D4B).withOpacity(0.2),
                width: 2,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFDDEBB6),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.72),
                width: 2,
              ),
            ),
          ),
          const SizedBox(
            width: 11,
            height: 11,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF355D4B),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreementErrorOverlay extends StatelessWidget {
  const _AgreementErrorOverlay({
    required this.message,
    required this.onReload,
  });

  final String message;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFFF8E8).withOpacity(0.96),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF3D8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: Color(0xFF355D4B),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF24382F),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: _DetailTextStyles.body,
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 46,
                child: FilledButton.icon(
                  onPressed: onReload,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF263D32),
                    foregroundColor: const Color(0xFFFFF7DF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
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

enum AgreementType { userAgreement, privacyPolicy }

extension _AgreementTypeView on AgreementType {
  String get title {
    switch (this) {
      case AgreementType.userAgreement:
        return 'User Agreement';
      case AgreementType.privacyPolicy:
        return 'Privacy Policy';
    }
  }

  String get subtitle {
    switch (this) {
      case AgreementType.userAgreement:
        return 'The basic terms for using Stack Match.';
      case AgreementType.privacyPolicy:
        return 'How this local game experience handles information.';
    }
  }

  String get url {
    final appEnv = AppEnv();
    switch (this) {
      case AgreementType.userAgreement:
        return appEnv.h5User;
      case AgreementType.privacyPolicy:
        return appEnv.h5Privacy;
    }
  }
}

class _DetailFlowItem {
  const _DetailFlowItem(this.child) : fullWidth = false;

  const _DetailFlowItem.full(this.child) : fullWidth = true;

  final Widget child;
  final bool fullWidth;
}

class _DetailFlow extends StatelessWidget {
  const _DetailFlow({
    required this.children,
    required this.maxWidth,
  });

  final List<_DetailFlowItem> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final itemWidth = maxWidth >= 620 ? (maxWidth - 12) / 2 : maxWidth;
    return Wrap(
      spacing: 12,
      runSpacing: 16,
      children: <Widget>[
        for (final item in children)
          SizedBox(
            width: item.fullWidth ? maxWidth : itemWidth,
            child: item.child,
          ),
      ],
    );
  }
}

class _ProfileDetailScaffold extends StatelessWidget {
  const _ProfileDetailScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<_DetailFlowItem> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAED7BF),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const Positioned.fill(child: _DetailBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const horizontalPadding = 20.0;
                const topPadding = 18.0;
                const bottomPadding = 24.0;
                final contentWidth = math.max(
                  0.0,
                  constraints.maxWidth - horizontalPadding * 2,
                );
                final minHeight = math.max(
                  0.0,
                  constraints.maxHeight - topPadding - bottomPadding,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    horizontalPadding,
                    topPadding,
                    horizontalPadding,
                    bottomPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _DetailTopBar(title: title),
                        const SizedBox(height: 16),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF5F7467),
                            fontSize: 14,
                            height: 1.35,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _DetailFlow(
                          maxWidth: contentWidth,
                          children: children,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTopBar extends StatelessWidget {
  const _DetailTopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _CircleButton(
          icon: Icons.arrow_back_rounded,
          label: 'Back',
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF22382E),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _BugScreenshotPicker extends StatelessWidget {
  const _BugScreenshotPicker({
    required this.images,
    required this.isPickingImage,
    required this.onPickImages,
    required this.onRemoveImage,
  });

  final List<_BugImageAttachment> images;
  final bool isPickingImage;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final hasImages = images.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Bug Screenshots',
                style: _DetailTextStyles.sectionTitle,
              ),
            ),
            if (hasImages)
              Text(
                '${images.length} attached',
                style: const TextStyle(
                  color: Color(0xFF66796D),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (hasImages)
          _BugScreenshotGrid(
            images: images,
            isPickingImage: isPickingImage,
            onPickImages: onPickImages,
            onRemoveImage: onRemoveImage,
          )
        else
          _BugScreenshotEmptyState(
            isPickingImage: isPickingImage,
            onPickImages: onPickImages,
          ),
      ],
    );
  }
}

class _BugScreenshotEmptyState extends StatelessWidget {
  const _BugScreenshotEmptyState({
    required this.isPickingImage,
    required this.onPickImages,
  });

  final bool isPickingImage;
  final VoidCallback onPickImages;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEAF3D8).withOpacity(0.72),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: isPickingImage ? null : onPickImages,
        child: Container(
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF355D4B).withOpacity(0.3),
              width: 1.4,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8E8),
                  shape: BoxShape.circle,
                ),
                child: isPickingImage
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF355D4B),
                        ),
                      )
                    : const Icon(
                        Icons.add_photo_alternate_rounded,
                        color: Color(0xFF355D4B),
                        size: 23,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPickingImage ? 'Opening photos...' : 'Upload bug images',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF355D4B),
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF7B8E80),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BugScreenshotGrid extends StatelessWidget {
  const _BugScreenshotGrid({
    required this.images,
    required this.isPickingImage,
    required this.onPickImages,
    required this.onRemoveImage,
  });

  final List<_BugImageAttachment> images;
  final bool isPickingImage;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.62),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF355D4B).withOpacity(0.24),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              for (var index = 0; index < images.length; index++)
                _BugScreenshotThumb(
                  image: images[index],
                  onRemove: () => onRemoveImage(index),
                ),
              _AddMoreImagesTile(
                isPickingImage: isPickingImage,
                onPickImages: onPickImages,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BugScreenshotThumb extends StatelessWidget {
  const _BugScreenshotThumb({
    required this.image,
    required this.onRemove,
  });

  final _BugImageAttachment image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 82,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              image.bytes,
              width: 82,
              height: 82,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: -7,
            right: -7,
            child: Material(
              color: const Color(0xFF263D32),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const SizedBox(
                  width: 26,
                  height: 26,
                  child: Icon(
                    Icons.close_rounded,
                    color: Color(0xFFFFF7DF),
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMoreImagesTile extends StatelessWidget {
  const _AddMoreImagesTile({
    required this.isPickingImage,
    required this.onPickImages,
  });

  final bool isPickingImage;
  final VoidCallback onPickImages;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEAF3D8).withOpacity(0.78),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isPickingImage ? null : onPickImages,
        child: SizedBox(
          width: 82,
          height: 82,
          child: Center(
            child: isPickingImage
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF355D4B),
                    ),
                  )
                : const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.add_photo_alternate_rounded,
                        color: Color(0xFF355D4B),
                        size: 24,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Add More',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF355D4B),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _VoiceButton extends StatelessWidget {
  const _VoiceButton({
    required this.isInitializing,
    required this.isListening,
    required this.onPressed,
  });

  final bool isInitializing;
  final bool isListening;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = isListening
        ? 'Stop Voice Input'
        : isInitializing
            ? 'Preparing Voice Input'
            : 'Voice Input';
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(isListening ? Icons.stop_rounded : Icons.mic_rounded),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF355D4B),
          side: BorderSide(
            color: const Color(0xFF355D4B).withOpacity(0.28),
            width: 1.5,
          ),
          backgroundColor: const Color(0xFFEAF3D8).withOpacity(0.72),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF263D32),
          foregroundColor: const Color(0xFFFFF7DF),
          disabledBackgroundColor: const Color(0xFF9EB1A2),
          disabledForegroundColor: const Color(0xFFE8EFE6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CoinBalanceCard extends StatelessWidget {
  const _CoinBalanceCard({required this.currentCoins});

  final int currentCoins;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Row(
        children: <Widget>[
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD170),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.paid_rounded,
              color: Color(0xFF704B1A),
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$currentCoins',
                  style: _DetailTextStyles.heroNumber,
                ),
                const SizedBox(height: 3),
                const Text(
                  'Available Coins',
                  style: _DetailTextStyles.bodyStrong,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your wallet is ready for rewards.',
                  style: _DetailTextStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinProductCard extends StatelessWidget {
  const _CoinProductCard({
    required this.product,
    required this.storeProduct,
    required this.isBuying,
    required this.isStoreLoading,
    required this.onBuy,
  });

  final Contact575CoinProduct product;
  final ProductDetails? storeProduct;
  final bool isBuying;
  final bool isStoreLoading;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final displayPrice = product.formattedOriginalPrice;
    final canBuy = storeProduct != null && !isBuying && !isStoreLoading;
    final buttonLabel = isBuying
        ? 'Buying'
        : isStoreLoading
            ? 'Loading'
            : 'Buy';
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: product.isPromotion
                      ? const Color(0xFFFFE1A6)
                      : const Color(0xFFEAF3D8),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  product.isPromotion
                      ? Icons.local_offer_rounded
                      : Icons.paid_rounded,
                  color: product.isPromotion
                      ? const Color(0xFF8A5520)
                      : const Color(0xFF355D4B),
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _DetailTextStyles.sectionTitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 8,
                  runSpacing: 3,
                  children: <Widget>[
                    Text(
                      displayPrice,
                      style: const TextStyle(
                        color: Color(0xFF24382F),
                        fontSize: 24,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 42,
                child: FilledButton.icon(
                  onPressed: canBuy ? onBuy : null,
                  icon: isBuying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFFF7DF),
                          ),
                        )
                      : const Icon(Icons.shopping_bag_rounded, size: 18),
                  label: Text(buttonLabel),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF263D32),
                    foregroundColor: const Color(0xFFFFF7DF),
                    disabledBackgroundColor: const Color(0xFF8EA092),
                    disabledForegroundColor: const Color(0xFFE8EFE6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8).withOpacity(0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.7)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF526840).withOpacity(0.14),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.white.withOpacity(0.62),
        clipBehavior: Clip.antiAlias,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: const Color(0xFF355D4B), size: 21),
          ),
        ),
      ),
    );
  }
}

class _DetailTextStyles {
  const _DetailTextStyles._();

  static const TextStyle sectionTitle = TextStyle(
    color: Color(0xFF24382F),
    fontSize: 17,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle bodyStrong = TextStyle(
    color: Color(0xFF24382F),
    fontSize: 14,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle body = TextStyle(
    color: Color(0xFF66796D),
    fontSize: 13,
    height: 1.42,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle heroNumber = TextStyle(
    color: Color(0xFF24382F),
    fontSize: 34,
    height: 1,
    fontWeight: FontWeight.w900,
  );
}

class _DetailBackground extends StatelessWidget {
  const _DetailBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFFFF2C2),
            Color(0xFFDDEBB6),
            Color(0xFFAED7BF),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _DetailPatternPainter(),
      ),
    );
  }
}

class _DetailPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stripePaint = Paint()
      ..color = const Color(0xFF8FB47D).withOpacity(0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    for (double x = -size.height; x < size.width; x += 36) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        stripePaint,
      );
    }

    final glowPaint = Paint()
      ..color = const Color(0xFFFFD170).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width - 24, 92), 108, glowPaint);
    canvas.drawCircle(Offset(0, size.height - 120), 130, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
