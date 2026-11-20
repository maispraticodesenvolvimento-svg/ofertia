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
    final results = await Future.wait([api.getProducts(), api.getBanners()]);
    return _HomeData(results[0] as List<Product>, results[1] as List<Map<String, dynamic>>);
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
      final firstProducts = products.take(6).toList();
      final remainingProducts = products.skip(6).toList();
      final width = MediaQuery.sizeOf(context).width;
      final wide = width > 960;
      final horizontalPadding = wide ? 24.0 : 16.0;

      return Container(
        color: AppColors.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            if (data.banners.isNotEmpty)
              _BannerSlider(banners: data.banners, wide: wide),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                0,
              ),
              child: _buildTrustSection(wide),
            ),
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

  Widget _buildFeaturedProducts(List<Product> products, double availableWidth) {
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
        title: 'Envio garantido',
        subtitle: 'chegamos sempre',
      ),
      _TrustCardData(
        icon: Icons.attach_money_rounded,
        title: 'Pagamento seguro',
        subtitle: 'protegemos seu dinheiro',
      ),
      _TrustCardData(
        icon: Icons.replay_rounded,
        title: 'Devolução grátis',
        subtitle: 'até 30 dias',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Cuidamos de cada compra',
            style: GoogleFonts.inter(
              fontSize: wide ? 22 : 18,
              fontWeight: FontWeight.w800,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: 20),
          if (wide)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: cards.map((c) => Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _buildTrustCard(c),
              ))).toList(),
            )
          else
            Column(
              children: cards.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTrustCard(c),
              )).toList(),
            ),
          const SizedBox(height: 16),
          Text(
            'Diante de qualquer eventualidade e a qualquer momento, sua compra está garantida.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustCard(_TrustCardData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF4D9), // Amarelo suave idêntico ao Mercado Livre
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE600),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: Colors.black87, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            data.title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.grey700,
            ),
          ),
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
// Slide infinito estilo Mercado Livre:
// - Largura total (edge-to-edge), sem margem, sem bordas arredondadas.
// - Transição automática com timer (autoplay).
// - Sem piscadas (gapless playback e renderização direta).
// ---------------------------------------------------------------------------
class _BannerSlider extends StatefulWidget {
  const _BannerSlider({required this.banners, required this.wide});

  final List<Map<String, dynamic>> banners;
  final bool wide;

  @override
  State<_BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<_BannerSlider> {
  late final PageController _controller;
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
    _controller = PageController(
      initialPage: _realCount > 0 ? _initialPage : 0,
      viewportFraction: 1.0,
    );
    _currentReal = 0;
    _startTimer();
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
            aspectRatio: 10 / 3,
            child: PageView.builder(
              controller: _controller,
              itemCount: _realCount * _virtualMultiplier,
              onPageChanged: _onPageChanged,
              physics: const ClampingScrollPhysics(),
              padEnds: false, // Garante que a página atual ocupe de ponta a ponta sem cortes
              itemBuilder: (context, virtualIndex) {
                if (_realCount == 0) return const SizedBox.shrink();
                final realIndex = virtualIndex % _realCount;
                return _BannerItem(banner: widget.banners[realIndex]);
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
// Item individual do banner (100% de largura, sem margem, sem raio de borda)
// ---------------------------------------------------------------------------
class _BannerItem extends StatelessWidget {
  const _BannerItem({required this.banner});

  final Map<String, dynamic> banner;

  @override
  Widget build(BuildContext context) {
    final category = banner['category']?.toString();
    final hasCategory = category != null && category.trim().isNotEmpty;

    return SizedBox.expand(
      child: InkWell(
        onTap: () {
          if (hasCategory) {
            context.go('/buyer/products?category=${Uri.encodeComponent(category.trim())}');
          } else {
            context.go('/buyer/products');
          }
        },
        child: ProductImage(
          dataUrl: banner['dataUrl']?.toString(),
          icon: Icons.campaign_outlined,
          fit: BoxFit.cover,
        ),
      ),
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
  const _HomeData(this.products, this.banners);
  final List<Product> products;
  final List<Map<String, dynamic>> banners;
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
                child: ProductImage(
                  dataUrl: product.imageDataUrl,
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
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
                      const Spacer(),
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
            SizedBox(
              height: 164,
              width: double.infinity,
              child: ProductImage(
                dataUrl: product.imageDataUrl,
                fit: BoxFit.contain,
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
          ],
        ),
      ),
    );
  }
}
