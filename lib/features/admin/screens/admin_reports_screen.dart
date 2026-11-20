import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
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
          final wide = MediaQuery.sizeOf(context).width > 780;
          return ListView(padding: const EdgeInsets.all(24), children: [
            Text('Relatórios', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
            Text('Resumo calculado com os dados existentes no banco.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
            const SizedBox(height: 22),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (snapshot.hasError)
              _empty(snapshot.error.toString())
            else
              GridView.count(
                crossAxisCount: wide ? 3 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  _report('Receita', NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format((data?['revenue'] as num?)?.toDouble() ?? 0)),
                  _report('Pedidos pagos', '${data?['paidOrders'] ?? 0}'),
                  _report('Ticket médio', NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format((data?['averageOrder'] as num?)?.toDouble() ?? 0)),
                  _report('Produtos cadastrados', '${data?['products'] ?? 0}'),
                  _report('Clientes', '${data?['customers'] ?? 0}'),
                  _report('Vendedores', '${data?['vendors'] ?? 0}'),
                ],
              ),
          ]);
        },
      );

  Widget _report(String label, String value) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey200)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
          Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.grey900)),
        ]),
      );

  Widget _empty(String text) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Text(text, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.grey600)),
      );
}
