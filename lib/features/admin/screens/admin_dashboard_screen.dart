import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 960;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Painel administrativo',
                    style: GoogleFonts.inter(
                      fontSize: isWide ? 26 : 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.grey900,
                    ),
                  ),
                  Text('Visão geral da sua plataforma em tempo real.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
              _DateFilter(),
            ],
          ),
          const SizedBox(height: 24),
          // Metrics
          isWide
            ? Row(
                children: [
                  Expanded(child: _MetricCard(icon: Icons.inventory_2_outlined, label: 'Produtos ativos', value: '152.430', change: '+12%', color: AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(icon: Icons.local_offer_outlined, label: 'Ofertas publicadas', value: '298.731', change: '+8%', color: AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(icon: Icons.people_outline, label: 'Vendedores', value: '12.548', change: '+15%', color: AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(icon: Icons.shopping_cart_outlined, label: 'Negociações abertas', value: '8.421', change: '+6%', color: AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(icon: Icons.access_time_outlined, label: 'Aprovações pendentes', value: '237', change: '+24%', color: AppColors.error, changeColor: AppColors.error)),
                ],
              )
            : GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _MetricCard(icon: Icons.inventory_2_outlined, label: 'Produtos ativos', value: '1.842', change: '+12%', color: AppColors.primary),
                  _MetricCard(icon: Icons.local_offer_outlined, label: 'Ofertas publicadas', value: '935', change: '+8%', color: AppColors.primary),
                  _MetricCard(icon: Icons.people_outline, label: 'Vendedores', value: '284', change: '+5%', color: AppColors.primary),
                  _MetricCard(icon: Icons.handshake_outlined, label: 'Negociações abertas', value: '127', change: '+18%', color: AppColors.primary),
                ],
              ),
          const SizedBox(height: 8),
          if (!isWide)
            _MetricCard(
              icon: Icons.description_outlined,
              label: 'Aprovações pendentes',
              value: '23',
              change: 'Urgente',
              color: AppColors.error,
              changeColor: AppColors.error,
              fullWidth: true,
            ),
          const SizedBox(height: 24),
          // Charts + approvals
          isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _SalesChart()),
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: _PendingApprovals()),
                ],
              )
            : Column(
                children: [
                  _SalesChart(),
                  const SizedBox(height: 16),
                  _PendingApprovals(),
                ],
              ),
          const SizedBox(height: 24),
          // Recent activity + quick actions
          isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _RecentActivity()),
                  if (isWide) ...[
                    const SizedBox(width: 16),
                    Expanded(flex: 1, child: _QuickActions()),
                  ],
                ],
              )
            : Column(
                children: [
                  _RecentActivity(),
                  const SizedBox(height: 16),
                  _QuickActions(),
                ],
              ),
        ],
      ),
    );
  }
}

class _DateFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: const Border.fromBorderSide(BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.grey600),
          const SizedBox(width: 8),
          Text('Últimos 30 dias',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey700),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.grey600),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String change;
  final Color color;
  final Color changeColor;
  final bool fullWidth;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.change,
    required this.color,
    this.changeColor = AppColors.success,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 12, color: changeColor),
                    const SizedBox(width: 2),
                    Text(change,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: changeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bars = [80, 90, 70, 100, 120, 110, 90, 130, 150, 140, 120, 160, 
                  170, 155, 140, 180, 190, 175, 160, 200, 210, 195, 180, 220, 230, 215, 200, 240, 260, 250];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Desempenho de vendas',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey200),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Text('Vendas (R\$)', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.grey500),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(bars.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: bars[i].toDouble(),
                        color: i == bars.length - 1 ? AppColors.primary : AppColors.primaryLight,
                        width: 7,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                      ),
                    ],
                  );
                }),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppColors.grey100,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) => Text(
                        v >= 1000 ? '${(v / 1000).toInt()} mil' : v.toInt().toString(),
                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey400),
                      ),
                      reservedSize: 44,
                      interval: 50,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        final labels = ['1 abr', '4 abr', '7 abr', '10 abr', '13 abr', '16 abr', '19 abr', '22 abr', '25 abr', '28 abr', '30 abr'];
                        final idx = v.toInt();
                        if (idx % 3 == 0 && idx ~/ 3 < labels.length) {
                          return Text(labels[idx ~/ 3], style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey400));
                        }
                        return const Text('');
                      },
                      reservedSize: 20,
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barTouchData: BarTouchData(enabled: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SalesMetric('Total de vendas', 'R\$ 2.840.320', '+18%'),
              const SizedBox(width: 40),
              _SalesMetric('Ticket médio', 'R\$ 189,90', '+7%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SalesMetric extends StatelessWidget {
  final String label;
  final String value;
  final String change;

  const _SalesMetric(this.label, this.value, this.change);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
        Text(value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.grey900,
          ),
        ),
        Row(
          children: [
            const Icon(Icons.arrow_upward, size: 12, color: AppColors.success),
            const SizedBox(width: 2),
            Text(change, style: GoogleFonts.inter(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Text('', style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey400)),
          ],
        ),
      ],
    );
  }
}

