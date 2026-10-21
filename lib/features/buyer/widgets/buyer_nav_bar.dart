import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class BuyerNavBar extends StatelessWidget {
  const BuyerNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 24),
          _NavItem('Início', Icons.home_outlined, '/buyer/home', location.contains('/buyer/home')),
          _NavItem('Produtos', Icons.inventory_2_outlined, '/buyer/products', location.contains('/buyer/products')),
          _NavItem('Ofertas', Icons.local_offer_outlined, '/buyer/offers', location.contains('/buyer/offers')),
          _NavItem('Meus pedidos', Icons.shopping_bag_outlined, '/buyer/orders', location.contains('/buyer/orders')),
          _NavItem('Minha conta', Icons.person_outline, '/buyer/account', location.contains('/buyer/account')),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final bool isActive;

  const _NavItem(this.label, this.icon, this.route, this.isActive);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: isActive
            ? const Border(bottom: BorderSide(color: AppColors.primary, width: 2))
            : null,
        ),
        child: Row(
          children: [
            Icon(icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.grey600,
            ),
            const SizedBox(width: 6),
            Text(label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isActive ? AppColors.primary : AppColors.grey600,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
