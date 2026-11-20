import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/models/product.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/via_cep_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_image.dart';

class BuyerCheckoutConfirmationScreen extends StatefulWidget {
  const BuyerCheckoutConfirmationScreen({
    super.key,
    required this.product,
    required this.offer,
  });

  final Product product;
  final Map<String, dynamic> offer;

  @override
  State<BuyerCheckoutConfirmationScreen> createState() => _BuyerCheckoutConfirmationScreenState();
}

class _BuyerCheckoutConfirmationScreenState extends State<BuyerCheckoutConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiClient();
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

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
  bool _processing = false;
  String _selectedPaymentMethod = 'Pix';

  double get _itemPrice => NumberFormat().tryParse(widget.offer['price']?.toString() ?? '0')?.toDouble() ?? (widget.offer['price'] is num ? (widget.offer['price'] as num).toDouble() : 0.0);
  double get _shippingPrice => widget.offer['freeShipping'] == true ? 0.0 : (NumberFormat().tryParse(widget.offer['shippingPrice']?.toString() ?? '0')?.toDouble() ?? (widget.offer['shippingPrice'] is num ? (widget.offer['shippingPrice'] as num).toDouble() : 0.0));
  double get _totalPrice => _itemPrice + _shippingPrice;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
          _cepFeedbackMessage = 'Endereço localizado com sucesso!';
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

  Future<void> _loadProfile() async {
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

  Future<void> _confirmAndFinish() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios de endereço e dados pessoais.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _processing = true);
    try {
      // 1. Salva/Atualiza o perfil e endereço no banco
      final updatedProfile = await _api.updateProfile({
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

      SessionService.instance.updateLocalUser(updatedProfile);
      await SessionService.instance.refresh();

      // 2. Registra o pedido no backend
      Map<String, dynamic> order = {};
      try {
        order = await _api.createOrder(widget.product.id, quantity: 1);
      } catch (_) {}

      if (mounted) {
        // 3. Vai para o Checkout Placeholder com os dados da transação
        context.go(
          '/buyer/checkout/placeholder',
          extra: {
            'product': widget.product,
            'offer': widget.offer,
            'total': _totalPrice,
            'paymentMethod': _selectedPaymentMethod,
            'orderId': order['id'] ?? 'PED-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
            'address': {
              'street': _streetCtrl.text.trim(),
              'number': _numberCtrl.text.trim(),
              'city': _cityCtrl.text.trim(),
              'state': _stateCtrl.text.trim().toUpperCase(),
              'cep': _cepCtrl.text.trim(),
            },
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 900;
    final paymentMethods = (widget.offer['paymentMethods'] as List? ?? ['Pix', 'Cartão de Crédito']).map((e) => e.toString()).toList();
    if (!paymentMethods.contains(_selectedPaymentMethod) && paymentMethods.isNotEmpty) {
      _selectedPaymentMethod = paymentMethods.first;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: wide ? 36 : 16, vertical: 24),
                children: [
                  // Breadcrumb / Voltar
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back_ios, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text('Voltar ao produto', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('|', style: TextStyle(color: AppColors.grey300)),
                      const SizedBox(width: 10),
                      Text('Conferência do Pedido', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey600)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Conferência de Dados e Endereço',
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900),
                  ),
                  Text(
                    'Verifique suas informações e endereço de entrega antes de prosseguir para o checkout.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey600),
                  ),
                  const SizedBox(height: 24),

                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Coluna da Esquerda: Dados Pessoais e Endereço
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPersonalDataSection(),
                              const SizedBox(height: 20),
                              _buildAddressSection(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Coluna da Direita: Resumo da Oferta e Botão Finalizar
                        Expanded(
                          flex: 4,
                          child: _buildOrderSummarySection(paymentMethods),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildOrderSummarySection(paymentMethods),
                        const SizedBox(height: 20),
                        _buildPersonalDataSection(),
                        const SizedBox(height: 20),
                        _buildAddressSection(),
                        const SizedBox(height: 24),
                        _buildFinishButton(),
                      ],
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildPersonalDataSection() {
    return Container(
      padding: const EdgeInsets.all(22),
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
              const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '1. Seus Dados Pessoais',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.grey900),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Nome completo *', prefixIcon: Icon(Icons.person_outline, size: 18)),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu nome completo' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Telefone / WhatsApp *', prefixIcon: Icon(Icons.phone_outlined, size: 18)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu telefone' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _docCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'CPF / CNPJ *', prefixIcon: Icon(Icons.credit_card_outlined, size: 18)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu documento' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(22),
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
              const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '2. Endereço de Entrega',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.grey900),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
            decoration: const InputDecoration(labelText: 'Complemento (apto, bloco, etc)'),
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
                  decoration: const InputDecoration(labelText: 'UF *', counterText: ''),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'UF' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection(List<String> paymentMethods) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do Pedido',
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.grey900),
          ),
          const SizedBox(height: 16),

          // Informações do produto
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey200),
                ),
                clipBehavior: Clip.antiAlias,
                child: ProductImage(
                  dataUrl: widget.product.allImages.isNotEmpty ? widget.product.allImages.first : null,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grey900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vendedor: ${widget.offer['userName'] ?? "Verificado"}',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey600),
                    ),
                    Text(
                      'Condição: ${widget.offer['condition'] ?? "Novo"}',
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF3483FA), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),

          // Seleção da forma de pagamento
          Text('Forma de Pagamento:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey700)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: paymentMethods.map((m) {
              final sel = _selectedPaymentMethod == m;
              return ChoiceChip(
                label: Text(m),
                selected: sel,
                onSelected: (val) => setState(() => _selectedPaymentMethod = m),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),

          // Linhas de preço
          _priceLine('Valor da oferta:', _currency.format(_itemPrice)),
          const SizedBox(height: 6),
          _priceLine(
            'Frete:',
            widget.offer['freeShipping'] == true ? 'Grátis' : _currency.format(_shippingPrice),
            isGreen: widget.offer['freeShipping'] == true,
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.grey900)),
              Text(_currency.format(_totalPrice), style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF00A650))),
            ],
          ),
          const SizedBox(height: 20),

          _buildFinishButton(),
        ],
      ),
    );
  }

  Widget _priceLine(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey600)),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isGreen ? const Color(0xFF00A650) : AppColors.grey800,
          ),
        ),
      ],
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: _processing ? null : _confirmAndFinish,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF00A650),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _processing
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 18),
                  const SizedBox(width: 8),
                  Text('Finalizar Compra', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
      ),
    );
  }
}

