import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_state.dart';
import 'config.dart';
import 'theme.dart';
import 'data/content.dart';
import 'services/prefs.dart';
import 'services/notification_service.dart';
import 'services/prayer_service.dart';
import 'widgets/root_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  await AppState.I.load();
  await ContentRepo.load();
  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
  );
  // Show the UI immediately, then top up the reminders in the background.
  runApp(const MuslimUmmahApp());
  _refreshReminders();
}

/// Refreshes scheduled reminders AFTER the app is running, fully guarded so a
/// notification/plugin/timezone error can never block or crash startup.
/// (A crash here before runApp() would freeze the app on every launch — and,
/// with the setting restored by Android backup, even after a reinstall.)
Future<void> _refreshReminders() async {
  try {
    await NotificationService.init();
    if (Prefs.getBool('notif_wird', false)) {
      await NotificationService.scheduleWird(
        Prefs.getInt('notif_wird_h', 7),
        Prefs.getInt('notif_wird_m', 0),
        AppState.I.lang == 'ar',
      );
    }
    if (Prefs.getBool('notif_prayers', false)) {
      final pd = await PrayerService.today();
      await NotificationService.schedulePrayers(
          pd.timings, AppState.I.lang == 'ar');
    }
  } catch (_) {/* reminders are best-effort — never let them break the app */}
}

class MuslimUmmahApp extends StatelessWidget {
  const MuslimUmmahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.I,
      builder: (context, _) {
        return MaterialApp(
          title: 'Muslim Ummah',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: AppState.I.themeMode,
          locale: AppState.I.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: RootNav(),
        );
      },
    );
  }
}
