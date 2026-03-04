import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/logo.dart';
import '../providers/language_provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSignUp;
  final void Function(UserProfile user) onLogin;

  const LoginScreen({
    super.key,
    required this.onSignUp,
    required this.onLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final lang = context.read<LanguageProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showError(lang.t('error'), lang.t('enterEmail'));
      return;
    }
    if (password.isEmpty) {
      _showError(lang.t('error'), lang.t('enterPassword'));
      return;
    }

    try {
      final user = await signIn(email: email, password: password);
      if (user != null && mounted) {
        widget.onLogin(user);
      } else {
        _showError(lang.t('error'), lang.t('wrongPassword'));
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Invalid') || msg.contains('credentials')) {
        _showError(lang.t('error'), lang.t('wrongPassword'));
      } else {
        _showError(lang.t('error'), msg);
      }
    }
  }

  void _showError(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.read<LanguageProvider>().t('back')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLogoColors['backgroundLogin'],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Logo(small: true),
                  const SizedBox(height: 14),
                  Consumer<LanguageProvider>(
                    builder: (_, lang, __) => Column(
                      children: [
                        Text(
                          lang.t('appName'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lang.t('tagline'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5A5A5A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Consumer<LanguageProvider>(
                    builder: (_, lang, __) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildField(
                          label: lang.t('email'),
                          controller: _emailController,
                          obscure: false,
                          keyboardType: TextInputType.emailAddress,
                          hint: 'mail@mail.com',
                        ),
                        const SizedBox(height: 22),
                        _buildField(
                          label: lang.t('password'),
                          controller: _passwordController,
                          obscure: true,
                          hint: '••••••••',
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kLogoColors['green'],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            lang.t('login'),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          lang.t('orSignIn'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5A5A5A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              lang.t('noAccount'),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF5A5A5A),
                              ),
                            ),
                            TextButton(
                              onPressed: widget.onSignUp,
                              child: Text(
                                lang.t('signUp'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFD85A6A),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: kLogoColors['stickerYellow'],
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: kLogoColors['stickerYellow'],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          ),
        ),
      ],
    );
  }
}
