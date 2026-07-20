import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/content.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/scene.dart';
import '../services/prayer_service.dart';
import '../services/prefs.dart';
import '../services/rawdah_service.dart';
import 'about_screen.dart';
import 'privacy_screen.dart';
import 'prayer_screen.dart';
import 'adhkar_screen.dart';
import 'tasbih_screen.dart';
import 'bookmarks_screen.dart';
import 'qibla_screen.dart';
import 'notifications_screen.dart';
import 'accounts_screen.dart';
import 'book_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onTab;
  const HomeScreen({super.key, required this.onTab});

  void _push(BuildContext c, Widget w) =>
      Navigator.push(c, MaterialPageRoute(builder: (_) => w));

  bool get _isMorning {
    final h = DateTime.now().hour;
    return h >= 3 && h < 15;
  }

  @override
  Widget build(BuildContext context) {
    final w = ContentRepo.wirdOfToday();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _dedication(context, dark),
        const SizedBox(height: 14),

        _wird(context, w, dark),
        const SizedBox(height: 16),

        // Foundation: Library + Curriculum
        Row(children: [
          Expanded(
              child: _foundation(
                  Scenes.pine,
                  tr('المكتبة', 'Library'),
                  tr('${ContentRepo.books.length} كتابًا موثوقًا',
                      '${ContentRepo.books.length} trusted books'),
                  () => onTab(1))),
          const SizedBox(width: 12),
          Expanded(
              child: _foundation(
                  Scenes.sage,
                  tr('المنهج', 'Curriculum'),
                  tr('${ContentRepo.playlists.length} قائمة · ٩ علوم',
                      '${ContentRepo.playlists.length} lists · 9 sciences'),
                  () => onTab(2))),
        ]),
        const SizedBox(height: 18),

        _label(tr('في روضة اليوم', 'Rawdah today')),
        _RawdahToday(onOpen: () => onTab(4)),
        const SizedBox(height: 10),

        _PrayerMini(),
        const SizedBox(height: 16),

        _label(_isMorning
            ? tr('أذكار الصباح', 'Morning Adhkar')
            : tr('أذكار المساء', 'Evening Adhkar')),
        _adhkarNow(context),
        const SizedBox(height: 16),

        _continueReading(context),

        _label(tr('أدوات', 'Tools')),
        _toolsGrid(context),

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

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
        child: Text(s,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.sage700)),
      );

  Widget _dedication(BuildContext context, bool dark) {
    return GestureDetector(
      onTap: () => _push(context, const AboutScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF16211B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sage300.withValues(alpha: 0.7)),
        ),
        child: Row(children: [
          const PearlMark(size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('أثرٌ باقٍ', 'A lasting legacy'),
                    style:
                        const TextStyle(fontSize: 11.5, color: AppColors.sage700)),
                const SizedBox(height: 2),
                Text(
                    tr('علي عبد العزيز الصدّيقي رحمه الله',
                        'Ali Abdulaziz Alseddiqi (may Allah have mercy on him)'),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: dark ? AppColors.darkHeading : AppColors.pine800)),
              ],
            ),
          ),
          Icon(Icons.chevron_left,
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
        ]),
      ),
    );
  }

  Widget _wird(BuildContext context, Wird w, bool dark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [const Color(0xFF16211B), const Color(0xFF1B2E24)]
              : [AppColors.sage100, AppColors.pearl100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sage300.withValues(alpha: 0.5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(tr('وِرد اليوم', "Today's Wird"),
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.sage700)),
          const Spacer(),
          InkWell(
            onTap: () => shareText(
                '${w.ar}\n${AppState.I.loc(w.source)}\n\n$kSiteUrl'),
            child: const Icon(Icons.ios_share, size: 18, color: AppColors.sage700),
          ),
        ]),
        const SizedBox(height: 10),
        Text(AppState.I.lang == 'ar' ? w.ar : w.en,
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 18, height: 1.9, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Text('— ${AppState.I.loc(w.source)}',
              style: TextStyle(
                  fontSize: 13,
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
        ),
      ]),
    );
  }

  Widget _foundation(
      CardScene scene, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 108,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: scene.colors,
              begin: Alignment.topRight,
              end: Alignment.bottomLeft),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: scene.colors.last.withValues(alpha: 0.22),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Positioned.fill(child: PearlBackdrop(scene)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(title,
                    style: TextStyle(
                        color: scene.onColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scene.subColor, fontSize: 11.5)),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _adhkarNow(BuildContext context) {
    final scene = _isMorning ? Scenes.dawn : Scenes.dusk;
    return GestureDetector(
      onTap: () =>
          _push(context, AdhkarScreen(initialTab: _isMorning ? 0 : 1)),
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: scene.colors,
              begin: Alignment.topRight,
              end: Alignment.bottomLeft),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Positioned.fill(child: PearlBackdrop(scene)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    _isMorning
                        ? tr('أذكار الصباح', 'Morning Adhkar')
                        : tr('أذكار المساء', 'Evening Adhkar'),
                    style: TextStyle(
                        color: scene.onColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(tr('حان وقتها الآن — اضغط للبدء', "It's time — tap to begin"),
                    style: TextStyle(color: scene.subColor, fontSize: 12.5)),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _continueReading(BuildContext context) {
    final id = Prefs.lastBook();
    final book = id < 0 ? null : ContentRepo.bookById(id);
    if (book == null) return const SizedBox.shrink();
    return Column(children: [
      _label(tr('تابع القراءة', 'Continue reading')),
      GestureDetector(
        onTap: () => _push(context, BookDetailScreen(book: book)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.sage300),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 58,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF2E5442), Color(0xFF1B3B2B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book,
                  color: AppColors.pearl50, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppState.I.loc(book.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(AppState.I.loc(book.author),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6))),
                ],
              ),
            ),
            Text(tr('أكمل', 'Resume'),
                style: const TextStyle(
                    color: AppColors.sage700,
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
          ]),
        ),
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _toolsGrid(BuildContext context) {
    Widget tile(String title, CardScene scene, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: scene.colors,
                begin: Alignment.topRight,
                end: Alignment.bottomLeft),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            Positioned.fill(child: PearlBackdrop(scene)),
            Padding(
              padding: const EdgeInsets.all(11),
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Text(title,
                    style: TextStyle(
                        color: scene.onColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.15,
      children: [
        tile(tr('اتجاه القبلة', 'Qibla'), Scenes.sky,
            () => _push(context, const QiblaScreen())),
        tile(tr('السبحة', 'Tasbih'), Scenes.sage,
            () => _push(context, const TasbihScreen())),
        tile(tr('ذكّرني', 'Remind me'), Scenes.night,
            () => _push(context, const NotificationsScreen())),
        tile(tr('منارات', 'Beacons'), Scenes.dusk,
            () => _push(context, const AccountsScreen())),
        tile(tr('المحفوظات', 'Saved'), Scenes.pearl,
            () => _push(context, const BookmarksScreen())),
        tile(tr('الخصوصية', 'Privacy'), Scenes.pearl,
            () => _push(context, const PrivacyScreen())),
      ],
    );
  }
}

/// Compact next-prayer card with countdown.
class _PrayerMini extends StatefulWidget {
  @override
  State<_PrayerMini> createState() => _PrayerMiniState();
}

class _PrayerMiniState extends State<_PrayerMini> {
  late Future<PrayerData> _future;

  @override
  void initState() {
    super.initState();
    _future = PrayerService.today();
  }

  String _countdown(String hhmm) {
    final p = hhmm.split(':');
    if (p.length < 2) return '';
    final target = (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
    final now = DateTime.now();
    var diff = target - (now.hour * 60 + now.minute);
    if (diff < 0) diff += 1440;
    final h = diff ~/ 60, m = diff % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const PrayerScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF1B3B2B), Color(0xFF2E5442)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft),
          borderRadius: BorderRadius.circular(20),
        ),
        child: FutureBuilder<PrayerData>(
          future: _future,
          builder: (context, snap) {
            if (!snap.hasData) {
              return Row(children: [
                const Icon(Icons.mosque_outlined, color: AppColors.sage300),
                const SizedBox(width: 10),
                Text(
                    snap.hasError
                        ? tr('مواقيت الصلاة', 'Prayer times')
                        : tr('جارٍ التحميل…', 'Loading…'),
                    style: const TextStyle(color: AppColors.pearl50)),
              ]);
            }
            final d = snap.data!;
            final next = PrayerService.nextPrayer(d);
            return Row(children: [
              const Icon(Icons.mosque, color: AppColors.sage300, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (next != null)
                      Text(
                        '${tr('الصلاة القادمة', 'Next')}: ${tr(PrayerData.labelAr[next.key]!, PrayerData.labelEn[next.key]!)} — ${next.value}',
                        style: const TextStyle(
                            color: AppColors.pearl50,
                            fontSize: 15,
                            fontWeight: FontWeight.w800),
                      ),
                    const SizedBox(height: 2),
                    Text('${d.hijriAr} · ${d.gregorian.replaceAll('-', '/')}',
                        style: const TextStyle(
                            color: AppColors.sage300, fontSize: 11.5)),
                  ],
                ),
              ),
              if (next != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_countdown(next.value),
                        style: const TextStyle(
                            color: AppColors.pearl50,
                            fontSize: 17,
                            fontWeight: FontWeight.w800)),
                    Text(tr('حتى الأذان', 'to adhan'),
                        style: const TextStyle(
                            color: AppColors.sage300, fontSize: 10)),
                  ],
                ),
            ]);
          },
        ),
      ),
    );
  }
}

