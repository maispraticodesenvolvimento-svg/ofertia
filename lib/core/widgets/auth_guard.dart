import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_client.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';

/// Envolve telas ou ações que exigem que o usuário esteja autenticado.
/// Se o usuário estiver logado, exibe [child].
/// Se não estiver logado, exibe um card / tela elegante convidando a fazer login ou criar conta.
class AuthGuard extends StatefulWidget {
  const AuthGuard({
    super.key,
    required this.child,
    this.title = 'Acesso restrito',
    this.message = 'Você precisa estar conectado à sua conta para acessar esta página.',
    this.icon = Icons.lock_outline_rounded,
    this.adminOnly = false,
  });

  final Widget child;
  final String title;
  final String message;
  final IconData icon;
  final bool adminOnly;

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  late Future<Map<String, dynamic>?> _authCheck;

  @override
  void initState() {
    super.initState();
    SessionService.instance.addListener(_handleSessionChanged);
    _check();
  }

  @override
  void dispose() {
    SessionService.instance.removeListener(_handleSessionChanged);
    super.dispose();
  }

  void _handleSessionChanged() {
    if (!mounted) return;
    final user = SessionService.instance.currentUser;
    setState(() {
      _authCheck = Future.value(
        user != null && user['uid'] != null ? user : null,
      );
    });
  }

  void _check() {
    _authCheck = ApiClient().currentUser().then<Map<String, dynamic>?>((u) {
      SessionService.instance.updateLocalUser(u);
      return u;
    }).catchError((_) {
      SessionService.instance.clear();
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _authCheck,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;
        final isAuthenticated = user != null && user['uid'] != null;

        // Se exige admin, valida se role == admin
        if (isAuthenticated) {
          if (widget.adminOnly) {
            final role = user['role']?.toString();
            if (role != 'admin') {
              return _UnauthorizedView(
                title: 'Acesso Administrativo',
                message: 'Esta área é exclusiva para administradores da plataforma.',
                icon: Icons.admin_panel_settings_outlined,
                onRetry: () => setState(_check),
              );
            }
          }
          return widget.child;
        }

        // Não autenticado -> exibe elemento exigindo autenticação
        return _UnauthorizedView(
          title: widget.title,
          message: widget.message,
          icon: widget.icon,
          onRetry: () => setState(_check),
        );
      },
    );
  }
}

class _UnauthorizedView extends StatelessWidget {
  const _UnauthorizedView({
    required this.title,
    required this.message,
    required this.icon,
    required this.onRetry,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.grey200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícone de destaque
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryBorder),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 34),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Mensagem explicativa
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.grey600,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Botão Entrar ou Cadastrar
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton.icon(
                      onPressed: () {
                        // Navega para login preservando a rota atual
                        final current = GoRouterState.of(context).uri.toString();
                        context.push('/login?redirect=${Uri.encodeComponent(current)}');
                      },
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: Text(
                        'Entrar ou Cadastrar',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botão Voltar para Início
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/buyer/home'),
                      icon: const Icon(Icons.home_outlined, size: 18),
                      label: Text(
                        'Continuar navegando na loja',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Botão Tentar novamente (caso tenha acabado de logar em outra aba)
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 15, color: AppColors.grey500),
                    label: Text(
                      'Já fiz login, atualizar página',
                      style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
