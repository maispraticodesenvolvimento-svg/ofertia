import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.redirect});

  final String? redirect;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _registering = false;
  bool _busy = false;
  bool _obscurePassword = true;
  String? _message;
  bool _success = false;

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    final target = widget.redirect;
    if (target != null && target.isNotEmpty && target != '/login') {
      context.go(target);
      return;
    }
    context.go('/buyer/home');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ApiClient().currentUser();
        if (mounted) _goBack();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _message = null;
      _success = false;
    });
    try {
      if (_registering) {
        await ApiClient().register(_email.text.trim(), _password.text);
      } else {
        await ApiClient().login(_email.text.trim(), _password.text);
      }
      await ApiClient().ensureProfile();
      await SessionService.instance.refresh();
      if (!mounted) return;
      _goBack();
    } on ApiException catch (error) {
      setState(() => _message = error.message);
    } catch (_) {
      setState(() => _message = 'Não foi possível concluir o acesso. Tente novamente.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recoverPassword() async {
    if (!_email.text.trim().contains('@')) {
      setState(() {
        _success = false;
        _message = 'Informe seu e-mail para receber o link de recuperação.';
      });
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await ApiClient().recoverPassword(_email.text.trim());
      setState(() {
        _success = true;
        _message = 'Enviamos um link de recuperação para ${_email.text.trim()}.';
      });
    } on ApiException catch (error) {
      setState(() { _success = false; _message = error.message; });
    } catch (_) {
      setState(() {
        _success = false;
        _message = 'Não foi possível enviar o e-mail de recuperação.';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        body: SafeArea(
          child: wide
              ? Row(
                  children: [
                    Expanded(flex: 11, child: _brandPanel()),
                    Expanded(flex: 9, child: _formPanel(wide: true)),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 280, child: _brandPanel(compact: true)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                        child: _formPanel(),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _brandPanel({bool compact = false}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 280),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF172B73), Color(0xFF3156C9), Color(0xFF5A75E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(right: -100, top: -110, child: _orb(340, 0.08)),
          Positioned(left: -110, bottom: -150, child: _orb(360, 0.07)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 24 : 64,
              vertical: compact ? 24 : 56,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _goBack,
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      tooltip: 'Voltar para a página anterior',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.16),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: Colors.white, size: 23),
                    ),
                    const SizedBox(width: 12),
                    Text('ofertia',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6)),
                  ],
                ),
                SizedBox(height: compact ? 23 : 66),
                Text(
                  'Boas escolhas\ncomeçam aqui.',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: compact ? 28 : 46,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Entre para acompanhar ofertas, encontrar seus favoritos e cuidar dos seus pedidos em um só lugar.',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: compact ? 13 : 16,
                    height: 1.6,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 38),
                  _promoCard(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );

  Widget _promoCard() => Container(
        padding: const EdgeInsets.all(18),
        constraints: const BoxConstraints(maxWidth: 410),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.local_offer_outlined,
                  color: Color(0xFFFFD47A), size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tudo o que você procura',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Ofertas e novidades em um só lugar.',
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _formPanel({bool wide = false}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back, size: 18, color: AppColors.primary),
                    label: Text(
                      'Voltar para a página anterior',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(_registering ? 'Crie sua conta' : 'Bem-vindo de volta',
                    style: GoogleFonts.inter(
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        color: AppColors.grey900,
                        letterSpacing: -0.7)),
                const SizedBox(height: 8),
                Text(
                  _registering
                      ? 'Preencha seus dados para começar.'
                      : 'Acesse sua conta para continuar.',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.grey500),
                ),
                const SizedBox(height: 30),
                _label('E-mail'),
                TextFormField(
                  controller: _email,
                  enabled: !_busy,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) => value == null || !value.contains('@')
                      ? 'Informe um e-mail válido.'
                      : null,
                  decoration: _decoration('voce@exemplo.com', Icons.mail_outline),
                ),
                const SizedBox(height: 18),
                _label('Senha'),
                TextFormField(
                  controller: _password,
                  enabled: !_busy,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) => value == null || value.length < 6
                      ? 'A senha precisa ter ao menos 6 caracteres.'
                      : null,
                  decoration: _decoration('Sua senha', Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                    ),
                  ),
                ),
                if (!_registering)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _busy ? null : _recoverPassword,
                      child: const Text('Esqueci minha senha'),
                    ),
                  )
                else
                  const SizedBox(height: 12),
                if (_message != null) ...[
                  const SizedBox(height: 4),
                  Text(_message!,
                      style: GoogleFonts.inter(
                          color: _success ? AppColors.success : AppColors.error,
                          fontSize: 12)),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _busy ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_registering ? 'Criar conta' : 'Entrar',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _registering ? 'Já tem uma conta?' : 'Ainda não tem conta?',
                      style: GoogleFonts.inter(
                          color: AppColors.grey600, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                                _registering = !_registering;
                                _message = null;
                                _success = false;
                              }),
                      child: Text(_registering ? 'Entrar' : 'Criar conta'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('Ao continuar, você concorda com nossos termos e política de privacidade.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: AppColors.grey400, fontSize: 11, height: 1.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800)),
      );

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 19),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.grey200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.grey200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      );
}