class _PendingApprovals extends StatelessWidget {
  final _items = const [
    {'title': 'Smartphone Delta X1', 'sub': 'Novo produto\nhá 2 horas', 'icon': Icons.smartphone_outlined},
    {'title': 'Loja TechBR', 'sub': 'Novo vendedor\nhá 5 horas', 'icon': Icons.store_outlined},
    {'title': 'Tênis Run Pro', 'sub': 'Alteração de produto\nhá 1 dia', 'icon': Icons.shopping_bag_outlined},
    {'title': 'Casa & Estilo', 'sub': 'Novo vendedor\nhá 1 dia', 'icon': Icons.store_outlined},
  ];

  const _PendingApprovals({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_outlined, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text('Aprovações pendentes',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey900,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text('Ver todas',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_items.map((item) => _ApprovalItem(
            title: item['title'] as String,
            sub: item['sub'] as String,
            icon: item['icon'] as IconData,
          ))).toList(),
        ],
      ),
    );
  }
}

class _ApprovalItem extends StatelessWidget {
  final String title;
  final String sub;
  final IconData icon;

  const _ApprovalItem({required this.title, required this.sub, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.grey600, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey800,
                  ),
                ),
                Text(sub,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(64, 30),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            child: const Text('Aprovar'),
          ),
          const SizedBox(width: 6),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size(60, 30),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            child: const Text('Rejeitar'),
          ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final _activities = const [
    {'date': '30/04/2024 14:32', 'type': 'Produto', 'desc': 'Novo produto publicado', 'user': 'Loja TechBR', 'status': 'Aprovado'},
    {'date': '30/04/2024 13:17', 'type': 'Vendedor', 'desc': 'Novo vendedor cadastrado', 'user': 'Casa & Estilo', 'status': 'Em análise'},
    {'date': '30/04/2024 11:03', 'type': 'Negociação', 'desc': 'Negociação iniciada', 'user': 'Cliente #98432', 'status': 'Ativa'},
    {'date': '30/04/2024 09:48', 'type': 'Oferta', 'desc': 'Oferta atualizada', 'user': 'Loja ModalVive', 'status': 'Aprovado'},
    {'date': '29/04/2024 18:21', 'type': 'Usuário', 'desc': 'Dados do vendedor alterados', 'user': 'Eletrônicos Já', 'status': 'Em análise'},
  ];

  const _RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.history, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text('Atividade recente',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey900,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text('Ver todas',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.2),
              2: FlexColumnWidth(2.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.grey100)),
                ),
                children: ['Data e hora', 'Tipo', 'Descrição', 'Usuário', 'Status'].map((h) =>
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(h,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                ).toList(),
              ),
              ..._activities.map((a) => TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.grey100)),
                ),
                children: [
                  _TableCell(a['date']!),
                  _TableCell(a['type']!, icon: _typeIcon(a['type']!)),
                  _TableCell(a['desc']!),
                  _TableCell(a['user']!),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _StatusChip(a['status']!),
                  ),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Produto': return Icons.inventory_2_outlined;
      case 'Vendedor': return Icons.store_outlined;
      case 'Negociação': return Icons.handshake_outlined;
      case 'Oferta': return Icons.local_offer_outlined;
      default: return Icons.person_outline;
    }
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final IconData? icon;

  const _TableCell(this.text, {this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(text,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip(this.status);

  Color get _color {
    switch (status) {
      case 'Aprovado': return AppColors.statusApproved;
      case 'Em análise': return AppColors.statusAnalysis;
      case 'Ativa': return AppColors.statusActive;
      default: return AppColors.grey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.accentAmber, size: 20),
              const SizedBox(width: 8),
              Text('Ações rápidas',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _QuickActionItem(
            icon: Icons.inventory_2_outlined,
            title: 'Gerenciar produtos',
            sub: 'Cadastrar, editar e revisar produtos',
          ),
          _QuickActionItem(
            icon: Icons.store_outlined,
            title: 'Vendedores',
            sub: 'Aprovar e administrar vendedores',
          ),
          _QuickActionItem(
            icon: Icons.bar_chart_outlined,
            title: 'Relatórios',
            sub: 'Acessar métricas e relatórios',
          ),
          _QuickActionItem(
            icon: Icons.settings_outlined,
            title: 'Configurações',
            sub: 'Ajustar preferências da plataforma',
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;

  const _QuickActionItem({required this.icon, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey800,
                  ),
                ),
                Text(sub,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.grey400),
        ],
      ),
    );
  }
}
