import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text('${user.name} ${user.lastName}'.trim().isEmpty
                  ? user.email
                  : '${user.name} ${user.lastName}'.trim()),
              subtitle: Text(user.email),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.contacts),
            title: Consumer<LanguageProvider>(
              builder: (_, lang, __) => Text(lang.t('contacts')),
            ),
            onTap: onOpenContacts,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
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
