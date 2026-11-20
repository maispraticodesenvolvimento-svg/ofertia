import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

class SessionService extends ChangeNotifier {
  SessionService._();
  static final SessionService instance = SessionService._();

  Map<String, dynamic>? _currentUser;
  int _sessionRevision = 0;

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && _currentUser!['uid'] != null;
  bool get isAdmin => _currentUser != null && _currentUser!['role'] == 'admin';

  String get displayName {
    if (!isAuthenticated) return 'Visitante';
    final name = _currentUser!['name']?.toString() ?? '';
    if (name.trim().isNotEmpty) return name.trim();
    final email = _currentUser!['email']?.toString() ?? '';
    if (email.contains('@')) return email.split('@').first;
    return 'Minha conta';
  }

  /// Retorna o endereço estruturado do usuário se existir
  Map<String, dynamic>? get address {
    final addr = _currentUser?['address'];
    return addr is Map<String, dynamic> ? addr : (addr is Map ? Map<String, dynamic>.from(addr) : null);
  }

  /// Formatação do endereço para exibição compacta no topo da tela (ex: "São Paulo - SP")
  String? get formattedAddress {
    if (!isAuthenticated) return null;
    final addr = address;
    if (addr == null) return null;
    final city = addr['city']?.toString().trim() ?? '';
    final state = addr['state']?.toString().trim() ?? '';
    if (city.isEmpty && state.isEmpty) return null;
    if (city.isNotEmpty && state.isNotEmpty) return '$city - $state';
    return city.isNotEmpty ? city : state;
  }

  /// Checagem estrita se o usuário completou dados pessoais e endereço completo
  bool get isProfileComplete {
    if (!isAuthenticated) return false;
    final u = _currentUser!;
    final name = u['name']?.toString().trim() ?? '';
    final phone = u['phone']?.toString().trim() ?? '';
    final document = u['document']?.toString().trim() ?? '';
    final addr = address;
    if (name.isEmpty || phone.isEmpty || document.isEmpty || addr == null) return false;

    final street = addr['street']?.toString().trim() ?? '';
    final number = addr['number']?.toString().trim() ?? '';
    final city = addr['city']?.toString().trim() ?? '';
    final state = addr['state']?.toString().trim() ?? '';
    final cep = addr['cep']?.toString().trim() ?? '';

    return street.isNotEmpty && number.isNotEmpty && city.isNotEmpty && state.isNotEmpty && cep.isNotEmpty;
  }

  Future<void> refresh() async {
    final revision = _sessionRevision;
    try {
      final user = await ApiClient().currentUser();
      if (revision == _sessionRevision) _currentUser = user;
    } catch (_) {
      if (revision == _sessionRevision) _currentUser = null;
    } finally {
      if (revision == _sessionRevision) notifyListeners();
    }
  }

  void updateLocalUser(Map<String, dynamic> updated) {
    _sessionRevision++;
    if (_currentUser == null) {
      _currentUser = updated;
    } else {
      _currentUser = {..._currentUser!, ...updated};
    }
    notifyListeners();
  }

  void clear() {
    _sessionRevision++;
    _currentUser = null;
    notifyListeners();
  }
}
