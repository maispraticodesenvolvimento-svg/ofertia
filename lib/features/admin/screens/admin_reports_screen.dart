import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Relatórios', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
          Text('Acompanhe as métricas e relatórios da plataforma.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Receita mensal', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.grey900)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [
                                  FlSpot(0, 180), FlSpot(1, 220), FlSpot(2, 195),
                                  FlSpot(3, 260), FlSpot(4, 310), FlSpot(5, 280),
                                  FlSpot(6, 340), FlSpot(7, 380), FlSpot(8, 360),
                                  FlSpot(9, 420), FlSpot(10, 400), FlSpot(11, 450),
                                ],
                                isCurved: true,
                                color: AppColors.primary,
                                barWidth: 2.5,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.primary.withOpacity(0.08),
                                ),
                                dotData: const FlDotData(show: false),
                              ),
                            ],
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (v) => FlLine(color: AppColors.grey100, strokeWidth: 1),
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 44,
                                getTitlesWidget: (v, m) => Text('${v.toInt()}k', style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey400)))),
                              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 20,
                                getTitlesWidget: (v, m) {
                                  final months = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];
                                  return Text(months[v.toInt()], style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey400));
                                })),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _ReportCard('Vendas totais', 'R\$ 2.840.320', '+18%'),
                    const SizedBox(height: 12),
                    _ReportCard('Novos usuários', '3.241', '+24%'),
                    const SizedBox(height: 12),
                    _ReportCard('Taxa de conversão', '3.8%', '+0.4%'),
                    const SizedBox(height: 12),
                    _ReportCard('Ticket médio', 'R\$ 189,90', '+7%'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String label;
  final String value;
  final String change;

  const _ReportCard(this.label, this.value, this.change);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.grey900)),
          Row(children: [
            const Icon(Icons.arrow_upward, size: 13, color: AppColors.success),
            const SizedBox(width: 2),
            Text(change, style: GoogleFonts.inter(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }
}
