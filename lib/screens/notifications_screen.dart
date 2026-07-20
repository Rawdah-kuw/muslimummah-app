import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// "ذكّرني" — TEMPORARILY a gentle "coming soon" screen.
///
/// Daily reminders (wird, morning/evening adhkar, Rawdah) will return in a
/// coming update using a modern scheduling setup.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('ذكّرني', 'Remind me'))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PearlMark(size: 56),
              const SizedBox(height: 20),
              Text(
                tr('التذكيرات اليومية', 'Daily reminders'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                tr('تذكيرات الورد وأذكار الصباح والمساء والدروس قادمة قريبًا بإذن الله في تحديث مقبل.',
                    'Reminders for the daily wird, morning and evening adhkar, and lessons are coming soon, God willing, in an upcoming update.'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.5,
                    height: 1.7,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
