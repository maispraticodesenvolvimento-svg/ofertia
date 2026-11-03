import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AdminNegotiationsScreen extends StatelessWidget {
  const AdminNegotiationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Negociações', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
          Text('Gerencie as negociações ativas da plataforma.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
          const SizedBox(height: 24),
          ...List.generate(6, (i) => _NegotiationCard(index: i)),
        ],
      ),
    );
  }
}

class _NegotiationCard extends StatelessWidget {
  final int index;

  const _NegotiationCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'id': '#45872', 'buyer': 'Cliente #98432', 'vendor': 'Loja TechBR', 'product': 'Smartphone Delta X1', 'value': 'R\$ 1.750,00', 'status': 'Ativa'},
      {'id': '#45871', 'buyer': 'Maria S.', 'vendor': 'EletroMais', 'product': 'Fritadeira Air Fryer', 'value': 'R\$ 270,00', 'status': 'Concluída'},
      {'id': '#45870', 'buyer': 'João P.', 'vendor': 'Casa & Estilo', 'product': 'Cadeira Office', 'value': 'R\$ 1.100,00', 'status': 'Em análise'},
      {'id': '#45869', 'buyer': 'Ana R.', 'vendor': 'MundoTech', 'product': 'Smartwatch GPS', 'value': 'R\$ 450,00', 'status': 'Ativa'},
      {'id': '#45868', 'buyer': 'Carlos M.', 'vendor': 'Digital Center', 'product': 'Fone Bluetooth', 'value': 'R\$ 290,00', 'status': 'Concluída'},
      {'id': '#45867', 'buyer': 'Lucia F.', 'vendor': 'Loja ModalVive', 'product': 'Tênis Run Pro', 'value': 'R\$ 260,00', 'status': 'Cancelada'},
    ];
    final item = items[index];
    final Color statusColor = item['status'] == 'Ativa' ? AppColors.statusActive
      : item['status'] == 'Concluída' ? AppColors.statusApproved
      : item['status'] == 'Em análise' ? AppColors.statusAnalysis
      : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.handshake_outlined, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item['id']!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grey900)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      child: Text(item['status']!, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${item['buyer']} ↔ ${item['vendor']}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600)),
                Text(item['product']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
              ],
            ),
          ),
          Text(item['value']!, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(width: 16),
          IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 14), onPressed: () {}, color: AppColors.grey400),
        ],
      ),
    );
  }
}
