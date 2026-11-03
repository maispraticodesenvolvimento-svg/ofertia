import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AdminVendorsScreen extends StatelessWidget {
  const AdminVendorsScreen({super.key});
  static final _vendors = [
    {'name': 'Loja TechBR', 'category': 'Eletrônicos', 'products': '234', 'rating': '4.9', 'status': 'Aprovado', 'since': 'Mar 2023'},
    {'name': 'Casa & Estilo', 'category': 'Casa e Decoração', 'products': '89', 'rating': '4.7', 'status': 'Aprovado', 'since': 'Jan 2024'},
    {'name': 'MundoTech', 'category': 'Eletrônicos', 'products': '156', 'rating': '4.8', 'status': 'Em análise', 'since': 'Out 2024'},
    {'name': 'EletroMais', 'category': 'Eletrodomésticos', 'products': '67', 'rating': '4.6', 'status': 'Aprovado', 'since': 'Jun 2023'},
    {'name': 'Loja ModalVive', 'category': 'Moda', 'products': '342', 'rating': '4.5', 'status': 'Em análise', 'since': 'Out 2024'},
    {'name': 'Digital Center', 'category': 'Eletrônicos', 'products': '45', 'rating': '4.4', 'status': 'Aprovado', 'since': 'Feb 2024'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vendedores', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
                  Text('Aprove e administre os vendedores da plataforma.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Convidar vendedor'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatCard('Total de vendedores', '12.548', Icons.store_outlined),
              const SizedBox(width: 12),
              _StatCard('Aprovados', '11.823', Icons.check_circle_outline),
              const SizedBox(width: 12),
              _StatCard('Em análise', '725', Icons.access_time_outlined),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar vendedores...',
                            prefixIcon: const Icon(Icons.search, size: 18),
                            hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      _TH('Vendedor', 3),
                      _TH('Categoria', 2),
                      _TH('Produtos', 1),
                      _TH('Avaliação', 1),
                      _TH('Desde', 1),
                      _TH('Status', 1),
                      _TH('Ações', 1),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ..._vendors.map((v) => _VendorRow(v)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.grey900)),
                Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  final int flex;

  const _TH(this.text, this.flex);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey500)),
    );
  }
}

class _VendorRow extends StatelessWidget {
  final Map<String, String> v;

  const _VendorRow(this.v);

  Color get _sc => v['status'] == 'Aprovado' ? AppColors.statusApproved : AppColors.statusAnalysis;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.grey100))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Row(children: [
            CircleAvatar(radius: 16, backgroundColor: AppColors.primarySurface,
              child: Text(v['name']![0], style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700))),
            const SizedBox(width: 10),
            Text(v['name']!, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
          ])),
          Expanded(flex: 2, child: Text(v['category']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600))),
          Expanded(flex: 1, child: Text(v['products']!, style: GoogleFonts.inter(fontSize: 12))),
          Expanded(flex: 1, child: Row(children: [
            const Icon(Icons.star, size: 13, color: Color(0xFFFFB300)),
            const SizedBox(width: 3),
            Text(v['rating']!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
          ])),
          Expanded(flex: 1, child: Text(v['since']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500))),
          Expanded(flex: 1, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _sc.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Text(v['status']!, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _sc)),
          )),
          Expanded(flex: 1, child: Row(children: [
            IconButton(icon: const Icon(Icons.visibility_outlined, size: 16), onPressed: () {}, color: AppColors.primary),
            IconButton(icon: const Icon(Icons.more_vert, size: 16), onPressed: () {}, color: AppColors.grey500),
          ])),
        ],
      ),
    );
  }
}
