import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

/// Reads published Rawdah lessons from Supabase and applies the exact same
/// rules as the website's components/Rawdah.jsx, in order:
///   0. read only is_published = true
///   1. hide paused / ended / more-than-a-week-away (Kuwait date)
///   2. de-duplicate by normalized title|teacher|day
///   3. resolve gender (explicit field, else infer)
/// Plus helpers for chronological time sorting and day ordering.
class RawdahService {
  static SupabaseClient get _db => Supabase.instance.client;

  /// The seven Arabic day names, indexed like JS getDay() (0 = Sunday).
  static const days = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  /// Main WhatsApp group — fallback for any lesson with no dedicated link.
  static const groupLink =
      'https://chat.whatsapp.com/J394CWBV7zw3aIexoulZAQ';

  // ── Fetch + filter ──────────────────────────────────────────────
  static Future<List<Lesson>> fetchLessons() async {
    final rows = await _db.from('lessons').select().eq('is_published', true);

    final todayKw = _todayKuwaitStr();
    final horizonKw = _dateStr(_kuwaitNow().add(const Duration(days: 7)));

    final seen = <String>{};
    final out = <Lesson>[];
    for (final r in (rows as List)) {
      final map = Map<String, dynamic>.from(r as Map);

      // 1. paused (temporary holiday for recurring lessons)
      if (map['is_paused'] == true) continue;

      final isRecurring = map['is_recurring'] == true;
      final rawDate = (map['lesson_date'] ?? '').toString().trim();
      final lessonDate = rawDate.isEmpty ? null : rawDate;

      // 1. ended (dated, non-recurring, already passed in Kuwait)
      if (!isRecurring &&
          lessonDate != null &&
          lessonDate.compareTo(todayKw) < 0) {
        continue;
      }
      // 1. more than a week away — appears only within its week
      if (!isRecurring &&
          lessonDate != null &&
          lessonDate.compareTo(horizonKw) > 0) {
        continue;
      }

      final l = Lesson.fromJson(map);
      // 3. resolve gender once (explicit field wins, else infer)
      l.gender = genderOf(l);

      // 2. de-duplicate by normalized title|teacher|day (keep first)
      final key =
          '${normalizeText(l.title)}|${normalizeText(l.teacher)}|${l.day}';
      if (seen.contains(key)) continue;
      seen.add(key);

      out.add(l);
    }
    return out;
  }

  // ── Gender ──────────────────────────────────────────────────────
  /// Resolved gender: explicit field wins, otherwise inferred, else "نساء".
  static String genderOf(Lesson l) {
    if (l.gender == 'رجال') return 'رجال';
    if (l.gender == 'نساء') return 'نساء';
    return _inferGender(l.teacher, l.title) ?? 'نساء';
  }

