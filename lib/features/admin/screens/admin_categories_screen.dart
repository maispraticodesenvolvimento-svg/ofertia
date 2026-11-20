import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/category_icons.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final _api = ApiClient();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedIcon = 'shopping_bag';
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  List<Map<String, dynamic>> _categories = [];
  final Set<String> _deletingIds = {};

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _api.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = List<Map<String, dynamic>>.from(items);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _createCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o título da categoria.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final created = await _api.createCategory(
        name: name,
        description: _descController.text.trim(),
        icon: _selectedIcon,
      );
      if (!mounted) return;
      _nameController.clear();
      _descController.clear();
      setState(() {
        _categories.insert(0, created);
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoria cadastrada com sucesso!'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _delete(String id) async {
    setState(() => _deletingIds.add(id));
    try {
      await _api.deleteCategory(id);
      if (!mounted) return;
      setState(() {
        _categories.removeWhere((c) => c['id'].toString() == id);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _deletingIds.remove(id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 760;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Gerenciar Categorias',
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900),
        ),
        Text(
          'Cadastre categorias com ícones para organizar produtos e associar a banners.',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500),
        ),
        const SizedBox(height: 20),

        // ── Card de cadastro de categoria ──────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nova Categoria',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.grey900),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: wide ? 320 : double.infinity,
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Título da categoria *',
                        hintText: 'Ex: Eletrônicos, Moda, Alimentos...',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: wide ? 420 : double.infinity,
                    child: TextField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição (opcional)',
                        hintText: 'Breve descrição da categoria',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Escolha um ícone:',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grey700),
              ),
              const SizedBox(height: 10),
              Container(
                height: 110,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CategoryIcons.map.entries.map((entry) {
                      final isSelected = _selectedIcon == entry.key;
                      return InkWell(
                        onTap: () => setState(() => _selectedIcon = entry.key),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.grey300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Icon(
                            entry.value,
                            size: 22,
                            color: isSelected ? Colors.white : AppColors.grey700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _createCategory,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.add_rounded),
                  label: Text(_submitting ? 'Cadastrando…' : 'Salvar Categoria'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Lista de categorias ─────────────────────────────────────────
        Text(
          'Categorias Existentes (${_categories.length})',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.grey900),
        ),
        const SizedBox(height: 12),

        if (_loading)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
        else if (_error != null)
          _emptyBox(_error!)
        else if (_categories.isEmpty)
          _emptyBox('Nenhuma categoria cadastrada ainda.')
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: wide ? 3 : 1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 80,
            ),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final id = cat['id'].toString();
              final isDeleting = _deletingIds.contains(id);
              final iconKey = cat['icon']?.toString();
              final iconData = CategoryIcons.getIcon(iconKey);

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.grey200),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(iconData, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cat['name']?.toString() ?? '',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grey900),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (cat['description']?.toString().isNotEmpty == true)
                              Text(
                                cat['description'].toString(),
                                style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      if (isDeleting)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                        )
                      else
                        IconButton(
                          onPressed: () => _delete(id),
                          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                          tooltip: 'Excluir categoria',
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _emptyBox(String text) => Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Text(text, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.grey600)),
      );
}

