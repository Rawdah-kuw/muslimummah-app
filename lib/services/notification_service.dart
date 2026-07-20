/// Local daily reminders — TEMPORARILY DISABLED.
///
/// The reminders feature (wird, morning/evening adhkar, Rawdah) will return in
/// a coming update using a modern scheduling setup. This stub keeps the same
/// public API so the rest of the app compiles and runs unchanged; every method
/// is a safe no-op for now.
class NotificationService {
  // Fixed notification ids (kept so the UI layer still references them).
  static const idWird = 1;
  static const idMorning = 2;
  static const idEvening = 3;
  static const idRawdah = 4;

  static Future<void> init() async {}

  static Future<void> requestPermissions() async {}

  static Future<void> scheduleDaily(
      int id, int hour, int minute, String title, String body) async {}

  static Future<void> cancel(int id) async {}
}
