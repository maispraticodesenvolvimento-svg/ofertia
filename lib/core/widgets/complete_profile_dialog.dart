import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_client.dart';
import '../services/session_service.dart';
import '../services/via_cep_service.dart';
import '../theme/app_theme.dart';

class CompleteProfileDialog extends StatefulWidget {
  const CompleteProfileDialog({
    super.key,
    this.title = 'Complete seu cadastro',
    this.subtitle = 'Para criar ofertas ou realizar compras, é obrigatório preencher seus dados pessoais e endereço completo.',
  });

  final String title;
  final String subtitle;

  /// Exibe o diálogo e retorna true se o cadastro estiver completo após o salvamento
  static Future<bool> ensureComplete(BuildContext context, {String? actionLabel}) async {
    final session = SessionService.instance;
    if (session.isProfileComplete) return true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CompleteProfileDialog(
        subtitle: actionLabel != null
            ? 'Para $actionLabel, é obrigatório finalizar seu cadastro com seus dados pessoais e endereço de entrega.'
            : 'Para criar ofertas ou realizar compras, é obrigatório preencher seus dados pessoais e endereço completo.',
      ),
    );

    return result == true && SessionService.instance.isProfileComplete;
  }

  /// Opens the profile form even when the current profile is already complete.
  static Future<bool> editProfile(BuildContext context) async {
    final isComplete = SessionService.instance.isProfileComplete;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CompleteProfileDialog(
        title: isComplete ? 'Editar dados e endereço' : 'Completar cadastro',
        subtitle: 'Atualize seus dados pessoais e endereço de entrega.',
      ),
    );
    return result == true;
  }

  @override
  State<CompleteProfileDialog> createState() => _CompleteProfileDialogState();
}

