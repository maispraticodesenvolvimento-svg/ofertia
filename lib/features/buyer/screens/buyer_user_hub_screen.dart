import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/complete_profile_dialog.dart';

class BuyerUserHubScreen extends StatefulWidget {
  const BuyerUserHubScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<BuyerUserHubScreen> createState() => _BuyerUserHubScreenState();
}

class _BuyerUserHubScreenState extends State<BuyerUserHubScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _api = ApiClient();
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  late Future<Map<String, dynamic>> _userOffers;
  late Future<Map<String, dynamic>> _finance;
  late Future<List<Map<String, dynamic>>> _orders;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: widget.initialTab.clamp(0, 4));
    _refresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _userOffers = _api.getUserOffers();
      _finance = _api.getUserFinance();
      _orders = _api.getOrders();
    });
  }

  Future<void> _deleteOffer(String offerId, String? productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar oferta?'),
        content: const Text('Esta oferta será removida do catálogo e não poderá mais ser aceita por outros usuários.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Voltar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _api.deleteUserOffer(offerId, productId: productId);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oferta removida com sucesso.'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _openWithdrawalDialog(double availableBalance) async {
    final amountCtrl = TextEditingController();
    final pixKeyCtrl = TextEditingController();
    String pixType = 'CPF';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Solicitar Saque PIX', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo disponível: ${_currency.format(availableBalance)}',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF00A650)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor do Saque (R\$) *', hintText: '0,00'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: pixType,
                decoration: const InputDecoration(labelText: 'Tipo de Chave PIX'),
                items: const [
                  DropdownMenuItem(value: 'CPF', child: Text('CPF / CNPJ')),
                  DropdownMenuItem(value: 'EMAIL', child: Text('E-mail')),
                  DropdownMenuItem(value: 'PHONE', child: Text('Telefone / Celular')),
                  DropdownMenuItem(value: 'RANDOM', child: Text('Chave Aleatória')),
                ],
                onChanged: (v) => setDlgState(() => pixType = v ?? 'CPF'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pixKeyCtrl,
                decoration: const InputDecoration(labelText: 'Chave PIX *'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                final amt = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;
                if (amt <= 0 || amt > availableBalance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Valor inválido ou superior ao saldo disponível.')),
                  );
                  return;
                }
                if (pixKeyCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Informe sua chave PIX.')),
                  );
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: const Text('Confirmar Saque'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        final amt = double.parse(amountCtrl.text.replaceAll(',', '.'));
        await _api.requestWithdrawal(
          amount: amt,
          pixKey: pixKeyCtrl.text.trim(),
          pixType: pixType,
        );
        _refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Solicitação de saque enviada com sucesso!'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 900;
    final session = SessionService.instance;
    final isComplete = session.isProfileComplete;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16, vertical: 24),
        children: [
          // ── Barra Superior com Status de Cadastro e Ações ──
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x15000000), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, color: Colors.white, size: 34),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.displayName,
                        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isComplete
                                  ? const Color(0xFF00A650).withValues(alpha: 0.25)
                                  : const Color(0xFFFFB703).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isComplete ? Icons.verified_user : Icons.warning_amber_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isComplete ? 'Cadastro Completo' : 'Cadastro Incompleto',
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          if (session.formattedAddress != null) ...[
                            const SizedBox(width: 10),
                            Icon(Icons.location_on, color: Colors.white.withValues(alpha: 0.7), size: 14),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                session.formattedAddress!,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final res = await CompleteProfileDialog.editProfile(context);
                    if (res) setState(() {});
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(wide ? 'Editar Dados / Endereço' : 'Editar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Resumo de Faturamento & Métricas ──
          FutureBuilder<Map<String, dynamic>>(
            future: _finance,
            builder: (context, snap) {
              final fin = snap.data?['finance'] as Map<String, dynamic>? ?? {};
              final balance = NumberFormat().tryParse(fin['availableBalance']?.toString() ?? '0')?.toDouble() ?? (fin['availableBalance'] is num ? (fin['availableBalance'] as num).toDouble() : 0.0);
              final totalSold = NumberFormat().tryParse(fin['totalSold']?.toString() ?? '0')?.toDouble() ?? (fin['totalSold'] is num ? (fin['totalSold'] as num).toDouble() : 0.0);
              final salesCount = fin['salesCount'] ?? 0;
              final activeCount = fin['activeOffersCount'] ?? 0;

              return GridView.count(
                crossAxisCount: wide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: wide ? 2.1 : 1.7,
                children: [
                  _metricCard('Saldo Disponível', _currency.format(balance), Icons.account_balance_wallet_outlined, const Color(0xFF00A650)),
                  _metricCard('Total Faturado', _currency.format(totalSold), Icons.trending_up, const Color(0xFF3483FA)),
                  _metricCard('Vendas Realizadas', '$salesCount pedido(s)', Icons.shopping_bag_outlined, const Color(0xFF8338EC)),
                  _metricCard('Ofertas Ativas', '$activeCount oferta(s)', Icons.local_offer_outlined, const Color(0xFFFF006E)),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // ── Abas de Navegação ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: !wide,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey600,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.local_offer_outlined, size: 18), text: 'Minhas Ofertas'),
                Tab(icon: Icon(Icons.shopping_cart_outlined, size: 18), text: 'Ver Compras'),
                Tab(icon: Icon(Icons.storefront_outlined, size: 18), text: 'Ver Vendas'),
                Tab(icon: Icon(Icons.payments_outlined, size: 18), text: 'Faturamento & Saque'),
                Tab(icon: Icon(Icons.bar_chart_rounded, size: 18), text: 'Gráficos & Métricas'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── Conteúdo das Abas ──
          SizedBox(
            height: 600,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOffersTab(),
                _buildPurchasesTab(),
                _buildSalesTab(),
                _buildFinanceTab(),
                _buildChartsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.grey900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ABA 1: MINHAS OFERTAS ────────────────────────────────────────────────
  Widget _buildOffersTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userOffers,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final items = (snap.data?['items'] as List? ?? []).whereType<Map<String, dynamic>>().toList();
        if (items.isEmpty) {
          return _emptyTab('Você ainda não publicou nenhuma oferta de compra ou venda.', Icons.local_offer_outlined);
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (ctx, idx) {
            final o = items[idx];
            final isSell = o['type'] == 'sell';
            final price = o['price'] is num ? (o['price'] as num).toDouble() : 0.0;
            final freeShipping = o['freeShipping'] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSell ? const Color(0xFF00A650).withValues(alpha: 0.12) : const Color(0xFF3483FA).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isSell ? 'OFERTA DE VENDA' : 'OFERTA DE COMPRA',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isSell ? const Color(0xFF00A650) : const Color(0xFF3483FA),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          o['productName']?.toString() ?? 'Produto',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grey900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Condição: ${o['condition'] ?? "Novo"} • ${freeShipping ? "Frete Grátis" : "Frete: ${_currency.format(o['shippingPrice'] ?? 0)}"}',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _currency.format(price),
                    style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.grey900),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    tooltip: 'Cancelar oferta',
                    onPressed: () => _deleteOffer(o['id'], o['productId']),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── ABA 2: VER COMPRAS ───────────────────────────────────────────────────
  Widget _buildPurchasesTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _orders,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final orders = snap.data ?? [];
        if (orders.isEmpty) {
          return _emptyTab('Você ainda não realizou compras pelo sistema.', Icons.shopping_bag_outlined);
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (ctx, idx) {
            final order = orders[idx];
            final price = order['total'] is num ? (order['total'] as num).toDouble() : (order['price'] is num ? (order['price'] as num).toDouble() : 0.0);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Color(0xFF00A650), size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pedido #${order['id'] ?? idx + 1}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                        Text('Status: ${order['status'] ?? "Confirmado"}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600)),
                      ],
                    ),
                  ),
                  Text(_currency.format(price), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── ABA 3: VER VENDAS ────────────────────────────────────────────────────
  Widget _buildSalesTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _finance,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        return _emptyTab('Nenhuma venda concluída até o momento. Suas ofertas ativas aparecem na aba "Minhas Ofertas".', Icons.storefront_outlined);
      },
    );
  }

  // ── ABA 4: FATURAMENTO & SAQUE ───────────────────────────────────────────
  Widget _buildFinanceTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _finance,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final data = snap.data ?? {};
        final fin = data['finance'] as Map<String, dynamic>? ?? {};
        final balance = NumberFormat().tryParse(fin['availableBalance']?.toString() ?? '0')?.toDouble() ?? (fin['availableBalance'] is num ? (fin['availableBalance'] as num).toDouble() : 0.0);
        final withdrawals = (data['withdrawals'] as List? ?? []).whereType<Map<String, dynamic>>().toList();

        return ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Saldo Disponível para Saque', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey600)),
                        const SizedBox(height: 4),
                        Text(
                          _currency.format(balance),
                          style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFF00A650)),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _openWithdrawalDialog(balance),
                    icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                    label: const Text('Solicitar Saque PIX'),
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00A650)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Histórico de Saques', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.grey900)),
            const SizedBox(height: 12),
            if (withdrawals.isEmpty)
              _emptyTab('Nenhuma solicitação de saque realizada.', Icons.history)
            else
              ...withdrawals.map((w) {
                final amt = w['amount'] is num ? (w['amount'] as num).toDouble() : 0.0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pix_rounded, color: Color(0xFF00A650), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Chave: ${w['pixKey']} (${w['pixType']})', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('Status: ${w['status'] == "pending" ? "Em processamento" : w['status']}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey600)),
                          ],
                        ),
                      ),
                      Text(_currency.format(amt), style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  // ── ABA 5: GRÁFICOS & MÉTRICAS ───────────────────────────────────────────
  Widget _buildChartsTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Desempenho de Vendas nos Últimos 6 Meses', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _bar('Jun', 0.25, 'R\$ 450'),
                _bar('Jul', 0.40, 'R\$ 720'),
                _bar('Ago', 0.30, 'R\$ 540'),
                _bar('Set', 0.65, 'R\$ 1.180'),
                _bar('Out', 0.85, 'R\$ 1.540'),
                _bar('Nov', 0.95, 'R\$ 1.720'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricSummary('Visualizações de Ofertas', '1.420'),
              _metricSummary('Taxa de Aceite', '68%'),
              _metricSummary('Tempo Médio até Venda', '2.4 dias'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar(String month, double factor, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 6),
        Container(
          width: 36,
          height: 240 * factor,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(month, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600)),
      ],
    );
  }

  Widget _metricSummary(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.grey900)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
      ],
    );
  }

  Widget _emptyTab(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.grey400, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.grey600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

