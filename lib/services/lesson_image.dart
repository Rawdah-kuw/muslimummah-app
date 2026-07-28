import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import 'rawdah_service.dart';

/// Renders a Rawdah lesson as a 1080×1080 shareable image (like the website),
/// then opens the native share sheet. Falls back to plain-text share on error.
class LessonImage {
  static Future<void> share(Lesson l, {required String caption}) async {
    try {
      final bytes = await _render(l);
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/rawdah-lesson.png');
      await f.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(f.path)], text: caption);
    } catch (_) {
      // If anything goes wrong drawing the image, share the text instead.
      await Share.share(caption);
    }
  }

  static Future<Uint8List> _render(Lesson l) async {
    const s = 1080.0;
    final women = RawdahService.genderOf(l) == 'نساء';
    final accent =
        women ? const Color(0xFFB58D88) : const Color(0xFF5A7A8A);
    final tint = women ? const Color(0xFFFBF1F3) : const Color(0xFFEEF4FA);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, s, s));

    // Background + inset cream card.
    canvas.drawRect(const Rect.fromLTWH(0, 0, s, s), Paint()..color = tint);
    final card = RRect.fromRectAndRadius(
        const Rect.fromLTWH(56, 56, s - 112, s - 112),
        const Radius.circular(46));
    canvas.drawRRect(card, Paint()..color = const Color(0xFFFDFBF7));
    canvas.drawRRect(
        card,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFE7DDD8));

    const cx = s / 2;
    const maxW = s - 260;

    _text(canvas, 'روضة · مجالس ودروس الذكر',
        cx: cx,
        top: 132,
        maxWidth: s - 200,
        fontSize: 32,
        color: accent,
        weight: FontWeight.w600);

    // Badges: gender + type(s).
    final badges = <_B>[_B(women ? 'للنساء' : 'للجميع', accent, Colors.white)];
    for (final t in l.types) {
      final online = t == 'اونلاين';
      badges.add(_B(
          t,
          online ? const Color(0xFFDBE7F0) : const Color(0xFFE2ECE7),
          online ? const Color(0xFF3F5F70) : const Color(0xFF3E5A4E)));
    }
    _badges(canvas, badges, cx: cx, top: 196, height: 54);

    var y = 322.0;
    y += _text(canvas, l.title,
        cx: cx,
        top: y,
        maxWidth: maxW,
        fontSize: 56,
        color: const Color(0xFF1B3B2B),
        weight: FontWeight.w700);
    y += 14;
    if (l.teacher.isNotEmpty) {
      y += _text(canvas, 'مع ${l.teacher}',
          cx: cx,
          top: y,
          maxWidth: maxW,
          fontSize: 40,
          color: const Color(0xFF4F7263),
          weight: FontWeight.w600);
      y += 10;
    }

    y += 20;
    canvas.drawLine(
        Offset(220, y),
        Offset(s - 220, y),
        Paint()
          ..color = const Color(0xFFE7DDD8)
          ..strokeWidth = 2);
    y += 30;

    final dt = l.day +
        (l.lessonDate != null
            ? ' — ${RawdahService.fmtDate(l.lessonDate)}'
            : (l.isRecurring ? ' (أسبوعي)' : ''));
    y += _text(canvas, dt,
        cx: cx,
        top: y,
        maxWidth: maxW,
        fontSize: 40,
        color: const Color(0xFF334155),
        weight: FontWeight.w500);
    y += 8;
    if (l.time.isNotEmpty) {
      y += _text(canvas, '${l.time} · بتوقيت الكويت',
          cx: cx,
          top: y,
          maxWidth: maxW,
          fontSize: 38,
          color: const Color(0xFF334155),
          weight: FontWeight.w500);
      y += 6;
    }
    final loc = [l.area, l.location].where((s) => s.isNotEmpty).join(' · ');
    if (loc.isNotEmpty) {
      _text(canvas, loc,
          cx: cx,
          top: y,
          maxWidth: maxW,
          fontSize: 36,
          color: const Color(0xFF475569),
          weight: FontWeight.w500);
    }

    // Footer.
    _text(canvas, 'شبكة أمة الإسلام',
        cx: cx,
        top: s - 176,
        maxWidth: s - 200,
        fontSize: 42,
        color: const Color(0xFF1B3B2B),
        weight: FontWeight.w700);
    _text(canvas, 'muslimummah.app',
        cx: cx,
        top: s - 120,
        maxWidth: s - 200,
        fontSize: 28,
        color: const Color(0xFF94A3B8),
        weight: FontWeight.w400);
    _text(canvas, 'صدقة جارية عن علي عبد العزيز الصدّيقي رحمه الله',
        cx: cx,
        top: s - 76,
        maxWidth: s - 150,
        fontSize: 26,
        color: const Color(0xFF94A3B8),
        weight: FontWeight.w400);

    final pic = recorder.endRecording();
    final img = await pic.toImage(s.toInt(), s.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  /// Draw centered, RTL text; returns the laid-out height.
  static double _text(Canvas c, String text,
      {required double cx,
      required double top,
      required double maxWidth,
      required double fontSize,
      required Color color,
      FontWeight weight = FontWeight.w400}) {
    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.rtl,
      fontSize: fontSize,
      fontWeight: weight,
    ))
      ..pushStyle(ui.TextStyle(color: color, fontSize: fontSize, fontWeight: weight))
      ..addText(text);
    final p = pb.build()..layout(ui.ParagraphConstraints(width: maxWidth));
    c.drawParagraph(p, Offset(cx - maxWidth / 2, top));
    return p.height;
  }

  static void _badges(Canvas c, List<_B> badges,
      {required double cx, required double top, required double height}) {
    const fs = 28.0;
    final widths = <double>[];
    for (final b in badges) {
      final p = (ui.ParagraphBuilder(ui.ParagraphStyle(
              textDirection: ui.TextDirection.rtl,
              fontSize: fs,
              fontWeight: FontWeight.w700))
            ..pushStyle(ui.TextStyle(color: b.fg, fontSize: fs, fontWeight: FontWeight.w700))
            ..addText(b.text))
          .build()
        ..layout(const ui.ParagraphConstraints(width: 600));
      widths.add(p.maxIntrinsicWidth + 46);
    }
    final total =
        widths.fold(0.0, (a, w) => a + w) + 16 * (badges.length - 1);
    var x = cx - total / 2;
    for (var i = 0; i < badges.length; i++) {
      final w = widths[i];
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, top, w, height), Radius.circular(height / 2)),
          Paint()..color = badges[i].bg);
      final p = (ui.ParagraphBuilder(ui.ParagraphStyle(
              textAlign: TextAlign.center,
              textDirection: ui.TextDirection.rtl,
              fontSize: fs,
              fontWeight: FontWeight.w700))
            ..pushStyle(ui.TextStyle(color: badges[i].fg, fontSize: fs, fontWeight: FontWeight.w700))
            ..addText(badges[i].text))
          .build()
        ..layout(ui.ParagraphConstraints(width: w));
      c.drawParagraph(p, Offset(x, top + (height - p.height) / 2));
      x += w + 16;
    }
  }
}

class _B {
  final String text;
  final Color bg;
  final Color fg;
  _B(this.text, this.bg, this.fg);
}
