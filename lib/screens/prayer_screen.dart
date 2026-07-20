import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/prayer_service.dart';
import '../theme.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});
  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  late Future<PrayerData> _future;

  @override
  void initState() {
    super.initState();
    _future = PrayerService.today();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('مواقيت الصلاة', 'Prayer Times'))),
      body: FutureBuilder<PrayerData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tr('تعذّر جلب المواقيت. تأكد من الإنترنت.',
                      'Could not load prayer times. Check your internet.')),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => setState(
                        () => _future = PrayerService.today(forceRefresh: true)),
                    child: Text(tr('إعادة المحاولة', 'Retry')),
                  ),
                ],
              ),
            );
          }
          final d = snap.data!;
          final next = PrayerService.nextPrayer(d);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _header(context, d, next),
              const SizedBox(height: 16),
              ...PrayerData.order.map((k) => _row(context, k, d, next)),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${d.city} · ${tr('بتوقيت الكويت', 'Kuwait time')}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _header(
      BuildContext context, PrayerData d, MapEntry<String, String>? next) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [const Color(0xFF16211B), const Color(0xFF1B2E24)]
              : [AppColors.pine800, AppColors.pine700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(d.hijriAr,
              style: const TextStyle(
                  color: AppColors.pearl50,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('${d.gregorian.replaceAll('-', '/')} م',
              style: const TextStyle(color: AppColors.sage300, fontSize: 13)),
          const SizedBox(height: 6),
          if (next != null)
            Text(
              '${tr('الصلاة القادمة', 'Next')}: ${tr(PrayerData.labelAr[next.key]!, PrayerData.labelEn[next.key]!)} — ${next.value}',
              style: const TextStyle(color: AppColors.sage300, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String k, PrayerData d,
      MapEntry<String, String>? next) {
    final isNext = next != null && next.key == k;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.sage100
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isNext ? AppColors.sage600 : AppColors.pearl200),
      ),
      child: Row(
        children: [
          Icon(
            k == 'Sunrise' ? Icons.wb_twilight : Icons.mosque_outlined,
            color: AppColors.sage700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(tr(PrayerData.labelAr[k]!, PrayerData.labelEn[k]!),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isNext ? FontWeight.w800 : FontWeight.w600)),
          const Spacer(),
          Text(d.timings[k] ?? '--',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pine800)),
        ],
      ),
    );
  }
}