/// Today's nearest Rawdah lesson (from Supabase).
class _RawdahToday extends StatefulWidget {
  final VoidCallback onOpen;
  const _RawdahToday({required this.onOpen});
  @override
  State<_RawdahToday> createState() => _RawdahTodayState();
}

class _RawdahTodayState extends State<_RawdahToday> {
  late Future<List<Lesson>> _future;

  @override
  void initState() {
    super.initState();
    _future = RawdahService.fetchLessons();
  }

  @override
  Widget build(BuildContext context) {
    const scene = Scenes.night;
    return GestureDetector(
      onTap: widget.onOpen,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF223452), Color(0xFF14251E)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Positioned.fill(child: PearlBackdrop(scene)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<List<Lesson>>(
              future: _future,
              builder: (context, snap) {
                final today = RawdahService.orderedDays().first;
                Lesson? lesson;
                if (snap.hasData) {
                  final items = snap.data!
                      .where((l) =>
                          RawdahService.normalizeDay(l.day) == today &&
                          !RawdahService.isEnded(l))
                      .toList()
                    ..sort((a, b) => RawdahService.timeToMinutes(a.time)
                        .compareTo(RawdahService.timeToMinutes(b.time)));
                  if (items.isNotEmpty) lesson = items.first;
                }
                if (lesson == null) {
                  return Row(children: [
                    const Expanded(
                      child: Text('روضة — مجالس ودروس الذكر',
                          style: TextStyle(
                              color: AppColors.pearl50,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                    ),
                    const Icon(Icons.chevron_left, color: AppColors.sage300),
                  ]);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('أقرب درس اليوم', "Today's next lesson"),
                        style: const TextStyle(
                            color: Color(0xFF9FB0C9), fontSize: 12)),
                    const SizedBox(height: 3),
                    Text(lesson.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.pearl50,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Text(
                        [lesson.teacher, lesson.time, lesson.location]
                            .where((s) => s.isNotEmpty)
                            .join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFFC7D2E2), fontSize: 12.5)),
                  ],
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
