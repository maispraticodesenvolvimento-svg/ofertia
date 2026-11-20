import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/product.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_image.dart';

class _UploadedImageItem {
  _UploadedImageItem({
    required this.id,
    this.bytes,
    this.dataUrl,
  });

  final String id;
  final Uint8List? bytes;
  final String? dataUrl;
}

class _SpecRow {
  _SpecRow({required this.keyController, required this.valueController});
  final TextEditingController keyController;
  final TextEditingController valueController;

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

class AdminProductFormScreen extends StatefulWidget {
  const AdminProductFormScreen({super.key, this.product});
  final Product? product;

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiClient();

  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _oldPrice;
  late final TextEditingController _stock;
  late final TextEditingController _brand;

  String? _selectedCategory;
  String _selectedCondition = 'Novo'; // 'Novo', 'Usado', 'Seminovo'
  late bool _active;
  late bool _featured;

  // Lista de categorias existentes do backend
  List<Map<String, dynamic>> _availableCategories = [];
  bool _loadingCategories = true;

  // Imagens (até 6)
  final List<_UploadedImageItem> _images = [];
  bool _saving = false;
  bool _uploadingImage = false;

  // Ficha técnica dinâmica (Ex: Memória RAM, Armazenamento, Processador, Cor, Tamanho, etc.)
  final List<_SpecRow> _specRows = [];

  bool get _editing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _name = TextEditingController(text: product?.name ?? '');
    _description = TextEditingController(text: product?.description ?? '');
    _price = TextEditingController(text: product?.price.toStringAsFixed(2) ?? '');
    _oldPrice = TextEditingController(text: product?.oldPrice?.toStringAsFixed(2) ?? '');
    _stock = TextEditingController(text: product?.stock.toString() ?? '0');
    _brand = TextEditingController(text: product?.brand ?? '');

    _selectedCategory = product?.category.isNotEmpty == true ? product!.category : null;
    _selectedCondition = product?.condition?.isNotEmpty == true ? product!.condition! : 'Novo';

    _active = product == null || product.status == 'active';
    _featured = product?.featured ?? false;

