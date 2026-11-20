import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/models/product.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';
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
    final results = await Future.wait([api.getProducts(featured: true), api.getBanners()]);
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
          final categories = data.products.map((item) => item.category).toSet().toList()..sort();
          final wide = MediaQuery.sizeOf(context).width > 960;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // ── Banners ocupando 100% da largura, sem margens ou bordas arredondadas ──
              if (data.banners.isNotEmpty) ...[
                _BannerSlider(banners: data.banners, wide: wide),
                const SizedBox(height: 24),
              ],

              // ── Demais conteúdos dentro do padding padrão da página ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Seção "Cuidamos de cada compra" estilo Mercado Livre ──
                    _buildTrustSection(wide),
                    const SizedBox(height: 28),

                    if (categories.isNotEmpty) ...[
                      Text('Explore categorias', style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.grey900)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((category) => ActionChip(
                          label: Text(category),
                          onPressed: () => context.go('/buyer/products'),
                        )).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    Row(children: [
                      Expanded(child: Text('Em destaque', style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.grey900))),
                      TextButton(onPressed: () => context.go('/buyer/products'), child: const Text('Ver produtos')),
                    ]),
                    const SizedBox(height: 10),

                    if (data.products.isEmpty)
                      _empty('Ainda não há produtos em destaque.', Icons.inventory_2_outlined)
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: wide ? 4 : 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: wide ? 0.76 : 0.68,
                        ),
                        itemBuilder: (_, index) => ProductCard(product: data.products[index]),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      );

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
