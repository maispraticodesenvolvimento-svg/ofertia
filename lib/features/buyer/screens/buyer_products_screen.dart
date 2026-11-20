import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/product.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';

class BuyerProductsScreen extends StatefulWidget {
  const BuyerProductsScreen({super.key, this.initialCategory, this.initialQuery});
  final String? initialCategory;
  final String? initialQuery;

  @override
  State<BuyerProductsScreen> createState() => _BuyerProductsScreenState();
}

class _BuyerProductsScreenState extends State<BuyerProductsScreen> {
  final _api = ApiClient();
  late Future<List<Product>> _future;
  String? _category;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _query = widget.initialQuery ?? '';
    _future = _api.getProducts(category: _category, query: _query);
  }

  @override
  void didUpdateWidget(covariant BuyerProductsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory ||
        oldWidget.initialQuery != widget.initialQuery) {
      _category = widget.initialCategory;
      _query = widget.initialQuery ?? '';
      _future = _api.getProducts(category: _category, query: _query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 960;
    return FutureBuilder<List<Product>>(
      future: _future,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <Product>[];
        final categories = items.map((p) => p.category).toSet().toList()..sort();
        return ListView(padding: EdgeInsets.all(wide ? 24 : 16), children: [
          Text('Produtos', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
          const SizedBox(height: 16),
          if (categories.isNotEmpty)
            SizedBox(
              height: 42,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                _categoryChip('Todos', null),
                ...categories.map((category) => _categoryChip(category, category)),
              ]),
            ),
          const SizedBox(height: 16),
          if (snapshot.connectionState == ConnectionState.waiting)
            const Center(child: Padding(padding: EdgeInsets.all(36), child: CircularProgressIndicator()))
          else if (snapshot.hasError)
            _empty(snapshot.error.toString(), icon: Icons.cloud_off_outlined)
          else if (items.isEmpty)
            _empty('Ainda não há produtos disponíveis.', icon: Icons.inventory_2_outlined)
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: wide ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: wide ? 0.76 : 0.68,
              ),
              itemBuilder: (_, index) => ProductCard(product: items[index]),
            ),
        ]);
      },
    );
  }

  Widget _categoryChip(String label, String? value) {
    final selected = _category == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() {
          _category = value;
          _future = _api.getProducts(category: value, query: _query);
        }),
      ),
    );
  }

  Widget _empty(String message, {required IconData icon}) => Container(
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(children: [Icon(icon, size: 36, color: AppColors.grey400), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.grey600))]),
      );
}
