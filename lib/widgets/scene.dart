import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// A gradient "scene" palette for a card. [dark] = dark background (light text).
class CardScene {
  final List<Color> colors;
  final bool dark;
  const CardScene(this.colors, this.dark);

  Color get onColor => dark ? AppColors.pearl50 : AppColors.pine900;
  Color get subColor => dark
      ? AppColors.pearl50.withValues(alpha: 0.82)
      : AppColors.pine800.withValues(alpha: 0.7);
  Color get ringColor => dark
      ? AppColors.pearl50.withValues(alpha: 0.11)
      : AppColors.pine800.withValues(alpha: 0.07);
}

/// Curated on-brand gradients (pine/pearl/sage family with warm/cool accents).
class Scenes {
  static const pine = CardScene([Color(0xFF1B3B2B), Color(0xFF2E5442)], true);
  static const sage = CardScene([Color(0xFF4F7263), Color(0xFF77A08D)], true);
  // Maghrib sunset — warm amber into dusky plum.
  static const dusk = CardScene([Color(0xFFCB6E45), Color(0xFF5A3A58)], true);
  static const night = CardScene([Color(0xFF223452), Color(0xFF14251E)], true);
  // Fajr dawn — soft first-light blue into warm peach.
  static const dawn = CardScene([Color(0xFFAFC6E6), Color(0xFFF3E0C7)], false);
  static const sky = CardScene([Color(0xFFBFD8EC), Color(0xFFEDF3F0)], false);
  static const pearl = CardScene([Color(0xFFF7F4ED), Color(0xFFE7E4D8)], false);
}

/// Paints the brand mark as a soft watermark: an open ring with a glossy pearl.
class _PearlPainter extends CustomPainter {
  final CardScene scene;
  _PearlPainter(this.scene);

  @override
  void paint(Canvas canvas, Size size) {
    final dark = scene.dark;
    // Anchored to the far-left edge so it never sits under the text (RTL text
    // is right-aligned). Small and soft.
    final r = math.min(size.height * 0.34, size.width * 0.16);
    final center = Offset(r * 0.85, size.height * 0.5);

    // Open ring ("C" of the logo); its left side clips off the edge.
    final arcPaint = Paint()
      ..color = scene.ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.16
      ..strokeCap = StrokeCap.round;
    const gapHalf = 0.55;
    canvas.drawArc(Rect.fromCircle(center: center, radius: r), gapHalf,
        (2 * math.pi) - (2 * gapHalf), false, arcPaint);

    // Glossy pearl at the centre (smaller, softer).
    final pr = r * 0.5;
    final orbRect = Rect.fromCircle(center: center, radius: pr);
    final centre = Colors.white.withValues(alpha: dark ? 0.40 : 0.60);
    final mid = dark
        ? AppColors.pearl50.withValues(alpha: 0.12)
        : AppColors.sage500.withValues(alpha: 0.15);
    final edge =
        (dark ? AppColors.pearl50 : AppColors.pine800).withValues(alpha: 0.0);
    final orbShader = RadialGradient(
      center: const Alignment(-0.4, -0.4),
      radius: 0.95,
      colors: [centre, mid, edge],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(orbRect);
    canvas.drawCircle(center, pr, Paint()..shader = orbShader);
  }

  @override
  bool shouldRepaint(covariant _PearlPainter old) => old.scene != scene;
}

/// The pearl motif as a fill-able backdrop (use inside a Stack / Positioned.fill).
class PearlBackdrop extends StatelessWidget {
  final CardScene scene;
  const PearlBackdrop(this.scene, {super.key});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _PearlPainter(scene), size: Size.infinite);
}

/// A compact, tappable gradient card for a main section (text + pearl motif).
class SceneCard extends StatelessWidget {
  final CardScene scene;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double height;
  const SceneCard({
    super.key,
    required this.scene,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: scene.colors,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: scene.colors.last.withValues(alpha: 0.24),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _PearlPainter(scene))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: scene.onColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: scene.subColor, fontSize: 12.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A smaller square tool tile — pearl motif + label, no icon.
class ToolTile extends StatelessWidget {
  final CardScene scene;
  final String title;
  final VoidCallback onTap;
  const ToolTile({
    super.key,
    required this.scene,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: scene.colors,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _PearlPainter(scene))),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Text(title,
                    style: TextStyle(
                        color: scene.onColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
