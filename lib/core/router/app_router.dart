import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_products_screen.dart';
import '../../features/admin/screens/admin_vendors_screen.dart';
import '../../features/admin/screens/admin_negotiations_screen.dart';
import '../../features/admin/screens/admin_orders_screen.dart';
import '../../features/admin/screens/admin_clients_screen.dart';
import '../../features/admin/screens/admin_reports_screen.dart';
import '../../features/admin/screens/admin_settings_screen.dart';
import '../../features/buyer/screens/buyer_home_screen.dart';
import '../../features/buyer/screens/buyer_product_detail_screen.dart';
import '../../features/buyer/screens/buyer_products_screen.dart';
import '../../features/buyer/screens/buyer_offers_screen.dart';
import '../../features/buyer/screens/buyer_orders_screen.dart';
import '../../features/buyer/screens/buyer_account_screen.dart';
import '../../features/root/screens/root_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/buyer/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => RootScreen(child: child),
      routes: [
        // Buyer routes
        GoRoute(
          path: '/buyer/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BuyerHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/buyer/products',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BuyerProductsScreen(),
          ),
        ),
        GoRoute(
          path: '/buyer/offers',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BuyerOffersScreen(),
          ),
        ),
        GoRoute(
          path: '/buyer/orders',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BuyerOrdersScreen(),
          ),
        ),
        GoRoute(
          path: '/buyer/account',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BuyerAccountScreen(),
          ),
        ),
        GoRoute(
          path: '/buyer/product/:id',
          pageBuilder: (context, state) => NoTransitionPage(
            child: BuyerProductDetailScreen(
              productId: state.pathParameters['id'] ?? '1',
            ),
          ),
        ),

        // Admin routes
        GoRoute(
          path: '/admin/dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AdminDashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/products',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AdminProductsScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/vendors',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AdminVendorsScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/negotiations',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AdminNegotiationsScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/orders',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AdminOrdersScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/clients',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AdminClientsScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/reports',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AdminReportsScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AdminSettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);
