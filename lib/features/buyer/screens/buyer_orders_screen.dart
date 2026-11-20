import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';

class BuyerOrdersScreen extends StatefulWidget {
  const BuyerOrdersScreen({super.key});

  @override
  State<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen> {
  late Future<List<Map<String, dynamic>>> _orders;

  @override
  void initState() {
    super.initState();
    _orders = ApiClient().getOrders();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Map<String, dynamic>>>(
        future: _orders,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          return ListView(padding: const EdgeInsets.all(20), children: [
            Text('Meus pedidos', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
            const SizedBox(height: 4),
            Text('Pedidos associados à sua conta.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
            const SizedBox(height: 18),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (snapshot.hasError)
              _empty(snapshot.error.toString(), Icons.cloud_off_outlined)
            else if (items.isEmpty)
              _empty('Você ainda não tem pedidos.', Icons.shopping_bag_outlined)
            else
              ...items.map(_orderCard),
          ]);
        },
      );

  Widget _orderCard(Map<String, dynamic> order) {
    final entries = (order['items'] as List?)?.whereType<Map>().toList() ?? [];
    final productNames = entries.map((entry) => entry['name']?.toString() ?? '').where((name) => name.isNotEmpty).join(', ');
    final time = DateTime.fromMillisecondsSinceEpoch(int.tryParse('${order['createdAt']}') ?? 0);
    final status = order['status']?.toString() ?? 'pending';
    final amount = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format((order['total'] as num?)?.toDouble() ?? 0);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey200)),
      child: Row(children: [
        const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('#${order['id']}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
          Text(productNames, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600)),
          Text(DateFormat.yMMMd('pt_BR').format(time), style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400)),
        ])),
        Text(status, style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
        const SizedBox(width: 14),
        Text(amount, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _empty(String message, IconData icon) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [Icon(icon, color: AppColors.grey400, size: 34), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.grey600))]),
      );
}
