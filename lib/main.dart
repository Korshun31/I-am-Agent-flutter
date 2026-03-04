import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'providers/language_provider.dart';
import 'screens/preloader_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();

  runApp(const IAmAgentApp());
}

class IAmAgentApp extends StatelessWidget {
  const IAmAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider()..load(),
      child: MaterialApp(
        title: 'I am Agent',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5DB87A)),
          useMaterial3: true,
        ),
        home: const AppRouter(),
      ),
    );
  }
}

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  String _screen = 'preloader';
  UserProfile? _user;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    try {
      final user = await getCurrentUser();
      if (user != null) {
        setState(() {
          _user = user;
          _screen = 'main';
        });
      } else {
        setState(() => _screen = 'login');
      }
    } catch (_) {
      if (mounted) setState(() => _screen = 'login');
    }
  }

  void _goToMain(UserProfile? user) {
    setState(() {
      _user = user;
      _screen = 'main';
    });
  }

  void _handleLogout() {
    setState(() {
      _user = null;
      _screen = 'login';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_screen == 'preloader') {
      return const PreloaderScreen();
    }
    if (_screen == 'login') {
      return LoginScreen(
        onSignUp: () => setState(() => _screen = 'registration'),
        onLogin: _goToMain,
      );
    }
    if (_screen == 'registration') {
      return RegistrationScreen(
        onBack: () => setState(() => _screen = 'login'),
        onSuccess: _goToMain,
      );
    }
    if (_screen == 'main' && _user != null) {
      return MainScreen(
        user: _user!,
        onLogout: _handleLogout,
      );
    }
    return const PreloaderScreen();
  }
}
