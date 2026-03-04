import 'package:flutter/material.dart';
import '../widgets/logo.dart';

class PreloaderScreen extends StatelessWidget {
  const PreloaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLogoColors['backgroundLogin'],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Logo(small: false),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              color: kLogoColors['green'],
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
