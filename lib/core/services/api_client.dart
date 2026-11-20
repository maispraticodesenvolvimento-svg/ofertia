import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/product.dart';
import 'api_http_client.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? _sharedClient;

  static final http.Client _sharedClient = createApiHttpClient();
  final http.Client _client;

  Uri _uri(String path) {
    final configuredBase = AppConfig.apiBaseUrl;
    final base = configuredBase.endsWith('/')
        ? configuredBase.substring(0, configuredBase.length - 1)
        : configuredBase;
    return Uri.parse('$base$path');
  }

  Uri uri(String path) => _uri(path);

  Future<Map<String, dynamic>?> fetchCep(String cep) async {
    try {
      final response = await _client.get(_uri('/api/cep/${Uri.encodeComponent(cep)}'));
      if (response.statusCode != 200) return null;
      final data = _decodeResponse(response);
      return data['item'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(_uri('/api/health'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return false;
      final body = jsonDecode(response.body);
      return body is Map && body['status'] == 'ok' && body['database'] == 'connected';
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> currentUser() async {
    final response = await _client.get(_uri('/api/auth/me'));
    return _decodeResponse(response);
  }

  Future<void> ensureProfile() async {
    final response = await _client
        .post(
          _uri('/api/auth/profile'),
          headers: _contentHeaders,
          body: jsonEncode({}),
        )
        .timeout(const Duration(seconds: 8));
    _decodeResponse(response);
  }

  Future<Map<String, dynamic>> login(String email, String password) async =>
      _decodeResponse(await _client.post(_uri('/api/auth/login'), headers: _contentHeaders, body: jsonEncode({'email': email, 'password': password})));

  Future<Map<String, dynamic>> register(String email, String password) async =>
      _decodeResponse(await _client.post(_uri('/api/auth/register'), headers: _contentHeaders, body: jsonEncode({'email': email, 'password': password})));

  Future<void> recoverPassword(String email) async =>
      _decodeResponse(await _client.post(_uri('/api/auth/recover'), headers: _contentHeaders, body: jsonEncode({'email': email})));

  Future<void> logout() async {
    _decodeResponse(await _client.post(_uri('/api/auth/logout')));
  }

  Future<List<Product>> getProducts({
    bool all = false,
    bool offers = false,
    bool featured = false,
    String? category,
    String? query,
  }) async {
    final parameters = <String, String>{};
    if (all) parameters['all'] = 'true';
    if (offers) parameters['offers'] = 'true';
    if (featured) parameters['featured'] = 'true';
    if (category != null && category.isNotEmpty && category != 'Todos') {
      parameters['category'] = category;
    }
    if (query != null && query.trim().isNotEmpty) parameters['q'] = query.trim();
    final uri = _uri('/api/products').replace(queryParameters: parameters.isEmpty ? null : parameters);
    final response = await _client.get(uri);
    final result = _decodeResponse(response);
    return _readItems(result).map(Product.fromJson).toList();
  }

  Future<Product> getProduct(String id) async {
    final response = await _client.get(
      _uri('/api/products/${Uri.encodeComponent(id)}'),
    );
    return Product.fromJson(_decodeResponse(response)['item'] as Map<String, dynamic>);
  }

  Future<Product> saveProduct(Product product, {required bool create}) async {
    final uri = create ? _uri('/api/products') : _uri('/api/products/${Uri.encodeComponent(product.id)}');
    final response = create
        ? await _client.post(uri, headers: _contentHeaders, body: jsonEncode(product.toJson()))
        : await _client.put(uri, headers: _contentHeaders, body: jsonEncode(product.toJson()));
    return Product.fromJson(_decodeResponse(response)['item'] as Map<String, dynamic>);
  }

  Future<void> deleteProduct(String id) async {
    final response = await _client.delete(
      _uri('/api/products/${Uri.encodeComponent(id)}'),
    );
    _decodeResponse(response);
  }

  Future<List<Map<String, dynamic>>> getOrders({bool all = false}) async {
    final response = await _client.get(
      _uri('/api/orders').replace(queryParameters: all ? {'all': 'true'} : null),
    );
    return _readItems(_decodeResponse(response));
  }

  Future<Map<String, dynamic>> createOrder(String productId, {int quantity = 1}) async {
    final response = await _client.post(
      _uri('/api/orders'),
      headers: _contentHeaders,
      body: jsonEncode({'productId': productId, 'quantity': quantity}),
    );
    return _decodeResponse(response)['item'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getUsers({required String role}) async {
    final response = await _client.get(
      _uri('/api/users').replace(queryParameters: {'role': role}),
    );
    return _readItems(_decodeResponse(response));
  }

  Future<List<Map<String, dynamic>>> getNegotiations({bool all = false}) async {
    final response = await _client.get(
      _uri('/api/negotiations').replace(queryParameters: all ? {'all': 'true'} : null),
    );
    return _readItems(_decodeResponse(response));
  }

  Future<Map<String, dynamic>> createNegotiation(String productId, double offerPrice) async {
    final response = await _client.post(
      _uri('/api/negotiations'),
      headers: _contentHeaders,
      body: jsonEncode({'productId': productId, 'offerPrice': offerPrice}),
    );
    return _decodeResponse(response)['item'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAdminSummary() async {
    final response = await _client.get(
      _uri('/api/admin/summary'),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> getAdminSettings() async {
    final response = await _client.get(_uri('/api/admin/settings'));
    return _decodeResponse(response)['item'] as Map<String, dynamic>;
  }

  Future<void> saveAdminSettings(Map<String, dynamic> settings) async {
    final response = await _client.put(
      _uri('/api/admin/settings'),
      headers: _contentHeaders,
      body: jsonEncode(settings),
    );
    _decodeResponse(response);
  }

  Future<List<Map<String, dynamic>>> getBanners() async {
    final response = await _client.get(_uri('/api/banners'));
    return _readItems(_decodeResponse(response));
  }

  Future<void> deleteBanner(String id) async {
    final response = await _client.delete(
      _uri('/api/banners/${Uri.encodeComponent(id)}'),
    );
    _decodeResponse(response);
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _client.get(
      _uri('/api/notifications'),
    );
    return _readItems(_decodeResponse(response));
  }

  Future<void> markNotificationRead(String id) async {
    final response = await _client.patch(
      _uri('/api/notifications/${Uri.encodeComponent(id)}'),
    );
    _decodeResponse(response);
  }

  Future<void> deleteNotification(String id) async {
    final response = await _client.delete(
      _uri('/api/notifications/${Uri.encodeComponent(id)}'),
    );
    _decodeResponse(response);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _client.get(_uri('/api/categories'));
    return _readItems(_decodeResponse(response));
  }

  Future<Map<String, dynamic>> createCategory({
    required String name,
    String? description,
    String? icon,
  }) async {
    final response = await _client.post(
      _uri('/api/categories'),
      headers: _contentHeaders,
      body: jsonEncode({
        'name': name,
        if (description != null) 'description': description,
        if (icon != null) 'icon': icon,
      }),
    );
    final result = _decodeResponse(response);
    return result['item'] as Map<String, dynamic>;
  }

  Future<void> deleteCategory(String id) async {
    final response = await _client.delete(
      _uri('/api/categories/${Uri.encodeComponent(id)}'),
    );
    _decodeResponse(response);
  }

  // ── Reviews ───────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getProductReviews(String productId) async {
    final response = await _client.get(
      _uri('/api/products/${Uri.encodeComponent(productId)}/reviews'),
    );
    return _readItems(_decodeResponse(response));
  }

  Future<Map<String, dynamic>> addProductReview(
    String productId, {
    required int stars,
    required String comment,
  }) async {
    final response = await _client.post(
      _uri('/api/products/${Uri.encodeComponent(productId)}/reviews'),
      headers: _contentHeaders,
      body: jsonEncode({'stars': stars, 'comment': comment}),
    );
    return _decodeResponse(response)['item'] as Map<String, dynamic>;
  }

  Future<void> deleteProductReview(String productId, String reviewId) async {
    final response = await _client.delete(
      _uri('/api/products/${Uri.encodeComponent(productId)}/reviews').replace(
        queryParameters: {'reviewId': reviewId},
      ),
    );
    _decodeResponse(response);
  }

  // ── Perfil do Usuário e Endereço Completo ─────────────────────────────────
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.get(_uri('/api/auth/profile'));
    final data = _decodeResponse(response);
    return data['item'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    final response = await _client.put(
      _uri('/api/auth/profile'),
      headers: _contentHeaders,
      body: jsonEncode(profileData),
    );
    final data = _decodeResponse(response);
    return data['item'] as Map<String, dynamic>;
  }

  // ── Ofertas de Compra e Venda por Produto ─────────────────────────────────
  Future<Map<String, List<Map<String, dynamic>>>> getProductOffers(String productId) async {
    final response = await _client.get(
      _uri('/api/products/${Uri.encodeComponent(productId)}/offers'),
    );
    final data = _decodeResponse(response);
    final sell = (data['sellOffers'] as List? ?? []).whereType<Map<String, dynamic>>().toList();
    final buy = (data['buyOffers'] as List? ?? []).whereType<Map<String, dynamic>>().toList();
    return {'sellOffers': sell, 'buyOffers': buy};
  }

  Future<Map<String, dynamic>> createProductOffer(
    String productId, {
    required String type, // 'sell' ou 'buy'
    required double price,
    bool freeShipping = false,
    double shippingPrice = 0,
    List<String> paymentMethods = const [],
    String condition = 'Novo',
    String notes = '',
  }) async {
    final response = await _client.post(
      _uri('/api/products/${Uri.encodeComponent(productId)}/offers'),
      headers: _contentHeaders,
      body: jsonEncode({
        'type': type,
        'price': price,
        'freeShipping': freeShipping,
        'shippingPrice': shippingPrice,
        'paymentMethods': paymentMethods,
        'condition': condition,
        'notes': notes,
      }),
    );
    return _decodeResponse(response)['item'] as Map<String, dynamic>;
  }

  // ── Ofertas do Usuário Logado ─────────────────────────────────────────────
  Future<Map<String, dynamic>> getUserOffers() async {
    final response = await _client.get(_uri('/api/user/offers'));
    return _decodeResponse(response);
  }

  Future<void> deleteUserOffer(String offerId, {String? productId}) async {
    final params = <String, String>{'offerId': offerId};
    if (productId != null) params['productId'] = productId;
    final response = await _client.delete(
      _uri('/api/user/offers').replace(queryParameters: params),
    );
    _decodeResponse(response);
  }

  // ── Financeiro e Faturamento do Usuário ──────────────────────────────────
  Future<Map<String, dynamic>> getUserFinance() async {
    final response = await _client.get(_uri('/api/user/finance'));
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> requestWithdrawal({
    required double amount,
    required String pixKey,
    required String pixType,
  }) async {
    final response = await _client.post(
      _uri('/api/user/finance'),
      headers: _contentHeaders,
      body: jsonEncode({
        'amount': amount,
        'pixKey': pixKey,
        'pixType': pixType,
      }),
    );
    return _decodeResponse(response)['item'] as Map<String, dynamic>;
  }

  // ── Payment Methods (via settings) ───────────────────────────────────────
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final response = await _client.get(_uri('/api/admin/settings'));
    final data = _decodeResponse(response)['item'];
    if (data is Map) {
      final methods = data['paymentMethods'];
      if (methods is List) {
        return methods.whereType<Map<String, dynamic>>().toList();
      }
    }
    return [];
  }

  Future<String> uploadImage({
    required String collection,
    required Uint8List bytes,
    required String contentType,
    String? title,
    String? category,
  }) async {
    final response = await _client.post(
      _uri('/api/media'),
      headers: _contentHeaders,
      body: jsonEncode({
        'collection': collection,
        if (title != null) 'title': title,
        if (category != null) 'category': category,
        'dataUrl': 'data:$contentType;base64,${base64Encode(bytes)}',
      }),
    );
    final result = _decodeResponse(response);
    final id = result['id'];
    if (id is! String) throw const ApiException('A API não retornou o ID da imagem.');
    return id;
  }

  static const _contentHeaders = {'Content-Type': 'application/json'};

  List<Map<String, dynamic>> _readItems(Map<String, dynamic> result) {
    final items = result['items'];
    if (items is! List) return [];
    return items.whereType<Map<String, dynamic>>().toList();
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw ApiException('Resposta inválida do backend (${response.statusCode}).');
    }

    if (decoded is Map<String, dynamic>) {
      if (response.statusCode >= 200 && response.statusCode < 300) return decoded;
      throw ApiException(decoded['error']?.toString() ?? 'Erro ${response.statusCode} no backend.');
    }
    throw const ApiException('Resposta inválida do backend.');
  }
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
