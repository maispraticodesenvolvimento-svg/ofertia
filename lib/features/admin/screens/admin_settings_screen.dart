import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Configurações', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
          Text('Ajuste as preferências da plataforma.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
          const SizedBox(height: 24),
          _SettingsSection('Geral', [
            _SettingItem('Nome da plataforma', 'Ofertia', Icons.store_outlined),
            _SettingItem('URL da plataforma', 'www.sistemarocha.com.br', Icons.link_outlined),
            _SettingItem('Email de contato', 'contato@sistemarocha.com.br', Icons.email_outlined),
          ]),
          const SizedBox(height: 16),
          _SettingsSection('Pagamentos', [
            _SettingItem('Taxa da plataforma', '5% por venda', Icons.percent),
            _SettingItem('Métodos aceitos', 'PIX, Cartão, Boleto', Icons.payment_outlined),
            _SettingItem('Prazo de repasse', '14 dias úteis', Icons.schedule_outlined),
          ]),
          const SizedBox(height: 16),
          _SettingsSection('Notificações', [
            _SettingToggle('Notificar novos pedidos'),
            _SettingToggle('Notificar novas negociações', value: false),
            _SettingToggle('Resumo diário por email'),
          ]),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grey900)),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SettingItem(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.grey100))),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.grey500),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey600)),
              Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grey900)),
            ],
          )),
          const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _SettingToggle extends StatefulWidget {
  final String label;
  final bool value;

  const _SettingToggle(this.label, {this.value = true});

  @override
  State<_SettingToggle> createState() => _SettingToggleState();
}

class _SettingToggleState extends State<_SettingToggle> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.grey100))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey800)),
          Switch(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
