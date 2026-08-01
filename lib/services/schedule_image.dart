import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import 'rawdah_service.dart';

/// Renders a full day's Rawdah schedule (all its lessons) into one tall
/// shareable image, like the website's schedule card.
class ScheduleImage {
  static Future<void> share(String day, List<Lesson> lessons) async {
    final caption =
        'جدول دروس $day — روضة · أمة الإسلام\nجميع الأوقات بتوقيت الكويت (GMT+3)\nhttps://muslimummah.app';
    try {
      if (lessons.isEmpty) {
        await Share.share(caption);
        return;
      }
      final bytes = await _render(day, lessons);
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/rawdah-schedule.png');
      await f.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(f.path)], text: caption);
    } catch (_) {
      await Share.share(caption);
    }
  }

  static Future<Uint8List> _render(String day, List<Lesson> lessons) async {
    const w = 1080.0;
    const headerH = 210.0;
    const rowH = 210.0;
    const footerH = 150.0;
    final h = headerH + lessons.length * rowH + footerH;

    final rec = ui.PictureRecorder();
    final c = Canvas(rec, Rect.fromLTWH(0, 0, w, h));

    c.drawRect(Rect.fromLTWH(0, 0, w, h),
        Paint()..color = const Color(0xFFFDFBF7));
    // Header band
    c.drawRect(const Rect.fromLTWH(0, 0, w, headerH),
        Paint()..color = const Color(0xFF1B3B2B));
    _center(c, 'روضة · مجالس ودروس الذكر',
        cx: w / 2,
        top: 46,
        maxWidth: w - 120,
        fontSize: 30,
        color: const Color(0xFFA8C3B4),
        weight: FontWeight.w500);
    _center(c, day,
        cx: w / 2,
        top: 96,
        maxWidth: w - 120,
        fontSize: 58,
        color: const Color(0xFFFDFBF7),
        weight: FontWeight.w800);

    var y = headerH + 18.0;
    for (final l in lessons) {
      _row(c, l, top: y, width: w, height: rowH - 18);
      y += rowH;
    }

    _center(c, 'جميع الأوقات بتوقيت الكويت (GMT+3)',
        cx: w / 2,
        top: h - footerH + 24,
        maxWidth: w - 120,
        fontSize: 26,
        color: const Color(0xFF94A3B8),
        weight: FontWeight.w400);
    _center(c, 'شبكة أمة الإسلام · muslimummah.app',
        cx: w / 2,
        top: h - footerH + 68,
        maxWidth: w - 120,
        fontSize: 32,
        color: const Color(0xFF1B3B2B),
        weight: FontWeight.w700);

    final img = await rec.endRecording().toImage(w.toInt(), h.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  static void _row(Canvas c, Lesson l,
      {required double top, required double width, required double height}) {
    final women = RawdahService.genderOf(l) == 'نساء';
    final accent = women ? const Color(0xFFB58D88) : const Color(0xFF5A7A8A);
    final tint = women ? const Color(0xFFFBF1F3) : const Color(0xFFEEF4FA);
    const pad = 40.0;
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(pad, top, width - 2 * pad, height),
            const Radius.circular(24)),
        Paint()..color = tint);
    // Accent bar on the right edge (RTL layout).
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(width - pad - 12, top + 16, 8, height - 32),
            const Radius.circular(4)),
        Paint()..color = accent);

    final rightX = width - pad - 28;
    final maxW = width - 2 * pad - 70;
    _badge(c, women ? 'للنساء' : 'للجميع',
        right: rightX, top: top + 22, bg: accent);
    _rtl(c, l.title,
        rightX: rightX,
        top: top + 72,
        maxWidth: maxW,
        fontSize: 38,
        color: const Color(0xFF1B3B2B),
        weight: FontWeight.w800);
    if (l.teacher.isNotEmpty) {
      _rtl(c, l.teacher,
          rightX: rightX,
          top: top + 118,
          maxWidth: maxW,
          fontSize: 30,
          color: const Color(0xFF4F7263),
          weight: FontWeight.w600);
    }
    final info =
        [l.time, l.area, l.location].where((s) => s.isNotEmpty).join('  ·  ');
    if (info.isNotEmpty) {
      _rtl(c, info,
          rightX: rightX,
          top: top + 156,
          maxWidth: maxW,
          fontSize: 26,
          color: const Color(0xFF475569),
          weight: FontWeight.w400);
    }
  }

  static void _center(Canvas c, String text,
      {required double cx,
      required double top,
      required double maxWidth,
      required double fontSize,
      required Color color,
      FontWeight weight = FontWeight.w400}) {
    final p = _para(text,
        align: TextAlign.center,
        fontSize: fontSize,
        color: color,
        weight: weight,
        maxWidth: maxWidth);
    c.drawParagraph(p, Offset(cx - maxWidth / 2, top));
  }

  static void _rtl(Canvas c, String text,
      {required double rightX,
      required double top,
      required double maxWidth,
      required double fontSize,
      required Color color,
      FontWeight weight = FontWeight.w400}) {
    final p = _para(text,
        align: TextAlign.right,
        fontSize: fontSize,
        color: color,
        weight: weight,
        maxWidth: maxWidth);
    c.drawParagraph(p, Offset(rightX - maxWidth, top));
  }

  static void _badge(Canvas c, String text,
      {required double right, required double top, required Color bg}) {
    const fs = 24.0;
    final measure = _para(text,
        align: TextAlign.center,
        fontSize: fs,
        color: Colors.white,
        weight: FontWeight.w700,
        maxWidth: 400);
    final pillW = measure.maxIntrinsicWidth + 36;
    const pillH = 42.0;
    final x = right - pillW;
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, top, pillW, pillH), const Radius.circular(21)),
        Paint()..color = bg);
    final p = _para(text,
        align: TextAlign.center,
        fontSize: fs,
        color: Colors.white,
        weight: FontWeight.w700,
        maxWidth: pillW);
    c.drawParagraph(p, Offset(x, top + (pillH - p.height) / 2));
  }

  static ui.Paragraph _para(String text,
      {required TextAlign align,
      required double fontSize,
      required Color color,
      required FontWeight weight,
      required double maxWidth}) {
    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: align,
      textDirection: ui.TextDirection.rtl,
      fontSize: fontSize,
      fontWeight: weight,
      maxLines: 1,
      ellipsis: '…',
    ))
      ..pushStyle(
          ui.TextStyle(color: color, fontSize: fontSize, fontWeight: weight))
      ..addText(text);
    return pb.build()..layout(ui.ParagraphConstraints(width: maxWidth));
  }
}