    // Inicializa imagens prévias
    if (product != null) {
      if (product.imageIds.isNotEmpty) {
        for (int i = 0; i < product.imageIds.length; i++) {
          final id = product.imageIds[i];
          final url = i < product.imagesDataUrls.length ? product.imagesDataUrls[i] : null;
          _images.add(_UploadedImageItem(id: id, dataUrl: url));
        }
      } else if (product.imageId != null && product.imageId!.isNotEmpty) {
        _images.add(_UploadedImageItem(id: product.imageId!, dataUrl: product.imageDataUrl));
      }

      // Inicializa ficha técnica existente
      if (product.specs.isNotEmpty) {
        product.specs.forEach((k, v) {
          _specRows.add(_SpecRow(
            keyController: TextEditingController(text: k),
            valueController: TextEditingController(text: v),
          ));
        });
      }
    }

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final list = await _api.getCategories();
      if (!mounted) return;
      setState(() {
        _availableCategories = list;
        _loadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCategories = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _oldPrice.dispose();
    _stock.dispose();
    _brand.dispose();
    for (final r in _specRows) {
      r.dispose();
    }
    super.dispose();
  }

  double? _parsePrice(String value) => double.tryParse(value.trim().replaceAll(',', '.'));

  Future<void> _pickImage() async {
    if (_images.length >= 6) {
      _showMessage('Limite máximo de 6 imagens por produto atingido.', error: true);
      return;
    }

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      imageQuality: 88,
      maxWidth: 1800,
      limit: 6 - _images.length,
    );

    if (pickedFiles.isEmpty) return;

    setState(() => _uploadingImage = true);

    try {
      for (final file in pickedFiles) {
        if (_images.length >= 6) break;

        final extension = file.name.split('.').last.toLowerCase();
        final type = switch (extension) {
          'png' => 'image/png',
          'webp' => 'image/webp',
          'gif' => 'image/gif',
          _ => 'image/jpeg',
        };

        final bytes = await file.readAsBytes();
        final id = await _api.uploadImage(
          collection: 'products',
          bytes: bytes,
          contentType: type,
        );

        if (!mounted) return;
        setState(() {
          _images.add(_UploadedImageItem(id: id, bytes: bytes));
        });
      }
      _showMessage('Imagens enviadas com sucesso.');
    } catch (error) {
      if (mounted) _showMessage(error.toString(), error: true);
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _addSpecRow([String defaultKey = '', String defaultValue = '']) {
    setState(() {
      _specRows.add(_SpecRow(
        keyController: TextEditingController(text: defaultKey),
        valueController: TextEditingController(text: defaultValue),
      ));
    });
  }

  void _removeSpecRow(int index) {
    setState(() {
      _specRows[index].dispose();
      _specRows.removeAt(index);
    });
  }

  // Atalhos rápidos para preencher especificações comuns
  void _applyQuickSpecs(List<MapEntry<String, String>> presets) {
    for (final p in presets) {
      final exists = _specRows.any((r) => r.keyController.text.trim().toLowerCase() == p.key.toLowerCase());
      if (!exists) {
        _addSpecRow(p.key, p.value);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null || _selectedCategory!.trim().isEmpty) {
      _showMessage('Por favor, selecione uma categoria para o produto.', error: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final imageIds = _images.map((img) => img.id).toList();

      // Monta mapa da ficha técnica
      final specsMap = <String, String>{};
      for (final row in _specRows) {
        final k = row.keyController.text.trim();
        final v = row.valueController.text.trim();
        if (k.isNotEmpty && v.isNotEmpty) {
          specsMap[k] = v;
        }
      }

      final item = Product(
        id: widget.product?.id ?? '',
        name: _name.text.trim(),
        category: _selectedCategory!.trim(),
        description: _description.text.trim(),
        price: _parsePrice(_price.text) ?? 0.0,
        oldPrice: _oldPrice.text.trim().isEmpty ? null : _parsePrice(_oldPrice.text),
        stock: int.tryParse(_stock.text.trim()) ?? 0,
        status: _active ? 'active' : 'inactive',
        featured: _featured,
        imageId: imageIds.isNotEmpty ? imageIds.first : null,
        imageIds: imageIds,
        brand: _brand.text.trim().isNotEmpty ? _brand.text.trim() : null,
        condition: _selectedCondition,
        specs: specsMap,
      );

      await _api.saveProduct(item, create: !_editing);
      if (!mounted) return;
      _showMessage(_editing ? 'Produto atualizado.' : 'Produto cadastrado.');
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) _showMessage(error.toString(), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: error ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 760;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_editing ? 'Editar produto' : 'Novo produto'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.grey900,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(wide ? 28 : 16),
              children: [
                Container(
                  padding: EdgeInsets.all(wide ? 28 : 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editing ? 'Informações do produto' : 'Cadastre um produto',
                        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.grey900),
                      ),
                      const SizedBox(height: 22),

                      // ── Galeria de Imagens (Até 6 fotos) ──────────────────
                      _imagesGalleryControl(),
                      const SizedBox(height: 24),

                      // ── Nome do Produto ──────────────────────────────────
                      _field(_name, 'Nome do Produto *', required: true),
                      const SizedBox(height: 16),

                      // ── Categoria (Dropdown com opções existentes) e Condição ─
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _categoryDropdown()),
                            const SizedBox(width: 14),
                            Expanded(flex: 2, child: _conditionDropdown()),
                            const SizedBox(width: 14),
                            Expanded(flex: 2, child: _field(_brand, 'Marca (Ex: Apple, Samsung, Nike)')),
                          ],
                        )
                      else ...[
                        _categoryDropdown(),
                        const SizedBox(height: 14),
                        _conditionDropdown(),
                        const SizedBox(height: 14),
                        _field(_brand, 'Marca (Ex: Apple, Samsung, Nike)'),
                      ],

                      const SizedBox(height: 18),
                      _descriptionField(),

                      const SizedBox(height: 24),
                      const Divider(color: AppColors.grey200),
                      const SizedBox(height: 16),

                      // ── Ficha Técnica do Produto ─────────────────────────
                      _specsSection(),

                      const SizedBox(height: 24),
                      const Divider(color: AppColors.grey200),
                      const SizedBox(height: 16),

                      // ── Preço, Preço Antigo e Estoque ─────────────────────
                      if (wide)
                        Row(children: [
                          Expanded(child: _field(_price, 'Preço sugerido (R\$)', numeric: true, validator: (v) => (v == null || v.trim().isEmpty || _parsePrice(v) != null) ? null : 'Informe um valor válido.')),
                          const SizedBox(width: 12),
                          Expanded(child: _field(_oldPrice, 'Preço anterior (riscado)', numeric: true, validator: (v) => (v == null || v.trim().isEmpty || _parsePrice(v) != null) ? null : 'Informe um preço válido.')),
                          const SizedBox(width: 12),
                          Expanded(child: _field(_stock, 'Estoque base', numeric: true)),
                        ])
                      else ...[
                        _field(_price, 'Preço sugerido (R\$)', numeric: true, validator: (v) => (v == null || v.trim().isEmpty || _parsePrice(v) != null) ? null : 'Informe um valor válido.'),
                        const SizedBox(height: 14),
                        _field(_oldPrice, 'Preço anterior (riscado)', numeric: true, validator: (v) => (v == null || v.trim().isEmpty || _parsePrice(v) != null) ? null : 'Informe um preço válido.'),
                        const SizedBox(height: 14),
                        _field(_stock, 'Estoque base', numeric: true),
                      ],

                      const SizedBox(height: 18),

                      // ── Switches de Status e Destaque ─────────────────────
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Produto ativo para venda'),
                        subtitle: const Text('Produtos inativos não aparecem na loja para os clientes.', style: TextStyle(fontSize: 12, color: AppColors.grey500)),
                        value: _active,
                        onChanged: (value) => setState(() => _active = value),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Destacar na vitrine da página inicial'),
                        value: _featured,
                        onChanged: (value) => setState(() => _featured = value ?? false),
                      ),

                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: _saving || _uploadingImage ? null : _save,
                          icon: _saving
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save_outlined),
                          label: Text(_editing ? 'Salvar alterações' : 'Cadastrar produto'),
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Dropdown de Categorias ────────────────────────────────────────────────
  Widget _categoryDropdown() {
    // Garante que o valor selecionado existe na lista (ou inclui se for pré-existente)
    final categoryNames = _availableCategories.map((c) => c['name']?.toString() ?? '').where((s) => s.isNotEmpty).toSet().toList();
    if (_selectedCategory != null && !categoryNames.contains(_selectedCategory)) {
      categoryNames.insert(0, _selectedCategory!);
    }

    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Categoria do produto *',
        prefixIcon: const Icon(Icons.category_outlined, size: 20),
        suffixIcon: _loadingCategories ? const SizedBox(width: 16, height: 16, child: Center(child: CircularProgressIndicator(strokeWidth: 2))) : null,
      ),
      hint: const Text('Selecione uma categoria'),
      items: categoryNames.map((name) {
        return DropdownMenuItem<String>(
          value: name,
          child: Text(name, style: GoogleFonts.inter(fontSize: 14)),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val),
      validator: (val) => val == null || val.trim().isEmpty ? 'Selecione uma categoria.' : null,
    );
  }

  // ── Dropdown de Condição (Novo, Usado, Seminovo) ─────────────────────────
  Widget _conditionDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCondition,
      decoration: const InputDecoration(
        labelText: 'Condição do item *',
        prefixIcon: Icon(Icons.verified_outlined, size: 20),
      ),
      items: const [
        DropdownMenuItem(value: 'Novo', child: Text('Novo')),
        DropdownMenuItem(value: 'Seminovo', child: Text('Seminovo')),
        DropdownMenuItem(value: 'Usado', child: Text('Usado')),
        DropdownMenuItem(value: 'Recondicionado', child: Text('Recondicionado')),
      ],
      onChanged: (val) {
        if (val != null) setState(() => _selectedCondition = val);
      },
    );
  }

