import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/product.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';

class BuyerOffersScreen extends StatefulWidget {
  const BuyerOffersScreen({super.key});

  @override
  State<BuyerOffersScreen> createState() => _BuyerOffersScreenState();
}

class _BuyerOffersScreenState extends State<BuyerOffersScreen> {
  late Future<List<Product>> _offers;

  @override
  void initState() {
    super.initState();
    _offers = ApiClient().getProducts(offers: true);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 960;
    return FutureBuilder<List<Product>>(
      future: _offers,
      builder: (context, snapshot) {
        final offers = snapshot.data ?? const <Product>[];
        return ListView(padding: EdgeInsets.all(wide ? 24 : 16), children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const Icon(Icons.local_offer_outlined, color: Color(0xFFFFD166), size: 30),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ofertas', style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                Text('Produtos com preço promocional cadastrado.', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
              ])),
            ]),
          ),
          const SizedBox(height: 20),
          if (snapshot.connectionState == ConnectionState.waiting)
            const Center(child: Padding(padding: EdgeInsets.all(36), child: CircularProgressIndicator()))
          else if (snapshot.hasError)
            _empty(snapshot.error.toString(), Icons.cloud_off_outlined)
          else if (offers.isEmpty)
            _empty('Nenhuma oferta ativa no momento.', Icons.local_offer_outlined)
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: offers.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: wide ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: wide ? 0.76 : 0.68,
              ),
              itemBuilder: (_, index) => ProductCard(product: offers[index]),
            ),
        ]);
      },
    );
  }

  Widget _empty(String text, IconData icon) => Container(
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(children: [Icon(icon, color: AppColors.grey400, size: 34), const SizedBox(height: 10), Text(text, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.grey600))]),
      );
}
