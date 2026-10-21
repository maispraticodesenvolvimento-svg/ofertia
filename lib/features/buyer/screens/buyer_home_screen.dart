import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_theme.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int _bannerIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 960;
    return isWide ? _buildWideLayout() : _buildMobileLayout();
  }

  Widget _buildWideLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sidebar categories
            _CategoriesSidebar(),
            const SizedBox(width: 16),
            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BannerCarousel(
                    index: _bannerIndex,
                    controller: _carouselController,
                    onChanged: (i) => setState(() => _bannerIndex = i),
                  ),
                  const SizedBox(height: 24),
                  _OffersSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Benefits strip
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BenefitChip(Icons.local_shipping_outlined, 'Frete rápido\npara todo o Brasil'),
                _BenefitChip(Icons.security_outlined, 'Compra segura\ne protegida'),
                _BenefitChip(Icons.credit_card_outlined, 'Parcelamento\nem até 12x'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Categorias', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () {},
                  child: Row(children: [
                    Text('Ver tudo', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
                    const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: const [
                _MobileCategoryItem(Icons.smartphone_outlined, 'Celulares'),
                _MobileCategoryItem(Icons.computer_outlined, 'Informática'),
                _MobileCategoryItem(Icons.home_outlined, 'Casa e\nDecoração'),
                _MobileCategoryItem(Icons.checkroom_outlined, 'Moda'),
                _MobileCategoryItem(Icons.sports_esports_outlined, 'Games'),
                _MobileCategoryItem(Icons.sports_soccer_outlined, 'Esporte\ne Lazer'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Mobile banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _MobileBanner(
              index: _bannerIndex,
              controller: _carouselController,
              onChanged: (i) => setState(() => _bannerIndex = i),
            ),
          ),
          const SizedBox(height: 16),
          // Featured offers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ofertas em destaque', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () {},
                  child: Row(children: [
                    Text('Ver tudo', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
                    const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 230,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _featuredProducts.map((p) => _MobileProductCard(product: p)).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BenefitChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey700)),
      ],
    );
  }
}

class _MobileCategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MobileCategoryItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey700),
          ),
        ],
      ),
    );
  }
}

class _MobileBanner extends StatelessWidget {
  final int index;
  final CarouselSliderController controller;
  final ValueChanged<int> onChanged;

  const _MobileBanner({required this.index, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: controller,
          options: CarouselOptions(
            height: 160,
            autoPlay: true,
            viewportFraction: 1.0,
            onPageChanged: (i, _) => onChanged(i),
          ),
          items: [
            _buildBannerItem('Grandes escolhas\npara o seu dia a dia', 'Qualidade, variedade\ne ótimos preços.', 'Buscar produtos'),
            _buildBannerItem('Tecnologia que\nfacilita o seu dia', 'Mais praticidade,\nmais possibilidades.', 'Aproveitar agora'),
            _buildBannerItem('Inovação para\numa vida mais simples', 'Encontre os melhores\nprodutos aqui.', 'Ver ofertas'),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedSmoothIndicator(
          activeIndex: index,
          count: 3,
          effect: ExpandingDotsEffect(
            dotHeight: 6,
            dotWidth: 6,
            activeDotColor: AppColors.primary,
            dotColor: AppColors.grey300,
          ),
        ),
      ],
    );
  }

  Widget _buildBannerItem(String title, String sub, String btn) {
    return Builder(
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF66BB6A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(sub,
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(btn,
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.headphones, color: Colors.white30, size: 70),
          ],
        ),
      ),
    );
  }
}

