import 'package:flutter/material.dart';
import '../app_state.dart';
import '../config.dart';
import '../models/models.dart';
import '../services/rawdah_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class RawdahScreen extends StatefulWidget {
  const RawdahScreen({super.key});
  @override
  State<RawdahScreen> createState() => _RawdahScreenState();
}

class _RawdahScreenState extends State<RawdahScreen> {
  late Future<List<Lesson>> _future;
  late List<String> _days;
  String _day = '';
  bool _womenOnly = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _days = RawdahService.orderedDays();
    _day = _days.first;
    _future = RawdahService.fetchLessons();
  }

  void _reload() {
    setState(() => _future = RawdahService.fetchLessons());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Day selector
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: _days.map((d) {
              final sel = d == _day;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(d),
                  selected: sel,
                  onSelected: (_) => setState(() => _day = d),
                ),
              );
            }).toList(),
          ),
        ),
        // Search + gender filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: tr('بحث…', 'Search…'),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(tr('دروس النساء', 'Women')),
                selected: _womenOnly,
                onSelected: (v) => setState(() => _womenOnly = v),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          child: Row(
            children: [
              const Icon(Icons.schedule, size: 14),
              const SizedBox(width: 5),
              Text(
                tr('جميع الأوقات بتوقيت الكويت (GMT+3)',
                    'All times are Kuwait time (GMT+3)'),
                style: TextStyle(
                    fontSize: 11.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Lesson>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return _errorState();
              }
              final all = snap.data ?? [];
              var items = all
                  .where((l) =>
                      RawdahService.normalizeDay(l.day) == _day)
                  .where((l) => !_womenOnly || l.isWomen)
                  .where((l) => _query.isEmpty ||
                      ('${l.title} ${l.teacher} ${l.area} ${l.location}')
                          .contains(_query))
                  .toList()
                ..sort((a, b) => RawdahService.timeToMinutes(a.time)
                    .compareTo(RawdahService.timeToMinutes(b.time)));

              if (items.isEmpty) {
                return Center(
                  child: Text(tr('لا توجد دروس في هذا اليوم.',
                      'No lessons on this day.')),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _LessonCard(items[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tr('تعذّر تحميل الدروس.', 'Could not load lessons.')),
          const SizedBox(height: 10),
          FilledButton(
              onPressed: _reload, child: Text(tr('إعادة المحاولة', 'Retry'))),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  const _LessonCard(this.lesson);

  @override
  Widget build(BuildContext context) {
    final women = lesson.isWomen;
    final ended = RawdahService.isEnded(lesson);
    final cardColor = women ? AppColors.womenCard : AppColors.menCard;
    final badge = women ? AppColors.womenBadge : AppColors.menBadge;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Opacity(
      opacity: ended ? 0.55 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF1B2820) : cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: badge.withValues(alpha: 0.35)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badges row
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _badge(women ? tr('للنساء', 'Women') : tr('للجميع', 'All'),
                    badge),
                if (ended) _badge(tr('انتهى', 'Ended'), Colors.grey),
                ...lesson.types.map((t) => _badge(t, AppColors.sage600)),
              ],
            ),
            const SizedBox(height: 10),
            Text(lesson.title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            if (lesson.teacher.isNotEmpty)
              _row(Icons.person_outline, lesson.teacher),
            if (lesson.time.isNotEmpty) _row(Icons.schedule, lesson.time),
            if (lesson.location.isNotEmpty || lesson.area.isNotEmpty)
              _row(Icons.place_outlined,
                  [lesson.location, lesson.area].where((s) => s.isNotEmpty).join(' — ')),
            const SizedBox(height: 12),
            _actions(context, women),
            if (women) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.womenBadge.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tr('للنساء فقط — ولا يجوز تسجيل الدرس أو نشره.',
                      'For women only — recording or sharing the lesson is not allowed.'),
                  style: TextStyle(fontSize: 12, color: badge),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actions(BuildContext context, bool women) {
    final buttons = <Widget>[];

    if (women) {
      final link =
          lesson.channelLink.isNotEmpty ? lesson.channelLink : Config.rawdahWhatsapp;
      buttons.add(_btn(context, Icons.chat, tr('القناة / واتساب', 'Channel / WhatsApp'), link));
    } else {
      final link =
          lesson.zoomLink.isNotEmpty ? lesson.zoomLink : Config.rawdahWhatsapp;
      buttons.add(_btn(context, Icons.videocam, tr('رابط الزوم', 'Zoom link'), link));
      if (lesson.zoomPasscode.isNotEmpty) {
        buttons.add(Chip(
          label: Text(tr('الرمز: ${lesson.zoomPasscode}',
              'Code: ${lesson.zoomPasscode}')),
        ));
      }
    }

    if (lesson.instagram.isNotEmpty) {
      buttons.add(_btn(context, Icons.camera_alt_outlined, '@${lesson.instagram}',
          'https://www.instagram.com/${lesson.instagram}'));
    }
    if (lesson.phone.isNotEmpty) {
      buttons.add(_btn(context, Icons.phone, tr('واتساب', 'WhatsApp'),
          'https://wa.me/965${lesson.phone}'));
    }

    return Wrap(spacing: 8, runSpacing: 8, children: buttons);
  }

  Widget _btn(BuildContext context, IconData icon, String label, String url) {
    return OutlinedButton.icon(
      onPressed: () => openUrl(context, url),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12.5)),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.sage700),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13.5))),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11.5, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
