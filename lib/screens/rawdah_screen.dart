import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/models.dart';
import '../services/lesson_image.dart';
import '../services/rawdah_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Weekly guide to Rawdah dhikr circles. Mirrors the website's Rawdah rules:
/// day chips starting from today, audience filter, search, time-sorted cards.
class RawdahScreen extends StatefulWidget {
  const RawdahScreen({super.key});
  @override
  State<RawdahScreen> createState() => _RawdahScreenState();
}

class _RawdahScreenState extends State<RawdahScreen> {
  late Future<List<Lesson>> _future;
  String _day = RawdahService.todayName();
  String _gender = 'all'; // all | نساء
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = RawdahService.fetchLessons();
  }

  void _reload() {
    setState(() => _future = RawdahService.fetchLessons());
  }

  @override
  Widget build(BuildContext context) {
    final searching = _query.trim().isNotEmpty;
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              isDense: true,
              hintText: tr('ابحث باسم الداعية أو العنوان أو المنطقة أو المسجد…',
                  'Search by teacher, title, area or mosque…'),
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // Audience filter
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Row(
            children: [
              ChoiceChip(
                label: Text(tr('الكل', 'All')),
                selected: _gender == 'all',
                onSelected: (_) => setState(() => _gender = 'all'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(tr('دروس النساء', "Women's lessons")),
                selected: _gender == 'نساء',
                onSelected: (_) => setState(() => _gender = 'نساء'),
              ),
            ],
          ),
        ),
        if (_gender == 'نساء') _womenNotice(context),
        Expanded(
          child: FutureBuilder<List<Lesson>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) return _errorState();
              final all = snap.data ?? [];
              final dwl = RawdahService.daysWithLessons(all);

              var selDay = _day;
              if (!searching && !dwl.contains(selDay)) {
                selDay = dwl.isNotEmpty ? dwl.first : selDay;
              }

              final term = _query.trim().toLowerCase();
              var out = all.where((l) =>
                  _gender == 'all' || RawdahService.genderOf(l) == _gender);
              if (searching) {
                out = out.where((l) => [l.title, l.teacher, l.area, l.location]
                    .any((f) => f.toLowerCase().contains(term)));
              } else {
                out = out.where((l) => l.day == selDay);
              }
              final results = out.toList()
                ..sort((a, b) => RawdahService.parseTime(a.time)
                    .compareTo(RawdahService.parseTime(b.time)));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!searching)
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        children: dwl.map((dn) {
                          final sel = dn == selDay;
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(dn),
                              selected: sel,
                              onSelected: (_) => setState(() => _day = dn),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, size: 14),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            searching
                                ? (results.isEmpty
                                    ? tr('لا توجد نتائج', 'No results')
                                    : tr('وجدنا ${results.length} نتيجة',
                                        'Found ${results.length} result(s)'))
                                : tr('جميع الأوقات بتوقيت الكويت (GMT+3)',
                                    'All times are Kuwait time (GMT+3)'),
                            style: TextStyle(
                                fontSize: 11.5,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: results.isEmpty
                        ? Center(
                            child: Text(tr('لا توجد دروس مطابقة.',
                                'No matching lessons.')),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _reload(),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(14),
                              itemCount: results.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) =>
                                  _LessonCard(results[i], showDay: searching),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _womenNotice(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF1F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDDADA)),
        ),
        child: Text(
          tr('🔒 مجالس الذكر التي تقدّمها الداعيات للنساء فقط — لا يُسمح للرجال بالدخول، ولا يُسمح بتسجيل المحاضرات؛ حفظًا للأصوات والخصوصية.',
              '🔒 These circles are for women only — men may not enter, and recording is not allowed, to protect voices and privacy.'),
          style: const TextStyle(
              fontSize: 12.5, height: 1.6, color: Color(0xFF7A5252)),
        ),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tr('تعذّر تحميل الدروس الآن.', 'Could not load lessons now.')),
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
  final bool showDay;
  const _LessonCard(this.lesson, {this.showDay = false});

  static const _womenTint = Color(0xFFFBF1F3);
  static const _womenAccent = Color(0xFFB58D88);
  static const _allTint = Color(0xFFEEF4FA);
  static const _allAccent = Color(0xFF5A7A8A);

  Lesson get l => lesson;

  @override
  Widget build(BuildContext context) {
    final women = RawdahService.genderOf(l) == 'نساء';
    final accent = women ? _womenAccent : _allAccent;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tint =
        dark ? const Color(0xFF1B2820) : (women ? _womenTint : _allTint);

    return Container(
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges: gender + types
          Wrap(spacing: 6, runSpacing: 6, children: [
            _badge(women ? tr('للنساء', 'Women') : tr('للجميع', 'All'), accent,
                Colors.white),
            ...l.types.map(_typeBadge),
          ]),
          const SizedBox(height: 10),
          Text(l.title,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          if (l.teacher.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(l.teacher,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sage700)),
          ],
          const SizedBox(height: 6),
          // Day + date line
          Row(
            children: [
              Text(l.day,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.pine800)),
              if (l.lessonDate != null) ...[
                const SizedBox(width: 6),
                Text('— ${RawdahService.fmtDate(l.lessonDate)}',
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5))),
              ],
              if (l.isRecurring) ...[
                const SizedBox(width: 6),
                Text(tr('(أسبوعي)', '(weekly)'),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.sage600)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 14, runSpacing: 4, children: [
            if (l.time.isNotEmpty) _info(Icons.schedule, l.time),
            if (l.area.isNotEmpty) _info(Icons.place_outlined, l.area),
            if (l.location.isNotEmpty)
              _info(Icons.apartment_outlined, l.location),
          ]),
          const SizedBox(height: 12),
          _actions(context, women),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context, bool women) {
    final buttons = <Widget>[];

    if (l.location.isNotEmpty) {
      final maps =
          'https://maps.google.com/?q=${Uri.encodeComponent('${l.location} ${l.area}')}';
      buttons.add(_outlined(
          context, Icons.place_outlined, tr('الموقع', 'Location'), maps));
    }

    // Zoom is primary; women see a conditions warning first.
    if (l.zoomLink.isNotEmpty) {
      if (women) {
        buttons.add(FilledButton.icon(
          onPressed: () => _showWomenWarning(context, l.zoomLink),
          icon: const Icon(Icons.videocam, size: 18),
          label: Text(tr('انضمي عبر زوم', 'Join via Zoom'),
              style: const TextStyle(fontSize: 12.5)),
        ));
      } else {
        buttons.add(FilledButton.icon(
          onPressed: () => openUrl(context, l.zoomLink),
          icon: const Icon(Icons.videocam, size: 18),
          label: Text(tr('انضم عبر زوم', 'Join via Zoom'),
              style: const TextStyle(fontSize: 12.5)),
        ));
      }
    } else if (women && l.channelLink.isNotEmpty) {
      buttons.add(FilledButton.icon(
        onPressed: () => openUrl(context, l.channelLink),
        icon: const Icon(Icons.chat, size: 18),
        label: Text(tr('انضمي للقناة', 'Join channel'),
            style: const TextStyle(fontSize: 12.5)),
      ));
    } else {
      buttons.add(FilledButton.icon(
        onPressed: () => openUrl(context, RawdahService.groupLink),
        icon: const Icon(Icons.videocam, size: 18),
        label: Text(tr('لرابط الزوم', 'For the Zoom link'),
            style: const TextStyle(fontSize: 12.5)),
      ));
    }

    if (l.instagram.isNotEmpty) {
      buttons.add(_outlined(context, Icons.camera_alt_outlined,
          '@${l.instagram}', 'https://instagram.com/${l.instagram}'));
    }
    if (l.phone.isNotEmpty) {
      final digits = l.phone.replaceAll(RegExp(r'\D'), '');
      buttons.add(_outlined(context, Icons.chat_bubble_outline,
          tr('واتساب', 'WhatsApp'), 'https://wa.me/965$digits'));
    }

    buttons.add(OutlinedButton.icon(
      onPressed: () => LessonImage.share(l, caption: _lessonText(women)),
      icon: const Icon(Icons.ios_share, size: 18),
      label:
          Text(tr('مشاركة', 'Share'), style: const TextStyle(fontSize: 12.5)),
    ));

    return Wrap(spacing: 8, runSpacing: 8, children: buttons);
  }

  String _lessonText(bool women) {
    final dt = l.lessonDate != null
        ? '${l.day} ${RawdahService.fmtDate(l.lessonDate)}'
        : (l.isRecurring ? '${l.day} (أسبوعي)' : l.day);
    final loc = [l.area, l.location].where((s) => s.isNotEmpty).join(' - ');
    final lines = <String>[
      '🌿 ${l.title}',
      if (l.teacher.isNotEmpty) '👤 ${l.teacher}',
      '📅 $dt',
      if (l.time.isNotEmpty) '🕐 ${l.time} (بتوقيت الكويت)',
      if (loc.isNotEmpty) '📍 $loc',
      women ? '🌸 درس للنساء' : '👥 للجميع',
      '',
      'روضة — أمة الإسلام',
      kSiteUrl,
    ];
    return lines.join('\n');
  }

  void _showWomenWarning(BuildContext context, String zoomLink) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('🌸 درس للنساء فقط', '🌸 Women-only lesson'),
            style: const TextStyle(color: _womenAccent, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('قبل الدخول، الرجاء الالتزام بالشروط التالية:',
                'Before joining, please observe the following:')),
            const SizedBox(height: 10),
            _bullet(tr('لا يحلّ للرجال الدخول.',
                'Men are not permitted to enter.')),
            _bullet(tr('الدخول بالاسم الصريح؛ للتحقّق من الحضور.',
                'Join with your real name for attendance.')),
            _bullet(tr('لا يُسمح بتسجيل الدرس أو إخراج الصوتيات.',
                'Recording or extracting audio is not allowed.')),
            _bullet(tr('عدم إدراج أي روابط في الدردشة.',
                'Do not post any links in the chat.')),
            const SizedBox(height: 8),
            Text(
                tr('«المؤمنون على شروطهم»',
                    '“Believers are bound by their conditions.”'),
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(ctx)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6))),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('إلغاء', 'Cancel'))),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              openUrl(context, zoomLink);
            },
            child: Text(tr('أوافق وأدخل', 'I agree — enter')),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('•  '),
            Expanded(child: Text(text, style: const TextStyle(height: 1.5))),
          ],
        ),
      );

  Widget _info(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.sage700),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      );

  Widget _badge(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w700, color: fg)),
      );

  Widget _typeBadge(String tp) {
    if (tp == 'اونلاين') {
      return _badge(
          '🖥️ اونلاين', const Color(0xFFE6EEF5), const Color(0xFF5A7A8A));
    }
    final label = tp == 'حضوري' ? '🕌 حضوري' : tp;
    return _badge(label, AppColors.sage100, AppColors.sage700);
  }

  Widget _outlined(
          BuildContext context, IconData icon, String label, String url) =>
      OutlinedButton.icon(
        onPressed: () => openUrl(context, url),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 12.5)),
      );
}
