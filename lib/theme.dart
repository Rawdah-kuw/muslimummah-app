import 'package:flutter/material.dart';

/// Muslim Ummah visual identity — pine green + pearl cream + sage.
class AppColors {
  // Pearl (creamy neutrals)
  static const pearl50 = Color(0xFFFDFBF7);
  static const pearl100 = Color(0xFFF7F4ED);
  static const pearl200 = Color(0xFFEDE9DF);
  static const pearl300 = Color(0xFFD9D4C7);

  // Pine (deep greens for headings / accents)
  static const pine700 = Color(0xFF2A4A39);
  static const pine800 = Color(0xFF1B3B2B);
  static const pine900 = Color(0xFF122B1F);

  // Sage (muted greens for buttons / chips)
  static const sage100 = Color(0xFFEDF3F0);
  static const sage300 = Color(0xFFD7E4DD);
  static const sage500 = Color(0xFF6B8F7E);
  static const sage600 = Color(0xFF4F7263);
  static const sage700 = Color(0xFF3E5A4E);

  static const ink = Color(0xFF1E293B);

  // Dark mode
  static const darkSurface = Color(0xFF121A16);
  static const darkText = Color(0xFFD5DED6);
  static const darkHeading = Color(0xFFCDE4D9);

  // Rawdah accents
  static const womenCard = Color(0xFFFBF1F3);
  static const womenBadge = Color(0xFFB58D88);
  static const menCard = Color(0xFFEEF4FA);
  static const menBadge = Color(0xFF5A7A8A);
}

class AppTheme {
  static ThemeData light() {
    const seed = AppColors.pine800;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.pine800,
      secondary: AppColors.sage600,
      surface: Colors.white,
    );
    return _base(scheme, AppColors.pearl50, AppColors.ink);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.sage500,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.sage500,
      secondary: AppColors.sage300,
      surface: const Color(0xFF16211B),
    );
    return _base(scheme, AppColors.darkSurface, AppColors.darkText);
  }

  static ThemeData _base(ColorScheme scheme, Color bg, Color text) {
    final dark = scheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: dark ? AppColors.darkHeading : AppColors.pine800,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: dark ? AppColors.darkHeading : AppColors.pine800,
        ),
      ),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF1B2820) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: dark ? const Color(0xFF2A3A31) : AppColors.pearl200,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.pine800,
          foregroundColor: AppColors.pearl50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dark ? const Color(0xFF1F2E25) : AppColors.sage100,
        selectedColor: AppColors.sage600,
        labelStyle: TextStyle(color: text),
        side: BorderSide(color: AppColors.sage300.withValues(alpha: 0.6)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: Typography.material2021().black.apply(
            bodyColor: text,
            displayColor: dark ? AppColors.darkHeading : AppColors.pine800,
          ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF16211B) : Colors.white,
        indicatorColor: AppColors.sage100,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
