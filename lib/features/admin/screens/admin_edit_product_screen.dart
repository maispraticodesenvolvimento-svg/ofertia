import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AdminEditProductScreen extends StatefulWidget {
  final Map<String, String> product;

  const AdminEditProductScreen({super.key, required this.product});

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _descCtrl;
  late String _selectedCategory;
  late String _selectedStatus;

  final _categories = [
    'Eletrônicos',
    'Moda e Acessórios',
    'Casa e Decoração',
    'Eletrodomésticos',
    'Esportes',
    'Beleza e Saúde',
    'Outros',
  ];

  final _statuses = ['Ativo', 'Inativo', 'Em análise'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product['name'] ?? '');
    _priceCtrl = TextEditingController(
        text: (widget.product['price'] ?? '')
            .replaceAll('R\$ ', '')
            .replaceAll('.', '')
            .replaceAll(',', '.'));
    _stockCtrl = TextEditingController(text: widget.product['stock'] ?? '');
    _descCtrl = TextEditingController(
        text: 'Descrição detalhada do produto. Informe as características, '
            'especificações técnicas e demais informações relevantes para o comprador.');

    final cat = widget.product['category'] ?? _categories[0];
    _selectedCategory =
        _categories.contains(cat) ? cat : _categories[0];

    final raw = widget.product['status'] ?? 'Ativo';
    _selectedStatus = _statuses.contains(raw)
        ? raw
        : (raw == 'Aprovado' ? 'Ativo' : 'Em análise');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),
            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image placeholder + basic info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ImagePicker(emoji: widget.product['img'] ?? '📦'),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: [
                              _FormField(
                                label: 'Nome do produto',
                                controller: _nameCtrl,
                                hint: 'Ex.: Smartphone Delta X1',
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _FormField(
                                      label: 'Preço (R\$)',
                                      controller: _priceCtrl,
                                      hint: '0,00',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _FormField(
                                      label: 'Estoque',
                                      controller: _stockCtrl,
                                      hint: '0',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Category & Status row
                    Row(
                      children: [
                        Expanded(
                          child: _DropdownField(
                            label: 'Categoria',
                            value: _selectedCategory,
                            items: _categories,
                            onChanged: (v) =>
                                setState(() => _selectedCategory = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DropdownField(
                            label: 'Status',
                            value: _selectedStatus,
                            items: _statuses,
                            onChanged: (v) =>
                                setState(() => _selectedStatus = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Description
                    _FormField(
                      label: 'Descrição',
                      controller: _descCtrl,
                      hint: 'Descreva o produto...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    // Tags row
                    _SectionTitle('Tags'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Tag('Destaque'),
                        _Tag('Promoção'),
                        _Tag('Novo'),
                        _Tag('+ Adicionar'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Footer actions
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.edit_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar produto',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                  ),
                ),
                Text(
                  widget.product['name'] ?? '',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.grey500),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.grey500, size: 20),
            tooltip: 'Fechar',
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.grey100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => _showDeleteConfirm(context),
            icon: const Icon(Icons.delete_outline,
                size: 16, color: AppColors.error),
            label: Text('Excluir produto',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.error)),
          ),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.grey700,
                  side: const BorderSide(color: AppColors.grey300),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
                child: Text('Cancelar',
                    style: GoogleFonts.inter(fontSize: 13)),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Produto "${_nameCtrl.text}" atualizado com sucesso!',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                },
                icon: const Icon(Icons.check, size: 16),
                label: Text('Salvar alterações',
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Excluir produto',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
          'Tem certeza que deseja excluir "${widget.product['name']}"? Esta ação não pode ser desfeita.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: AppColors.grey600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Excluir',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.grey700,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey900),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400),
            filled: true,
            fillColor: AppColors.grey50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.grey200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style:
                            GoogleFonts.inter(fontSize: 13, color: AppColors.grey800)),
                  ))
              .toList(),
          onChanged: onChanged,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey900),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.grey50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.grey200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePicker extends StatelessWidget {
  final String emoji;
  const _ImagePicker({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200, width: 2),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_outlined,
              size: 14, color: AppColors.primary),
          label: Text('Alterar imagem',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    final isAdd = label.startsWith('+');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAdd ? Colors.transparent : AppColors.primarySurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAdd ? AppColors.grey300 : AppColors.primary,
          style: isAdd ? BorderStyle.solid : BorderStyle.solid,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: isAdd ? AppColors.grey500 : AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
