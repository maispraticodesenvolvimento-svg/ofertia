import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class BuyerOrdersScreen extends StatelessWidget {
  const BuyerOrdersScreen({super.key});

  static const _orders = [
    {'id': '#PED-001234', 'product': 'Smartphone Delta X1 256GB', 'emoji': '📱', 'value': 'R\$ 1.899,90', 'date': '30/04/2024', 'status': 'Entregue'},
    {'id': '#PED-001233', 'product': 'Fone Bluetooth ANC Pro', 'emoji': '🎧', 'value': 'R\$ 349,90', 'date': '28/04/2024', 'status': 'Em trânsito'},
    {'id': '#PED-001232', 'product': 'Fritadeira Air Fryer 4L', 'emoji': '🍳', 'value': 'R\$ 289,90', 'date': '25/04/2024', 'status': 'Entregue'},
    {'id': '#PED-001231', 'product': 'Smartwatch GPS Monitor', 'emoji': '⌚', 'value': 'R\$ 499,90', 'date': '20/04/2024', 'status': 'Entregue'},
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 960;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Meus pedidos', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.grey900)),
          const SizedBox(height: 4),
          Text('Acompanhe seus pedidos', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
          const SizedBox(height: 20),
          ..._orders.map((o) {
            final Color sc = o['status'] == 'Entregue' ? AppColors.statusApproved
              : o['status'] == 'Em trânsito' ? AppColors.statusActive
              : AppColors.statusAnalysis;

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
                    width: 52, height: 52,
                    decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(o['emoji'] as String, style: const TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(o['id'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grey800)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(color: sc.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                              child: Text(o['status'] as String, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: sc)),
                            ),
                          ],
                        ),
                        Text(o['product'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(o['date'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400)),
                            Text(o['value'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grey900)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
