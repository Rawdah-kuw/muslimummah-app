import 'package:flutter/material.dart';
import '../app_state.dart';
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
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: tr('الرئيسية', 'Home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: tr('المكتبة', 'Library'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.school_outlined),
            selectedIcon: const Icon(Icons.school),
            label: tr('المنهج', 'Curriculum'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.search),
            selectedIcon: const Icon(Icons.search),
            label: tr('ابحث', 'Search'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups),
            label: tr('روضة', 'Rawdah'),
          ),
        ],
      ),
    );
  }
}
