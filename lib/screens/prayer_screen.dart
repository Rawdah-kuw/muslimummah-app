import 'dart:async';
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
  String? _selectedKey; // the prayer whose countdown shows at the top
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _future = PrayerService.today();
    // Keep the countdown fresh.
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
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
          // Show the tapped prayer's countdown at the top; default to next.
          final selKey = _selectedKey ?? next?.key;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _header(context, d, selKey, isNext: selKey == next?.key),
              const SizedBox(height: 16),
              ...PrayerData.order.map((k) => _row(context, k, d, selKey)),
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

  Widget _header(BuildContext context, PrayerData d, String? selKey,
      {required bool isNext}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ar = AppState.I.lang == 'ar';
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
          Text(d.hijri(ar),
              style: const TextStyle(
                  color: AppColors.pearl50,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(d.gregorian.replaceAll('-', '/'),
              style: const TextStyle(color: AppColors.sage300, fontSize: 13)),
          if (selKey != null) ...[
            const SizedBox(height: 12),
            // Selected prayer (defaults to the next one) + how long remains.
            Text(
              '${isNext ? '${tr('الصلاة القادمة', 'Next')}: ' : ''}${tr(PrayerData.labelAr[selKey]!, PrayerData.labelEn[selKey]!)} — ${PrayerData.time12(d.timings[selKey] ?? '--', ar)}',
              style: const TextStyle(
                  color: AppColors.pearl50,
                  fontSize: 16,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(_untilText(d.timings[selKey]),
                style: const TextStyle(color: AppColors.sage300, fontSize: 14)),
          ],
        ],
      ),
    );
  }

  /// Human "time remaining until this prayer" (today, or the next occurrence).
  String _untilText(String? hhmm) {
    if (hhmm == null || !hhmm.contains(':')) return '';
    final ar = AppState.I.lang == 'ar';
    final p = hhmm.split(':');
    final target = (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
    final now = DateTime.now();
    var diff = target - (now.hour * 60 + now.minute);
    if (diff <= 0) diff += 1440; // already passed today → next occurrence
    final h = diff ~/ 60, m = diff % 60;
    if (ar) {
      final hp = h > 0 ? '$h ساعة' : '';
      final mp = m > 0 ? '$m دقيقة' : '';
      final sep = (h > 0 && m > 0) ? ' و' : '';
      return 'متبقٍّ: ${hp.isEmpty && mp.isEmpty ? 'أقل من دقيقة' : '$hp$sep$mp'}';
    } else {
      final hp = h > 0 ? '${h}h' : '';
      final mp = m > 0 ? '${m}m' : '';
      final sep = (h > 0 && m > 0) ? ' ' : '';
      return 'Remaining: ${hp.isEmpty && mp.isEmpty ? 'less than a minute' : '$hp$sep$mp'}';
    }
  }

  Widget _row(BuildContext context, String k, PrayerData d, String? selKey) {
    final isSelected = k == selKey;
    final ar = AppState.I.lang == 'ar';
    return GestureDetector(
      // Tap a prayer → its countdown moves up to the header.
      onTap: () => setState(() => _selectedKey = k),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.sage100
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected ? AppColors.sage600 : AppColors.pearl200),
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
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600)),
            const Spacer(),
            Text(PrayerData.time12(d.timings[k] ?? '--', ar),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pine800)),
            const SizedBox(width: 6),
            Icon(Icons.touch_app_outlined,
                size: 14,
                color: AppColors.sage600.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
