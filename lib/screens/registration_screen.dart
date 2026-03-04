import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/logo.dart';
import '../providers/language_provider.dart';
import '../services/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(UserProfile user) onSuccess;

  const RegistrationScreen({
    super.key,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp(
    BuildContext context,
    String email,
    String password,
    String name,
  ) async {
    final lang = context.read<LanguageProvider>();
    try {
      final user = await signUp(
        email: email,
        password: password,
        name: name.isEmpty ? null : name,
      );
      if (context.mounted) widget.onSuccess(user);
    } catch (e) {
      final msg = e.toString();
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(lang.t('error')),
            content: Text(msg.contains('already') ? lang.t('accountExists') : lang.t('saveFailed')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(lang.t('back')),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLogoColors['backgroundLogin'],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Consumer<LanguageProvider>(
              builder: (_, lang, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    lang.t('createAccount'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: lang.t('name'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: lang.t('email'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: lang.t('password'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text;
                      if (email.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(lang.t('error')),
                            content: Text(lang.t('enterEmail')),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(lang.t('back')),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      if (password.isEmpty || password.length < 6) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(lang.t('error')),
                            content: Text(lang.t('enterPassword')),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(lang.t('back')),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      _handleSignUp(
                        context,
                        email,
                        password,
                        _nameController.text.trim(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kLogoColors['green'],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(lang.t('createAccountBtn')),
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
