import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';

// Formas de pagamento pré-definidas que o admin pode ativar/desativar
const _kDefaultMethods = [
  {'id': 'pix', 'name': 'Pix', 'icon': 'pix', 'subtitle': 'Transferência instantânea'},
  {'id': 'credit_card', 'name': 'Cartão de Crédito', 'icon': 'credit_card', 'subtitle': 'Pague em até 12x'},
  {'id': 'debit_card', 'name': 'Cartão de Débito', 'icon': 'debit_card', 'subtitle': 'Débito em conta corrente'},
  {'id': 'boleto', 'name': 'Boleto Bancário', 'icon': 'boleto', 'subtitle': 'Vence em até 3 dias'},
  {'id': 'bank_transfer', 'name': 'Transferência Bancária', 'icon': 'bank', 'subtitle': 'TED / DOC'},
  {'id': 'mercado_pago', 'name': 'Mercado Pago', 'icon': 'wallet', 'subtitle': 'Parcelado com proteção'},
  {'id': 'cash', 'name': 'Dinheiro (Presencial)', 'icon': 'cash', 'subtitle': 'Apenas para retirada'},
];

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _api = ApiClient();
  late Future<Map<String, dynamic>> _settings;
  final _controllers = <String, TextEditingController>{};
  final _notifications = <String, bool>{};
  // Set of active payment method ids
  final Set<String> _activeMethods = {};
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _settings = _api.getAdminSettings();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initialize(Map<String, dynamic> values) {
    if (_loaded) return;
    final general = values['general'] as Map? ?? {};
    final payments = values['payments'] as Map? ?? {};
    final notifications = values['notifications'] as Map? ?? {};
    final savedMethods = values['paymentMethods'];

    for (final key in ['platformName', 'platformUrl', 'contactEmail']) {
      _controllers[key] = TextEditingController(text: '${general[key] ?? ''}');
    }
    for (final key in ['feePercent', 'payoutDays']) {
      _controllers[key] = TextEditingController(text: '${payments[key] ?? ''}');
    }
    for (final key in ['newOrders', 'newNegotiations', 'dailySummary']) {
      _notifications[key] = notifications[key] == true;
    }

    // Load saved payment methods
    _activeMethods.clear();
    if (savedMethods is List && savedMethods.isNotEmpty) {
      for (final m in savedMethods) {
        if (m is Map && m['id'] != null) {
          _activeMethods.add(m['id'].toString());
        }
      }
    } else {
      // Default: PIX and credit card enabled
      _activeMethods.addAll(['pix', 'credit_card']);
    }

    _loaded = true;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final selectedMethods = _kDefaultMethods
          .where((m) => _activeMethods.contains(m['id']))
          .toList();

      await _api.saveAdminSettings({
        'general': {
          'platformName': _controllers['platformName']!.text.trim(),
          'platformUrl': _controllers['platformUrl']!.text.trim(),
          'contactEmail': _controllers['contactEmail']!.text.trim(),
        },
        'payments': {
          'feePercent': double.tryParse(_controllers['feePercent']!.text.replaceAll(',', '.')),
          'payoutDays': int.tryParse(_controllers['payoutDays']!.text),
        },
        'paymentMethods': selectedMethods,
        'notifications': _notifications,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configurações salvas com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
        future: _settings,
        builder: (context, snapshot) {
          if (snapshot.hasData) _initialize(snapshot.data!);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));

          final wide = MediaQuery.sizeOf(context).width > 900;

          return ListView(
            padding: EdgeInsets.all(wide ? 28 : 16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Configurações',
                            style: GoogleFonts.inter(
                                fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
                        Text('Configurações gerais da plataforma.',
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Salvando…' : 'Salvar configurações'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Geral ─────────────────────────────────────────────────────
              _section(
                icon: Icons.settings_outlined,
                title: 'Geral',
                children: [
                  _field('Nome da plataforma', 'platformName'),
                  _field('URL da plataforma', 'platformUrl'),
                  _field('E-mail de contato', 'contactEmail'),
                ],
              ),
              const SizedBox(height: 16),

              // ── Formas de Pagamento ───────────────────────────────────────
              _section(
                icon: Icons.payments_outlined,
                title: 'Formas de Pagamento Aceitas',
                subtitle: 'Selecione as formas de pagamento que sua loja aceita. Elas serão exibidas na página do produto.',
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _kDefaultMethods.map((method) {
                        final id = method['id']!;
                        final isActive = _activeMethods.contains(id);

                        return GestureDetector(
                          onTap: () => setState(() {
                            if (isActive) {
                              _activeMethods.remove(id);
                            } else {
                              _activeMethods.add(id);
                            }
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isActive ? AppColors.primary : AppColors.grey300,
                                width: isActive ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _methodIcon(id),
                                  color: isActive ? AppColors.primary : AppColors.grey500,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      method['name']!,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isActive ? AppColors.primary : AppColors.grey800,
                                      ),
                                    ),
                                    Text(
                                      method['subtitle']!,
                                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isActive ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                                  color: isActive ? AppColors.primary : AppColors.grey400,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Configurações Financeiras ─────────────────────────────────
              _section(
                icon: Icons.percent_rounded,
                title: 'Financeiro',
                children: [
                  _field('Taxa da plataforma (%)', 'feePercent', numeric: true),
                  _field('Prazo de repasse (dias)', 'payoutDays', numeric: true),
                ],
              ),
              const SizedBox(height: 16),

              // ── Notificações ──────────────────────────────────────────────
              _section(
                icon: Icons.notifications_outlined,
                title: 'Notificações',
                children: _notifications.keys
                    .map(
                      (key) => SwitchListTile(
                        title: Text(_notificationLabel(key),
                            style: GoogleFonts.inter(fontSize: 14)),
                        value: _notifications[key] ?? false,
                        onChanged: (value) => setState(() => _notifications[key] = value),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      );

  IconData _methodIcon(String id) => switch (id) {
        'pix' => Icons.qr_code_2_rounded,
        'credit_card' => Icons.credit_card_rounded,
        'debit_card' => Icons.credit_card_outlined,
        'boleto' => Icons.receipt_long_rounded,
        'bank_transfer' => Icons.account_balance_rounded,
        'mercado_pago' => Icons.wallet_rounded,
        'cash' => Icons.payments_rounded,
        _ => Icons.payment_rounded,
      };

  String _notificationLabel(String key) => switch (key) {
        'newOrders' => 'Notificar novos pedidos',
        'newNegotiations' => 'Notificar novas negociações',
        _ => 'Enviar resumo diário por e-mail',
      };

  Widget _field(String label, String key, {bool numeric = false}) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: TextField(
          controller: _controllers[key],
          keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        ),
      );

  Widget _section({
    required IconData icon,
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: GoogleFonts.inter(
                                fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grey900)),
                        if (subtitle != null)
                          Text(subtitle,
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 4),
            ...children,
            const SizedBox(height: 4),
          ],
        ),
      );
}