class _CompleteProfileDialogState extends State<CompleteProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiClient();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _docCtrl = TextEditingController();

  final _cepCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _compCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();

  final _numberFocusNode = FocusNode();
  bool _searchingCep = false;
  String? _cepFeedbackMessage;
  bool _cepFeedbackSuccess = false;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _docCtrl.dispose();
    _cepCtrl.dispose();
    _streetCtrl.dispose();
    _numberCtrl.dispose();
    _compCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _numberFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleCepSearch(String rawValue) async {
    final clean = ViaCepService.cleanCep(rawValue);
    if (clean.length != 8) return;

    setState(() {
      _searchingCep = true;
      _cepFeedbackMessage = null;
    });

    try {
      final address = await ViaCepService.search(clean);
      if (!mounted) return;

      if (address != null) {
        _cepCtrl.text = ViaCepService.formatCep(clean);
        _cepCtrl.selection = TextSelection.collapsed(offset: _cepCtrl.text.length);

        if (address.street.isNotEmpty) _streetCtrl.text = address.street;
        if (address.neighborhood.isNotEmpty) _neighborhoodCtrl.text = address.neighborhood;
        if (address.city.isNotEmpty) _cityCtrl.text = address.city;
        if (address.state.isNotEmpty) _stateCtrl.text = address.state;
        if (address.complement.isNotEmpty && _compCtrl.text.trim().isEmpty) {
          _compCtrl.text = address.complement;
        }

        setState(() {
          _cepFeedbackMessage = 'Endereço preenchido via CEP!';
          _cepFeedbackSuccess = true;
        });

        _numberFocusNode.requestFocus();
      } else {
        setState(() {
          _cepFeedbackMessage = 'CEP não encontrado. Preencha os campos manualmente.';
          _cepFeedbackSuccess = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _cepFeedbackMessage = 'Não foi possível consultar o CEP. Preencha manualmente.';
          _cepFeedbackSuccess = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _searchingCep = false);
      }
    }
  }

  Future<void> _loadData() async {
    try {
      final user = await _api.getProfile();
      _nameCtrl.text = user['name']?.toString() ?? '';
      _phoneCtrl.text = user['phone']?.toString() ?? '';
      _docCtrl.text = user['document']?.toString() ?? '';

      final addr = user['address'];
      if (addr is Map) {
        _cepCtrl.text = addr['cep']?.toString() ?? '';
        _streetCtrl.text = addr['street']?.toString() ?? '';
        _numberCtrl.text = addr['number']?.toString() ?? '';
        _compCtrl.text = addr['complement']?.toString() ?? '';
        _neighborhoodCtrl.text = addr['neighborhood']?.toString() ?? '';
        _cityCtrl.text = addr['city']?.toString() ?? '';
        _stateCtrl.text = addr['state']?.toString() ?? '';
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final updated = await _api.updateProfile({
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'document': _docCtrl.text.trim(),
        'address': {
          'cep': _cepCtrl.text.trim(),
          'street': _streetCtrl.text.trim(),
          'number': _numberCtrl.text.trim(),
          'complement': _compCtrl.text.trim(),
          'neighborhood': _neighborhoodCtrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'state': _stateCtrl.text.trim().toUpperCase(),
        },
      });

      SessionService.instance.updateLocalUser(updated);
      await SessionService.instance.refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro e endereço atualizados com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: _loading
            ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cabeçalho
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.badge_outlined, color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.subtitle,
                                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                        ],
                      ),
                    ),

                    // Formulário
                    Flexible(
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          // ── Dados Pessoais ──
                          Text(
                            'Dados Pessoais',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey900,
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nome completo *',
                              prefixIcon: Icon(Icons.person_outline, size: 20),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: TextFormField(
                                  controller: _phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Telefone / WhatsApp *',
                                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu telefone' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 5,
                                child: TextFormField(
                                  controller: _docCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'CPF / CNPJ *',
                                    prefixIcon: Icon(Icons.credit_card_outlined, size: 20),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe CPF ou CNPJ' : null,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),
                          const Divider(),
                          const SizedBox(height: 12),

                          // ── Endereço Completo ──
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                'Endereço de Entrega & Cobrança',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.grey900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      controller: _cepCtrl,
                                      keyboardType: TextInputType.number,
                                      maxLength: 9,
                                      decoration: InputDecoration(
                                        labelText: 'CEP *',
                                        hintText: '00000-000',
                                        counterText: '',
                                        prefixIcon: const Icon(Icons.location_searching, size: 18),
                                        suffixIcon: _searchingCep
                                            ? const Padding(
                                                padding: EdgeInsets.all(12),
                                                child: SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                              )
                                            : IconButton(
                                                icon: const Icon(Icons.search, size: 20),
                                                tooltip: 'Buscar CEP no ViaCEP',
                                                onPressed: () => _handleCepSearch(_cepCtrl.text),
                                              ),
                                      ),
                                      onChanged: (val) {
                                        final clean = ViaCepService.cleanCep(val);
                                        if (clean.length == 8 && !_searchingCep) {
                                          _handleCepSearch(clean);
                                        }
                                      },
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) return 'Informe o CEP';
                                        if (ViaCepService.cleanCep(v).length != 8) return 'CEP inválido';
                                        return null;
                                      },
                                    ),
                                    if (_cepFeedbackMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4, left: 2),
                                        child: Text(
                                          _cepFeedbackMessage!,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: _cepFeedbackSuccess ? AppColors.success : AppColors.error,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 5,
                                child: TextFormField(
                                  controller: _neighborhoodCtrl,
                                  decoration: const InputDecoration(labelText: 'Bairro *'),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o bairro' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                flex: 7,
                                child: TextFormField(
                                  controller: _streetCtrl,
                                  decoration: const InputDecoration(labelText: 'Rua / Logradouro *'),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a rua' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _numberCtrl,
                                  focusNode: _numberFocusNode,
                                  decoration: const InputDecoration(labelText: 'Número *'),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nº' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _compCtrl,
                            decoration: const InputDecoration(labelText: 'Complemento (opcional)'),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                flex: 7,
                                child: TextFormField(
                                  controller: _cityCtrl,
                                  decoration: const InputDecoration(labelText: 'Cidade *'),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a cidade' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _stateCtrl,
                                  maxLength: 2,
                                  textCapitalization: TextCapitalization.characters,
                                  decoration: const InputDecoration(
                                    labelText: 'UF *',
                                    counterText: '',
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'UF' : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Rodapé
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: _saving
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.check, size: 18),
                            label: Text(_saving ? 'Salvando…' : 'Salvar e Continuar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

