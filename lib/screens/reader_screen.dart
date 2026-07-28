import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// In-app PDF reader: iOS/Android WebView renders the hosted PDF from the site.
/// For bilingual books, pass [enUrl] to show an in-reader Arabic/English toggle.
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
  late final WebViewController _controller;
  bool _loading = true;
  bool _showingEn = false;

  String get _current => _showingEn ? (widget.enUrl ?? widget.url) : widget.url;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadRequest(Uri.parse(_current));
  }

  void _toggleLang() {
    setState(() {
      _showingEn = !_showingEn;
      _loading = true;
    });
    _controller.loadRequest(Uri.parse(_current));
  }

  @override
  Widget build(BuildContext context) {
    final bilingual = widget.enUrl != null;
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (bilingual)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                onPressed: _toggleLang,
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.sage600,
                    textStyle: const TextStyle(fontWeight: FontWeight.w800)),
                child: Text(_showingEn ? 'ع' : 'EN'),
              ),
            ),
          IconButton(
            tooltip: tr('افتح في المتصفّح', 'Open in browser'),
            icon: const Icon(Icons.open_in_new),
            onPressed: () => openUrl(context, _current),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
