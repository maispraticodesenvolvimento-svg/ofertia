import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class BuyerAccountScreen extends StatelessWidget {
  const BuyerAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 960;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text('CR', style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Carlos Roberto', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('carlos@email.com', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Text('Comprador', style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Stats
          Row(
            children: [
              _StatBox('12', 'Pedidos'),
              const SizedBox(width: 12),
              _StatBox('5', 'Favoritos'),
              const SizedBox(width: 12),
              _StatBox('R\$ 4.230', 'Total gasto'),
            ],
          ),
          const SizedBox(height: 20),
          // Menu
          _AccountSection('Minha conta', [
            _AccountMenuItem(Icons.person_outline, 'Dados pessoais'),
            _AccountMenuItem(Icons.location_on_outlined, 'Endereços'),
            _AccountMenuItem(Icons.payment_outlined, 'Métodos de pagamento'),
            _AccountMenuItem(Icons.lock_outline, 'Segurança e privacidade'),
          ]),
          const SizedBox(height: 12),
          _AccountSection('Compras', [
            _AccountMenuItem(Icons.shopping_bag_outlined, 'Meus pedidos', onTap: () => context.go('/buyer/orders')),
            _AccountMenuItem(Icons.favorite_outline, 'Lista de desejos'),
            _AccountMenuItem(Icons.star_outline, 'Avaliações'),
          ]),
          const SizedBox(height: 12),
          _AccountSection('Suporte', [
            _AccountMenuItem(Icons.help_outline, 'Central de ajuda'),
            _AccountMenuItem(Icons.chat_outlined, 'Fale conosco'),
            _AccountMenuItem(Icons.logout, 'Sair', color: AppColors.error),
          ]),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
          ],
        ),
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _AccountSection(this.title, this.items);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grey500)),
          ),
          ...items,
        ],
      ),
    );
  }
}

class _AccountMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _AccountMenuItem(this.icon, this.label, {this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.grey800;
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.grey100))),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.grey500),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14, color: c))),
            Icon(Icons.chevron_right, size: 18, color: color ?? AppColors.grey300),
          ],
        ),
      ),
    );
  }
}
