import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/models/product.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_image.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _api = ApiClient();
  final _search = TextEditingController();
  late Future<List<Product>> _products;

  @override
  void initState() {
    super.initState();
    _products = _api.getProducts(all: true);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload() => setState(() => _products = _api.getProducts(all: true, query: _search.text));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _products,
      builder: (context, snapshot) {
        final products = snapshot.data ?? const <Product>[];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Produtos', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
                Text('Os produtos exibidos aqui vêm do Realtime Database.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
              ])),
              FilledButton.icon(
                onPressed: () async {
                  final saved = await context.push<bool>('/admin/products/new');
                  if (saved == true) _reload();
                },
                icon: const Icon(Icons.add),
                label: const Text('Novo produto'),
              ),
            ]),
            const SizedBox(height: 20),
            TextField(
              controller: _search,
              onSubmitted: (_) => _reload(),
              decoration: InputDecoration(
                hintText: 'Buscar por nome, categoria ou descrição',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(onPressed: _reload, icon: const Icon(Icons.arrow_forward)),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: Padding(padding: EdgeInsets.all(36), child: CircularProgressIndicator()))
            else if (snapshot.hasError)
              _messageCard(snapshot.error.toString(), icon: Icons.cloud_off_outlined)
            else if (products.isEmpty)
              _messageCard('Nenhum produto cadastrado. Use “Novo produto” para começar.', icon: Icons.inventory_2_outlined)
            else
              ...products.map(_productCard),
          ]),
        );
      },
    );
  }

  Widget _productCard(Product product) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey200)),
        child: Column(children: [
          Row(children: [
            SizedBox(width: 58, height: 58, child: ClipRRect(borderRadius: BorderRadius.circular(9), child: ProductImage(dataUrl: product.imageDataUrl))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.grey900)),
              Text('${product.category} · Estoque: ${product.stock}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
            ])),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text(NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(product.price), style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
            Chip(label: Text(product.status == 'active' ? 'Ativo' : 'Inativo'), visualDensity: VisualDensity.compact),
            IconButton(
              tooltip: 'Editar produto',
              onPressed: () async {
                final saved = await context.push<bool>('/admin/products/${product.id}/edit', extra: product);
                if (saved == true) _reload();
              },
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(tooltip: 'Excluir produto', onPressed: () => _delete(product), icon: const Icon(Icons.delete_outline, color: AppColors.error)),
          ]),
        ]),
      );

  Future<void> _delete(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir produto?'),
        content: Text('“${product.name}” será removido do catálogo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.deleteProduct(product.id);
      _reload();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Widget _messageCard(String message, {required IconData icon}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey200)),
        child: Column(children: [Icon(icon, size: 34, color: AppColors.grey400), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.grey600))]),
      );
}
