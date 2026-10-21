import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class BuyerMobileBottomBar extends StatelessWidget {
  const BuyerMobileBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int idx = 0;
    if (location.contains('/buyer/home')) idx = 0;
    if (location.contains('/buyer/products')) idx = 1;
    if (location.contains('/buyer/offers')) idx = 2;
    if (location.contains('/buyer/account')) idx = 3;

    return BottomNavigationBar(
      currentIndex: idx,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey400,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        BottomNavigationBarItem(icon: Icon(Icons.local_offer_outlined), label: 'Ofertas'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
      ],
      onTap: (i) {
        final routes = ['/buyer/home', '/buyer/products', '/buyer/offers', '/buyer/account'];
        context.go(routes[i]);
      },
    );
  }
}
