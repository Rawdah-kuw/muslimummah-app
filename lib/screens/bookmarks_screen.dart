import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/content.dart';
import '../services/prefs.dart';
import '../theme.dart';
import 'book_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});
  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  Widget build(BuildContext context) {
    final ids = Prefs.bookmarks();
    final saved = ContentRepo.books.where((b) => ids.contains(b.id)).toList();
    return Scaffold(
      appBar: AppBar(title: Text(tr('المحفوظات', 'Saved'))),
      body: saved.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  tr('لا توجد كتب محفوظة بعد. اضغط على أيقونة الحفظ في أي كتاب.',
                      'No saved books yet. Tap the bookmark icon on any book.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6)),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: saved.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final b = saved[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.bookmark, color: AppColors.sage600),
                    title: Text(AppState.I.loc(b.title),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(AppState.I.loc(b.author),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => BookDetailScreen(book: b)));
                      if (mounted) setState(() {});
                    },
                  ),
                );
              },
            ),
    );
  }
}
