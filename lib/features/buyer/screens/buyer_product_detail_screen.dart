import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/models/product.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/complete_profile_dialog.dart';
import '../../../core/widgets/product_image.dart';

class BuyerProductDetailScreen extends StatefulWidget {
  const BuyerProductDetailScreen({super.key, required this.productId});
  final String productId;

  @override
  State<BuyerProductDetailScreen> createState() => _BuyerProductDetailScreenState();
}

class _BuyerProductDetailScreenState extends State<BuyerProductDetailScreen> {
  final _api = ApiClient();
  late Future<Product> _product;
  late Future<Map<String, List<Map<String, dynamic>>>> _offers;
  late Future<List<Map<String, dynamic>>> _reviews;
  late Future<List<Map<String, dynamic>>> _paymentMethods;
  late Future<List<Product>> _similarProducts;

  int _selectedImageIndex = 0;
  bool _descriptionExpanded = false;

  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  void _refreshAll() {
    _product = _api.getProduct(widget.productId);
    _offers = _api.getProductOffers(widget.productId);
    _reviews = _api.getProductReviews(widget.productId);
    _paymentMethods = _api.getPaymentMethods();
    _similarProducts = _product.then((p) => _api.getProducts(category: p.category));
  }

  void _refreshOffers() {
    setState(() {
      _offers = _api.getProductOffers(widget.productId);
    });
  }

