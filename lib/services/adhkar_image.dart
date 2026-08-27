import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../app_state.dart';
import '../models/models.dart';

/// Renders a single dhikr as a 1080×1080 shareable card (cream background,
/// matching the wird card), then opens the native share sheet. In English mode
/// the English translation is shown beneath the Arabic.
class AdhkarImage {
  static const _bg = Color(0xFFFDFBF7);
  static const _pine = Color(0xFF1B3B2B);
  static const _sage = Color(0xFF4F7263);
  static const _muted = Color(0xFF94A3B8);

  static Future<void> share(Dhikr d) async {
    final ar = AppState.I.lang == 'ar';
    final src = ar ? d.source : (d.sourceEn.isNotEmpty ? d.sourceEn : d.source);
    final note = ar ? d.note : (d.noteEn.isNotEmpty ? d.noteEn : d.note);
    final caption = [
      if (d.prefix.isNotEmpty) d.prefix,
      if (!ar && d.prefixEn.isNotEmpty) d.prefixEn,
      d.ar,
      if (!ar && d.en.isNotEmpty) d.en,
      if (src.isNotEmpty) src,
      if (note.isNotEmpty) note,
      '',
      ar ? 'أمة الإسلام' : 'Muslim Ummah',
      'https://muslimummah.app',
    ].join('\n');
    try {
      final bytes = await _render(d, ar);
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/muslim-ummah-dhikr.png');
      await f.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(f.path)],
          text: caption,
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100));
    } catch (_) {
      await Share.share(caption,
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100));
    }
  }

  static Future<Uint8List> _render(Dhikr d, bool ar) async {
    const s = 1080.0;
    final rec = ui.PictureRecorder();
    final c = Canvas(rec, const Rect.fromLTWH(0, 0, s, s));
    c.drawRect(const Rect.fromLTWH(0, 0, s, s), Paint()..color = _bg);
    // Frame inset well away from the edges (Instagram feed crop-safe).
    c.drawRect(
        const Rect.fromLTWH(118, 118, s - 236, s - 236),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = const Color(0xFFD7E4DD));

    const cx = s / 2;
    const maxW = s - 340;
    final prefix = ar ? d.prefix : (d.prefixEn.isNotEmpty ? d.prefixEn : '');
    final en = (!ar && d.en.isNotEmpty) ? d.en : '';
    final src = ar ? d.source : (d.sourceEn.isNotEmpty ? d.sourceEn : d.source);
    final note = ar ? d.note : (d.noteEn.isNotEmpty ? d.noteEn : d.note);

    // Header label.
    _draw(c, ar ? 'من الأذكار 🌿' : 'Daily Adhkar 🌿',
        cx: cx, top: 150, maxWidth: maxW, fontSize: 32,
        color: _sage, weight: FontWeight.w500, family: 'Tajawal', rtl: ar);

    // Build the paragraphs (prefix, Arabic, English) and auto-fit to a budget.
    double arSize = 52, enSize = 30, preSize = 30;
    ui.Paragraph? prePara;
    late ui.Paragraph arPara;
    ui.Paragraph? enPara;
    for (var pass = 0; pass < 14; pass++) {
      prePara = prefix.isEmpty
          ? null
          : _para(prefix,
              fontSize: preSize, weight: FontWeight.w600, color: _sage,
              family: 'Amiri', rtl: true, maxWidth: maxW, height: 1.6);
      arPara = _para(d.ar,
          fontSize: arSize, weight: FontWeight.w700, color: _pine,
          family: 'Amiri', rtl: true, maxWidth: maxW, height: 1.75);
      enPara = en.isEmpty
          ? null
          : _para(en,
              fontSize: enSize, weight: FontWeight.w500,
              color: const Color(0xFF44603F), family: null, rtl: false,
              maxWidth: maxW, height: 1.4);
      final total = (prePara?.height ?? 0) +
          arPara.height +
          (enPara != null ? enPara.height + 24 : 0);
      if (total <= 560) break;
      arSize -= 3;
      enSize -= 2;
      preSize -= 2;
    }

    final blockH = (prePara != null ? prePara.height + 14 : 0) +
        arPara.height +
        (enPara != null ? 26 + enPara.height : 0);
    var y = ((250 + 820) / 2) - blockH / 2;
    if (prePara != null) {
      c.drawParagraph(prePara, Offset(cx - maxW / 2, y));
      y += prePara.height + 14;
    }
    c.drawParagraph(arPara, Offset(cx - maxW / 2, y));
    y += arPara.height;
    if (enPara != null) {
      y += 26;
      c.drawParagraph(enPara, Offset(cx - maxW / 2, y));
      y += enPara.height;
    }
    y += 24;

    if (src.isNotEmpty) {
      final h = _draw(c, src,
          cx: cx, top: y, maxWidth: maxW, fontSize: 28,
          color: _sage, weight: FontWeight.w600, family: 'Tajawal', rtl: ar);
      y += h + 6;
    }
    if (note.isNotEmpty) {
      _draw(c, note,
          cx: cx, top: y, maxWidth: maxW, fontSize: 24,
          color: _muted, weight: FontWeight.w400, family: 'Tajawal', rtl: ar);
    }

    _draw(c, ar ? 'شبكة أمة الإسلام' : 'Muslim Ummah Network',
        cx: cx, top: 892, maxWidth: s - 240, fontSize: 38,
        color: _pine, weight: FontWeight.w700, family: 'Tajawal', rtl: ar);
    _draw(c, 'muslimummah.app',
        cx: cx, top: 950, maxWidth: s - 240, fontSize: 26,
        color: _muted, weight: FontWeight.w400, family: 'Tajawal', rtl: false);

    final img = await rec.endRecording().toImage(s.toInt(), s.toInt());
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
        fontSize: fontSize, weight: weight, color: color, family: family,
        rtl: rtl, maxWidth: maxWidth);
    c.drawParagraph(p, Offset(cx - maxWidth / 2, top));
    return p.height;
  }
}
