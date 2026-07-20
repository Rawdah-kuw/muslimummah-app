import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Qibla — TEMPORARILY a gentle "coming soon" screen.
///
/// The live compass will return in a coming update using a modern sensor setup.
class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('اتجاه القبلة', 'Qibla'))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PearlMark(size: 56),
              const SizedBox(height: 20),
              Text(
                tr('اتجاه القبلة', 'Qibla direction'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                tr('بوصلة القبلة قادمة قريبًا بإذن الله في تحديث مقبل.',
                    'The Qibla compass is coming soon, God willing, in an upcoming update.'),
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