  /// Infer gender from honorifics / kunya / name patterns. Female is checked
  /// first so «أم عبد الكريم» stays female despite «عبد».
  static String? _inferGender(String teacher, String title) {
    final s = ('$teacher $title')
        .replaceAll(RegExp(r'[إأآا]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ');
    // — female signals (first) —
    if (RegExp(
            r'(الشيخه|الدكتوره|الاستاذه|الواعظه|الباحثه|المعلمه|الداعيه|الاخت|المربيه|المدربه)')
        .hasMatch(s)) return 'نساء';
    if (RegExp(r'(^|\s)ام\s').hasMatch(s)) return 'نساء';
    if (RegExp(r'للنساء|النساء فقط|نسائي').hasMatch(s)) return 'نساء';
    if (RegExp(
            r'(مريم|فاطمه|نوره|حصه|ساره|ابتسام|جميله|منيره|هيا|دلال|شيخه|موضي|بشاير|غريبه|امل|هدي|عائشه|خديجه|زينب|رقيه|اسماء|لطيفه|منال|صفاء|انفال|شيماء|وضحه|حنان|شهد|نجلاء|عبير)')
        .hasMatch(s)) return 'نساء';
    // — male signals —
    if (RegExp(r'(الشيخ|الدكتور|الاستاذ|الداعي)(?!ه)').hasMatch(s)) {
      return 'رجال';
    }
    if (RegExp(r'(^|\s)(ابو|بن|ابن)\s').hasMatch(s)) return 'رجال';
    if (RegExp(r'(^|\s)عبد\s?ال').hasMatch(s)) return 'رجال';
    if (RegExp(
            r'(محمد|احمد|علي|عمر|خالد|يوسف|ابراهيم|صالح|سعد|فهد|ناصر|سلطان|بدر|طارق|زياد|حسن|حسين|عثمان|مشاري|عادل|وليد|ماجد|فيصل|عبدالله|سلمان)')
        .hasMatch(s)) return 'رجال';
    return null;
  }

  static bool isWomen(Lesson l) => genderOf(l) == 'نساء';

  // ── Time parsing (minutes from midnight, for sorting) ───────────
  static final List<MapEntry<String, int>> _prayerTimes = [
    MapEntry(r'(?:بعد|عقب)\s*العشاء', 1200),
    MapEntry(r'قبل\s*العشاء', 1170),
    MapEntry(r'(?:بعد|عقب)\s*المغرب', 1110),
    MapEntry(r'قبل\s*المغرب', 1050),
    MapEntry(r'(?:بعد|عقب)\s*العصر', 960),
    MapEntry(r'قبل\s*العصر', 870),
    MapEntry(r'(?:بعد|عقب)\s*الظهر', 750),
    MapEntry(r'قبل\s*الظهر', 690),
    MapEntry(r'(?:بعد|عقب)\s*الضحي', 540),
    MapEntry(r'(?:بعد|عقب)\s*(?:الاشراق|الشروق)', 420),
    MapEntry(r'(?:بعد|عقب)\s*الفجر', 330),
    MapEntry(r'العشاء', 1195),
    MapEntry(r'المغرب', 1105),
    MapEntry(r'العصر', 955),
    MapEntry(r'الظهر', 745),
    MapEntry(r'الشروق|الاشراق', 415),
    MapEntry(r'الفجر', 325),
  ];

  static int parseTime(String? t) {
    if (t == null || t.isEmpty) return 9999;
    final s = _toLatinDigits(t)
        .replaceAll(RegExp(r'[إأآا]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('صلاه', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    for (final e in _prayerTimes) {
      if (RegExp(e.key).hasMatch(s)) return e.value;
    }
    final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(s);
    if (m == null) return 9999;
    var h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    final pm = RegExp(r'م|pm|مساء', caseSensitive: false).hasMatch(s);
    final am = RegExp(r'ص|am|صباح', caseSensitive: false).hasMatch(s);
    if (pm && h < 12) h += 12;
    if (am && h == 12) h = 0;
    if (!pm && !am && h >= 1 && h <= 7) h += 12;
    return h * 60 + min;
  }

  // ── Text normalization + dedup key ──────────────────────────────
  static const _honorifics = {
    'د', 'ا', 'الدكتور', 'الدكتوره', 'دكتور', 'دكتوره', 'الشيخ', 'الشيخه',
    'شيخ', 'شيخه', 'الاستاذ', 'الاستاذه', 'استاذ', 'استاذه', 'الاخت',
    'الواعظه', 'الداعيه', 'المعلمه', 'الباحثه',
  };

  static String normalizeText(String? s) {
    if (s == null || s.isEmpty) return '';
    final t = _toLatinDigits(s)
        .replaceAll(RegExp(r'[ً-ْ]'), '') // diacritics
        .replaceAll(RegExp(r'[إأآا]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'''[.،,؛:!؟"'()\-_]'''), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
    return t
        .split(' ')
        .where((w) => w.isNotEmpty && !_honorifics.contains(w))
        .join(' ');
  }

  // ── Day ordering (starting from today, Kuwait) ──────────────────
  static DateTime _kuwaitNow() =>
      DateTime.now().toUtc().add(const Duration(hours: 3));

  static String _dateStr(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  static String _todayKuwaitStr() => _dateStr(_kuwaitNow());

  static String todayName() => days[_kuwaitNow().weekday % 7];

  /// The seven days ordered starting from today, then wrapping.
  static List<String> orderedFromToday() {
    final ti = days.indexOf(todayName());
    if (ti < 0) return List.of(days);
    return [...days.sublist(ti), ...days.sublist(0, ti)];
  }

  /// Ordered-from-today days that actually have lessons.
  static List<String> daysWithLessons(List<Lesson> lessons) => orderedFromToday()
      .where((dn) => lessons.any((l) => l.day == dn))
      .toList();

  /// English names for the seven days (parallel to [days]).
  static const _daysEn = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  /// Localized label for an Arabic day name (English in English mode).
  static String dayLabel(String arDay, bool english) {
    if (!english) return arDay;
    final i = days.indexOf(arDay);
    return i >= 0 ? _daysEn[i] : arDay;
  }

  /// The next upcoming lesson relative to the current Kuwait time. Considers
  /// today's remaining lessons first, then wraps to the next day that has any.
  static Lesson? nextLesson(List<Lesson> all) {
    if (all.isEmpty) return null;
    final now = _kuwaitNow();
    final nowMin = now.hour * 60 + now.minute;
    final ordered = orderedFromToday();
    for (var i = 0; i < ordered.length; i++) {
      final dn = ordered[i];
      var items = all.where((l) => l.day == dn).toList()
        ..sort((a, b) => parseTime(a.time).compareTo(parseTime(b.time)));
      if (i == 0) {
        // Today — keep only lessons whose time has not passed yet.
        items = items.where((l) => parseTime(l.time) >= nowMin).toList();
      }
      if (items.isNotEmpty) return items.first;
    }
    return null;
  }

  /// Format an ISO date (YYYY-MM-DD) as D/M/YYYY.
  static String fmtDate(String? d) {
    if (d == null || d.isEmpty) return '';
    final p = d.split('-');
    if (p.length == 3) {
      return '${int.parse(p[2])}/${int.parse(p[1])}/${p[0]}';
    }
    return d;
  }

  static String _toLatinDigits(String s) {
    const ar = '٠١٢٣٤٥٦٧٨٩';
    final b = StringBuffer();
    for (final ch in s.split('')) {
      final i = ar.indexOf(ch);
      b.write(i >= 0 ? i.toString() : ch);
    }
    return b.toString();
  }
}
