import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AdminClientsScreen extends StatelessWidget {
  const AdminClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clientes', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
          Text('Gerencie os clientes cadastrados na plataforma.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
          const SizedBox(height: 24),
          ...['Carlos M.', 'Ana R.', 'Maria S.', 'João P.', 'Lucia F.', 'Roberto K.'].asMap().entries.map((e) => _ClientCard(name: e.value, index: e.key)),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final String name;
  final int index;
  const _ClientCard({required this.name, required this.index});

  @override
  Widget build(BuildContext context) {
    final orders = [12, 5, 28, 3, 17, 9][index];
    final spent = ['R\$ 4.230,00', 'R\$ 890,00', 'R\$ 12.400,00', 'R\$ 320,00', 'R\$ 7.800,00', 'R\$ 2.100,00'][index];

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
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primarySurface,
            child: Text(name[0], style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.grey900)),
                Text('$orders pedidos • Total gasto: $spent', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primaryBorder),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: Size.zero,
            ),
            child: Text('Ver perfil', style: GoogleFonts.inter(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
