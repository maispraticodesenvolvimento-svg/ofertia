import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/models/product.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_image.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  late Future<_HomeData> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<_HomeData> _load() async {
    final api = ApiClient();
    final results = await Future.wait([
      api.getProducts(),
      api.getBanners(),
      api.getBanners(mobile: true),
    ]);
    return _HomeData(
      results[0] as List<Product>,
      results[1] as List<Map<String, dynamic>>,
      results[2] as List<Map<String, dynamic>>,
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_HomeData>(
    future: _data,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return _empty(snapshot.error.toString(), Icons.cloud_off_outlined);
      }

      final data = snapshot.data!;
      final products = data.products;
      final width = MediaQuery.sizeOf(context).width;
      final wide = width > 960;
      final compact = width <= 600;
      final banners = compact && data.mobileBanners.isNotEmpty
          ? data.mobileBanners
          : data.banners;
      final firstProducts = products.take(6).toList();
      final remainingProducts = products.skip(6).toList();
      final horizontalPadding = wide ? 24.0 : 16.0;

      return Container(
        color: AppColors.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            if (banners.isNotEmpty)
              compact
                  ? _MobileBannerArea(
                      child: _BannerSlider(
                        banners: banners,
                        wide: wide,
                        compact: true,
                      ),
                    )
                  : _BannerSlider(
                      banners: banners,
                      wide: wide,
                      compact: false,
                    ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                0,
              ),
              child: _buildTrustSection(wide),
            ),
            if (compact) ...[
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: products.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _empty(
                          'Ainda não há produtos em destaque.',
                          Icons.inventory_2_outlined,
                        ),
                      )
                    : _buildFeaturedProducts(
                        firstProducts,
                        width - horizontalPadding * 2,
                        compact: true,
                      ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  remainingProducts.isNotEmpty ? 24 : 20,
                  horizontalPadding,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (remainingProducts.isNotEmpty)
                      _buildMoreProducts(remainingProducts),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () => context.go('/buyer/products'),
                        child: const Text('Ver todos os produtos'),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (products.isEmpty)
                      _empty(
                        'Ainda não há produtos em destaque.',
                        Icons.inventory_2_outlined,
                      )
                    else
                      _buildFeaturedProducts(
                        firstProducts,
                        width - horizontalPadding * 2,
                        compact: false,
                      ),
                    if (remainingProducts.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildMoreProducts(remainingProducts),
                    ],
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () => context.go('/buyer/products'),
                        child: const Text('Ver todos os produtos'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    },
  );

  Widget _buildFeaturedProducts(
    List<Product> products,
    double availableWidth, {
    required bool compact,
  }) {
    if (compact) {
      const spacing = 12.0;
      const cardHeight = 280.0;
      final cardWidth = (availableWidth - spacing) / 2;
      return SizedBox(
        height: cardHeight,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(width: spacing),
          itemBuilder: (context, index) => _FeaturedProductCard(
            product: products[index],
            width: cardWidth,
          ),
        ),
      );
    }

    const spacing = 12.0;
    final cardWidth = ((availableWidth - spacing * 5) / 6)
        .clamp(174.0, 220.0)
        .toDouble();

    return SizedBox(
      height: 322,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < products.length; index++) ...[
              if (index > 0) const SizedBox(width: spacing),
              _FeaturedProductCard(product: products[index], width: cardWidth),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoreProducts(List<Product> products) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mais produtos para você',
            style: GoogleFonts.inter(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 292,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < products.length; index++) ...[
                    if (index > 0) const SizedBox(width: 20),
                    _InlineProductTile(product: products[index]),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Seção de Segurança e Garantia estilo Mercado Livre ──────────────────
  Widget _buildTrustSection(bool wide) {
    final cards = [
      _TrustCardData(
        icon: Icons.local_shipping_rounded,
        title: 'Envio Garantido',
        subtitle: 'chegamos sempre',
      ),
      _TrustCardData(
        icon: Icons.attach_money_rounded,
        title: 'Pagamento Seguro',
        subtitle: 'protegemos seu dinheiro',
      ),
      _TrustCardData(
        icon: Icons.replay_rounded,
        title: 'Devolução Grátis',
        subtitle: 'até 30 dias',
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: wide ? 760 : 260),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 16 : 12,
            vertical: wide ? 12 : 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: wide
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Cuidamos de cada compra',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: cards
                          .map(
                            (card) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: _buildTrustCard(card),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: cards
                      .map((card) => _buildTrustIcon(card, showLabel: true))
                      .toList(),
                ),
        ),
      ),
    );
  }

  Widget _buildTrustCard(_TrustCardData data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTrustIcon(data),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                ),
              ),
              Text(
                data.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrustIcon(_TrustCardData data, {bool showLabel = false}) {
    return Tooltip(
      message: data.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE600),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: Colors.black87, size: 20),
          ),
          if (showLabel) ...[
            const SizedBox(height: 2),
            Text(
              data.title,
              maxLines: 1,
              softWrap: false,
              style: GoogleFonts.inter(
                fontSize: 7,
                fontWeight: FontWeight.w500,
                color: AppColors.grey900,
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _empty(String message, IconData icon) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Icon(icon, color: AppColors.grey400, size: 36),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.grey600)),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------
// Carrossel infinito de banners:
// - No mobile, centraliza o slide ativo e mostra parte dos vizinhos.
// - Transição automática com timer (autoplay).
// - Sem piscadas (gapless playback e renderização direta).
// ---------------------------------------------------------------------------
class _MobileBannerArea extends StatelessWidget {
  const _MobileBannerArea({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const topGap = 5.0;
        final bannerHeight = constraints.maxWidth / 2.15;

        return SizedBox(
          height: bannerHeight + topGap,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: bannerHeight / 2 + topGap,
                child: const ColoredBox(color: AppColors.primary),
              ),
              Positioned(
                top: topGap,
                left: 0,
                right: 0,
                height: bannerHeight,
                child: child,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BannerSlider extends StatefulWidget {
  const _BannerSlider({
    required this.banners,
    required this.wide,
    required this.compact,
  });

  final List<Map<String, dynamic>> banners;
  final bool wide;
  final bool compact;

  @override
  State<_BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<_BannerSlider> {
  late PageController _controller;
  Timer? _timer;

  // Para slide infinito usamos um multiplicador virtual
  static const int _virtualMultiplier = 1000;

  int get _realCount => widget.banners.length;
  int get _initialPage => _realCount * (_virtualMultiplier ~/ 2);
  int _currentReal = 0;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
    _currentReal = 0;
    _startTimer();
  }

  PageController _createController({int? initialPage}) => PageController(
        initialPage: initialPage ?? (_realCount > 0 ? _initialPage : 0),
        viewportFraction: widget.compact ? 0.88 : 1.0,
      );

  void _resetController() {
    final currentPage = _controller.hasClients
        ? (_controller.page?.round() ?? _currentReal)
        : _currentReal;
    final currentReal = _realCount == 0 ? 0 : currentPage % _realCount;
    _controller.dispose();
    _controller = _createController(
      initialPage: _realCount == 0 ? 0 : _initialPage + currentReal,
    );
    _currentReal = currentReal;
  }

  @override
  void didUpdateWidget(covariant _BannerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.compact != widget.compact ||
        oldWidget.banners.length != widget.banners.length) {
      _resetController();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    _resetController();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_realCount <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      _animateTo(1);
    });
  }

  void _resetTimer() {
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(int delta) {
    if (!_controller.hasClients) return;
    final current = (_controller.page ?? _initialPage.toDouble()).round();
    _controller.animateToPage(
      current + delta,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int virtualIndex) {
    if (_realCount == 0) return;
    setState(() => _currentReal = virtualIndex % _realCount);
  }

  @override
  Widget build(BuildContext context) {
    if (_realCount == 0) return const SizedBox.shrink();

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _timer?.cancel();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _resetTimer();
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // ── PageView Full-width sem margens ou bordas ──
          AspectRatio(
            aspectRatio: widget.compact ? 2.15 : 10 / 3,
            child: PageView.builder(
              controller: _controller,
              itemCount: _realCount * _virtualMultiplier,
              onPageChanged: _onPageChanged,
              physics: const ClampingScrollPhysics(),
              padEnds: true,
              itemBuilder: (context, virtualIndex) {
                if (_realCount == 0) return const SizedBox.shrink();
                final realIndex = virtualIndex % _realCount;
                return _BannerItem(
                  banner: widget.banners[realIndex],
                  compact: widget.compact,
                );
              },
            ),
          ),

          // ── Botão Anterior (aparece APENAS quando o mouse estiver em cima do banner) ──
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            left: _isHovered ? 16 : -60,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _isHovered ? 1.0 : 0.0,
                child: _NavButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () {
                    _resetTimer();
                    _animateTo(-1);
                  },
                ),
              ),
            ),
          ),

          // ── Botão Próximo (aparece APENAS quando o mouse estiver em cima do banner) ──
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            right: _isHovered ? 16 : -60,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _isHovered ? 1.0 : 0.0,
                child: _NavButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () {
                    _resetTimer();
                    _animateTo(1);
                  },
                ),
              ),
            ),
          ),

          // ── Indicadores de página discretos na parte inferior ──
          Positioned(
            bottom: 12,
            child: AnimatedSmoothIndicator(
              activeIndex: _currentReal,
              count: _realCount,
              effect: const ExpandingDotsEffect(
                dotHeight: 6,
                dotWidth: 6,
                activeDotColor: Colors.white,
                dotColor: Colors.white54,
                expansionFactor: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Item individual do banner
// ---------------------------------------------------------------------------
class _BannerItem extends StatelessWidget {
  const _BannerItem({required this.banner, required this.compact});

  final Map<String, dynamic> banner;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final category = banner['category']?.toString();
    final hasCategory = category != null && category.trim().isNotEmpty;
    final image = ProductImage(
      dataUrl: banner['dataUrl']?.toString(),
      icon: Icons.campaign_outlined,
      fit: BoxFit.cover,
    );

    void openBanner() {
      if (hasCategory) {
        context.go('/buyer/products?category=${Uri.encodeComponent(category.trim())}');
      } else {
        context.go('/buyer/products');
      }
    }

    return SizedBox.expand(
      child: compact
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: Material(
                color: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: openBanner,
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: image,
                  ),
                ),
              ),
            )
          : InkWell(onTap: openBanner, child: image),
    );
  }
}

