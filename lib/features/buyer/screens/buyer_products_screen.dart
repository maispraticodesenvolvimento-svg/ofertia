import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class BuyerProductsScreen extends StatelessWidget {
  const BuyerProductsScreen({super.key});

  static const _categories = [
    'Todos', 'Eletrônicos', 'Casa e Decoração', 'Moda', 'Eletrodomésticos', 'Esporte',
  ];

  static const _products = [
    {'emoji': '📱', 'name': 'Smartphone Delta X1 256GB', 'price': 'R\$ 1.899,90', 'rating': 4, 'reviews': '326'},
    {'emoji': '🎧', 'name': 'Fone Bluetooth com ANC', 'price': 'R\$ 349,90', 'rating': 5, 'reviews': '1.421'},
    {'emoji': '⌚', 'name': 'Smartwatch GPS Monitor', 'price': 'R\$ 499,90', 'rating': 4, 'reviews': '876'},
    {'emoji': '💻', 'name': 'Notebook Ultraslim 14"', 'price': 'R\$ 3.299,00', 'rating': 5, 'reviews': '234'},
    {'emoji': '🍳', 'name': 'Fritadeira Air Fryer 4L', 'price': 'R\$ 289,90', 'rating': 4, 'reviews': '1.234'},
    {'emoji': '👟', 'name': 'Tênis Run Pro Unissex', 'price': 'R\$ 289,00', 'rating': 4, 'reviews': '963'},
    {'emoji': '📷', 'name': 'Câmera Digital 24 MP', 'price': 'R\$ 1.499,00', 'rating': 4, 'reviews': '456'},
    {'emoji': '🎮', 'name': 'Controle Gamer Wireless', 'price': 'R\$ 199,90', 'rating': 5, 'reviews': '2.341'},
    {'emoji': '🪑', 'name': 'Cadeira Office Executive', 'price': 'R\$ 1.299,00', 'rating': 4, 'reviews': '789'},
    {'emoji': '🧴', 'name': 'Kit Skincare Premium', 'price': 'R\$ 149,90', 'rating': 5, 'reviews': '567'},
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 960;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Produtos', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.grey900)),
          const SizedBox(height: 12),
          // Category filter
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? AppColors.primary : AppColors.grey300),
                  ),
                  child: Center(
                    child: Text(_categories[i],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: selected ? Colors.white : AppColors.grey600,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: isWide ? 5 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isWide ? 0.7 : 0.72,
            children: _products.map((p) => GestureDetector(
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
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.grey50,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: Center(child: Text(p['emoji'] as String, style: const TextStyle(fontSize: 52))),
                          ),
                          const Positioned(
                            top: 8, right: 8,
                            child: Icon(Icons.favorite_border, size: 18, color: AppColors.grey400),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['name'] as String,
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey800),
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(children: [
                            ...List.generate(5, (i) => Icon(
                              i < (p['rating'] as int) ? Icons.star : Icons.star_border,
                              size: 11, color: const Color(0xFFFFB300),
                            )),
                            const SizedBox(width: 3),
                            Text('(${p['reviews']})', style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey400)),
                          ]),
                          const SizedBox(height: 4),
                          Text(p['price'] as String,
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.grey900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
