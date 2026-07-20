import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/notification_service.dart';
import '../services/prefs.dart';
import '../theme.dart';

class _Reminder {
  final String key;
  final int id;
  final String titleAr, titleEn;
  final String bodyAr, bodyEn;
  final int defH, defM;
  const _Reminder(this.key, this.id, this.titleAr, this.titleEn, this.bodyAr,
      this.bodyEn, this.defH, this.defM);
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _reminders = [
    _Reminder('wird', NotificationService.idWird, 'وِرد اليوم', 'Daily Wird',
        'تذكير اليوم من القرآن والسنة', 'Today\'s reminder from the Qur\'an and Sunnah', 7, 0),
    _Reminder('morning', NotificationService.idMorning, 'أذكار الصباح',
        'Morning Adhkar', 'حان وقت أذكار الصباح', 'Time for the morning adhkar', 6, 30),
    _Reminder('evening', NotificationService.idEvening, 'أذكار المساء',
        'Evening Adhkar', 'حان وقت أذكار المساء', 'Time for the evening adhkar', 17, 30),
    _Reminder('rawdah', NotificationService.idRawdah, 'دروس روضة',
        'Rawdah Lessons', 'تفقّدي دروس اليوم في روضة', 'Check today\'s Rawdah lessons', 16, 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('التذكيرات', 'Reminders'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            tr('فعّلي التذكيرات اليومية التي تريدينها، واختاري وقت كل منها.',
                'Turn on the daily reminders you want, and pick a time for each.'),
            style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.65)),
          ),
          const SizedBox(height: 12),
          ..._reminders.map((r) => _ReminderTile(r)),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatefulWidget {
  final _Reminder r;
  const _ReminderTile(this.r);
  @override
  State<_ReminderTile> createState() => _ReminderTileState();
}

class _ReminderTileState extends State<_ReminderTile> {
  late bool _on;
  late int _h;
  late int _m;

  @override
  void initState() {
    super.initState();
    final r = widget.r;
    _on = Prefs.getBool('notif_${r.key}', false);
    _h = Prefs.getInt('notif_${r.key}_h', r.defH);
    _m = Prefs.getInt('notif_${r.key}_m', r.defM);
  }

  Future<void> _apply() async {
    final r = widget.r;
    await Prefs.setBool('notif_${r.key}', _on);
    await Prefs.setInt('notif_${r.key}_h', _h);
    await Prefs.setInt('notif_${r.key}_m', _m);
    if (_on) {
      await NotificationService.requestPermissions();
      await NotificationService.scheduleDaily(
        r.id,
        _h,
        _m,
        AppState.I.lang == 'ar' ? r.titleAr : r.titleEn,
        AppState.I.lang == 'ar' ? r.bodyAr : r.bodyEn,
      );
    } else {
      await NotificationService.cancel(r.id);
    }
  }

  String get _timeLabel {
    final hh = _h.toString().padLeft(2, '0');
    final mm = _m.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _h, minute: _m),
    );
    if (picked != null) {
      setState(() {
        _h = picked.hour;
        _m = picked.minute;
      });
      await _apply();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(tr(r.titleAr, r.titleEn),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(tr(r.bodyAr, r.bodyEn),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              value: _on,
              activeColor: AppColors.sage600,
              onChanged: (v) async {
                setState(() => _on = v);
                await _apply();
              },
            ),
            if (_on)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 18, color: AppColors.sage700),
                    const SizedBox(width: 8),
                    Text(tr('الوقت', 'Time')),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: _pickTime,
                      child: Text(_timeLabel,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
