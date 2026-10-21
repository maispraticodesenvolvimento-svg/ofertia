import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class BuyerOffersScreen extends StatelessWidget {
  const BuyerOffersScreen({super.key});

  static const _offers = [
    {'emoji': '📱', 'name': 'Smartphone 128GB Câmera Tripla', 'price': 'R\$ 1.299,00', 'oldPrice': 'R\$ 1.529,00', 'discount': '-15%', 'rating': 4, 'reviews': '2.189'},
    {'emoji': '🍳', 'name': 'Fritadeira Air Fryer 4L 1500W', 'price': 'R\$ 289,90', 'oldPrice': 'R\$ 359,90', 'discount': '-20%', 'rating': 4, 'reviews': '1.234'},
    {'emoji': '🎧', 'name': 'Fone Bluetooth com Cancelamento', 'price': 'R\$ 349,90', 'oldPrice': 'R\$ 429,90', 'discount': '-18%', 'rating': 4, 'reviews': '1.421'},
    {'emoji': '⌚', 'name': 'Smartwatch com GPS e Monitor', 'price': 'R\$ 499,90', 'oldPrice': 'R\$ 569,90', 'discount': '-12%', 'rating': 4, 'reviews': '876'},
    {'emoji': '👟', 'name': 'Tênis Casual Unissex Conforto', 'price': 'R\$ 89,90', 'oldPrice': 'R\$ 129,90', 'discount': '-31%', 'rating': 5, 'reviews': '963'},
    {'emoji': '💻', 'name': 'Notebook Ultraslim 14" i5', 'price': 'R\$ 2.899,00', 'oldPrice': 'R\$ 3.499,00', 'discount': '-17%', 'rating': 5, 'reviews': '234'},
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 960;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
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
                    children: [
                      const Icon(Icons.local_offer, color: Colors.amber, size: 28),
                      const SizedBox(height: 8),
                      Text('Ofertas em destaque', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                      Text('Descontos incríveis por tempo limitado!', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text('Até', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                      Text('40%', style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                      Text('OFF', style: GoogleFonts.inter(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Todas as ofertas', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.grey900)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: isWide ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isWide ? 0.72 : 0.68,
            children: _offers.map((p) => GestureDetector(
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
                            decoration: BoxDecoration(color: AppColors.grey50, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                            child: Center(child: Text(p['emoji'] as String, style: const TextStyle(fontSize: 56))),
                          ),
                          Positioned(
                            top: 10, left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(4)),
                              child: Text(p['discount'] as String, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ),
                          const Positioned(top: 8, right: 8, child: Icon(Icons.favorite_border, size: 18, color: AppColors.grey400)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['name'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey800), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(children: [
                            ...List.generate(5, (i) => Icon(i < (p['rating'] as int) ? Icons.star : Icons.star_border, size: 11, color: const Color(0xFFFFB300))),
                            const SizedBox(width: 3),
                            Text('(${p['reviews']})', style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey400)),
                          ]),
                          const SizedBox(height: 4),
                          Text(p['oldPrice'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400, decoration: TextDecoration.lineThrough)),
                          Text(p['price'] as String, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.grey900)),
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
