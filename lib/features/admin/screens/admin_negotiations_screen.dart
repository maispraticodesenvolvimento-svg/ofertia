import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';

class AdminNegotiationsScreen extends StatefulWidget {
  const AdminNegotiationsScreen({super.key});

  @override
  State<AdminNegotiationsScreen> createState() => _AdminNegotiationsScreenState();
}

class _AdminNegotiationsScreenState extends State<AdminNegotiationsScreen> {
  late Future<List<Map<String, dynamic>>> _negotiations;

  @override
  void initState() {
    super.initState();
    _negotiations = ApiClient().getNegotiations(all: true);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Map<String, dynamic>>>(
        future: _negotiations,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          return ListView(padding: const EdgeInsets.all(24), children: [
            Text('Negociações', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
            Text('Ofertas enviadas por clientes.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
            const SizedBox(height: 20),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (snapshot.hasError)
              _empty(snapshot.error.toString(), Icons.cloud_off_outlined)
            else if (items.isEmpty)
              _empty('Ainda não há negociações.', Icons.handshake_outlined)
            else
              ...items.map(_card),
          ]);
        },
      );

  Widget _card(Map<String, dynamic> item) {
    final amount = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format((item['offerPrice'] as num?)?.toDouble() ?? 0);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey200)),
      child: Row(children: [
        const Icon(Icons.handshake_outlined, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['productName']?.toString() ?? 'Produto', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          Text(item['customerEmail']?.toString() ?? item['customerUid']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
        ])),
        Text(item['status']?.toString() ?? 'open', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
        const SizedBox(width: 14),
        Text(amount, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary)),
      ]),
    );
  }

  Widget _empty(String message, IconData icon) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [Icon(icon, size: 34, color: AppColors.grey400), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.grey600))]),
      );
}
