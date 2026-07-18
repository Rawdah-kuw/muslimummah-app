import 'package:shared_preferences/shared_preferences.dart';

/// Thin synchronous-ish wrapper around SharedPreferences.
/// Call [Prefs.init] once at startup.
class Prefs {
  static late SharedPreferences _p;

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  static String getString(String key, String fallback) =>
      _p.getString(key) ?? fallback;

  static Future<void> setString(String key, String value) =>
      _p.setString(key, value);

  static bool getBool(String key, bool fallback) =>
      _p.getBool(key) ?? fallback;

  static Future<void> setBool(String key, bool value) =>
      _p.setBool(key, value);

  // Curriculum progress: a set of completed playlist ids.
  static Set<int> completedPlaylists() {
    final list = _p.getStringList('mu_progress') ?? [];
    return list.map(int.tryParse).whereType<int>().toSet();
  }

  static Future<void> setPlaylistDone(int id, bool done) async {
    final set = completedPlaylists();
    if (done) {
      set.add(id);
    } else {
      set.remove(id);
    }
    await _p.setStringList('mu_progress', set.map((e) => e.toString()).toList());
  }
}
