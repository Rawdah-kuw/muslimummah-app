import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../app_state.dart';
import '../theme.dart';

/// Qibla compass — location gives the exact bearing to the Kaaba (from true
/// north), and a tilt-compensated magnetometer heading rotates the dial.
/// Uses only modern, jcenter-free plugins.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});
  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  static const _kaabaLat = 21.4225;
  static const _kaabaLon = 39.8262;

  double? _qibla; // bearing to Kaaba from true north
  double _heading = 0; // device heading from magnetic north
  String _status = 'loading'; // loading | denied | error | ready

  List<double>? _accel;
  StreamSubscription<AccelerometerEvent>? _accSub;
  StreamSubscription<MagnetometerEvent>? _magSub;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _startSensors();
  }

  @override
  void dispose() {
    _accSub?.cancel();
    _magSub?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() => _status = 'loading');
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) setState(() => _status = 'denied');
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _status = 'denied');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      final b = _bearing(pos.latitude, pos.longitude, _kaabaLat, _kaabaLon);
      if (mounted) {
        setState(() {
          _qibla = b;
          _status = 'ready';
        });
      }
    } catch (_) {
      if (mounted) setState(() => _status = 'error');
    }
  }

  void _startSensors() {
    _accSub = accelerometerEventStream().listen((e) {
      _accel = [e.x, e.y, e.z];
    });
    _magSub = magnetometerEventStream().listen((e) {
      final a = _accel;
      if (a == null) return;
      final az = _azimuth(a[0], a[1], a[2], e.x, e.y, e.z);
      if (az != null && mounted) setState(() => _heading = az);
    });
  }

  /// Great-circle initial bearing from (lat1,lon1) to (lat2,lon2), degrees.
  double _bearing(double lat1, double lon1, double lat2, double lon2) {
    final p1 = lat1 * math.pi / 180;
    final p2 = lat2 * math.pi / 180;
    final dl = (lon2 - lon1) * math.pi / 180;
    final y = math.sin(dl) * math.cos(p2);
    final x =
        math.cos(p1) * math.sin(p2) - math.sin(p1) * math.cos(p2) * math.cos(dl);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  /// Tilt-compensated azimuth (device heading from magnetic north), degrees.
  double? _azimuth(double ax, double ay, double az, double mx, double my,
      double mz) {
    // H = m x a
    final hx = my * az - mz * ay;
    final hy = mz * ax - mx * az;
    final hz = mx * ay - my * ax;
    final normH = math.sqrt(hx * hx + hy * hy + hz * hz);
    if (normH < 0.1) return null;
    final invH = 1 / normH;
    final nhx = hx * invH, nhy = hy * invH, nhz = hz * invH;
    final normA = math.sqrt(ax * ax + ay * ay + az * az);
    if (normA < 0.1) return null;
    final iax = ax / normA, iaz = az / normA;
    final my2 = iaz * nhx - iax * nhz; // rotation-matrix element R[4]
    final deg = math.atan2(nhy, my2) * 180 / math.pi;
    return (deg + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('اتجاه القبلة', 'Qibla'))),
      body: switch (_status) {
        'loading' => const Center(child: CircularProgressIndicator()),
        'denied' => _message(
            context,
            Icons.location_off_outlined,
            tr('نحتاج إذن الموقع لتحديد اتجاه القبلة. فعّل الموقع للتطبيق ثم أعِد المحاولة.',
                'We need location access to find the Qibla. Enable location for the app, then retry.'),
          ),
        'error' => _message(
            context,
            Icons.error_outline,
            tr('تعذّر تحديد موقعك. تأكّد من تفعيل الموقع وحاول مرة أخرى.',
                'Could not determine your location. Make sure location is on and try again.'),
          ),
        _ => _compass(context),
      },
    );
  }

  Widget _message(BuildContext context, IconData icon, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.sage600),
            const SizedBox(height: 14),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _initLocation,
              child: Text(tr('إعادة المحاولة', 'Retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compass(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final qibla = _qibla ?? 0;
    final needle = (qibla - _heading) * math.pi / 180;
    final north = (-_heading) * math.pi / 180;
    return Column(
      children: [
        const SizedBox(height: 20),
        Text('${tr('اتجاه القبلة', 'Qibla direction')}: ${qibla.toStringAsFixed(0)}° ${tr('عن الشمال', 'from north')}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(
          tr('امسك الجهاز أفقيًا ووجّه أعلاه نحو السهم الأخضر.',
              'Hold the device flat and point its top toward the green arrow.'),
          textAlign: TextAlign.center,
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
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dark ? const Color(0xFF1B2820) : AppColors.pearl100,
                    border: Border.all(color: AppColors.sage300, width: 2),
                  ),
                ),
                // North marker
                Transform.rotate(
                  angle: north,
                  child: const Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: Text('N',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.pine800)),
                    ),
                  ),
                ),
                // Qibla needle
                Transform.rotate(
                  angle: needle,
                  child: const Icon(Icons.navigation,
                      size: 130, color: AppColors.sage600),
                ),
                const Icon(Icons.mosque, size: 22, color: AppColors.pine800),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
          child: Text(
            tr('بوصلة مغناطيسية — قد تتأثّر بالمعادن. للمعايرة حرّك الجهاز على شكل رقم ٨.',
                'Magnetic compass — may be affected by metal. To calibrate, move the device in a figure-8.'),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11.5,
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