  Future<bool> _ensureAuth(String action) async {
    try {
      final user = await _api.currentUser();
      if (user['uid'] != null) return true;
    } catch (_) {}
    if (!mounted) return false;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Login necessário', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ]),
        content: Text('Para $action, você precisa estar conectado à sua conta.',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey700)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Agora não')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Fazer Login')),
        ],
      ),
    );
    if (proceed == true && mounted) {
      final current = GoRouterState.of(context).uri.toString();
      context.push('/login?redirect=${Uri.encodeComponent(current)}');
    }
    return false;
  }

  // ── Abertura do Modal de Adicionar Oferta de Venda ─────────────────────────
  Future<void> _openCreateSellOfferDialog(Product product) async {
    if (!await _ensureAuth('adicionar uma oferta de venda')) return;
    if (!mounted) return;

    // Obriga o usuário a ter cadastro e endereço completos
    final complete = await CompleteProfileDialog.ensureComplete(
      context,
      actionLabel: 'adicionar uma oferta de venda',
    );
    if (!complete || !mounted) return;

    final priceCtrl = TextEditingController(text: product.price > 0 ? product.price.toStringAsFixed(2) : '');
    final shippingCtrl = TextEditingController(text: '0,00');
    final notesCtrl = TextEditingController();
    bool freeShipping = true;
    String condition = 'Novo';
    final selectedPaymentMethods = <String>{'Pix', 'Cartão de Crédito'};

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.sell_outlined, color: Color(0xFF00A650)),
              const SizedBox(width: 8),
              Text('Adicionar Oferta de Venda', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grey700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Preço de Venda (R\$) *',
                      hintText: '0,00',
                      prefixIcon: Icon(Icons.attach_money, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: condition,
                    decoration: const InputDecoration(labelText: 'Condição do Produto'),
                    items: const [
                      DropdownMenuItem(value: 'Novo', child: Text('Novo (Na embalagem lacrada)')),
                      DropdownMenuItem(value: 'Seminovo', child: Text('Seminovo (Excelente estado)')),
                      DropdownMenuItem(value: 'Usado', child: Text('Usado (Funcionando perfeitamente)')),
                    ],
                    onChanged: (v) => setDlgState(() => condition = v ?? 'Novo'),
                  ),
                  const SizedBox(height: 14),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Oferecer Frete Grátis'),
                    subtitle: Text(freeShipping ? 'Você assume o custo do envio' : 'Comprador paga o frete', style: GoogleFonts.inter(fontSize: 11)),
                    value: freeShipping,
                    onChanged: (v) => setDlgState(() => freeShipping = v),
                  ),
                  if (!freeShipping) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: shippingCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Valor do Frete (R\$) *',
                        hintText: 'Ex: 25,00',
                        prefixIcon: Icon(Icons.local_shipping_outlined, size: 20),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  Text('Formas de Pagamento Aceitas:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey700)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Pix', 'Cartão de Crédito', 'Boleto', 'Dinheiro na entrega'].map((m) {
                      final sel = selectedPaymentMethods.contains(m);
                      return FilterChip(
                        label: Text(m),
                        selected: sel,
                        onSelected: (val) => setDlgState(() {
                          if (val) {
                            selectedPaymentMethods.add(m);
                          } else if (selectedPaymentMethods.length > 1) {
                            selectedPaymentMethods.remove(m);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Observações / Detalhes adicionais (opcional)',
                      hintText: 'Ex: Acompanha caixa original e carregador...',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00A650)),
              onPressed: () async {
                final price = double.tryParse(priceCtrl.text.replaceAll(',', '.')) ?? 0;
                if (price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Informe um preço válido maior que zero.')),
                  );
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: const Text('Publicar Oferta de Venda'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      try {
        final price = double.parse(priceCtrl.text.replaceAll(',', '.'));
        final shipping = freeShipping ? 0.0 : (double.tryParse(shippingCtrl.text.replaceAll(',', '.')) ?? 0.0);

        await _api.createProductOffer(
          product.id,
          type: 'sell',
          price: price,
          freeShipping: freeShipping,
          shippingPrice: shipping,
          paymentMethods: selectedPaymentMethods.toList(),
          condition: condition,
          notes: notesCtrl.text.trim(),
        );

        _refreshOffers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sua oferta de venda foi publicada com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  // ── Abertura do Modal de Fazer Oferta de Compra ────────────────────────────
  Future<void> _openCreateBuyOfferDialog(Product product) async {
    if (!await _ensureAuth('fazer uma oferta de compra')) return;
    if (!mounted) return;

    // Obriga o usuário a ter cadastro e endereço completos
    final complete = await CompleteProfileDialog.ensureComplete(
      context,
      actionLabel: 'fazer uma oferta de compra',
    );
    if (!complete || !mounted) return;

    final priceCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    bool wantFreeShipping = true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, color: Color(0xFF3483FA)),
              const SizedBox(width: 8),
              Text('Fazer Oferta de Compra', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grey700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.price > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Preço sugerido: ${_currency.format(product.price)}',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600),
                    ),
                  ],
                  const SizedBox(height: 16),

                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Quanto você quer pagar? (R\$) *',
                      hintText: '0,00',
                      prefixIcon: Icon(Icons.attach_money, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Desejo Frete Grátis'),
                    subtitle: Text(
                      wantFreeShipping ? 'Sua oferta já inclui o frete' : 'Você aceita combinar o frete com o vendedor',
                      style: GoogleFonts.inter(fontSize: 11),
                    ),
                    value: wantFreeShipping,
                    onChanged: (v) => setDlgState(() => wantFreeShipping = v),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: notesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Requisitos / Mensagem para o vendedor (opcional)',
                      hintText: 'Ex: Pago à vista no Pix assim que aceitar...',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3483FA)),
              onPressed: () {
                final price = double.tryParse(priceCtrl.text.replaceAll(',', '.')) ?? 0;
                if (price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Informe um valor válido maior que zero.')),
                  );
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: const Text('Enviar Oferta de Compra'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      try {
        final price = double.parse(priceCtrl.text.replaceAll(',', '.'));
        await _api.createProductOffer(
          product.id,
          type: 'buy',
          price: price,
          freeShipping: wantFreeShipping,
          notes: notesCtrl.text.trim(),
        );

        _refreshOffers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sua oferta de compra foi registrada! Os vendedores serão notificados.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  // ── Fluxo ao Clicar em "Comprar" em uma Oferta de Venda ────────────────────
  Future<void> _buyOffer(Product product, Map<String, dynamic> offer) async {
    if (!await _ensureAuth('comprar este produto')) return;
    if (!mounted) return;

    // Obriga o usuário a ter cadastro e endereço completos
    final complete = await CompleteProfileDialog.ensureComplete(
      context,
      actionLabel: 'finalizar a compra',
    );
    if (!complete || !mounted) return;

    // Abre a tela de conferência de dados pessoais e endereço
    context.push(
      '/buyer/checkout/confirm',
      extra: {
        'product': product,
        'offer': offer,
      },
    );
  }

  void _openImageZoom(BuildContext context, String? dataUrl, List<String> images) {
    if (dataUrl == null || dataUrl.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (ctx) => _ImageZoomDialog(
        initialImageUrl: dataUrl,
        images: images,
        initialIndex: _selectedImageIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Product>(
        future: _product,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text(snapshot.error?.toString() ?? 'Produto não encontrado.'));
          }
          final product = snapshot.data!;
          final images = product.allImages;
          final sw = MediaQuery.sizeOf(context).width;
          final isLarge = sw >= 1100;
          final isMedium = sw >= 768 && sw < 1100;

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isLarge ? 36 : (isMedium ? 20 : 12),
              vertical: 20,
            ),
            children: [
              // ── Breadcrumb ──
              Row(children: [
                InkWell(
                  onTap: () => context.go('/buyer/products'),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.arrow_back_ios, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Voltar', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ]),
                ),
                const SizedBox(width: 10),
                const Text('|', style: TextStyle(color: AppColors.grey300)),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => context.go('/buyer/products'),
                  child: Text('Produtos', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
                ),
                const Text('  >  ', style: TextStyle(color: AppColors.grey400, fontSize: 12)),
                Text(product.category, style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey600)),
              ]),
              const SizedBox(height: 16),

              // ── Bloco Superior: Fotos e Informações com Sugestão de Preço ──
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.grey200),
                  boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
                ),
                padding: EdgeInsets.all(isLarge ? 28 : (isMedium ? 20 : 16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLarge || isMedium)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: isLarge ? 420 : 360, child: _buildGalleryDesktop(images)),
                          const SizedBox(width: 28),
                          Expanded(child: _buildCenterDetails(product)),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGalleryMobile(images),
                          const SizedBox(height: 20),
                          _buildCenterDetails(product),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Bloco Inferior: Ofertas de Compra & Venda lado a lado com Ficha & Descrição ──
              FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                future: _offers,
                builder: (context, snapOffers) {
                  final offersData = snapOffers.data ?? {'sellOffers': [], 'buyOffers': []};
                  final sellOffers = offersData['sellOffers'] ?? [];
                  final buyOffers = offersData['buyOffers'] ?? [];

                  if (isLarge) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Coluna da Esquerda: Ficha Técnica + Descrição + Avaliações
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.specs.isNotEmpty) ...[
                                _buildSpecsSection(product),
                                const SizedBox(height: 24),
                              ],
                              _buildDescriptionSection(product),
                              const SizedBox(height: 24),
                              _buildReviewsSection(product),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Coluna da Direita: Os 2 Elementos de OFERTAS DE VENDA e OFERTAS DE COMPRA
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSellOffersElement(product, sellOffers),
                              const SizedBox(height: 20),
                              _buildBuyOffersElement(product, buyOffers),
                              const SizedBox(height: 20),
                              _buildPaymentMethodsCard(),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Mobile / Médio: Empilhado de forma fluida
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSellOffersElement(product, sellOffers),
                        const SizedBox(height: 20),
                        _buildBuyOffersElement(product, buyOffers),
                        const SizedBox(height: 24),
                        if (product.specs.isNotEmpty) ...[
                          _buildSpecsSection(product),
                          const SizedBox(height: 20),
                        ],
                        _buildDescriptionSection(product),
                        const SizedBox(height: 20),
                        _buildReviewsSection(product),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 32),

              // ── Carrossel: Produtos semelhantes ──
              _buildSimilarProducts(product.id),
              const SizedBox(height: 40),
            ],
          );
        },
      );

  // ─────────────────────────────────────────────────────────────────────────
  // ELEMENTO 1: OFERTAS DE VENDA (Vendedores disponíveis)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSellOffersElement(Product product, List<Map<String, dynamic>> offers) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00A650).withValues(alpha: 0.35)),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A650).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sell_outlined, color: Color(0xFF00A650), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Ofertas de Venda',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.grey900),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A650),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${offers.length} disponível${offers.length == 1 ? "" : "is"}',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Vendedores anunciando este produto com entrega imediata',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Botão para qualquer usuário adicionar oferta de venda
          SizedBox(
            width: double.infinity,
            height: 42,
            child: FilledButton.icon(
              onPressed: () => _openCreateSellOfferDialog(product),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00A650),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: Text('Adicionar oferta de venda', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),

          // Lista de ofertas de venda
          if (offers.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.storefront_outlined, color: AppColors.grey400, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Ainda não há ofertas de venda cadastradas.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey600, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Clique acima para ser o primeiro vendedor a anunciar!',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: offers.map((offer) => _sellOfferCard(product, offer)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _sellOfferCard(Product product, Map<String, dynamic> offer) {
    final price = offer['price'] is num ? (offer['price'] as num).toDouble() : 0.0;
    final freeShipping = offer['freeShipping'] == true;
    final shippingPrice = offer['shippingPrice'] is num ? (offer['shippingPrice'] as num).toDouble() : 0.0;
    final vendorName = offer['userName']?.toString() ?? 'Vendedor Verificado';
    final condition = offer['condition']?.toString() ?? 'Novo';
    final payments = (offer['paymentMethods'] as List? ?? ['Pix', 'Cartão']).map((e) => e.toString()).toList();
    final notes = offer['notes']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFDFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF00A650).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, size: 14, color: Color(0xFF00A650)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            vendorName,
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grey900),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.grey200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(condition, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.grey700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          _currency.format(price),
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF00A650)),
                        ),
                        const SizedBox(width: 8),
                        if (freeShipping)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A650).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Frete Grátis',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF00A650)),
                            ),
                          )
                        else
                          Text(
                            '+ ${_currency.format(shippingPrice)} frete',
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey600),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Botão Comprar nesta oferta
              FilledButton(
                onPressed: () => _buyOffer(product, offer),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00A650),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text('Comprar', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              notes,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey600, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: payments.map((p) => Text('• $p', style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500))).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ELEMENTO 2: OFERTAS DE COMPRA (Compradores interessados)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBuyOffersElement(Product product, List<Map<String, dynamic>> offers) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3483FA).withValues(alpha: 0.35)),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3483FA).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.handshake_outlined, color: Color(0xFF3483FA), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Ofertas de Compra',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.grey900),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3483FA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${offers.length} proposta${offers.length == 1 ? "" : "s"}',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Compradores interessados aguardando vendedores aceitarem',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Botão para qualquer comprador registrar sua oferta
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: () => _openCreateBuyOfferDialog(product),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3483FA),
                side: const BorderSide(color: Color(0xFF3483FA), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text('Fazer oferta de compra', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),

          // Lista de ofertas de compra
          if (offers.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.pan_tool_outlined, color: AppColors.grey400, size: 30),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhuma oferta de compra no momento.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey600, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Defina quanto você deseja pagar e aguarde um vendedor!',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: offers.map((offer) => _buyOfferCard(offer)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buyOfferCard(Map<String, dynamic> offer) {
    final price = offer['price'] is num ? (offer['price'] as num).toDouble() : 0.0;
    final buyerName = offer['userName']?.toString() ?? 'Comprador';
    final notes = offer['notes']?.toString() ?? '';
    final freeShipping = offer['freeShipping'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3483FA).withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_pin, size: 14, color: Color(0xFF3483FA)),
                    const SizedBox(width: 4),
                    Text(buyerName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.grey900)),
                    const SizedBox(width: 8),
                    if (freeShipping)
                      Text('• Deseja frete grátis', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF00A650), fontWeight: FontWeight.w600)),
                  ],
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(notes, style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey700)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currency.format(price),
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF3483FA)),
              ),
              Text('Oferta proposta', style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500)),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Galeria Desktop com clique para ampliar (sem zoom de scroll)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGalleryDesktop(List<String> images) {
    final cur = images.isNotEmpty && _selectedImageIndex < images.length
        ? images[_selectedImageIndex]
        : (images.isNotEmpty ? images.first : null);

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (images.length > 1)
        Container(
          width: 56,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: images.asMap().entries.map((e) {
              final sel = _selectedImageIndex == e.key;
              return MouseRegion(
                onEnter: (_) => setState(() => _selectedImageIndex = e.key),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedImageIndex = e.key),
                  child: Container(
                    width: 52,
                    height: 52,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: sel ? const Color(0xFF3483FA) : AppColors.grey300, width: sel ? 2.2 : 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ProductImage(dataUrl: e.value, fit: BoxFit.contain),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      Expanded(
        child: GestureDetector(
          onTap: () => _openImageZoom(context, cur, images),
          child: MouseRegion(
            cursor: SystemMouseCursors.zoomIn,
            child: Container(
              height: 440,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.antiAlias,
              child: SizedBox.expand(
                child: ProductImage(dataUrl: cur, fit: BoxFit.contain, icon: Icons.inventory_2_outlined),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Galeria Mobile
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGalleryMobile(List<String> images) {
    final cur = images.isNotEmpty && _selectedImageIndex < images.length
        ? images[_selectedImageIndex]
        : (images.isNotEmpty ? images.first : null);
    return Column(children: [
      GestureDetector(
        onTap: () => _openImageZoom(context, cur, images),
        child: MouseRegion(
          cursor: SystemMouseCursors.zoomIn,
          child: Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            clipBehavior: Clip.antiAlias,
            child: SizedBox.expand(child: ProductImage(dataUrl: cur, fit: BoxFit.contain)),
          ),
        ),
      ),
      if (images.length > 1) ...[
        const SizedBox(height: 10),
        SizedBox(
          height: 54,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (_, idx) {
              final sel = _selectedImageIndex == idx;
              return GestureDetector(
                onTap: () => setState(() => _selectedImageIndex = idx),
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: sel ? const Color(0xFF3483FA) : AppColors.grey300, width: sel ? 2 : 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ProductImage(dataUrl: images[idx], fit: BoxFit.contain),
                ),
              );
            },
          ),
        ),
      ],
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Coluna Central: Informações do produto + Sugestão de Preço
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCenterDetails(Product product) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (product.brand != null && product.brand!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'Marca: ${product.brand}',
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF3483FA), fontWeight: FontWeight.w600),
          ),
        ),
      Row(children: [
        Text('${product.condition ?? "Novo"}  |  Catálogo de Negociação Livre',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
        const Spacer(),
        const Icon(Icons.favorite_border, color: Color(0xFF3483FA), size: 22),
      ]),
      const SizedBox(height: 6),
      Text(product.name, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.grey900, height: 1.25)),
      const SizedBox(height: 8),

      // Avaliação em estrelas
      Row(children: [
        Text('4.8', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF3483FA))),
        const SizedBox(width: 4),
        ...List.generate(5, (_) => const Icon(Icons.star, size: 16, color: Color(0xFF3483FA))),
        const SizedBox(width: 6),
        Text('(442)', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
      ]),
      const SizedBox(height: 18),

      // ── Sugestão para o Preço (conforme modelo de negociação livre) ──
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, size: 16, color: Color(0xFF3483FA)),
                const SizedBox(width: 6),
                Text('Sugestão para o preço:', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  product.price > 0 ? _currency.format(product.price) : 'Livre para propostas',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text('valor de referência', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Os preços reais são definidos pelos vendedores nas ofertas abaixo. Você também pode propor o valor que quer pagar.',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey600),
            ),
          ],
        ),
      ),

      // Quick specs
      if (product.specs.isNotEmpty) ...[
        const SizedBox(height: 20),
        ...product.specs.entries.take(4).map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey700),
                  children: [
                    TextSpan(text: '${s.key}: ', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF333333))),
                    TextSpan(text: s.value),
                  ],
                ),
              ),
            )),
      ],
      const SizedBox(height: 20),
      Text('O que você precisa saber sobre este produto',
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grey900)),
      const SizedBox(height: 10),
      _buildHighlightsList(product),
    ]);
  }

  Widget _buildHighlightsList(Product product) {
    final bullets = <String>[];
    for (final e in product.specs.entries) { bullets.add('${e.key}: ${e.value}'); }
    if (bullets.length < 3 && product.description.isNotEmpty) {
      final lines = product.description.split('\n').map((l) => l.trim()).where((l) => l.length > 10 && l.length < 150).take(4);
      for (final l in lines) {
        if (!bullets.contains(l)) bullets.add(l.replaceFirst(RegExp(r'^[-•*]\s*'), ''));
      }
    }
    if (bullets.isEmpty) {
      bullets.addAll(['Produto autêntico com garantia.', 'Envio rápido com rastreamento.', 'Disponível para pronta entrega.']);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bullets.take(5).map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(padding: EdgeInsets.only(top: 5, right: 8), child: Icon(Icons.circle, size: 6, color: AppColors.grey600)),
              Expanded(child: Text(b, style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey700, height: 1.4))),
            ]),
          )).toList(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Card de Formas de Pagamento
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPaymentMethodsCard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _paymentMethods,
      builder: (context, snap) {
        final methods = snap.data ?? [];
        if (methods.isEmpty && snap.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final display = methods.isNotEmpty
            ? methods
            : [
                {'id': 'pix', 'name': 'Pix'},
                {'id': 'credit_card', 'name': 'Cartão de Crédito'},
                {'id': 'boleto', 'name': 'Boleto Bancário'},
              ];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey300),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Meios de pagamento aceitos',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grey900)),
            const SizedBox(height: 14),
            ...display.map((m) => _paymentMethodRow(m)),
          ]),
        );
      },
    );
  }

  Widget _paymentMethodRow(Map<String, dynamic> method) {
    final id = method['id']?.toString() ?? '';
    final name = method['name']?.toString() ?? '';
    final sub = method['subtitle']?.toString();

    String subtitle;
    if (sub != null && sub.isNotEmpty) {
      subtitle = sub;
    } else {
      subtitle = switch (id) {
        'pix' => 'Transferência instantânea',
        'credit_card' => 'Pague em até 12x sem juros',
        'debit_card' => 'Débito em conta corrente',
        'boleto' => 'Vence em até 3 dias úteis',
        'bank_transfer' => 'TED / DOC',
        'mercado_pago' => 'Parcelado com proteção',
        'cash' => 'Apenas para retirada presencial',
        _ => '',
      };
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(_methodIcon(id), size: 16, color: AppColors.grey700),
          const SizedBox(width: 8),
          Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grey900)),
        ]),
        if (subtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
          ),
      ]),
    );
  }

  IconData _methodIcon(String id) => switch (id) {
        'pix' => Icons.qr_code_2_rounded,
        'credit_card' => Icons.credit_card_rounded,
        'debit_card' => Icons.credit_card_outlined,
        'boleto' => Icons.receipt_long_rounded,
        'bank_transfer' => Icons.account_balance_rounded,
        'mercado_pago' => Icons.wallet_rounded,
        'cash' => Icons.payments_rounded,
        _ => Icons.payment_rounded,
      };

  // ─────────────────────────────────────────────────────────────────────────
  // Ficha Técnica (ACIMA da Descrição)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSpecsSection(Product product) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Características do produto',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.grey900)),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.grey200)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: product.specs.entries.toList().asMap().entries.map((entry) {
              final isEven = entry.key % 2 == 0;
              final spec = entry.value;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: isEven ? const Color(0xFFF7F7F7) : Colors.white,
                child: Row(children: [
                  Expanded(
                      flex: 4,
                      child: Text(spec.key,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grey800))),
                  Expanded(
                      flex: 6,
                      child: Text(spec.value,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey900, fontWeight: FontWeight.w500))),
                ]),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Descrição (Não rolável - altura máx. 500px recortada com fade + expandir)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDescriptionSection(Product product) {
    const maxH = 500.0;
    final isLong = product.description.length > 400 || product.description.split('\n').length > 10;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Descrição', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.grey900)),
          const SizedBox(height: 14),
          if (!isLong)
            SelectionArea(
              child: Text(
                product.description,
                style: GoogleFonts.inter(fontSize: 14, height: 1.7, color: const Color(0xFF4A4A4A)),
              ),
            )
          else ...[
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _descriptionExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: ClipRect(
                child: SizedBox(
                  height: maxH,
                  child: ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.transparent],
                      stops: [0.75, 1.0],
                    ).createShader(rect),
                    blendMode: BlendMode.dstIn,
                    child: SelectionArea(
                      child: Text(
                        product.description,
                        style: GoogleFonts.inter(fontSize: 14, height: 1.7, color: const Color(0xFF4A4A4A)),
                      ),
                    ),
                  ),
                ),
              ),
              secondChild: SelectionArea(
                child: Text(
                  product.description,
                  style: GoogleFonts.inter(fontSize: 14, height: 1.7, color: const Color(0xFF4A4A4A)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _descriptionExpanded ? 'Ver menos' : 'Ver descrição completa',
                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF3483FA), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _descriptionExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF3483FA),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Seção de Avaliações / Qualificações
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildReviewsSection(Product product) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: _ReviewsSection(
        productId: product.id,
        reviews: _reviews,
        api: _api,
        onReviewAdded: () => setState(() {
          _reviews = _api.getProductReviews(product.id);
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Carrossel: Produtos semelhantes
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSimilarProducts(String currentProductId) {
    return FutureBuilder<List<Product>>(
      future: _similarProducts,
      builder: (context, snap) {
        final all = snap.data ?? [];
        final similar = all.where((p) => p.id != currentProductId).take(10).toList();
        if (similar.isEmpty) return const SizedBox.shrink();

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Produtos semelhantes',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.grey900)),
          const SizedBox(height: 14),
          SizedBox(
            height: 270,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: similar.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (ctx, idx) => _SimilarProductCard(product: similar[idx]),
            ),
          ),
        ]);
      },
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Card de Produto Similar (Carrossel)
// ───────────────────────────────────────────────────────────────────────────
class _SimilarProductCard extends StatelessWidget {
  const _SimilarProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return GestureDetector(
      onTap: () => context.go('/buyer/product/${product.id}'),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.grey200),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: ProductImage(
                dataUrl: product.allImages.isNotEmpty ? product.allImages.first : null,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grey900, height: 1.3),
                ),
                const Spacer(),
                Text(
                  product.price > 0 ? currency.format(product.price) : 'Sob proposta',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grey900),
                ),
                Text(
                  'Sugestão de preço',
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Seção de Avaliações
// ───────────────────────────────────────────────────────────────────────────
class _ReviewsSection extends StatefulWidget {
  const _ReviewsSection({
    required this.productId,
    required this.reviews,
    required this.api,
    required this.onReviewAdded,
  });

  final String productId;
  final Future<List<Map<String, dynamic>>> reviews;
  final ApiClient api;
  final VoidCallback onReviewAdded;

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  int _newStars = 5;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;
  bool _showForm = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_commentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escreva um comentário.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final user = await widget.api.currentUser();
      if (user['uid'] == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Faça login para avaliar o produto.'), backgroundColor: Colors.orange),
          );
        }
        setState(() => _submitting = false);
        return;
      }
      await widget.api.addProductReview(widget.productId, stars: _newStars, comment: _commentCtrl.text.trim());
      _commentCtrl.clear();
      setState(() {
        _showForm = false;
        _newStars = 5;
      });
      widget.onReviewAdded();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avaliação publicada com sucesso!'), backgroundColor: AppColors.success),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: widget.reviews,
      builder: (context, snap) {
        final reviews = snap.data ?? [];
        final avgStars = reviews.isEmpty
            ? 0.0
            : reviews.fold<double>(0, (s, r) => s + (num.tryParse(r['stars']?.toString() ?? '0') ?? 0)) / reviews.length;

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Qualificações do produto',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.grey900)),
                if (reviews.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    Text(avgStars.toStringAsFixed(1),
                        style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.grey900)),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _starRow(avgStars.round()),
                      Text('${reviews.length} avaliações',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
                    ]),
                  ]),
                ],
              ]),
            ),
            if (!_showForm)
              FilledButton.icon(
                onPressed: () => setState(() => _showForm = true),
                icon: const Icon(Icons.rate_review_outlined, size: 16),
                label: const Text('Avaliar produto'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3483FA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
          ]),
          const SizedBox(height: 16),

          if (_showForm)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF3483FA).withValues(alpha: 0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Sua avaliação', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setState(() => _newStars = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          i < _newStars ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: const Color(0xFFFFA500),
                          size: 30,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _commentCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Escreva seu comentário sobre o produto...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3483FA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(_submitting ? 'Publicando…' : 'Publicar avaliação',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => setState(() => _showForm = false),
                    child: const Text('Cancelar'),
                  ),
                ]),
              ]),
            ),

          if (snap.connectionState == ConnectionState.waiting)
            const Center(child: CircularProgressIndicator())
          else if (reviews.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text('Nenhuma avaliação ainda. Seja o primeiro a avaliar!',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
              ),
            )
          else
            Column(
              children: reviews.map((r) => _reviewCard(r)).toList(),
            ),
        ]);
      },
    );
  }

  Widget _reviewCard(Map<String, dynamic> r) {
    final stars = int.tryParse(r['stars']?.toString() ?? '0') ?? 0;
    final name = r['userName']?.toString() ?? 'Usuário';
    final comment = r['comment']?.toString() ?? '';
    final ts = int.tryParse(r['createdAt']?.toString() ?? '0') ?? 0;
    final date = ts > 0
        ? DateFormat('dd/MM/yyyy', 'pt_BR').format(DateTime.fromMillisecondsSinceEpoch(ts))
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF3483FA).withValues(alpha: 0.1),
            child: Text(name[0].toUpperCase(), style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF3483FA), fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
              if (date.isNotEmpty) Text(date, style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500)),
            ]),
          ),
          _starRow(stars),
        ]),
        const SizedBox(height: 8),
        Text(comment, style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey800, height: 1.4)),
      ]),
    );
  }

  Widget _starRow(int stars) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          5,
          (i) => Icon(
            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            color: const Color(0xFFFFA500),
            size: 14,
          ),
        ),
      );
}

