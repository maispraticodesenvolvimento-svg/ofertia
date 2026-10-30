import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isWide = MediaQuery.of(context).size.width > 960;

    return Container(
      width: isWide ? 220 : double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ofertia',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Admin',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SidebarItem(
                  icon: Icons.home_outlined,
                  label: 'Painel administrativo',
                  route: '/admin/dashboard',
                  isActive: location.contains('/admin/dashboard'),
                ),
                _SidebarItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Gerenciar produtos',
                  route: '/admin/products',
                  isActive: location.contains('/admin/products'),
                ),

                _SidebarItem(
                  icon: Icons.handshake_outlined,
                  label: 'Negociações',
                  route: '/admin/negotiations',
                  isActive: location.contains('/admin/negotiations'),
                ),
                _SidebarItem(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Pedidos',
                  route: '/admin/orders',
                  isActive: location.contains('/admin/orders'),
                ),
                _SidebarItem(
                  icon: Icons.people_outline,
                  label: 'Clientes',
                  route: '/admin/clients',
                  isActive: location.contains('/admin/clients'),
                ),
                _SidebarItem(
                  icon: Icons.bar_chart_outlined,
                  label: 'Relatórios',
                  route: '/admin/reports',
                  isActive: location.contains('/admin/reports'),
                ),
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  label: 'Configurações',
                  route: '/admin/settings',
                  isActive: location.contains('/admin/settings'),
                ),
              ],
            ),
          ),
          // Switch to buyer view
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () => context.go('/buyer/home'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.bar_chart, color: AppColors.primaryLight, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mais crescimento',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text('para todos',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text('Uma plataforma segura, justa e feita para grandes oportunidades.',
                            style: GoogleFonts.inter(
                              color: AppColors.sidebarText.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.sidebarActive : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon,
              color: isActive ? Colors.white : AppColors.sidebarIcon,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(label,
              style: GoogleFonts.inter(
                color: isActive ? Colors.white : AppColors.sidebarText,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
