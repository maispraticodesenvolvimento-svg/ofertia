import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class ViaCepAddress {
  final String cep;
  final String street;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;

  const ViaCepAddress({
    required this.cep,
    required this.street,
    required this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  factory ViaCepAddress.fromViaCepJson(Map<String, dynamic> json) {
    return ViaCepAddress(
      cep: json['cep']?.toString() ?? '',
      street: json['logradouro']?.toString() ?? '',
      complement: json['complemento']?.toString() ?? '',
      neighborhood: json['bairro']?.toString() ?? '',
      city: json['localidade']?.toString() ?? '',
      state: (json['uf']?.toString() ?? '').toUpperCase(),
    );
  }
}

class ViaCepService {
  static final _client = http.Client();

  /// Remove caracteres não numéricos
  static String cleanCep(String raw) => raw.replaceAll(RegExp(r'\D'), '');

  /// Formata para 00000-000
  static String formatCep(String raw) {
    final digits = cleanCep(raw);
    if (digits.length <= 5) return digits;
    if (digits.length <= 8) {
      return '${digits.substring(0, 5)}-${digits.substring(5)}';
    }
    return '${digits.substring(0, 5)}-${digits.substring(5, 8)}';
  }

  /// Busca endereço pelo CEP na API ViaCEP.
  /// Caso falhe ou ocorra restrição de rede, recorre à rota de contingência do backend.
  static Future<ViaCepAddress?> search(String rawCep) async {
    final cep = cleanCep(rawCep);
    if (cep.length != 8) return null;

    // 1. Tentativa direta na ViaCEP
    try {
      final uri = Uri.parse('https://viacep.com.br/ws/$cep/json/');
      final res = await _client.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) {
          if (data['erro'] == true || data['erro'] == 'true') {
            return null;
          }
          return ViaCepAddress.fromViaCepJson(data);
        }
      }
    } catch (_) {}

    // 2. Contingência via Backend Ofertia
    try {
      final backendItem = await ApiClient().fetchCep(cep);
      if (backendItem != null) {
        return ViaCepAddress.fromViaCepJson(backendItem);
      }
    } catch (_) {}

    return null;
  }
}
