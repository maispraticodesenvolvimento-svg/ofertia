import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class BuyerProductDetailScreen extends StatefulWidget {
  final String productId;

  const BuyerProductDetailScreen({super.key, required this.productId});

  @override
  State<BuyerProductDetailScreen> createState() => _BuyerProductDetailScreenState();
}

class _BuyerProductDetailScreenState extends State<BuyerProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _selectedImage = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final _productImages = ['📱', '📲', '🔳', '📴'];
  final _vendors = [
    {
      'name': 'TechHouse',
      'official': true,
      'price': 'R\$ 1.899,90',
      'rating': '4,9',
      'reviews': 1204,
      'delivery': 'Entrega em até 3 dias\nFrete grátis',
      'condition': 'Novo\nLacrado',
      'badge': 'Melhor preço',
    },
    {
      'name': 'MundoTech',
      'official': false,
      'price': 'R\$ 1.949,00',
      'rating': '4,8',
      'reviews': 892,
      'delivery': 'Entrega em até 3 dias\nFrete grátis',
      'condition': 'Novo\nLacrado',
      'badge': null,
    },
    {
      'name': 'EletroMais',
      'official': false,
      'price': 'R\$ 1.999,00',
      'rating': '4,7',
      'reviews': 456,
      'delivery': 'Entrega em até 4 dias',
      'condition': 'Novo\nLacrado',
      'badge': null,
    },
    {
      'name': 'Digital Center',
      'official': false,
      'price': 'R\$ 2.049,00',
      'rating': '4,6',
      'reviews': 310,
      'delivery': 'Entrega em até 5 dias',
      'condition': 'Novo\nLacrado',
      'badge': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 960;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 24 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          if (isWide) _Breadcrumb(),
          if (isWide) const SizedBox(height: 16),
          // Main product section
          isWide ? _buildWideProduct() : _buildMobileProduct(),
          const SizedBox(height: 24),
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(child: Text('Descrição do produto', style: GoogleFonts.inter(fontSize: 14))),
              Tab(child: Text('Ficha técnica', style: GoogleFonts.inter(fontSize: 14))),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isWide ? 400 : 600,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDescription(isWide),
                _buildSpecs(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideProduct() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image gallery
        Column(
          children: [
            ...List.generate(_productImages.length, (i) => GestureDetector(
              onTap: () => setState(() => _selectedImage = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: _selectedImage == i ? AppColors.primary : AppColors.grey200,
                    width: _selectedImage == i ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text(_productImages[i], style: const TextStyle(fontSize: 32))),
              ),
            )),
            Container(
              width: 70, height: 40,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text('+3', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600, fontWeight: FontWeight.w600))),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Main image
        Container(
          width: 360,
          height: 340,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Stack(
            children: [
              Center(child: Text(_productImages[_selectedImage], style: const TextStyle(fontSize: 140))),
              Positioned(
                left: 10, top: 0, bottom: 0,
                child: Center(child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _selectedImage = (_selectedImage - 1 + _productImages.length) % _productImages.length),
                )),
              ),
              Positioned(
                right: 10, top: 0, bottom: 0,
                child: Center(child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _selectedImage = (_selectedImage + 1) % _productImages.length),
                )),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Product info
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(4)),
                child: Text('Lançamento', style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 10),
              Text('Smartphone Nova X 256 GB',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ...List.generate(5, (i) => Icon(
                    i < 4 ? Icons.star : Icons.star_half,
                    size: 16, color: const Color(0xFFFFB300),
                  )),
                  const SizedBox(width: 8),
                  Text('4.8 (326 avaliações)', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Desempenho de outro nível, câmera incrível e bateria para o seu dia todo. O Nova X 256 GB combina tecnologia, design e velocidade para você ir mais longe.',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey700, height: 1.5),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  _SpecBadge(Icons.memory_outlined, 'Processador\nocta-core'),
                  SizedBox(width: 12),
                  _SpecBadge(Icons.photo_camera_outlined, 'Câmera tripla\nde 108 MP'),
                  SizedBox(width: 12),
                  _SpecBadge(Icons.storage_outlined, '256 GB\nde armazenamento'),
                  SizedBox(width: 12),
                  _SpecBadge(Icons.battery_full_outlined, 'Bateria de\n5.000 mAh'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border, size: 16),
                    label: Text('Adicionar aos favoritos', style: GoogleFonts.inter(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.grey700,
                      side: const BorderSide(color: AppColors.grey300),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: Text('Compartilhar', style: GoogleFonts.inter(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.grey700,
                      side: const BorderSide(color: AppColors.grey300),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Buy box
        Container(
          width: 260,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                  const SizedBox(width: 6),
                  Text('Melhor preço', style: GoogleFonts.inter(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 10),
              Text('A partir de', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
              Text('R\$ 1.899,90',
                style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.grey900),
              ),
              Text('12 ofertas disponíveis', style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                  label: const Text('Comprar'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.handshake_outlined, size: 16),
                  label: Text('Fazer uma oferta', style: GoogleFonts.inter(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primaryBorder),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.grey500),
                const SizedBox(width: 8),
                Text('Entrega em até 3 dias', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.security_outlined, size: 16, color: AppColors.grey500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Compra segura\ne proteção ao seu dinheiro',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileProduct() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Center(child: Text('📱', style: const TextStyle(fontSize: 100))),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(4)),
          child: Text('Lançamento', style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        Text('Smartphone Nova X 256 GB',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.grey900),
        ),
        const SizedBox(height: 6),
        Row(children: [
          ...List.generate(5, (i) => Icon(i < 4 ? Icons.star : Icons.star_half, size: 15, color: const Color(0xFFFFB300))),
          const SizedBox(width: 6),
          Text('4.8 (326 avaliações)', style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
        ]),
        const SizedBox(height: 14),
        Text('A partir de', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
        Text('R\$ 1.899,90',
          style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.grey900),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_outlined, size: 16),
            label: const Text('Comprar'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.handshake_outlined, size: 16),
            label: Text('Fazer uma oferta', style: GoogleFonts.inter(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primaryBorder),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(bool isWide) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: isWide ? 1 : 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Descrição do produto',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.grey900),
                ),
                const SizedBox(height: 10),
                Text(
                  'O Smartphone Nova X 256 GB foi feito para quem busca mais performance, mais liberdade e mais possibilidades. Com design moderno, câmeras de alta resolução e bateria de longa duração, ele acompanha o seu ritmo em todas as situações, do trabalho ao lazer.',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey700, height: 1.6),
                ),
                const SizedBox(height: 14),
                _BulletPoint('Tela AMOLED de 6,7" com alta definição'),
                _BulletPoint('Câmera tripla de 108 MP com inteligência artificial'),
                _BulletPoint('256 GB de armazenamento'),
                _BulletPoint('Bateria de 5.000 mAh com carregamento rápido'),
                _BulletPoint('Conectividade 5G, Wi-Fi 6 e Bluetooth 5.3'),
              ],
            ),
          ),
          if (isWide) ...[
            const SizedBox(width: 32),
            Expanded(
              flex: 2,
              child: _VendorsTable(vendors: _vendors),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecs() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ficha técnica', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _SpecRow('Sistema operacional', 'Android 14'),
          _SpecRow('Processador', 'Octa-core 3.2GHz'),
          _SpecRow('Memória RAM', '12 GB'),
          _SpecRow('Armazenamento', '256 GB'),
          _SpecRow('Tela', 'AMOLED 6,7" FHD+'),
          _SpecRow('Câmera traseira', '108 MP + 12 MP + 5 MP'),
          _SpecRow('Câmera frontal', '32 MP'),
          _SpecRow('Bateria', '5.000 mAh'),
          _SpecRow('5G', 'Sim'),
          _SpecRow('Dimensões', '162 x 74 x 8,9 mm'),
          _SpecRow('Peso', '195 g'),
          _SpecRow('Cores disponíveis', 'Verde, Grafite, Prata'),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.grey100))),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500))),
          Expanded(flex: 2, child: Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.grey800))),
        ],
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final segments = ['Início', 'Celulares e Tecnologia', 'Celulares e Smartphones', 'Smartphone Nova X 256 GB'];
    return Row(
      children: segments.asMap().entries.map((e) {
        final isLast = e.key == segments.length - 1;
        return Row(
          children: [
            GestureDetector(
              onTap: isLast ? null : () => context.go('/buyer/home'),
              child: Text(e.value,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isLast ? AppColors.grey800 : AppColors.primary,
                  fontWeight: isLast ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (!isLast) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text('>', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400)),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _SpecBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SpecBadge(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.grey600, size: 26),
        const SizedBox(height: 4),
        Text(label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey600),
        ),
      ],
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey700))),
        ],
      ),
    );
  }
}

