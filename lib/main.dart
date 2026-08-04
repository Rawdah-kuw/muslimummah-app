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
  await NotificationService.init();
  // Keep the daily-Wird notification series topped up with each day's text.
  if (Prefs.getBool('notif_wird', false)) {
    await NotificationService.scheduleWird(
      Prefs.getInt('notif_wird_h', 7),
      Prefs.getInt('notif_wird_m', 0),
      AppState.I.lang == 'ar',
    );
  }
  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
  );
  // Refresh the five-prayer reminders with today's exact times (best effort).
  if (Prefs.getBool('notif_prayers', false)) {
    () async {
      try {
        final pd = await PrayerService.today();
        await NotificationService.schedulePrayers(
            pd.timings, AppState.I.lang == 'ar');
      } catch (_) {/* offline — keep the existing schedule */}
    }();
  }
  runApp(const MuslimUmmahApp());
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
