import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_state.dart';
import 'config.dart';
import 'theme.dart';
import 'data/content.dart';
import 'services/prefs.dart';
import 'services/notification_service.dart';
import 'widgets/root_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  await AppState.I.load();
  await ContentRepo.load();
  await NotificationService.init();
  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
  );
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
          home: const RootNav(),
        );
      },
    );
  }
}