// ---------------------------------------------------------------------------
// Botão de navegação lateral com fundo translúcido circular
// ---------------------------------------------------------------------------
class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
// Modelo de dados da tela inicial
// ---------------------------------------------------------------------------
class _HomeData {
  const _HomeData(this.products, this.banners, this.mobileBanners);
  final List<Product> products;
  final List<Map<String, dynamic>> banners;
  final List<Map<String, dynamic>> mobileBanners;
}

class _TrustCardData {
  const _TrustCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class _FeaturedProductCard extends StatefulWidget {
  const _FeaturedProductCard({required this.product, required this.width});

  final Product product;
  final double width;

  @override
  State<_FeaturedProductCard> createState() => _FeaturedProductCardState();
}

class _FeaturedProductCardState extends State<_FeaturedProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final width = widget.width;
    final price = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(product.price);
    final oldPrice = product.oldPrice;
    final hasDiscount = oldPrice != null && oldPrice > product.price;

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.grey200),
        ),
        child: InkWell(
          onHover: (hovering) {
            if (_isHovered != hovering) {
              setState(() => _isHovered = hovering);
            }
          },
          hoverColor: Colors.transparent,
          onTap: () => context.go('/buyer/product/${product.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 144,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                  child: ProductImage(
                    dataUrl: product.imageDataUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _isHovered ? AppColors.primary : AppColors.grey800,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (hasDiscount)
                        Text(
                          NumberFormat.currency(
                            locale: 'pt_BR',
                            symbol: 'R\$',
                          ).format(oldPrice),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.grey500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${(((oldPrice - product.price) / oldPrice) * 100).round()}% OFF',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.grey500,
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

class _InlineProductTile extends StatefulWidget {
  const _InlineProductTile({required this.product});

  final Product product;

  @override
  State<_InlineProductTile> createState() => _InlineProductTileState();
}

class _InlineProductTileState extends State<_InlineProductTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final price = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(product.price);
    final oldPrice = product.oldPrice;
    final hasDiscount = oldPrice != null && oldPrice > product.price;

    return SizedBox(
      width: 176,
      child: InkWell(
        onHover: (hovering) {
          if (_isHovered != hovering) {
            setState(() => _isHovered = hovering);
          }
        },
        hoverColor: Colors.transparent,
        onTap: () => context.go('/buyer/product/${product.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: 164,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                child: ProductImage(
                  dataUrl: product.imageDataUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _isHovered ? AppColors.primary : AppColors.grey800,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 6),
            if (hasDiscount)
              Text(
                '${(((oldPrice - product.price) / oldPrice) * 100).round()}% OFF',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            Text(
              price,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.grey900,
              ),
            ),
            Text(
              product.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
