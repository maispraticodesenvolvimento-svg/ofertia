import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/app_theme.dart';
import 'notifications_panel.dart';

class BuyerTopBar extends StatefulWidget {
  const BuyerTopBar({super.key});

  @override
  State<BuyerTopBar> createState() => _BuyerTopBarState();
}

class _BuyerTopBarState extends State<BuyerTopBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String value) {
    final query = value.trim();
    context.go(query.isEmpty
        ? '/buyer/products'
        : '/buyer/products?q=${Uri.encodeQueryComponent(query)}');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SessionService.instance,
      builder: (context, _) {
        final session = SessionService.instance;
        final greeting = session.displayName;
        final isAuth = session.isAuthenticated;

        return Container(
          height: 64,
          color: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              // Logo
              Text('Ofertia',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 20),
              // Search bar
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(6)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.search,
                          onSubmitted: _search,
                          decoration: InputDecoration(
                            hintText: 'O que você está procurando?',
                            hintStyle: GoogleFonts.inter(color: AppColors.grey400, fontSize: 13),
                            prefixIcon: const Icon(Icons.search, color: AppColors.grey400, size: 18),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: AppColors.primaryLight,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
                      child: InkWell(
                        onTap: () => _search(_searchController.text),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Center(
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text('Buscar', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Location (exibe SOMENTE se o usuário estiver logado e possuir endereço cadastrado)
              if (session.formattedAddress != null && session.formattedAddress!.isNotEmpty) ...[
                InkWell(
                  onTap: () => context.go('/buyer/account'),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Enviar para', style: GoogleFonts.inter(color: Colors.white70, fontSize: 10)),
                            Text(session.formattedAddress!, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
              ],
              // Notifications
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                onPressed: () => NotificationsPanel.show(context),
              ),
              // Account / Visitante
              InkWell(
                onTap: () {
                  if (isAuth) {
                    context.go('/buyer/account');
                  } else {
                    final current = GoRouterState.of(context).uri.toString();
                    context.push('/login?redirect=${Uri.encodeComponent(current)}');
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(isAuth ? Icons.person_outline : Icons.account_circle_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAuth ? 'Olá, $greeting' : greeting,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          if (!isAuth)
                            Text('Entrar / Cadastrar', style: GoogleFonts.inter(color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Switch to admin
              OutlinedButton.icon(
                onPressed: () => context.go('/admin/dashboard'),
                icon: const Icon(Icons.admin_panel_settings_outlined, size: 14),
                label: Text('Admin', style: GoogleFonts.inter(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
