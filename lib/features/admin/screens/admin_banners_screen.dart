import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/widgets/banner_crop_dialog.dart';
import '../../../core/widgets/product_image.dart';

class AdminBannersScreen extends StatefulWidget {
  const AdminBannersScreen({super.key});

  @override
  State<AdminBannersScreen> createState() => _AdminBannersScreenState();
}

class _AdminBannersScreenState extends State<AdminBannersScreen> {
  final _api = ApiClient();

  // ── Estado da lista de banners e categorias ─────────────────────────────
  bool _loadingList = true;
  String? _listError;
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _mobileItems = [];
  List<Map<String, dynamic>> _categories = [];

  // Categoria selecionada para associar ao novo banner
  String? _selectedCategory;

  // IDs cujo botão de exclusão está em loading
  final Set<String> _deleting = {};

  // Upload em progresso
  bool _uploading = false;
  // Carregando e preparando imagem selecionada
  bool _preparingImage = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _loadingList = true;
      _listError = null;
    });
    try {
      final results = await Future.wait([
        _api.getBanners(),
        _api.getBanners(mobile: true),
        _api.getCategories(),
      ]);
      if (!mounted) return;
      setState(() {
        _items = List<Map<String, dynamic>>.from(results[0]);
        _mobileItems = List<Map<String, dynamic>>.from(results[1]);
        _categories = List<Map<String, dynamic>>.from(results[2]);
        _loadingList = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _listError = e.toString();
        _loadingList = false;
      });
    }
  }

  // ── Upload com recorte ───────────────────────────────────────────────────
  Future<void> _addBanner({required bool mobile}) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
      maxWidth: 2400,
    );
    if (file == null) return;
    if (!mounted) return;

    // Ativa spinner imediatamente após o usuário escolher a imagem
    setState(() => _preparingImage = true);

    final rawBytes = await file.readAsBytes();
    if (!mounted) return;

    // Aguarda um pequeno instante para liberar o frame do Flutter
    await Future.delayed(const Duration(milliseconds: 30));
    if (!mounted) return;

    setState(() => _preparingImage = false);

    // Abre o recorte na proporção adequada para navegador ou mobile.
    final croppedBytes = await BannerCropDialog.show(
      context,
      rawBytes,
      mobile: mobile,
    );
    if (croppedBytes == null) return; // Usuário cancelou

    if (!mounted) return;
    setState(() => _uploading = true);
    try {
      await _api.uploadImage(
        collection: mobile ? 'mobileBanners' : 'banners',
        bytes: croppedBytes,
        contentType: 'image/jpeg',
        category: _selectedCategory,
      );
      await _loadData(); // recarrega lista após upload
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mobile
                ? 'Banner mobile cadastrado com sucesso!'
                : 'Banner web cadastrado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // ── Exclusão com feedback imediato ───────────────────────────────────────
  Future<void> _delete(String id, {required bool mobile}) async {
    setState(() => _deleting.add(id));
    try {
      await _api.deleteBanner(id, mobile: mobile);
      if (!mounted) return;
      setState(() {
        (mobile ? _mobileItems : _items)
            .removeWhere((b) => b['id'].toString() == id);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _deleting.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 760;

    return ListView(padding: const EdgeInsets.all(24), children: [
      Text('Banners da vitrine',
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
      Text('Envie banners e associe-os a categorias para navegação rápida do comprador.',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),

      const SizedBox(height: 14),

      // ── Card de proporções recomendadas ───────────────────────────────
      const _ProportionCard(),

      const SizedBox(height: 18),

      // ── Formulário de upload e seleção de categoria ────────────────────
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Wrap(spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
          SizedBox(
            width: wide ? 320 : double.infinity,
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Associar à categoria (opcional)',
                prefixIcon: Icon(Icons.link_rounded),
              ),
              isExpanded: true,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Nenhuma (apenas destaque)'),
                ),
                ..._categories.map((c) {
                  final name = c['name']?.toString() ?? '';
                  final icon = CategoryIcons.getIcon(c['icon']?.toString());
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Row(
                      children: [
                        Icon(icon, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(name),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
          ),
          FilledButton.icon(
            onPressed: (_uploading || _preparingImage)
                ? null
                : () => _addBanner(mobile: false),
            icon: (_uploading || _preparingImage)
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.desktop_windows_outlined),
            label: Text(_preparingImage
                ? 'Preparando imagem…'
                : _uploading
                    ? 'Enviando…'
                    : 'Adicionar banner web'),
          ),
          OutlinedButton.icon(
            onPressed: (_uploading || _preparingImage)
                ? null
                : () => _addBanner(mobile: true),
            icon: const Icon(Icons.smartphone_outlined),
            label: const Text('Adicionar banner mobile'),
          ),
        ]),
      ),

      const SizedBox(height: 18),

      // ── Conteúdo da lista ─────────────────────────────────────────────
      if (_loadingList)
        const Center(child: Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator()))
      else if (_listError != null)
        _emptyBox(_listError!)
      else if (_items.isEmpty && _mobileItems.isEmpty)
        _emptyBox('Nenhum banner cadastrado.')
      else ...[
        if (_items.isNotEmpty) ...[
          _sectionHeading('Banners para navegador'),
          ..._items.map((banner) => _bannerCard(banner, mobile: false)),
        ],
        if (_mobileItems.isNotEmpty) ...[
          _sectionHeading('Banners para mobile'),
          ..._mobileItems.map((banner) => _bannerCard(banner, mobile: true)),
        ],
      ],
    ]);
  }

  Widget _emptyBox(String text) => Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Text(text, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.grey600)),
      );

  Widget _sectionHeading(String title) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 6),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.grey900,
          ),
        ),
      );

  Widget _bannerCard(Map<String, dynamic> banner, {required bool mobile}) {
    final id = banner['id'].toString();
    final isDeleting = _deleting.contains(id);
    final categoryName = banner['category']?.toString();
    final hasCategory = categoryName != null && categoryName.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AspectRatio(
          aspectRatio: mobile ? 16 / 9 : 10 / 3,
          child: ProductImage(
            dataUrl: banner['dataUrl']?.toString(),
            icon: Icons.campaign_outlined,
          ),
        ),
        ListTile(
          title: Row(
            children: [
              if (hasCategory)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.link_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        categoryName,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                )
              else
                Text('Sem categoria vinculada', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
            ],
          ),
          subtitle: Text('${mobile ? 'Mobile' : 'Navegador'} · ID: $id'),
          trailing: isDeleting
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                  ),
                )
              : IconButton(
                  onPressed: () => _delete(id, mobile: mobile),
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  tooltip: 'Excluir banner',
                ),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Card informativo com as proporções ideais do banner
// ---------------------------------------------------------------------------
class _ProportionCard extends StatelessWidget {
  const _ProportionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Proporções recomendadas para o banner',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ]),
        const SizedBox(height: 12),

        const _ProportionRow(
          icon: Icons.desktop_windows_outlined,
          label: 'Banners para navegador',
          resolution: '1800 × 540 px',
          ratio: '10:3',
          color: AppColors.primary,
        ),

        const SizedBox(height: 10),
        const _ProportionRow(
          icon: Icons.smartphone_outlined,
          label: 'Banners para mobile',
          resolution: '1600 × 900 px',
          ratio: '16:9',
          color: AppColors.primary,
        ),

        const SizedBox(height: 12),
        Container(height: 1, color: AppColors.primaryBorder),
        const SizedBox(height: 10),

        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.accentAmber),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Cada imagem é recortada separadamente para a proporção do dispositivo, evitando cortes importantes na vitrine.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _ProportionRow extends StatelessWidget {
  const _ProportionRow({
    required this.icon,
    required this.label,
    required this.resolution,
    required this.ratio,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String resolution;
  final String ratio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: 10),
      Expanded(
        child: Text(label,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grey800)),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(resolution,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grey900)),
        Text('Proporção $ratio',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
      ]),
    ]);
  }
}
