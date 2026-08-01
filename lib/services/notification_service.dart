import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../data/content.dart';

/// Local daily reminders: wird, morning adhkar, evening adhkar, Rawdah lessons.
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  // Fixed notification ids.
  static const idWird = 1;
  static const idMorning = 2;
  static const idEvening = 3;
  static const idRawdah = 4;

  static Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Kuwait'));
    } catch (_) {/* fallback to UTC */}

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios));
    _ready = true;
  }

  static Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static final _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'mu_daily',
      'التذكيرات اليومية',
      channelDescription: 'تذكيرات الوِرد والأذكار والدروس',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: const DarwinNotificationDetails(),
  );

  static tz.TZDateTime _nextTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var d = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (d.isBefore(now)) d = d.add(const Duration(days: 1));
    return d;
  }

  static Future<void> scheduleDaily(
      int id, int hour, int minute, String title, String body) async {
    await init();
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextTime(hour, minute),
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancel(int id) async {
    await init();
    await _plugin.cancel(id);
  }

  // ── Daily Wird: schedule the next 14 days, each with that day's actual
  //    reminder text. Rescheduled on every app start to stay topped up. ──
  static const _wirdBase = 100;
  static const _wirdDays = 14;

  static NotificationDetails _bigText(String body) => NotificationDetails(
        android: AndroidNotificationDetails(
          'mu_daily',
          'التذكيرات اليومية',
          channelDescription: 'تذكيرات الوِرد والأذكار والدروس',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(),
      );

  static Future<void> scheduleWird(int hour, int minute, bool ar) async {
    await init();
    await cancelWird();
    final now = tz.TZDateTime.now(tz.local);
    for (var i = 0; i < _wirdDays; i++) {
      final day = now.add(Duration(days: i));
      final when =
          tz.TZDateTime(tz.local, day.year, day.month, day.day, hour, minute);
      if (when.isBefore(now)) continue; // skip if today's time already passed
      final w =
          ContentRepo.wirdForDate(DateTime(day.year, day.month, day.day));
      final src = ar ? (w.source['ar'] ?? '') : (w.source['en'] ?? '');
      final body = '${ar ? w.ar : w.en}\n$src';
      await _plugin.zonedSchedule(
        _wirdBase + i,
        ar ? 'وِرد اليوم 🌿' : "Today's Wird 🌿",
        body,
        when,
        _bigText(body),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> cancelWird() async {
    await init();
    for (var i = 0; i < _wirdDays; i++) {
      await _plugin.cancel(_wirdBase + i);
    }
  }
}
