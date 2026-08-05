import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import 'rawdah_service.dart';

/// Renders a day's Rawdah schedule as one or more reasonably-sized shareable
/// images (paginated), like the website — so a busy day never becomes a single
/// over-tall image that gets cut off.
class ScheduleImage {
  static const _perPage = 6; // lessons per image

  static Future<void> share(String day, List<Lesson> lessons) async {
    final caption =
        'جدول دروس $day — روضة · أمة الإسلام\nجميع الأوقات بتوقيت الكويت (GMT+3)\nhttps://muslimummah.app';
    const origin = Rect.fromLTWH(0, 0, 100, 100);
    try {
      if (lessons.isEmpty) {
        await Share.share(caption, sharePositionOrigin: origin);
        return;
      }
      // Split into pages of a comfortable size.
      final pages = <List<Lesson>>[];
      for (var i = 0; i < lessons.length; i += _perPage) {
        final end =
            (i + _perPage < lessons.length) ? i + _perPage : lessons.length;
        pages.add(lessons.sublist(i, end));
      }
      final dir = await getTemporaryDirectory();
      final files = <XFile>[];
      for (var p = 0; p < pages.length; p++) {
        final bytes = await _render(day, pages[p], p + 1, pages.length);
        final f = File('${dir.path}/rawdah-schedule-${p + 1}.png');
        await f.writeAsBytes(bytes);
        files.add(XFile(f.path));
      }
      await Share.shareXFiles(files,
          text: caption, sharePositionOrigin: origin);
    } catch (_) {
      await Share.share(caption, sharePositionOrigin: origin);
    }
  }

  static Future<Uint8List> _render(
      String day, List<Lesson> lessons, int page, int totalPages) async {
    const w = 1080.0;
    const headerH = 190.0;
    const rowH = 200.0;
    const footerH = 130.0;
    final h = headerH + lessons.length * rowH + footerH;

    final rec = ui.PictureRecorder();
    final c = Canvas(rec, Rect.fromLTWH(0, 0, w, h));

    c.drawRect(Rect.fromLTWH(0, 0, w, h),
        Paint()..color = const Color(0xFFFDFBF7));
    c.drawRect(const Rect.fromLTWH(0, 0, w, headerH),
        Paint()..color = const Color(0xFF1B3B2B));
    _center(c, 'روضة · مجالس ودروس الذكر',
        cx: w / 2,
        top: 42,
        maxWidth: w - 120,
        fontSize: 28,
        color: const Color(0xFFA8C3B4),
        weight: FontWeight.w500);
    _center(c, totalPages > 1 ? '$day · $page/$totalPages' : day,
        cx: w / 2,
        top: 90,
        maxWidth: w - 120,
        fontSize: 54,
        color: const Color(0xFFFDFBF7),
        weight: FontWeight.w800);

    var y = headerH;
    for (final l in lessons) {
      _row(c, l, top: y, width: w, height: rowH);
      y += rowH;
    }

    _center(c, 'جميع الأوقات بتوقيت الكويت (GMT+3)',
        cx: w / 2,
        top: h - footerH + 28,
        maxWidth: w - 120,
        fontSize: 24,
        color: const Color(0xFF94A3B8),
        weight: FontWeight.w400);
    _center(c, 'شبكة أمة الإسلام · muslimummah.app',
        cx: w / 2,
        top: h - footerH + 66,
        maxWidth: w - 120,
        fontSize: 30,
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
    const pad = 34.0;
    final cardH = height - 10;
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(pad, top + 5, width - 2 * pad, cardH),
            const Radius.circular(20)),
        Paint()..color = tint);
    // Accent bar on the right edge encodes the audience (rose = women).
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(width - pad - 10, top + 14, 7, cardH - 18),
            const Radius.circular(4)),
        Paint()..color = accent);

    final rightX = width - pad - 28;
    final maxW = width - 2 * pad - 56;
    final fT = (height * 0.28).clamp(26.0, 38.0).toDouble();
    final fS = (height * 0.20).clamp(20.0, 28.0).toDouble();
    final fI = (height * 0.17).clamp(17.0, 24.0).toDouble();

    _rtl(c, l.title,
        rightX: rightX,
        top: top + height * 0.12,
        maxWidth: maxW,
        fontSize: fT,
        color: const Color(0xFF1B3B2B),
        weight: FontWeight.w800);
    if (l.teacher.isNotEmpty) {
      _rtl(c, l.teacher,
          rightX: rightX,
          top: top + height * 0.44,
          maxWidth: maxW,
          fontSize: fS,
          color: const Color(0xFF4F7263),
          weight: FontWeight.w600);
    }
    final info =
        [l.time, l.area, l.location].where((s) => s.isNotEmpty).join('  ·  ');
    if (info.isNotEmpty) {
      _rtl(c, info,
          rightX: rightX,
          top: top + height * 0.70,
          maxWidth: maxW,
          fontSize: fI,
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
