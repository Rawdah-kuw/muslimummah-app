import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// In-app PDF reader using a native renderer. The book is downloaded once and
/// cached locally, so it opens fast and works offline afterwards. Bilingual
/// books get an in-reader Arabic/English toggle.
class ReaderScreen extends StatefulWidget {
  final String url; // primary (Arabic) edition
  final String? enUrl; // optional English edition
  final String title;
  const ReaderScreen(
      {super.key, required this.url, this.enUrl, required this.title});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  PdfControllerPinch? _controller;
  bool _loading = true;
  bool _error = false;
  bool _showingEn = false;

  String get _current => _showingEn ? (widget.enUrl ?? widget.url) : widget.url;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final bytes = await _getBytes(_current);
      _controller?.dispose();
      _controller = PdfControllerPinch(document: PdfDocument.openData(bytes));
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    }
  }

  /// Return the PDF bytes — from the local cache if present, otherwise
  /// download once and cache for offline reading.
  Future<Uint8List> _getBytes(String url) async {
    final dir = await getApplicationSupportDirectory();
    final safe =
        url.split('/').last.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final file = File('${dir.path}/books/$safe');
    if (await file.exists() && await file.length() > 0) {
      return file.readAsBytes();
    }
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200 || resp.bodyBytes.isEmpty) {
      throw Exception('download failed: ${resp.statusCode}');
    }
    await file.parent.create(recursive: true);
    await file.writeAsBytes(resp.bodyBytes);
    return resp.bodyBytes;
  }

  void _toggle() {
    setState(() => _showingEn = !_showingEn);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final bilingual = widget.enUrl != null;
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: tr('افتح في المتصفّح', 'Open in browser'),
            icon: const Icon(Icons.open_in_new),
            onPressed: () => openUrl(context, _current),
          ),
        ],
      ),
      body: Column(
        children: [
          if (bilingual) _langBar(context),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  /// A clear, always-visible Arabic / English switch for bilingual books.
  Widget _langBar(BuildContext context) {
    Widget seg(String label, bool en) {
      final active = _showingEn == en;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            if (_showingEn != en) _toggle();
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: active ? AppColors.sage600 : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: active
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(
        color: AppColors.sage100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        seg('العربية', false),
        seg('English', true),
      ]),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 14),
            Text(tr('جارٍ تحميل الكتاب…', 'Loading the book…')),
            const SizedBox(height: 4),
            Text(
              tr('يُحفظ للقراءة بدون إنترنت لاحقًا.',
                  'Saved for offline reading afterwards.'),
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6)),
            ),
          ],
        ),
      );
    }
    if (_error || _controller == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 44, color: AppColors.sage600),
              const SizedBox(height: 12),
              Text(
                tr('تعذّر فتح الكتاب. تأكّد من الإنترنت وحاول مرة أخرى.',
                    'Could not open the book. Check your connection and retry.'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              FilledButton(
                  onPressed: _load,
                  child: Text(tr('إعادة المحاولة', 'Retry'))),
              TextButton(
                  onPressed: () => openUrl(context, _current),
                  child: Text(tr('افتح في المتصفّح', 'Open in browser'))),
            ],
          ),
        ),
      );
    }
    return PdfViewPinch(controller: _controller!);
  }
}