class _MobileProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _MobileProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/buyer/product/1'),
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.favorite_border, size: 18, color: AppColors.grey400),
            ),
            Center(
              child: Text(product['emoji'] as String, style: const TextStyle(fontSize: 44)),
            ),
            const SizedBox(height: 6),
            Text(product['name'] as String,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey800),
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (i) =>
                Icon(i < (product['rating'] as int) ? Icons.star : Icons.star_border,
                  size: 10, color: const Color(0xFFFFB300)),
              ),
            ),
            const SizedBox(height: 4),
            Text('A partir de', style: GoogleFonts.inter(fontSize: 9, color: AppColors.primary)),
            Text(product['price'] as String,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

// Wide layout components
class _CategoriesSidebar extends StatelessWidget {
  static const _categories = [
    'Eletrônicos', 'Casa e Decoração', 'Moda e Acessórios', 'Beleza e Cuidados Pessoais',
    'Esporte e Lazer', 'Brinquedos e Infantil', 'Automotivo', 'Pet Shop',
    'Supermercado', 'Saúde e Bem-estar', 'Livros e Papelaria', 'Ferramentas e Construção',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text('Categorias', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grey900)),
          ),
          const Divider(height: 1),
          ..._categories.map((c) => _CategoryItem(c)),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text('Ver todas as categorias', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Um futuro\nmais verde juntos', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      Text('Produtos sustentáveis para um mundo melhor', style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey600)),
                      const SizedBox(height: 6),
                      Text('Conheça', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;

  const _CategoryItem(this.label);

  IconData get _icon {
    if (label.contains('Eletrônico')) return Icons.smartphone_outlined;
    if (label.contains('Casa')) return Icons.home_outlined;
    if (label.contains('Moda')) return Icons.checkroom_outlined;
    if (label.contains('Beleza')) return Icons.spa_outlined;
    if (label.contains('Esporte')) return Icons.sports_soccer_outlined;
    if (label.contains('Brinquedo')) return Icons.toys_outlined;
    if (label.contains('Auto')) return Icons.directions_car_outlined;
    if (label.contains('Pet')) return Icons.pets_outlined;
    if (label.contains('Super')) return Icons.shopping_basket_outlined;
    if (label.contains('Saúde')) return Icons.favorite_outline;
    if (label.contains('Livro')) return Icons.menu_book_outlined;
    return Icons.build_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          children: [
            Icon(_icon, size: 15, color: AppColors.grey600),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey700))),
            const Icon(Icons.chevron_right, size: 14, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}

class _BannerCarousel extends StatelessWidget {
  final int index;
  final CarouselSliderController controller;
  final ValueChanged<int> onChanged;

  const _BannerCarousel({required this.index, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          carouselController: controller,
          options: CarouselOptions(
            height: 280,
            autoPlay: true,
            viewportFraction: 1.0,
            onPageChanged: (i, _) => onChanged(i),
          ),
          items: [
            _WideBannerItem(
              title: 'Tecnologia que\nfacilita o seu dia',
              sub: 'Mais praticidade, mais possibilidades.\nEncontre os melhores eletrônicos\ncom ótimas ofertas.',
              btn: 'Aproveitar agora',
            ),
            _WideBannerItem(
              title: 'Grandes promoções\npara você!',
              sub: 'Descontos de até 40% em\nmais de 300 categorias diferentes.\nAproveite já!',
              btn: 'Ver todas as ofertas',
            ),
            _WideBannerItem(
              title: 'Inovação para\numa vida mais simples',
              sub: 'Encontre os melhores produtos\nem tecnologia, moda, casa\ne muito mais.',
              btn: 'Explorar',
            ),
          ],
        ),
        // Controls
        Positioned(
          left: 10, top: 0, bottom: 0,
          child: Center(
            child: InkWell(
              onTap: () => controller.previousPage(),
              child: _CarouselButton(Icons.chevron_left),
            ),
          ),
        ),
        Positioned(
          right: 10, top: 0, bottom: 0,
          child: Center(
            child: InkWell(
              onTap: () => controller.nextPage(),
              child: _CarouselButton(Icons.chevron_right),
            ),
          ),
        ),
        // Dots
        Positioned(
          bottom: 14, left: 0, right: 0,
          child: Center(
            child: AnimatedSmoothIndicator(
              activeIndex: index,
              count: 3,
              effect: ExpandingDotsEffect(
                dotHeight: 7,
                dotWidth: 7,
                activeDotColor: AppColors.primary,
                dotColor: Colors.white54,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CarouselButton extends StatelessWidget {
  final IconData icon;

  const _CarouselButton(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
      ),
      child: Icon(icon, color: AppColors.grey700, size: 18),
    );
  }
}

class _WideBannerItem extends StatelessWidget {
  final String title;
  final String sub;
  final String btn;

  const _WideBannerItem({required this.title, required this.sub, required this.btn});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDCF5E4), Color(0xFFA5D6A7), Color(0xFFE8F5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primaryDark, height: 1.2)),
                const SizedBox(height: 12),
                Text(sub, style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey700, height: 1.5)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text(btn),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            flex: 1,
            child: Icon(Icons.devices, color: AppColors.primary, size: 120),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Inovação', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  Text('para uma vida', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  Text('mais simples', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  Container(width: 40, height: 3, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OffersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ofertas em destaque',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.grey900),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
              label: Text('Ver tudo', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
          children: _featuredProducts.map((p) => _ProductCard(product: p)).toList(),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/buyer/product/1'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(child: Text(product['emoji'] as String, style: const TextStyle(fontSize: 64))),
                ),
                if (product['badge'] != null)
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: product['badgeColor'] as Color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(product['badge'] as String,
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8, right: 8,
                  child: const Icon(Icons.favorite_border, size: 20, color: AppColors.grey400),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'] as String,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey800),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ...List.generate(5, (i) => Icon(
                        i < (product['rating'] as int) ? Icons.star : Icons.star_border,
                        size: 12, color: const Color(0xFFFFB300),
                      )),
                      const SizedBox(width: 4),
                      Text('(${product['reviews']})', style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (product['oldPrice'] != null)
                    Text(product['oldPrice'] as String,
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400, decoration: TextDecoration.lineThrough),
                    ),
                  Text(product['price'] as String,
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.grey900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _featuredProducts = [
  {
    'emoji': '🍳',
    'name': 'Fritadeira Elétrica Air Fryer 4L 1500W',
    'price': 'R\$ 289,90',
    'oldPrice': 'R\$ 359,90',
    'badge': '-20%',
    'badgeColor': AppColors.error,
    'rating': 4,
    'reviews': '1.234',
  },
  {
    'emoji': '📱',
    'name': 'Smartphone 128GB Câmera Tripla',
    'price': 'R\$ 1.299,00',
    'oldPrice': 'R\$ 1.529,00',
    'badge': '-15%',
    'badgeColor': AppColors.error,
    'rating': 4,
    'reviews': '2.189',
  },
  {
    'emoji': '👟',
    'name': 'Tênis Casual Unissex Conforto e Estilo',
    'price': 'R\$ 89,90',
    'oldPrice': null,
    'badge': 'A partir de R\$ 89,90',
    'badgeColor': AppColors.primary,
    'rating': 5,
    'reviews': '963',
  },
  {
    'emoji': '🎧',
    'name': 'Fone de Ouvido Bluetooth Cancelamento de Ruído',
    'price': 'R\$ 349,90',
    'oldPrice': 'R\$ 429,90',
    'badge': '-18%',
    'badgeColor': AppColors.error,
    'rating': 4,
    'reviews': '1.421',
  },
  {
    'emoji': '⌚',
    'name': 'Smartwatch com GPS e Monitor de Saúde',
    'price': 'R\$ 499,90',
    'oldPrice': 'R\$ 569,90',
    'badge': '-12%',
    'badgeColor': AppColors.error,
    'rating': 4,
    'reviews': '876',
  },
];
