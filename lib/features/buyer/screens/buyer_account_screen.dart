import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/complete_profile_dialog.dart';

class BuyerAccountScreen extends StatefulWidget {
  const BuyerAccountScreen({super.key});

  @override
  State<BuyerAccountScreen> createState() => _BuyerAccountScreenState();
}

class _BuyerAccountScreenState extends State<BuyerAccountScreen> {
  @override
  Widget build(BuildContext context) {
    final session = SessionService.instance;
    final user = session.currentUser ?? const <String, dynamic>{};
    final email = user['email']?.toString() ?? 'E-mail não disponível';
    final name = user['name']?.toString() ?? session.displayName;
    final isComplete = session.isProfileComplete;
    final addressText = session.formattedAddress;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Minha conta',
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900),
        ),
        const SizedBox(height: 18),

        // ── Card Superior com Usuário e Status de Cadastro ──
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x15000000), blurRadius: 10, offset: Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19)),
                        Text(email, style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isComplete
                                ? const Color(0xFF00A650).withValues(alpha: 0.3)
                                : const Color(0xFFFFB703).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isComplete ? '✓ Cadastro Completo' : '⚠ Cadastro Incompleto',
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await ApiClient().logout();
                        SessionService.instance.clear();
                        if (context.mounted) context.go('/login');
                      } catch (_) {}
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Sair'),
                  ),
                ],
              ),
              if (addressText != null) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Endereço: $addressText',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Painel de Ações Rápidas (Atalhos do Usuário) ──
        Text(
          'Painel do Usuário & Ofertas',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.grey900),
        ),
        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 3 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _hubActionCard(
              title: 'Minhas Ofertas',
              subtitle: 'Compras e Vendas ativas',
              icon: Icons.local_offer_outlined,
              color: const Color(0xFF3483FA),
              onTap: () => context.go('/buyer/hub?tab=0'),
            ),
            _hubActionCard(
              title: 'Ver Compras',
              subtitle: 'Histórico de pedidos',
              icon: Icons.shopping_bag_outlined,
              color: const Color(0xFF00A650),
              onTap: () => context.go('/buyer/hub?tab=1'),
            ),
            _hubActionCard(
              title: 'Ver Vendas',
              subtitle: 'Pedidos recebidos',
              icon: Icons.storefront_outlined,
              color: const Color(0xFF8338EC),
              onTap: () => context.go('/buyer/hub?tab=2'),
            ),
            _hubActionCard(
              title: 'Faturamento & Saque',
              subtitle: 'Saldo e recebimentos PIX',
              icon: Icons.payments_outlined,
              color: const Color(0xFFFF9E00),
              onTap: () => context.go('/buyer/hub?tab=3'),
            ),
            _hubActionCard(
              title: 'Gráficos & Métricas',
              subtitle: 'Desempenho de vendas',
              icon: Icons.bar_chart_rounded,
              color: const Color(0xFFFF006E),
              onTap: () => context.go('/buyer/hub?tab=4'),
            ),
            _hubActionCard(
              title: 'Dados e Endereço',
              subtitle: isComplete ? 'Editar cadastro' : 'Completar agora',
              icon: Icons.edit_note_rounded,
              color: const Color(0xFF3A86FF),
              onTap: () async {
                await CompleteProfileDialog.ensureComplete(context);
                setState(() {});
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _hubActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grey900)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
