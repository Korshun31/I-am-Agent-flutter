import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class ContactsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const ContactsScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EB),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: Consumer<LanguageProvider>(
          builder: (_, lang, __) => Text(lang.t('contacts')),
        ),
        backgroundColor: const Color(0xFFF5F2EB),
        elevation: 0,
      ),
      body: Center(
        child: Consumer<LanguageProvider>(
          builder: (_, lang, __) => Text(
            lang.t('contacts'),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
