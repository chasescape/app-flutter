import 'dart:async';

import 'package:flutter/material.dart';

import 'coin_iap_service.dart';
import 'favio_palette.dart';
import 'game_progress_store.dart';

Future<int?> openDodgeBlocksCoinPage(
  BuildContext context, {
  required int currentCoins,
  required int bestScore,
  int reviveCost = 80,
}) {
  return Navigator.of(context).push<int>(
    MaterialPageRoute<int>(
      builder: (_) => DodgeBlocksCoinPage(
        currentCoins: currentCoins,
        reviveCost: reviveCost,
        bestScore: bestScore,
      ),
    ),
  );
}

class DodgeBlocksCoinPage extends StatefulWidget {
  const DodgeBlocksCoinPage({
    super.key,
    required this.currentCoins,
    required this.reviveCost,
    required this.bestScore,
  });

  final int currentCoins;
  final int reviveCost;
  final int bestScore;

  @override
  State<DodgeBlocksCoinPage> createState() => _DodgeBlocksCoinPageState();
}

class _DodgeBlocksCoinPageState extends State<DodgeBlocksCoinPage> {
  final CoinIapService _iapService = CoinIapService.instance;

  late int _coins = widget.currentCoins;
  int _lastNoticeId = 0;
  late final VoidCallback _iapListener = _handleIapChanged;

  List<List<CoinPackOffer>> get _packColumns {
    const int itemsPerColumn = 2;
    final List<List<CoinPackOffer>> pages = <List<CoinPackOffer>>[];
    final List<CoinPackOffer> packs = CoinIapService.catalog;

    for (int i = 0; i < packs.length; i += itemsPerColumn) {
      final int end = (i + itemsPerColumn).clamp(0, packs.length);
      pages.add(packs.sublist(i, end));
    }

    return pages;
  }

  @override
  void initState() {
    super.initState();
    _iapService.addListener(_iapListener);
    unawaited(_iapService.initialize());
  }

  @override
  void dispose() {
    _iapService.removeListener(_iapListener);
    super.dispose();
  }

