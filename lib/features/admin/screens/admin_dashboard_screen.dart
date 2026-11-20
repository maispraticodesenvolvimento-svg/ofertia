import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<String, dynamic>> _summary;

  @override
  void initState() {
    super.initState();
    _summary = ApiClient().getAdminSummary();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
        future: _summary,
        builder: (context, snapshot) {
          final data = snapshot.data;
          final wide = MediaQuery.sizeOf(context).width > 900;
          return ListView(padding: EdgeInsets.all(wide ? 24 : 16), children: [
            Text('Painel administrativo', style: GoogleFonts.inter(fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.grey900)),
            Text('Indicadores calculados a partir dos registros do banco.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
            const SizedBox(height: 22),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (snapshot.hasError)
              _empty(snapshot.error.toString(), Icons.cloud_off_outlined)
            else ...[
              GridView.count(
                crossAxisCount: wide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: wide ? 1.5 : 1.35,
                children: [
                  _metric('Produtos ativos', '${data?['activeProducts'] ?? 0}', Icons.inventory_2_outlined),
                  _metric('Pedidos', '${data?['orders'] ?? 0}', Icons.receipt_long_outlined),
                  _metric('Clientes', '${data?['customers'] ?? 0}', Icons.people_outline),
                  _metric('Negociações', '${data?['negotiations'] ?? 0}', Icons.handshake_outlined),
                ],
              ),
              const SizedBox(height: 16),
              _metric('Receita de pedidos pagos', NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format((data?['revenue'] as num?)?.toDouble() ?? 0), Icons.payments_outlined),
            ],
          ]);
        },
      );

  Widget _metric(String label, String value, IconData icon) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey200)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const Spacer(),
          Text(value, style: GoogleFonts.inter(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.grey900)),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
        ]),
      );

  Widget _empty(String message, IconData icon) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [Icon(icon, size: 34, color: AppColors.grey400), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.grey600))]),
      );
}
