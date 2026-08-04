import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../app_state.dart';
import '../models/models.dart';

/// Renders the daily Wird as a 1080×1080 shareable image (like the website's
/// WirdDownload card), then opens the native share sheet. Text falls back
/// gracefully if drawing fails.
class WirdImage {
  static const _typeAr = {'ayah': 'آية', 'hadith': 'حديث', 'dua': 'دعاء'};
  static const _typeEn = {'ayah': 'Ayah', 'hadith': 'Hadith', 'dua': 'Dua'};

  static Future<void> share(Wird w) async {
    final ar = AppState.I.lang == 'ar';
    final src = ar
        ? (w.source['ar']?.toString() ?? '')
        : (w.source['en']?.toString() ?? '');
    final caption =
        '${ar ? w.ar : w.en}\n$src\n\nأمة الإسلام\nhttps://muslimummah.app';
    try {
      final bytes = await _render(w, ar);
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/muslim-ummah-wird.png');
      await f.writeAsBytes(bytes);
      await SharePlus.instance
          .share(ShareParams(files: [XFile(f.path)], text: caption));
    } catch (_) {
      await SharePlus.instance.share(ShareParams(text: caption));
    }
  }

  static Future<Uint8List> _render(Wird w, bool ar) async {
    const s = 1080.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, s, s));

    canvas.drawRect(const Rect.fromLTWH(0, 0, s, s),
        Paint()..color = const Color(0xFFFDFBF7));
    canvas.drawRect(
        const Rect.fromLTWH(48, 48, s - 96, s - 96),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = const Color(0xFFD7E4DD));

    const cx = s / 2;

    final typeLabel = ar
        ? (_typeAr[w.type] ?? '')
        : (_typeEn[w.type] ?? '');
    final label = ar ? 'الوِرد · $typeLabel' : 'Daily Wird · $typeLabel';
    _draw(canvas, label,
        cx: cx,
        top: 152,
        maxWidth: s - 200,
        fontSize: 34,
        color: const Color(0xFF4F7263),
        weight: FontWeight.w500,
        family: 'Tajawal',
        rtl: ar);

    // Main text, auto-fit to a vertical budget.
    final text = ar ? w.ar : w.en;
    final family = ar ? 'Amiri' : null;
    const maxW = s - 220;
    var size = 64.0;
    var p = _para(text,
        fontSize: size,
        weight: FontWeight.w700,
        color: const Color(0xFF1B3B2B),
        family: family,
        rtl: ar,
        maxWidth: maxW,
        height: 1.55);
    while (p.height > 520 && size > 30) {
      size -= 4;
      p = _para(text,
          fontSize: size,
          weight: FontWeight.w700,
          color: const Color(0xFF1B3B2B),
          family: family,
          rtl: ar,
          maxWidth: maxW,
          height: 1.55);
    }
    final ty = 500 - p.height / 2;
    canvas.drawParagraph(p, Offset(cx - maxW / 2, ty));
    final y = ty + p.height + 20;

    final src = ar
        ? (w.source['ar']?.toString() ?? '')
        : (w.source['en']?.toString() ?? '');
    if (src.isNotEmpty) {
      _draw(canvas, src,
          cx: cx,
          top: y,
          maxWidth: maxW,
          fontSize: 36,
          color: const Color(0xFF4F7263),
          weight: FontWeight.w500,
          family: 'Tajawal',
          rtl: ar);
    }

    _draw(canvas, ar ? 'شبكة أمة الإسلام' : 'Muslim Ummah Network',
        cx: cx,
        top: 872,
        maxWidth: s - 140,
        fontSize: 40,
        color: const Color(0xFF1B3B2B),
        weight: FontWeight.w700,
        family: 'Tajawal',
        rtl: ar);
    _draw(
        canvas,
        ar
            ? 'صدقة جارية عن علي عبد العزيز الصدّيقي رحمه الله'
            : 'A sadaqah jariyah for Ali Abdulaziz Alseddiqi',
        cx: cx,
        top: 930,
        maxWidth: s - 120,
        fontSize: 27,
        color: const Color(0xFF94A3B8),
        weight: FontWeight.w400,
        family: 'Tajawal',
        rtl: ar);
    _draw(canvas, 'muslimummah.app',
        cx: cx,
        top: 974,
        maxWidth: s - 160,
        fontSize: 27,
        color: const Color(0xFF94A3B8),
        weight: FontWeight.w400,
        family: 'Tajawal',
        rtl: ar);

    final pic = recorder.endRecording();
    final img = await pic.toImage(s.toInt(), s.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  static ui.Paragraph _para(String text,
      {required double fontSize,
      required FontWeight weight,
      required Color color,
      String? family,
      required bool rtl,
      required double maxWidth,
      double height = 1.3}) {
    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      textDirection: rtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      fontSize: fontSize,
      fontWeight: weight,
      fontFamily: family,
      height: height,
    ))
      ..pushStyle(ui.TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          fontFamily: family,
          height: height))
      ..addText(text);
    return pb.build()..layout(ui.ParagraphConstraints(width: maxWidth));
  }

  static double _draw(Canvas c, String text,
      {required double cx,
      required double top,
      required double maxWidth,
      required double fontSize,
      required Color color,
      FontWeight weight = FontWeight.w400,
      String? family,
      required bool rtl}) {
    final p = _para(text,
        fontSize: fontSize,
        weight: weight,
        color: color,
        family: family,
        rtl: rtl,
        maxWidth: maxWidth);
    c.drawParagraph(p, Offset(cx - maxWidth / 2, top));
    return p.height;
  }
}
