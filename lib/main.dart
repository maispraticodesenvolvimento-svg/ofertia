import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/services/session_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');

  // Inicializa a checagem de sessão em background
  SessionService.instance.refresh();

  // Captura erros do Flutter e evita tela branca
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Registra no console mas não deixa o app travar completamente
    debugPrint('[FlutterError] ${details.exceptionAsString()}');
  };

  // Widget de erro customizado — substitui a tela vermelha/branca
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return _AppErrorWidget(message: details.exceptionAsString());
  };

  runApp(const SistemaRochaApp());
}

class SistemaRochaApp extends StatelessWidget {
  const SistemaRochaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ofertia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}

// ---------------------------------------------------------------------------
// Widget exibido quando ocorre uma exceção não tratada na árvore de widgets.
// Substitui a tela branca/vermelha padrão do Flutter.
// ---------------------------------------------------------------------------
class _AppErrorWidget extends StatelessWidget {
  const _AppErrorWidget({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 52),
              const SizedBox(height: 16),
              Text(
                'Algo deu errado',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Recarregue a página ou tente novamente.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey600),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  // Tenta navegar para o início para recuperar o estado
                  appRouter.go('/login');
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Voltar ao início'),
              ),
              const SizedBox(height: 16),
              // Detalhe técnico colapsável
              ExpansionTile(
                title: Text(
                  'Detalhes técnicos',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      message,
                      style: GoogleFonts.robotoMono(fontSize: 11, color: AppColors.grey700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
