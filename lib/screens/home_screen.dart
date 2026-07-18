import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/content.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'accounts_screen.dart';
import 'about_screen.dart';
import 'privacy_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onTab;
  const HomeScreen({super.key, required this.onTab});

  @override
  Widget build(BuildContext context) {
    final w = ContentRepo.wirdOfToday();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Story intro
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const PearlMark(size: 28),
                    const SizedBox(width: 10),
                    Text(
                      tr('شبكة أمة الإسلام', 'Muslim Ummah Network'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: dark ? AppColors.darkHeading : AppColors.pine800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  tr(
                    'منصّة معرفية إسلامية موثوقة — صدقة جارية عن علي عبد العزيز الصدّيقي رحمه الله: مكتبة كتب، ومنهج تعلّم، وبحث ذكي من الكتب، ودليل مجالس الذكر «روضة».',
                    'A trusted Islamic knowledge platform — an ongoing charity for Ali Abdulaziz Alseddiqi (may Allah have mercy on him): a book library, a learning curriculum, smart search from the books, and the "Rawdah" guide to dhikr gatherings.',
                  ),
                  style: const TextStyle(fontSize: 14, height: 1.7),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AboutScreen())),
                    child: Text(tr('اقرأ القصة كاملة', 'Read the full story')),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Daily wird
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: dark
                  ? [const Color(0xFF16211B), const Color(0xFF1B2E24)]
                  : [AppColors.sage100, AppColors.pearl100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.sage300.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('وِرد اليوم', 'Today\'s Wird'),
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.sage700)),
              const SizedBox(height: 12),
              Text(
                AppState.I.lang == 'ar' ? w.ar : w.en,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 19, height: 1.9, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  '— ${AppState.I.loc(w.source)}',
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        SectionHead(tr('الأقسام', 'Sections')),
        EntryCard(
          icon: Icons.menu_book,
          title: tr('المكتبة', 'Library'),
          subtitle: tr('${ContentRepo.books.length} كتابًا في العقيدة والحديث والحياة مع الله',
              '${ContentRepo.books.length} books on creed, hadith, and life with Allah'),
          onTap: () => onTab(1),
        ),
        const SizedBox(height: 12),
        EntryCard(
          icon: Icons.school,
          title: tr('المنهج', 'Curriculum'),
          subtitle: tr('${ContentRepo.playlists.length} قائمة تعلّم في ٩ علوم',
              '${ContentRepo.playlists.length} learning playlists across 9 sciences'),
          onTap: () => onTab(2),
        ),
        const SizedBox(height: 12),
        EntryCard(
          icon: Icons.search,
          title: tr('اسأل المكتبة', 'Ask the Library'),
          subtitle: tr('بحث ذكي يجيب من نصوص الكتب',
              'Smart search that answers from the books'),
          onTap: () => onTab(3),
        ),
        const SizedBox(height: 12),
        EntryCard(
          icon: Icons.groups,
          title: tr('روضة', 'Rawdah'),
          subtitle: tr('مجالس ودروس الذكر في الكويت',
              'Dhikr gatherings and lessons in Kuwait'),
          onTap: () => onTab(4),
        ),
        const SizedBox(height: 12),
        EntryCard(
          icon: Icons.play_circle_outline,
          title: tr('حسابات موصى بها', 'Recommended Accounts'),
          subtitle: tr('قنوات يوتيوب وحسابات إنستغرام مختارة',
              'Selected YouTube and Instagram accounts'),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AccountsScreen())),
        ),
        const SizedBox(height: 12),
        EntryCard(
          icon: Icons.privacy_tip_outlined,
          title: tr('الخصوصية', 'Privacy'),
          subtitle: tr('لا نجمع بياناتك — تخزين محلي فقط',
              'We collect no data — on-device storage only'),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PrivacyScreen())),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            tr('وقل ربِّ زدني علمًا', 'And say: My Lord, increase me in knowledge'),
            style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5)),
          ),
        ),
      ],
    );
  }
}