  // ── Seção da Ficha Técnica ───────────────────────────────────────────────
  Widget _specsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ficha Técnica & Especificações',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.grey900),
                ),
                Text(
                  'Adicione atributos específicos como Memória RAM, Armazenamento, Cor, Tamanho, etc.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () => _addSpecRow(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Adicionar campo'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Atalhos rápidos para preenchimento
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Sugestões rápidas:', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.grey600)),
            ActionChip(
              label: const Text('Eletrônicos / Informática', style: TextStyle(fontSize: 11)),
              onPressed: () => _applyQuickSpecs(const [
                MapEntry('Memória RAM', ''),
                MapEntry('Armazenamento', ''),
                MapEntry('Processador', ''),
                MapEntry('Tela', ''),
                MapEntry('Sistema Operacional', ''),
              ]),
            ),
            ActionChip(
              label: const Text('Moda / Vestuário', style: TextStyle(fontSize: 11)),
              onPressed: () => _applyQuickSpecs(const [
                MapEntry('Tamanho', ''),
                MapEntry('Cor', ''),
                MapEntry('Material', ''),
                MapEntry('Gênero', ''),
              ]),
            ),
            ActionChip(
              label: const Text('Geral (Dimensões / Peso)', style: TextStyle(fontSize: 11)),
              onPressed: () => _applyQuickSpecs(const [
                MapEntry('Dimensões', ''),
                MapEntry('Peso', ''),
                MapEntry('Garantia', ''),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (_specRows.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: AppColors.grey500),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nenhum campo de especificação adicionado ainda. Clique em "Adicionar campo" ou em uma sugestão acima.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600),
                  ),
                ),
              ],
            ),
          )
        else
          ..._specRows.asMap().entries.map((entry) {
            final idx = entry.key;
            final row = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: row.keyController,
                      decoration: const InputDecoration(
                        labelText: 'Atributo (ex: Memória RAM)',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 6,
                    child: TextFormField(
                      controller: row.valueController,
                      decoration: const InputDecoration(
                        labelText: 'Valor (ex: 8 GB)',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () => _removeSpecRow(idx),
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    tooltip: 'Remover especificação',
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ── Galeria de Imagens ───────────────────────────────────────────────────
  Widget _imagesGalleryControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_library_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Fotos do Produto (${_images.length}/6)',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grey900),
                ),
              ],
            ),
            if (_images.length < 6)
              OutlinedButton.icon(
                onPressed: _uploadingImage ? null : _pickImage,
                icon: _uploadingImage
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add_photo_alternate_outlined, size: 16),
                label: Text(_uploadingImage ? 'Enviando…' : 'Adicionar fotos'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'A 1ª imagem será a capa principal. Adicione fotos em diferentes ângulos para a galeria.',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500),
        ),
        const SizedBox(height: 14),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ..._images.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isMain = idx == 0;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 105,
                    height: 105,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isMain ? AppColors.primary : AppColors.grey300,
                        width: isMain ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: item.bytes != null
                        ? Image.memory(item.bytes!, fit: BoxFit.cover)
                        : ProductImage(dataUrl: item.dataUrl),
                  ),
                  if (isMain)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Capa',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () => _removeImage(idx),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              );
            }),

            if (_images.length < 6)
              InkWell(
                onTap: _uploadingImage ? null : _pickImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey300, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_outlined, color: AppColors.grey400, size: 28),
                      const SizedBox(height: 4),
                      Text('Adicionar', style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 11)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  double _descHeight = 220.0;

  Widget _descriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Descrição do Produto *',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grey800),
                ),
                const SizedBox(width: 8),
                Text(
                  '(quebras de linha, parágrafos e listas são respeitados)',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500),
                ),
              ],
            ),
            // Botões de redimensionamento rápido
            Row(
              children: [
                IconButton(
                  tooltip: 'Diminuir altura do campo',
                  visualDensity: VisualDensity.compact,
                  onPressed: _descHeight > 140
                      ? () => setState(() => _descHeight = (_descHeight - 80).clamp(140.0, 600.0))
                      : null,
                  icon: const Icon(Icons.remove, size: 16),
                ),
                Text(
                  '${_descHeight.toInt()}px',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey600),
                ),
                IconButton(
                  tooltip: 'Aumentar altura do campo (expandir textarea)',
                  visualDensity: VisualDensity.compact,
                  onPressed: _descHeight < 600
                      ? () => setState(() => _descHeight = (_descHeight + 80).clamp(140.0, 600.0))
                      : null,
                  icon: const Icon(Icons.add, size: 16),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: _descHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: TextFormField(
                  controller: _description,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (v) => v == null || v.trim().isEmpty ? 'A descrição é obrigatória.' : null,
                  decoration: const InputDecoration(
                    hintText: 'Escreva a descrição detalhada do produto...\n\nVocê pode pular linhas e criar tópicos:\n• Característica 1\n• Característica 2',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    contentPadding: EdgeInsets.fromLTRB(14, 14, 14, 28),
                  ),
                ),
              ),

              // Alça visual no canto inferior direito para arrastar e redimensionar a altura (estilo textarea web)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      _descHeight = (_descHeight + details.delta.dy).clamp(140.0, 650.0);
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.south_east_rounded,
                      size: 16,
                      color: AppColors.grey400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool numeric = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) => TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        validator: validator ?? (required ? (value) => value == null || value.trim().isEmpty ? 'Campo obrigatório.' : null : null),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      );
}
