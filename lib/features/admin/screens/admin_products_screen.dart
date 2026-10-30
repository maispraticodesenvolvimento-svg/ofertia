import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'admin_edit_product_screen.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gerenciar produtos',
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900),
                  ),
                  Text('Cadastre, edite e gerencie os produtos da plataforma.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Novo produto'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar produtos...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _FilterChip('Todos'),
                const SizedBox(width: 8),
                _FilterChip('Ativos', selected: true),
                const SizedBox(width: 8),
                _FilterChip('Inativos'),
                const SizedBox(width: 8),
                _FilterChip('Pendentes'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              children: [
                // Table header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      const SizedBox(width: 44),
                      _TableHeader('Produto', flex: 3),
                      _TableHeader('Categoria', flex: 2),
                      _TableHeader('Preço', flex: 1),
                      _TableHeader('Estoque', flex: 1),
                      _TableHeader('Status', flex: 1),
                      _TableHeader('Ações', flex: 1),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ..._products.map((p) => _ProductRow(product: p)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static final _products = [
    {'img': '📱', 'name': 'Smartphone Delta X1', 'category': 'Eletrônicos', 'price': 'R\$ 1.899,90', 'stock': '234', 'status': 'Aprovado'},
    {'img': '🎧', 'name': 'Fone de Ouvido Bluetooth', 'category': 'Eletrônicos', 'price': 'R\$ 349,90', 'stock': '89', 'status': 'Aprovado'},
    {'img': '👟', 'name': 'Tênis Run Pro', 'category': 'Moda e Acessórios', 'price': 'R\$ 289,00', 'stock': '56', 'status': 'Em análise'},
    {'img': '🏠', 'name': 'Cadeira Office Executive', 'category': 'Casa e Decoração', 'price': 'R\$ 1.299,00', 'stock': '12', 'status': 'Aprovado'},
    {'img': '⌚', 'name': 'Smartwatch GPS Monitor', 'category': 'Eletrônicos', 'price': 'R\$ 499,90', 'stock': '67', 'status': 'Aprovado'},
    {'img': '🍳', 'name': 'Fritadeira Air Fryer 4L', 'category': 'Eletrodomésticos', 'price': 'R\$ 289,90', 'stock': '203', 'status': 'Em análise'},
  ];
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChip(this.label, {this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySurface : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.grey200,
        ),
      ),
      child: Text(label,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: selected ? AppColors.primary : AppColors.grey600,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  final int flex;

  const _TableHeader(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.grey500,
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Map<String, String> product;

  const _ProductRow({required this.product});

  Color get _statusColor {
    switch (product['status']) {
      case 'Aprovado': return AppColors.statusApproved;
      case 'Em análise': return AppColors.statusAnalysis;
      default: return AppColors.grey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey100)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(product['img']!, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text(product['name']!, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.grey800))),
          Expanded(flex: 2, child: Text(product['category']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600))),
          Expanded(flex: 1, child: Text(product['price']!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey800))),
          Expanded(flex: 1, child: Text(product['stock']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600))),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(product['status']!,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  color: AppColors.primary,
                  tooltip: 'Editar produto',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AdminEditProductScreen(product: product),
                    );
                  },
                ),
                IconButton(icon: const Icon(Icons.delete_outline, size: 16), onPressed: () {}, color: AppColors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