  void _handleIapChanged() {
    final CoinPurchaseNotice? notice = _iapService.latestNotice;
    if (notice != null && notice.id != _lastNoticeId && mounted) {
      _lastNoticeId = notice.id;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     backgroundColor: notice.isError
      //         ? const Color(0xFF7A1D2C)
      //         : FavioPalette.brandShadow,
      //     content: Text(notice.message),
      //   ),
      // );
    }

    final int latestCoins = GameProgressStore.instance.coins;
    if (_coins != latestCoins && mounted) {
      setState(() {
        _coins = latestCoins;
      });
      return;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _buyPack(CoinPackOffer pack) async {
    await _iapService.purchasePack(pack);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(_coins);
      },
      child: Scaffold(
        backgroundColor: FavioPalette.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 12,
          title: const Text(
            'RECHARGE',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(_coins),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                FavioPalette.backgroundTop,
                FavioPalette.backgroundMid,
                FavioPalette.backgroundBottom,
              ],
            ),
          ),
          child: Stack(
            children: <Widget>[
              const Positioned.fill(
                child: _CoinStoreBackdrop(),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _StoreSummary(
                        coins: _coins,
                        reviveCost: widget.reviveCost,
                        bestScore: widget.bestScore,
                        iapService: _iapService,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            final List<List<CoinPackOffer>> columns =
                                _packColumns;
                            final double columnWidth =
                                ((constraints.maxWidth - 12) / 2)
                                    .clamp(150.0, 176.0);

                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemBuilder: (BuildContext context, int index) {
                                final List<CoinPackOffer> column =
                                    columns[index];

                                return SizedBox(
                                  width: columnWidth,
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: _CoinPackCard(
                                          pack: column[0],
                                          priceLabel:
                                              column[0].fallbackPriceLabel,
                                          isBusy:
                                              _iapService.isPackBusy(column[0]),
                                          isAvailable: _iapService
                                              .isPackAvailable(column[0]),
                                          onTap: () => _buyPack(column[0]),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Expanded(
                                        child: column.length > 1
                                            ? _CoinPackCard(
                                                pack: column[1],
                                                priceLabel: column[1]
                                                    .fallbackPriceLabel,
                                                isBusy: _iapService
                                                    .isPackBusy(column[1]),
                                                isAvailable: _iapService
                                                    .isPackAvailable(column[1]),
                                                onTap: () =>
                                                    _buyPack(column[1]),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 16),
                              itemCount: columns.length,
                            );
                          },
                        ),
                      ),
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
}

class _CoinStoreBackdrop extends StatelessWidget {
  const _CoinStoreBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CoinStoreBackdropPainter(),
    );
  }
}

class _CoinStoreBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint redShape = Paint()..color = FavioPalette.brandShadow;
    final Paint darkShape = Paint()..color = const Color(0xFF101319);
    final Paint whiteLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.2;

    final Path leftSlash = Path()
      ..moveTo(0, size.height * 0.12)
      ..lineTo(size.width * 0.27, 0)
      ..lineTo(size.width * 0.14, size.height * 0.42)
      ..lineTo(0, size.height * 0.36)
      ..close();
    canvas.drawPath(leftSlash, redShape);

    final Path rightPanel = Path()
      ..moveTo(size.width * 0.72, size.height * 0.06)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.26)
      ..lineTo(size.width * 0.80, size.height * 0.32)
      ..close();
    canvas.drawPath(rightPanel, darkShape);

    for (double i = -size.height; i < size.width; i += 26) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        whiteLine,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StoreSummary extends StatelessWidget {
  const _StoreSummary({
    required this.coins,
    required this.reviveCost,
    required this.bestScore,
    required this.iapService,
  });

  final int coins;
  final int reviveCost;
  final int bestScore;
  final CoinIapService iapService;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            FavioPalette.brandBright,
            FavioPalette.brand,
            FavioPalette.brandDark,
          ],
        ),
        border: Border.all(
          color: FavioPalette.brandGlow.withValues(alpha: 0.20),
        ),
        boxShadow: <BoxShadow>[
          const BoxShadow(
            color: Color(0x66000000),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
          BoxShadow(
            color: FavioPalette.brandGlow.withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFFFFD166),
                      Color(0xFFFF8C42),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.currency_bitcoin_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'BALANCE',
                      style: TextStyle(
                        color: FavioPalette.brandSoftText,
                        fontSize: 11,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$coins C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (iapService.queryError != null) ...<Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              child: Text(
                iapService.queryError!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Divider(
            color: Colors.white.withValues(alpha: 0.14),
            height: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _StoreMetric(
                  label: 'REVIVE',
                  value: '$reviveCost',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StoreMetric(
                  label: 'BEST',
                  value: '$bestScore',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoreMetric extends StatelessWidget {
  const _StoreMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: FavioPalette.brandSoftText,
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinPackCard extends StatelessWidget {
  const _CoinPackCard({
    required this.pack,
    required this.priceLabel,
    required this.isBusy,
    required this.isAvailable,
    required this.onTap,
  });

  final CoinPackOffer pack;
  final String priceLabel;
  final bool isBusy;
  final bool isAvailable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _StoreSlashClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color.lerp(FavioPalette.brandBright, pack.accentColor, 0.22) ??
                  FavioPalette.brandBright,
              Color.lerp(FavioPalette.brand, pack.accentColor, 0.14) ??
                  FavioPalette.brand,
              FavioPalette.brandDark,
            ],
          ),
          border: Border.all(
            color: pack.accentColor.withValues(alpha: 0.34),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: pack.accentColor.withValues(alpha: 0.14),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: '${pack.coins}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 0.92,
                        letterSpacing: -1.1,
                      ),
                    ),
                    TextSpan(
                      text: ' coins',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              pack.packLabel,
              style: TextStyle(
                color: pack.isPromotion
                    ? Colors.white
                    : FavioPalette.brandSoftText,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            if (pack.originalPriceLabel != null) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                pack.originalPriceLabel!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.white.withValues(alpha: 0.72),
                ),
              ),
            ],
            if (pack.badge != null) ...<Widget>[
              const SizedBox(height: 6),
              _PackBadge(label: pack.badge!),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
                child: FilledButton(
                onPressed: isBusy ? null : onTap,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF111111),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF111111),
                          ),
                        ),
                      )
                    : Text(
                        priceLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackBadge extends StatelessWidget {
  const _PackBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _StoreSlashClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * 0.08, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.93, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
