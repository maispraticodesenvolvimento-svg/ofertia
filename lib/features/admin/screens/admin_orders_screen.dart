import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pedidos', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
          Text('Acompanhe todos os pedidos da plataforma.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
          const SizedBox(height: 24),
          ...List.generate(7, (i) => _OrderCard(index: i)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final int index;
  const _OrderCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'id': '#PED-001234', 'product': 'Smartphone Delta X1 256GB', 'buyer': 'Carlos M.', 'value': 'R\$ 1.899,90', 'status': 'Entregue', 'date': '30/04/2024'},
      {'id': '#PED-001233', 'product': 'Fone Bluetooth ANC Pro', 'buyer': 'Ana R.', 'value': 'R\$ 349,90', 'status': 'Em trânsito', 'date': '30/04/2024'},
      {'id': '#PED-001232', 'product': 'Fritadeira Air Fryer 4L', 'buyer': 'Maria S.', 'value': 'R\$ 289,90', 'status': 'Aguardando', 'date': '29/04/2024'},
      {'id': '#PED-001231', 'product': 'Smartwatch GPS Monitor', 'buyer': 'João P.', 'value': 'R\$ 499,90', 'status': 'Entregue', 'date': '29/04/2024'},
      {'id': '#PED-001230', 'product': 'Tênis Run Pro', 'buyer': 'Lucia F.', 'value': 'R\$ 289,00', 'status': 'Cancelado', 'date': '28/04/2024'},
      {'id': '#PED-001229', 'product': 'Cadeira Office Executive', 'buyer': 'Roberto K.', 'value': 'R\$ 1.299,00', 'status': 'Em trânsito', 'date': '28/04/2024'},
      {'id': '#PED-001228', 'product': 'Smartphone 128GB Câmera Tripla', 'buyer': 'Pedro L.', 'value': 'R\$ 1.299,00', 'status': 'Aguardando', 'date': '27/04/2024'},
    ];
    final item = items[index];
    final Color sc = item['status'] == 'Entregue' ? AppColors.statusApproved
      : item['status'] == 'Em trânsito' ? AppColors.statusActive
      : item['status'] == 'Aguardando' ? AppColors.statusAnalysis
      : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item['id']!, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text('• ${item['date']}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400)),
                  ],
                ),
                Text(item['product']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600)),
                Text('Comprador: ${item['buyer']}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400)),
              ],
            ),
          ),
          Text(item['value']!, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grey900)),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: sc.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Text(item['status']!, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: sc)),
          ),
        ],
      ),
    );
  }
}
