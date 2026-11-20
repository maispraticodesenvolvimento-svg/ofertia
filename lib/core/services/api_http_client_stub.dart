import 'package:http/http.dart' as http;

http.Client createApiHttpClient() => _SessionClient();

class _SessionClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  String? _cookie;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_cookie != null) request.headers['Cookie'] = _cookie!;
    final response = await _inner.send(request);
    final setCookie = response.headers['set-cookie'];
    final session = setCookie?.split(';').firstWhere(
      (part) => part.trim().startsWith('ofertia_session='),
      orElse: () => '',
    );
    if (session != null && session.isNotEmpty) {
      _cookie = session.trim();
    } else if (setCookie?.contains('ofertia_session=;') == true) {
      _cookie = null;
    }
    return response;
  }
}
