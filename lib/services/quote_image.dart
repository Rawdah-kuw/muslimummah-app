import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../app_state.dart';
import '../models/models.dart';

/// Renders "Quote of the Day" as a 1080×1080 shareable card on the app's
/// dark-green logo background (#16302A), then opens the native share sheet.
class QuoteImage {
  static const _bg = Color(0xFF16302A);
  static const _pearl = Color(0xFFF2ECDD);
  static const _sage = Color(0xFF7FA090);
  static const _gold = Color(0xFFC8A86B);

  static Future<void> share(Quote q) async {
    final ar = AppState.I.lang == 'ar';
    final book =
        ar ? (q.source['ar']?.toString() ?? '') : (q.source['en']?.toString() ?? '');
    final author = ar
        ? (q.source['authorAr']?.toString() ?? '')
        : (q.source['authorEn']?.toString() ?? '');
    // Cited scholar-saying → speaker first, then "Quoted from the book …".
    final attribution = q.source['cited'] == true
        ? [
            if (author.isNotEmpty) author,
            if (book.isNotEmpty)
              (ar ? 'مقتبَس من كتاب «$book»' : 'Quoted from “$book”'),
          ]
        : [
            if (book.isNotEmpty) book,
            if (author.isNotEmpty) author,
          ];
    final caption = [
      if (q.ar.isNotEmpty) q.ar,
      if (q.en.isNotEmpty) q.en,
      ...attribution,
      '',
      ar ? 'أمة الإسلام' : 'Muslim Ummah',
      'https://muslimummah.app',
    ].join('\n');
    try {
      final bytes = await _render(q);
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/muslim-ummah-quote.png');
      await f.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(f.path)],
          text: caption, sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100));
    } catch (_) {
      await Share.share(caption,
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100));
    }
  }

  static Future<Uint8List> _render(Quote q) async {
    const s = 1080.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, s, s));

    // Dark-green logo background + thin frame.
    canvas.drawRect(const Rect.fromLTWH(0, 0, s, s), Paint()..color = _bg);
    canvas.drawRect(
        const Rect.fromLTWH(48, 48, s - 96, s - 96),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = _sage.withValues(alpha: 0.5));

    const cx = s / 2;
    const maxW = s - 220;

    // Opening quotation mark.
    _draw(canvas, '❝',
        cx: cx, top: 150, maxWidth: maxW, fontSize: 120,
        color: _sage.withValues(alpha: 0.55), rtl: false);

    // Arabic — auto-fit.
    var arSize = 58.0;
    var arPara = _para(q.ar,
        fontSize: arSize, weight: FontWeight.w700, color: _pearl,
        family: 'Amiri', rtl: true, maxWidth: maxW, height: 1.75);
    while (arPara.height > 360 && arSize > 26) {
      arSize -= 4;
      arPara = _para(q.ar,
          fontSize: arSize, weight: FontWeight.w700, color: _pearl,
          family: 'Amiri', rtl: true, maxWidth: maxW, height: 1.75);
    }

    // English — a touch larger for readability.
    var enSize = 39.0;
    var enPara = _para(q.en,
        fontSize: enSize, weight: FontWeight.w500,
        color: _pearl.withValues(alpha: 0.88), family: null, rtl: false,
        maxWidth: maxW, height: 1.45);
    while (enPara.height > 250 && enSize > 24) {
      enSize -= 3;
      enPara = _para(q.en,
          fontSize: enSize, weight: FontWeight.w500,
          color: _pearl.withValues(alpha: 0.88), family: null, rtl: false,
          maxWidth: maxW, height: 1.45);
    }

    final hasAr = q.ar.isNotEmpty, hasEn = q.en.isNotEmpty;
    const gap = 34.0;
    var blockH = 0.0;
    if (hasAr) blockH += arPara.height;
    if (hasAr && hasEn) blockH += gap + 2 + gap;
    if (hasEn) blockH += enPara.height;
    var y = ((300 + 800) / 2) - blockH / 2;
    if (hasAr) {
      canvas.drawParagraph(arPara, Offset(cx - maxW / 2, y));
      y += arPara.height;
    }
    if (hasAr && hasEn) {
      y += gap;
      canvas.drawLine(Offset(cx - 80, y), Offset(cx + 80, y),
          Paint()
            ..color = _sage.withValues(alpha: 0.5)
            ..strokeWidth = 2);
      y += gap + 2;
    }
    if (hasEn) {
      canvas.drawParagraph(enPara, Offset(cx - maxW / 2, y));
      y += enPara.height;
    }
    y += 26;

    final ar = AppState.I.lang == 'ar';
    final book =
        ar ? (q.source['ar']?.toString() ?? '') : (q.source['en']?.toString() ?? '');
    final author = ar
        ? (q.source['authorAr']?.toString() ?? '')
        : (q.source['authorEn']?.toString() ?? '');
    if (q.source['cited'] == true) {
      // Scholar saying: speaker first (gold), then "Quoted from the book …".
      if (author.isNotEmpty) {
        final h = _draw(canvas, author,
            cx: cx, top: y, maxWidth: maxW, fontSize: 30,
            color: _gold, weight: FontWeight.w700, family: 'Tajawal', rtl: ar);
        y += h + 6;
      }
      if (book.isNotEmpty) {
        _draw(canvas, ar ? 'مقتبَس من كتاب «$book»' : 'Quoted from “$book”',
            cx: cx, top: y, maxWidth: maxW, fontSize: 24,
            color: _sage, weight: FontWeight.w500, family: 'Tajawal', rtl: ar);
      }
    } else {
      if (book.isNotEmpty) {
        // Lighter sage so the book title reads clearly on the dark green.
        final h = _draw(canvas, book,
            cx: cx, top: y, maxWidth: maxW, fontSize: 30,
            color: const Color(0xFFA8C3B4), weight: FontWeight.w600,
            family: 'Tajawal', rtl: ar);
        y += h + 6;
      }
      if (author.isNotEmpty) {
        // The author's name in gold — matching the in-app quote card.
        _draw(canvas, author,
            cx: cx, top: y, maxWidth: maxW, fontSize: 27,
            color: _gold, weight: FontWeight.w700, family: 'Tajawal', rtl: ar);
      }
    }

    _draw(canvas, ar ? 'أمة الإسلام' : 'Muslim Ummah',
        cx: cx, top: 900, maxWidth: s - 140, fontSize: 38,
        color: _pearl, weight: FontWeight.w700, family: 'Tajawal', rtl: ar);
    _draw(canvas, 'muslimummah.app',
        cx: cx, top: 958, maxWidth: s - 160, fontSize: 26,
        color: _sage.withValues(alpha: 0.9), family: 'Tajawal', rtl: false);

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
