import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../app_state.dart';
import '../widgets/common.dart';

/// A simple in-app web view so search results and trusted sites open inside
/// the app instead of bouncing out to an external browser.
class InAppBrowser extends StatefulWidget {
  final String url;
  final String title;
  const InAppBrowser({super.key, required this.url, required this.title});

  @override
  State<InAppBrowser> createState() => _InAppBrowserState();
}

class _InAppBrowserState extends State<InAppBrowser> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _loading = true);
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: tr('افتح في المتصفّح', 'Open in browser'),
            icon: const Icon(Icons.open_in_new),
            onPressed: () => openUrl(context, widget.url),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(minHeight: 3),
        ],
      ),
    );
  }
}
