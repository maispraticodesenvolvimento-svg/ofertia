import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../admin/widgets/admin_sidebar.dart';
import '../../admin/widgets/admin_top_bar.dart';
import '../../buyer/widgets/buyer_nav_bar.dart';
import '../../buyer/widgets/buyer_top_bar.dart';
import '../../buyer/widgets/buyer_mobile_bottom_bar.dart';
import '../../buyer/widgets/notifications_panel.dart';

class RootScreen extends StatelessWidget {
  final Widget child;

  const RootScreen({super.key, required this.child});

  bool _isAdminRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return location.startsWith('/admin');
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _isAdminRoute(context);
    final isWide = MediaQuery.of(context).size.width > 960;

    if (isAdmin) {
      return _AdminLayout(child: child, isWide: isWide);
    } else {
      return _BuyerLayout(child: child, isWide: isWide);
    }
  }
}

class _AdminLayout extends StatelessWidget {
  final Widget child;
  final bool isWide;

  const _AdminLayout({required this.child, required this.isWide});

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            const AdminSidebar(),
            Expanded(
              child: Column(
                children: [
                  const AdminTopBar(),
                  Expanded(
                    child: child,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile admin
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _MobileAdminAppBar(),
        drawer: const Drawer(child: AdminSidebar()),
        body: child,
        bottomNavigationBar: _AdminMobileBottomBar(),
      );
    }
  }
}

class _MobileAdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ofertia',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => NotificationsPanel.show(context),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('3',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Text('AM',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AdminMobileBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int selectedIndex = 0;
    if (location.contains('/admin/dashboard')) selectedIndex = 0;
    if (location.contains('/admin/products')) selectedIndex = 1;

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey500,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Produtos'),
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Usuários'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Mais'),
      ],
      onTap: (i) {
        final routes = ['/admin/dashboard', '/admin/products', '/admin/clients', '/admin/orders'];
        context.go(routes[i]);
      },
    );
  }
}

class _BuyerLayout extends StatelessWidget {
  final Widget child;
  final bool isWide;

  const _BuyerLayout({required this.child, required this.isWide});

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            const BuyerTopBar(),
            const BuyerNavBar(),
            Expanded(child: child),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _MobileBuyerAppBar(),
            Expanded(child: child),
          ],
        ),
        bottomNavigationBar: const BuyerMobileBottomBar(),
      );
    }
  }
}

class _MobileBuyerAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ofertia',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                      Text(
                      'Olá, usuário',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      'Boas compras, um dia incrível para você!',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => NotificationsPanel.show(context),
                  child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'O que você está procurando?',
                  hintStyle: GoogleFonts.inter(color: AppColors.grey500, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey500),
                  suffixIcon: const Icon(Icons.qr_code_scanner, color: AppColors.grey500),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
