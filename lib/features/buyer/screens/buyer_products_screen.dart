import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/product.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';

class BuyerProductsScreen extends StatefulWidget {
  const BuyerProductsScreen({super.key, this.initialCategory});
  final String? initialCategory;

  @override
  State<BuyerProductsScreen> createState() => _BuyerProductsScreenState();
}

class _BuyerProductsScreenState extends State<BuyerProductsScreen> {
  final _api = ApiClient();
  final _search = TextEditingController();
  late Future<List<Product>> _future;
  String? _category;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _future = _api.getProducts(category: _category);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() => setState(() => _future = _api.getProducts(category: _category, query: _search.text));

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
          TextField(
            controller: _search,
            onSubmitted: (_) => _load(),
            decoration: InputDecoration(
              hintText: 'Buscar produtos',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(onPressed: _load, icon: const Icon(Icons.arrow_forward)),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
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
          _future = _api.getProducts(category: value, query: _search.text);
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
