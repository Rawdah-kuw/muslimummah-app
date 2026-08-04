import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../app_state.dart';
import '../config.dart';
import '../data/content.dart';
import '../models/models.dart';
import '../services/prefs.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'reader_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final related = ContentRepo.booksByCat(book.cat)
        .where((b) => b.id != book.id)
        .take(4)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('تفاصيل الكتاب', 'Book')),
        actions: [
          IconButton(
            tooltip: tr('مشاركة', 'Share'),
            icon: const Icon(Icons.ios_share),
            onPressed: () => shareText(
                '${AppState.I.loc(book.title)}\n${AppState.I.loc(book.author)}\n\n$kSiteUrl'),
          ),
          _BookmarkButton(book.id),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(AppState.I.loc(book.title),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(AppState.I.loc(book.author),
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7))),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _meta('${book.pages} ${tr('صفحة', 'pages')}'),
            _meta(book.size),
            if (book.bilingual) _meta(tr('عربي وإنجليزي', 'Arabic & English')),
          ]),
          const SizedBox(height: 18),
          Text(AppState.I.loc(book.desc),
              style: const TextStyle(fontSize: 15, height: 1.8)),
          const SizedBox(height: 24),

          // Read button (bilingual books get an in-reader AR/EN toggle)
          if (book.bilingual && book.fileEn != null)
            _readButton(context, tr('اقرأ الكتاب (عربي/إنجليزي)', 'Read (AR/EN)'),
                Config.fileUrl(book.fileAr), AppState.I.loc(book.title),
                enUrl: Config.fileUrl(book.fileEn!))
          else
            _readButton(context, tr('اقرأ الكتاب', 'Read the book'),
                Config.fileUrl(book.fileAr), AppState.I.loc(book.title)),

          const SizedBox(height: 10),
          _DownloadButton(
            url: Config.fileUrl(book.fileAr),
            title: AppState.I.loc(book.title),
          ),

          if (related.isNotEmpty) ...[
            const SizedBox(height: 30),
            Text(tr('كتب ذات صلة', 'Related books'),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...related.map((b) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.menu_book_outlined,
                      color: AppColors.sage700),
                  title: Text(AppState.I.loc(b.title),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BookDetailScreen(book: b))),
                )),
          ],
        ],
      ),
    );
  }

  Widget _meta(String s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.sage100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(s,
            style: const TextStyle(fontSize: 12.5, color: AppColors.sage700)),
      );

  Widget _readButton(
      BuildContext context, String label, String url, String title,
      {bool filled = true, String? enUrl}) {
    void open() {
      Prefs.setLastBook(book.id);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ReaderScreen(url: url, enUrl: enUrl, title: title)));
    }
    final icon = const Icon(Icons.chrome_reader_mode_outlined);
    return SizedBox(
      width: double.infinity,
      child: filled
          ? FilledButton.icon(onPressed: open, icon: icon, label: Text(label))
          : OutlinedButton.icon(
              onPressed: open, icon: icon, label: Text(label)),
    );
  }
}

/// Downloads the book's PDF and opens the share sheet so the reader can
/// "Save to Files" (or send it anywhere). Shows progress + errors inline.
class _DownloadButton extends StatefulWidget {
  final String url;
  final String title;
  const _DownloadButton({required this.url, required this.title});
  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _busy = false;

  Future<void> _download() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final resp = await http.get(Uri.parse(widget.url));
      if (resp.statusCode != 200 || resp.bodyBytes.isEmpty) {
        throw Exception('status ${resp.statusCode}');
      }
      final dir = await getTemporaryDirectory();
      final safe = widget.url.split('/').last;
      final f = File('${dir.path}/$safe');
      await f.writeAsBytes(resp.bodyBytes);
      await Share.shareXFiles([XFile(f.path)], text: widget.title);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr('تعذّر التحميل. تأكّد من الإنترنت وحاول مجدداً.',
              'Download failed. Check your connection and try again.')),
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _busy ? null : _download,
        icon: _busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.download_outlined),
        label: Text(_busy
            ? tr('جارٍ التحميل…', 'Downloading…')
            : tr('تحميل / حفظ الكتاب', 'Download / save book')),
      ),
    );
  }
}

class _BookmarkButton extends StatefulWidget {
  final int bookId;
  const _BookmarkButton(this.bookId);
  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton> {
  @override
  Widget build(BuildContext context) {
    final saved = Prefs.isBookmarked(widget.bookId);
    return IconButton(
      tooltip: tr('حفظ', 'Save'),
      icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
      onPressed: () async {
        await Prefs.setBookmark(widget.bookId, !saved);
        if (mounted) setState(() {});
      },
    );
  }
}
