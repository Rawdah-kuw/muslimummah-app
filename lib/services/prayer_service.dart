import 'dart:convert';
import 'package:http/http.dart' as http;
import 'prefs.dart';

/// Today's prayer times + Hijri date from the free Aladhan API.
/// Defaults to Kuwait City (calculation method 9 = Kuwait). Cached per day so
/// it also works offline after the first fetch.
class PrayerData {
  final Map<String, String> timings; // e.g. {"Fajr": "04:12", ...}
  final String hijriAr; // e.g. "١٥ محرم ١٤٤٧"
  final String gregorian; // e.g. "20-07-2026"
  final String city;

  PrayerData(this.timings, this.hijriAr, this.gregorian, this.city);

  static const order = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  static const labelAr = {
    'Fajr': 'الفجر',
    'Sunrise': 'الشروق',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };
  static const labelEn = {
    'Fajr': 'Fajr',
    'Sunrise': 'Sunrise',
    'Dhuhr': 'Dhuhr',
    'Asr': 'Asr',
    'Maghrib': 'Maghrib',
    'Isha': 'Isha',
  };

  Map<String, dynamic> toJson() => {
        'timings': timings,
        'hijriAr': hijriAr,
        'gregorian': gregorian,
        'city': city,
      };

  factory PrayerData.fromJson(Map j) => PrayerData(
        Map<String, String>.from(j['timings']),
        j['hijriAr'] as String,
        j['gregorian'] as String,
        (j['city'] ?? 'Kuwait City') as String,
      );
}

class PrayerService {
  static const _city = 'Kuwait City';
  static const _country = 'Kuwait';
  static const _method = 9; // Kuwait

  static Future<PrayerData> today({bool forceRefresh = false}) async {
    final todayKey = _dateKey();
    if (!forceRefresh &&
        Prefs.getString('prayer_date', '') == todayKey &&
        Prefs.getString('prayer_cache', '').isNotEmpty) {
      try {
        return PrayerData.fromJson(
            jsonDecode(Prefs.getString('prayer_cache', '')) as Map);
      } catch (_) {/* fall through to fetch */}
    }

    final url = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity?city=$_city&country=$_country&method=$_method');
    final resp = await http.get(url).timeout(const Duration(seconds: 20));
    if (resp.statusCode != 200) {
      throw Exception('prayer fetch failed');
    }
    final data = (jsonDecode(resp.body) as Map)['data'] as Map;
    final rawTimings = Map<String, dynamic>.from(data['timings'] as Map);
    final timings = <String, String>{};
    for (final k in PrayerData.order) {
      final v = (rawTimings[k] ?? '').toString();
      timings[k] = v.split(' ').first; // strip " (+03)"
    }
    final hijri = data['date']['hijri'] as Map;
    final hijriAr =
        '${hijri['day']} ${hijri['month']['ar']} ${hijri['year']}هـ';
    final greg = (data['date']['gregorian']['date'] ?? '').toString();

    final pd = PrayerData(timings, hijriAr, greg, _city);
    await Prefs.setString('prayer_cache', jsonEncode(pd.toJson()));
    await Prefs.setString('prayer_date', todayKey);
    return pd;
  }

  static String _dateKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  /// Minutes-since-midnight for an "HH:MM" string.
  static int _mins(String hhmm) {
    final p = hhmm.split(':');
    if (p.length < 2) return 0;
    return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
  }

  /// Returns the key of the next upcoming prayer and its time string.
  static MapEntry<String, String>? nextPrayer(PrayerData d) {
    final now = DateTime.now();
    final nowM = now.hour * 60 + now.minute;
    for (final k in PrayerData.order) {
      if (k == 'Sunrise') continue;
      final t = d.timings[k];
      if (t == null) continue;
      if (_mins(t) > nowM) return MapEntry(k, t);
    }
    // after Isha → next is Fajr tomorrow
    final f = d.timings['Fajr'];
    return f == null ? null : MapEntry('Fajr', f);
  }
}
