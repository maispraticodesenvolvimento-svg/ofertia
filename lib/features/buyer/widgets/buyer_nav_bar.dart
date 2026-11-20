import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/category_icons.dart';

class BuyerNavBar extends StatelessWidget {
  const BuyerNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 24),
          _NavItem(
            'Início',
            Icons.home_outlined,
            '/buyer/home',
            location.contains('/buyer/home'),
          ),
          _NavItem(
            'Produtos',
            Icons.inventory_2_outlined,
            '/buyer/products',
            location.contains('/buyer/products'),
          ),
          _CategoryNavMenu(isActive: location.contains('/buyer/products')),
          _NavItem(
            'Ofertas',
            Icons.local_offer_outlined,
            '/buyer/offers',
            location.contains('/buyer/offers'),
          ),
          _NavItem(
            'Meus pedidos',
            Icons.shopping_bag_outlined,
            '/buyer/orders',
            location.contains('/buyer/orders'),
          ),
          _NavItem(
            'Minha conta',
            Icons.person_outline,
            '/buyer/account',
            location.contains('/buyer/account'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final bool isActive;

  const _NavItem(this.label, this.icon, this.route, this.isActive);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
                  bottom: BorderSide(color: AppColors.primary, width: 2),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.grey600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isActive ? AppColors.primary : AppColors.grey600,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryNavMenu extends StatefulWidget {
  const _CategoryNavMenu({required this.isActive});

  final bool isActive;

  @override
  State<_CategoryNavMenu> createState() => _CategoryNavMenuState();
}

class _CategoryNavMenuState extends State<_CategoryNavMenu> {
  final LayerLink _layerLink = LayerLink();
  late final Future<List<Map<String, dynamic>>> _categories;
  OverlayEntry? _overlayEntry;
  Timer? _closeTimer;

  @override
  void initState() {
    super.initState();
    _categories = ApiClient().getCategories();
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _removeDropdown();
    super.dispose();
  }

  void _openDropdown() {
    _closeTimer?.cancel();
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final maxHeight = math.min(
          MediaQuery.sizeOf(overlayContext).height * 0.72,
          600.0,
        );

        return Positioned.fill(
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 4),
                child: MouseRegion(
                  onEnter: (_) => _closeTimer?.cancel(),
                  onExit: (_) => _scheduleClose(),
                  child: _buildDropdown(maxHeight),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 180), _removeDropdown);
  }

  void _removeDropdown() {
    _closeTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _openDropdown();
    } else {
      _removeDropdown();
    }
  }

  void _selectCategory(String name) {
    _removeDropdown();
    context.go('/buyer/products?category=${Uri.encodeComponent(name)}');
  }

  void _openAllCategories() {
    _removeDropdown();
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar categorias',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (dialogContext, _, __) {
        final panelWidth = math.min(
          MediaQuery.sizeOf(dialogContext).width * 0.9,
          420.0,
        );

        return SafeArea(
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: panelWidth,
              height: double.infinity,
              child: _AllCategoriesPanel(
                categories: _categories,
                onSelect: (name) {
                  Navigator.of(dialogContext).pop();
                  context.go(
                    '/buyer/products?category=${Uri.encodeComponent(name)}',
                  );
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(position: animation.drive(slide), child: child);
      },
    );
  }

  Widget _buildDropdown(double maxHeight) {
    return Material(
      elevation: 12,
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 300,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _categories,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('Não foi possível carregar as categorias.'),
                );
              }

              final categories = snapshot.data ?? const [];
              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final category in categories.take(20))
                    _CategoryRow(
                      category: category,
                      onTap: () =>
                          _selectCategory(category['name']?.toString() ?? ''),
                    ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.list_alt_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'Ver mais categorias',
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: _openAllCategories,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive ? AppColors.primary : AppColors.grey600;

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _openDropdown(),
        onExit: (_) => _scheduleClose(),
        child: InkWell(
          onTap: _toggleDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: widget.isActive
                  ? const Border(
                      bottom: BorderSide(color: AppColors.primary, width: 2),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(Icons.category_outlined, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  'Categorias',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: color,
                    fontWeight: widget.isActive
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(Icons.keyboard_arrow_down, size: 16, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AllCategoriesPanel extends StatefulWidget {
  const _AllCategoriesPanel({required this.categories, required this.onSelect});

  final Future<List<Map<String, dynamic>>> categories;
  final ValueChanged<String> onSelect;

  @override
  State<_AllCategoriesPanel> createState() => _AllCategoriesPanelState();
}

class _AllCategoriesPanelState extends State<_AllCategoriesPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Todas as categorias',
                    style: GoogleFonts.inter(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.grey900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Fechar',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: 'Buscar categorias',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: widget.categories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Não foi possível carregar as categorias.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: AppColors.grey600),
                      ),
                    ),
                  );
                }

                final query = _query.toLowerCase();
                final categories = (snapshot.data ?? const []).where((item) {
                  final name = item['name']?.toString().toLowerCase() ?? '';
                  return name.contains(query);
                }).toList();

                if (categories.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhuma categoria encontrada.',
                      style: GoogleFonts.inter(color: AppColors.grey500),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 56),
                  itemBuilder: (context, index) => _CategoryRow(
                    category: categories[index],
                    onTap: () => widget.onSelect(
                      categories[index]['name']?.toString() ?? '',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.onTap});

  final Map<String, dynamic> category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = category['name']?.toString() ?? '';
    final icon = CategoryIcons.getIcon(category['icon']?.toString());

    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: AppColors.grey700),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey800),
      ),
      onTap: onTap,
    );
  }
}