// ───────────────────────────────────────────────────────────────────────────
// Diálogo de Zoom em Tela Cheia
// ─────────────────────────────────────────────────────────────────────────
class _ImageZoomDialog extends StatefulWidget {
  const _ImageZoomDialog({required this.initialImageUrl, required this.images, required this.initialIndex});
  final String initialImageUrl;
  final List<String> images;
  final int initialIndex;

  @override
  State<_ImageZoomDialog> createState() => _ImageZoomDialogState();
}

class _ImageZoomDialogState extends State<_ImageZoomDialog> {
  late int _currentIndex;
  final TransformationController _transCtrl = TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.isNotEmpty ? widget.images.length - 1 : 0);
  }

  @override
  void dispose() {
    _transCtrl.dispose();
    super.dispose();
  }

  void _resetZoom() => _transCtrl.value = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    final cur = widget.images.isNotEmpty ? widget.images[_currentIndex] : widget.initialImageUrl;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(12),
      child: Stack(alignment: Alignment.center, children: [
        InteractiveViewer(
          transformationController: _transCtrl,
          minScale: 1.0,
          maxScale: 6.0,
          child: Center(child: ProductImage(dataUrl: cur, fit: BoxFit.contain)),
        ),
        Positioned(
          top: 10, right: 10,
          child: Material(
            color: Colors.black54, shape: const CircleBorder(),
            child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
          ),
        ),
        Positioned(
          top: 10, left: 10,
          child: Material(
            color: Colors.black54, borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: _resetZoom,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(children: [
                  const Icon(Icons.restart_alt, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text('100%', style: GoogleFonts.inter(color: Colors.white, fontSize: 12)),
                ]),
              ),
            ),
          ),
        ),
        if (widget.images.length > 1) ...[
          if (_currentIndex > 0)
            Positioned(
              left: 10,
              child: Material(
                color: Colors.black54, shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
                  onPressed: () { _resetZoom(); setState(() => _currentIndex--); },
                ),
              ),
            ),
          if (_currentIndex < widget.images.length - 1)
            Positioned(
              right: 10,
              child: Material(
                color: Colors.black54, shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white, size: 32),
                  onPressed: () { _resetZoom(); setState(() => _currentIndex++); },
                ),
              ),
            ),
        ],
      ]),
    );
  }
}