class _VendorsTable extends StatelessWidget {
  final List<Map<String, dynamic>> vendors;

  const _VendorsTable({required this.vendors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ofertas dos vendedores',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.grey900),
            ),
            Text('12 ofertas disponíveis', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Row(children: [
                  _VH('Vendedor', 2),
                  _VH('Preço', 1),
                  _VH('Avaliação', 1),
                  _VH('Entrega', 2),
                  _VH('Condição', 1),
                  const SizedBox(width: 82),
                ]),
              ),
              const Divider(height: 1),
              ...vendors.map((v) => _VendorRow(v: v)),
            ],
          ),
        ),
      ],
    );
  }
}

class _VH extends StatelessWidget {
  final String text;
  final int flex;

  const _VH(this.text, this.flex);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey500)),
    );
  }
}

class _VendorRow extends StatelessWidget {
  final Map<String, dynamic> v;

  const _VendorRow({required this.v});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.grey100))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(4)),
                  child: Center(child: Icon(Icons.store_outlined, color: AppColors.primary, size: 14)),
                ),
                const SizedBox(width: 8),
                Text(v['name'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ]),
              if (v['official'] as bool)
                Text('Loja oficial', style: GoogleFonts.inter(fontSize: 10, color: AppColors.success)),
              if (v['badge'] != null) ...[
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(4)),
                  child: Text(v['badge'] as String, style: GoogleFonts.inter(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          )),
          Expanded(flex: 1, child: Text(v['price'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grey900))),
          Expanded(flex: 1, child: Row(children: [
            const Icon(Icons.star, size: 13, color: Color(0xFFFFB300)),
            const SizedBox(width: 2),
            Text('${v['rating']} (${v['reviews']})', style: GoogleFonts.inter(fontSize: 11)),
          ])),
          Expanded(flex: 2, child: Row(children: [
            const Icon(Icons.local_shipping_outlined, size: 14, color: AppColors.grey400),
            const SizedBox(width: 4),
            Expanded(child: Text(v['delivery'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey600))),
          ])),
          Expanded(flex: 1, child: Text(v['condition'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey600))),
          SizedBox(
            width: 82,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 32),
                padding: EdgeInsets.zero,
                textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              child: const Text('Comprar'),
            ),
          ),
        ],
      ),
    );
  }
}
