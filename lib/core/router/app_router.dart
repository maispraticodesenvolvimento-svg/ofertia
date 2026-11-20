import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../widgets/auth_guard.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/root/screens/root_screen.dart';

import '../../features/buyer/screens/buyer_home_screen.dart';
import '../../features/buyer/screens/buyer_products_screen.dart';
import '../../features/buyer/screens/buyer_product_detail_screen.dart';
import '../../features/buyer/screens/buyer_offers_screen.dart';
import '../../features/buyer/screens/buyer_orders_screen.dart';
import '../../features/buyer/screens/buyer_account_screen.dart';
import '../../features/buyer/screens/buyer_user_hub_screen.dart';
import '../../features/buyer/screens/buyer_checkout_confirmation_screen.dart';
import '../../features/buyer/screens/buyer_checkout_screen.dart';

import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_products_screen.dart';
import '../../features/admin/screens/admin_product_form_screen.dart';
import '../../features/admin/screens/admin_negotiations_screen.dart';
import '../../features/admin/screens/admin_orders_screen.dart';
import '../../features/admin/screens/admin_clients_screen.dart';
import '../../features/admin/screens/admin_vendors_screen.dart';
import '../../features/admin/screens/admin_categories_screen.dart';
import '../../features/admin/screens/admin_banners_screen.dart';
import '../../features/admin/screens/admin_reports_screen.dart';
import '../../features/admin/screens/admin_settings_screen.dart';

final GoRouter appRouter = GoRouter(
  // Usuário começa diretamente navegando pela loja sem obrigatoriedade de login
  initialLocation: '/buyer/home',
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => NoTransitionPage(
        child: LoginScreen(
          redirect: state.uri.queryParameters['redirect'],
        ),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => RootScreen(child: child),
      routes: [
        // =====================================================================
        // ROTAS PÚBLICAS DO COMPRADOR (Qualquer visitante pode acessar)
        // =====================================================================
        GoRoute(
          path: '/buyer/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BuyerHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/buyer/products',
          pageBuilder: (context, state) => NoTransitionPage(
            child: BuyerProductsScreen(
              initialCategory: state.uri.queryParameters['category'],
              initialQuery: state.uri.queryParameters['q'],
            ),
          ),
        ),
        GoRoute(
          path: '/buyer/offers',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BuyerOffersScreen(),
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

        // =====================================================================
        // ROTAS PRIVADAS DO COMPRADOR (Exigem autenticação)
        // =====================================================================
        GoRoute(
          path: '/buyer/orders',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AuthGuard(
              title: 'Seus Pedidos',
              message: 'Faça login para acompanhar suas compras, entregas e histórico de pedidos.',
              icon: Icons.shopping_bag_outlined,
              child: BuyerOrdersScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/buyer/account',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AuthGuard(
              title: 'Minha Conta',
              message: 'Conecte-se para visualizar seus dados, endereços e preferências.',
              icon: Icons.person_outline_rounded,
              child: BuyerAccountScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/buyer/hub',
          pageBuilder: (context, state) {
            final tabParam = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
            return NoTransitionPage(
              child: AuthGuard(
                title: 'Painel do Usuário',
                message: 'Conecte-se para gerenciar suas compras, vendas, ofertas e faturamento.',
                icon: Icons.dashboard_outlined,
                child: BuyerUserHubScreen(initialTab: tabParam),
              ),
            );
          },
        ),
        GoRoute(
          path: '/buyer/checkout/confirm',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final product = extra['product'] as Product;
            final offer = extra['offer'] as Map<String, dynamic>;
            return BuyerCheckoutConfirmationScreen(product: product, offer: offer);
          },
        ),
        GoRoute(
          path: '/buyer/checkout/placeholder',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return BuyerCheckoutScreen(data: extra);
          },
        ),

        // =====================================================================
        // ROTAS DO PAINEL ADMINISTRATIVO (Exigem login de Admin)
        // =====================================================================
        GoRoute(
          path: '/admin/dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AuthGuard(
              adminOnly: true,
              child: AdminDashboardScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/admin/products',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AuthGuard(
              adminOnly: true,
              child: AdminProductsScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/admin/products/new',
          builder: (context, state) => const AuthGuard(
            adminOnly: true,
            child: AdminProductFormScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/products/:id/edit',
          builder: (context, state) => AuthGuard(
            adminOnly: true,
            child: AdminProductFormScreen(
              product: state.extra is Product ? state.extra as Product : null,
            ),
          ),
        ),
        GoRoute(
          path: '/admin/negotiations',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AuthGuard(
              adminOnly: true,
              child: AdminNegotiationsScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/admin/orders',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AuthGuard(
              adminOnly: true,
              child: AdminOrdersScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/admin/clients',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AuthGuard(
              adminOnly: true,
              child: AdminClientsScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/admin/vendors',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AuthGuard(
              adminOnly: true,
              child: AdminVendorsScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/admin/categories',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AuthGuard(
              adminOnly: true,
              child: AdminCategoriesScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/admin/banners',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AuthGuard(
              adminOnly: true,
              child: AdminBannersScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/admin/reports',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AuthGuard(
              adminOnly: true,
              child: AdminReportsScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/admin/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AuthGuard(
              adminOnly: true,
              child: AdminSettingsScreen(),
            ),
          ),
        ),
      ],
    ),
  ],
);
