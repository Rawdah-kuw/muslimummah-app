import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import '../app_state.dart';
import '../theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});
  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  @override
  void initState() {
    super.initState();
    FlutterQiblah.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('اتجاه القبلة', 'Qibla'))),
      body: StreamBuilder<QiblahDirection>(
        stream: FlutterQiblah.qiblahStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _needPermission(context);
          }
          final q = snapshot.data!;
          return _compass(context, q);
        },
      ),
    );
  }

  Widget _needPermission(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_outlined,
                size: 48, color: AppColors.sage600),
            const SizedBox(height: 14),
            Text(
              tr('نحتاج إذن الموقع والبوصلة لتحديد اتجاه القبلة. فعّلي الموقع للتطبيق ثم أعيدي المحاولة.',
                  'We need location and compass access to find the Qibla. Enable location for the app, then retry.'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await FlutterQiblah.requestPermissions();
                if (mounted) setState(() {});
              },
              child: Text(tr('السماح وإعادة المحاولة', 'Allow & retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compass(BuildContext context, QiblahDirection q) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          '${tr('اتجاه القبلة', 'Qibla direction')}: ${q.qiblah.toStringAsFixed(0)}°',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          tr('وجّهي أعلى الجهاز نحو السهم الأخضر', 'Point the top of your device toward the green arrow'),
          style: TextStyle(
              fontSize: 12.5,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6)),
        ),
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Dial rotates with the compass heading.
                Transform.rotate(
                  angle: (q.direction * (math.pi / 180) * -1),
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dark
                          ? const Color(0xFF1B2820)
                          : AppColors.pearl100,
                      border:
                          Border.all(color: AppColors.sage300, width: 2),
                    ),
                    child: const Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text('N',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.pine800)),
                      ),
                    ),
                  ),
                ),
                // Needle points to the Qibla.
                Transform.rotate(
                  angle: (q.qiblah * (math.pi / 180) * -1),
                  child: const Icon(Icons.navigation,
                      size: 120, color: AppColors.sage600),
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Icon(Icons.mosque, color: AppColors.sage700),
        ),
      ],
    );
  }
}
