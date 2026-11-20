import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  late Future<List<Map<String, dynamic>>> _orders;

  @override
  void initState() {
    super.initState();
    _orders = ApiClient().getOrders(all: true);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Map<String, dynamic>>>(
        future: _orders,
        builder: (context, snapshot) {
          final orders = snapshot.data ?? const <Map<String, dynamic>>[];
          return ListView(padding: const EdgeInsets.all(24), children: [
            Text('Pedidos', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
            Text('Pedidos registrados no Realtime Database.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
            const SizedBox(height: 20),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (snapshot.hasError)
              _empty(snapshot.error.toString(), Icons.cloud_off_outlined)
            else if (orders.isEmpty)
              _empty('Ainda não há pedidos.', Icons.receipt_long_outlined)
            else
              ...orders.map(_orderCard),
          ]);
        },
      );

  Widget _orderCard(Map<String, dynamic> order) {
    final items = (order['items'] as List?)?.whereType<Map>().toList() ?? [];
    final labels = items.map((item) => '${item['name'] ?? ''} × ${item['quantity'] ?? 1}').join(', ');
    final total = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format((order['total'] as num?)?.toDouble() ?? 0);
    final createdAt = DateTime.fromMillisecondsSinceEpoch(int.tryParse('${order['createdAt']}') ?? 0);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey200)),
      child: Row(children: [
        const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('#${order['id']} · ${order['status'] ?? 'pending'}', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          Text(labels, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600)),
          Text('${order['customerEmail'] ?? order['customerUid'] ?? ''} · ${DateFormat.yMMMd('pt_BR').format(createdAt)}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400)),
        ])),
        Text(total, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _empty(String message, IconData icon) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [Icon(icon, size: 34, color: AppColors.grey400), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.grey600))]),
      );
}
