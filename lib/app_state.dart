import 'package:flutter/material.dart';
import 'services/prefs.dart';

/// Global app state: language (ar/en) and light/dark theme.
/// A tiny ChangeNotifier singleton so we avoid extra state packages.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState I = AppState._();

  String lang = 'ar';
  ThemeMode themeMode = ThemeMode.light;

  bool get isRtl => lang == 'ar';
  Locale get locale => Locale(lang);

  Future<void> load() async {
    lang = Prefs.getString('lang', 'ar');
    themeMode =
        Prefs.getString('theme', 'light') == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleLang() {
    lang = lang == 'ar' ? 'en' : 'ar';
    Prefs.setString('lang', lang);
    notifyListeners();
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    Prefs.setString('theme', themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  /// Pick the localized value from a {"ar":..,"en":..} map.
  String loc(Map? m) {
    if (m == null) return '';
    return (m[lang] ?? m['ar'] ?? m['en'] ?? '').toString();
  }
}

/// Inline bilingual string helper: tr('عربي', 'English').
String tr(String ar, String en) => AppState.I.lang == 'ar' ? ar : en;
