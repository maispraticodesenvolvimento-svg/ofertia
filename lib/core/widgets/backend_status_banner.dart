import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_client.dart';
import '../theme/app_theme.dart';

class BackendStatusBanner extends StatefulWidget {
  const BackendStatusBanner({super.key});

  @override
  State<BackendStatusBanner> createState() => _BackendStatusBannerState();
}

class _BackendStatusBannerState extends State<BackendStatusBanner> {
  final _api = ApiClient();
  late Future<bool> _health;

  @override
  void initState() {
    super.initState();
    _health = _api.checkHealth();
  }

  void _refresh() => setState(() => _health = _api.checkHealth());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _health,
      builder: (context, snapshot) {
        // Enquanto estiver checando ou se estiver online (conectado), não exibe nada
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final online = snapshot.data == true;
        if (online) {
          return const SizedBox.shrink();
        }

        // Exibe SOMENTE se estiver indisponível/offline
        return Container(
          width: double.infinity,
          color: AppColors.error,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Erro de conexão. Favor contactar o nosso suporte.',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: _refresh,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                tooltip: 'Tentar reconectar',
                icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}
