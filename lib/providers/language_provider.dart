import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../i18n/translations.dart' as i18n;

const _langKey = 'app_language';
const _currKey = 'app_currency';

class LanguageProvider extends ChangeNotifier {
  String _language = 'en';
  String _currency = 'THB';

  String get language => _language;
  String get currency => _currency;

  String t(String key) => i18n.t(language, key);

  String get currencySymbol {
    switch (_currency) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'RUB': return '₽';
      default: return '฿';
    }
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final storedLang = prefs.getString(_langKey);
      if (storedLang != null && ['en', 'th', 'ru'].contains(storedLang)) {
        _language = storedLang;
      }

      final storedCurr = prefs.getString(_currKey);
      if (storedCurr != null && ['THB', 'USD', 'EUR', 'RUB'].contains(storedCurr)) {
        _currency = storedCurr;
      }

      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLanguage(String lang) async {
    if (!['en', 'th', 'ru'].contains(lang)) return;
    _language = lang;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_langKey, lang);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setCurrency(String curr) async {
    if (!['THB', 'USD', 'EUR', 'RUB'].contains(curr)) return;
    _currency = curr;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currKey, curr);
    } catch (_) {}
    notifyListeners();
  }
}
