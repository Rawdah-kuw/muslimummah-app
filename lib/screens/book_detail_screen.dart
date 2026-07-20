import 'package:flutter/material.dart';
import '../app_state.dart';
import '../config.dart';
import '../data/content.dart';
import '../models/models.dart';
import '../services/prefs.dart';
import '../theme.dart';
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
        actions: [_BookmarkButton(book.id)],
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

          // Read buttons
          if (book.bilingual && book.fileEn != null) ...[
            _readButton(context, tr('اقرأ (عربي)', 'Read (Arabic)'),
                Config.fileUrl(book.fileAr), AppState.I.loc(book.title)),
            const SizedBox(height: 10),
            _readButton(context, tr('اقرأ (إنجليزي)', 'Read (English)'),
                Config.fileUrl(book.fileEn!), AppState.I.loc(book.title),
                filled: false),
          ] else
            _readButton(context, tr('اقرأ الكتاب', 'Read the book'),
                Config.fileUrl(book.fileAr), AppState.I.loc(book.title)),

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
      {bool filled = true}) {
    void open() => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ReaderScreen(url: url, title: title)));
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
