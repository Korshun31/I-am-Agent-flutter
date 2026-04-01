import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../assets/app_assets.dart';
import '../providers/language_provider.dart';
import '../services/auth_service.dart';

class AccountScreen extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onLogout;
  final VoidCallback onOpenContacts;

  const AccountScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onOpenContacts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EB),
      appBar: AppBar(
        title: Consumer<LanguageProvider>(
          builder: (_, lang, __) => Text(lang.t('myAccount')),
        ),
        backgroundColor: const Color(0xFFF5F2EB),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Image.asset(AppAssets.account, width: 32, height: 32, fit: BoxFit.contain),
              ),
              title: Text('${user.name} ${user.lastName}'.trim().isEmpty
                  ? user.email
                  : '${user.name} ${user.lastName}'.trim()),
              subtitle: Text(user.email),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Image.asset(AppAssets.contacts, width: 24, height: 24, fit: BoxFit.contain),
            title: Consumer<LanguageProvider>(
              builder: (_, lang, __) => Text(lang.t('contacts')),
            ),
            onTap: onOpenContacts,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.currency_exchange, color: Color(0xFF3D7D82), size: 24),
            title: Consumer<LanguageProvider>(
              builder: (_, lang, __) => Text(lang.t('currencySelection')),
            ),
            trailing: Consumer<LanguageProvider>(
              builder: (_, lang, __) => Text(
                lang.currency,
                style: const TextStyle(color: Color(0xFF3D7D82), fontWeight: FontWeight.w700),
              ),
            ),
            onTap: () {
              final lang = context.read<LanguageProvider>();
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: ['THB', 'USD', 'EUR', 'RUB'].map((curr) => ListTile(
                      title: Text(curr, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
                      onTap: () {
                        lang.setCurrency(curr);
                        Navigator.pop(ctx);
                      },
                      selected: lang.currency == curr,
                      selectedColor: const Color(0xFF3D7D82),
                    )).toList(),
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Image.asset(AppAssets.logout, width: 24, height: 24, fit: BoxFit.contain),
            title: Consumer<LanguageProvider>(
              builder: (_, lang, __) => Text(
                lang.t('logout'),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onTap: () {
              final lang = context.read<LanguageProvider>();
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(lang.t('logoutTitle')),
                  content: Text(lang.t('logoutMessage')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(lang.t('no')),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        signOut();
                        onLogout();
                      },
                      child: Text(
                        lang.t('yes'),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
