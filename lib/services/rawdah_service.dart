import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

/// Reads published Rawdah lessons from Supabase and applies the display rules
/// from the project notes (section 7): publish/pause filter, week window,
/// de-duplication, gender inference, chronological ordering.
class RawdahService {
  static SupabaseClient get _db => Supabase.instance.client;

  static Future<List<Lesson>> fetchLessons() async {
    final rows = await _db.from('lessons').select().eq('is_published', true);

    final list = <Lesson>[];
    for (final r in (rows as List)) {
      final map = Map<String, dynamic>.from(r as Map);
      if (map['is_paused'] == true) continue; // hidden while paused
      final lesson = Lesson.fromJson(map);
      if (lesson.gender.isEmpty) {
        lesson.gender = _inferGender(lesson.teacher);
      }
      // Week window: hide a dated, non-recurring lesson more than 7 days out.
      if (!lesson.isRecurring && lesson.lessonDate != null) {
        final d = DateTime.tryParse(lesson.lessonDate!);
        if (d != null) {
          final days = d.difference(_todayMidnight()).inDays;
          if (days > 7) continue;
        }
      }
      list.add(lesson);
    }

    // De-duplicate by title|teacher|day|time.
    final seen = <String>{};
    final deduped = <Lesson>[];
    for (final l in list) {
      final key = '${_norm(l.title)}|${_norm(l.teacher)}|${_norm(l.day)}|${_norm(l.time)}';
      if (seen.add(key)) deduped.add(l);
    }
    return deduped;
  }

  /// True if a dated, non-recurring lesson is in the past ("ended").
  static bool isEnded(Lesson l) {
    if (l.isRecurring || l.lessonDate == null) return false;
    final d = DateTime.tryParse(l.lessonDate!);
    if (d == null) return false;
    return d.isBefore(_todayMidnight());
  }

  static DateTime _todayMidnight() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static String _norm(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _inferGender(String teacher) {
    const women = ['الشيخة', 'الدكتورة', 'الأستاذة', 'الواعظة', 'الباحثة', 'المعلمة'];
    const men = ['الشيخ', 'الدكتور', 'الأستاذ'];
    for (final w in women) {
      if (teacher.contains(w)) return 'نساء';
    }
    for (final m in men) {
      if (teacher.contains(m)) return 'رجال';
    }
    return 'نساء'; // default
  }

  // ── Day ordering (Arabic), starting from today ──
  static const _weekdayAr = {
    1: 'الإثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
    6: 'السبت',
    7: 'الأحد',
  };

  /// The seven Arabic day names ordered starting from today.
  static List<String> orderedDays() {
    final today = DateTime.now().weekday; // 1..7
    return List.generate(7, (i) {
      final wd = ((today - 1 + i) % 7) + 1;
      return _weekdayAr[wd]!;
    });
  }

  static String normalizeDay(String day) {
    final d = day.trim();
    if (d.contains('اثن') || d.contains('إثن')) return 'الإثنين';
    return d;
  }

  /// Convert a displayed time to minutes-since-midnight for sorting.
  static int timeToMinutes(String raw) {
    final t = _toLatinDigits(raw);
    // Named prayer times.
    if (raw.contains('الفجر')) return 5 * 60;
    if (raw.contains('الظهر')) return 13 * 60;
    if (raw.contains('العصر')) return 16 * 60;
    if (raw.contains('المغرب')) return 18 * 60 + 30;
    if (raw.contains('العشاء')) return 20 * 60;
    final m = RegExp(r'(\d{1,2})\s*[:٫].*?(\d{1,2})').firstMatch(t);
    int hour = 0, min = 0;
    final simple = RegExp(r'(\d{1,2}):(\d{1,2})').firstMatch(t);
    if (simple != null) {
      hour = int.parse(simple.group(1)!);
      min = int.parse(simple.group(2)!);
    } else if (m != null) {
      hour = int.parse(m.group(1)!);
      min = int.parse(m.group(2)!);
    } else {
      return 23 * 60 + 59;
    }
    final pm = raw.contains('م') && !raw.contains('ص');
    final am = raw.contains('ص');
    if (pm && hour < 12) hour += 12;
    if (am && hour == 12) hour = 0;
    return hour * 60 + min;
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
