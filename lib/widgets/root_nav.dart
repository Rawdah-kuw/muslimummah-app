import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/curriculum_screen.dart';
import '../screens/search_screen.dart';
import '../screens/rawdah_screen.dart';

class RootNav extends StatefulWidget {
  const RootNav({super.key});
  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  void _goTab(int i) => setState(() => _index = i);

  String _titleFor(int i) {
    switch (i) {
      case 0:
        return tr('أمة الإسلام', 'Muslim Ummah');
      case 1:
        return tr('المكتبة', 'Library');
      case 2:
        return tr('المنهج', 'Curriculum');
      case 3:
        return tr('ابحث وتعلّم', 'Search & Learn');
      default:
        return tr('روضة', 'Rawdah');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFor(_index)),
        actions: [
          IconButton(
            tooltip: tr('اللغة', 'Language'),
            onPressed: () => AppState.I.toggleLang(),
            icon: Text(
              AppState.I.lang == 'ar' ? 'EN' : 'ع',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            tooltip: tr('الوضع الليلي', 'Dark mode'),
            onPressed: () => AppState.I.toggleTheme(),
            icon: Icon(AppState.I.themeMode == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onTab: _goTab),
          const LibraryScreen(),
          const CurriculumScreen(),
          const SearchScreen(),
          const RawdahScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const _NavDot(false),
            selectedIcon: const _NavDot(true),
            label: tr('الرئيسية', 'Home'),
          ),
          NavigationDestination(
            icon: const _NavDot(false),
            selectedIcon: const _NavDot(true),
            label: tr('المكتبة', 'Library'),
          ),
          NavigationDestination(
            icon: const _NavDot(false),
            selectedIcon: const _NavDot(true),
            label: tr('المنهج', 'Curriculum'),
          ),
          NavigationDestination(
            icon: const _NavDot(false),
            selectedIcon: const _NavDot(true),
            label: tr('ابحث', 'Search'),
          ),
          NavigationDestination(
            icon: const _NavDot(false),
            selectedIcon: const _NavDot(true),
            label: tr('روضة', 'Rawdah'),
          ),
        ],
      ),
    );
  }
}

/// A pearl-circle nav mark: hollow ring when idle, glossy pearl when selected.
class _NavDot extends StatelessWidget {
  final bool selected;
  const _NavDot(this.selected);

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: 13,
        height: 13,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment(-0.35, -0.35),
            radius: 0.95,
            colors: [Color(0xFFFFFFFF), AppColors.sage500, AppColors.pine800],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
      );
    }
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: AppColors.sage500.withValues(alpha: 0.6), width: 1.5),
      ),
    );
  }
}
