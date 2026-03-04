import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../i18n/translations.dart' as i18n;

const _storageKey = 'app_language';

class LanguageProvider extends ChangeNotifier {
  String _language = 'en';

  String get language => _language;

  String t(String key) => i18n.t(language, key);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_storageKey);
      if (stored != null && ['en', 'th', 'ru'].contains(stored)) {
        _language = stored;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String lang) async {
    if (!['en', 'th', 'ru'].contains(lang)) return;
    _language = lang;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, lang);
    } catch (_) {}
    notifyListeners();
  }
}
