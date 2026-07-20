import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/content.dart';
import '../models/models.dart';
import '../services/prefs.dart';
import '../theme.dart';
import 'book_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _cat = 'all';
  String _query = '';

  List<Book> get _filtered {
    var list = ContentRepo.booksByCat(_cat);
    if (_query.trim().isNotEmpty) {
      final q = _query.trim();
      list = list
          .where((b) =>
              AppState.I.loc(b.title).contains(q) ||
              AppState.I.loc(b.author).contains(q) ||
              b.title['en'].toString().toLowerCase().contains(q.toLowerCase()) ||
              b.author['en'].toString().toLowerCase().contains(q.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final books = _filtered;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              isDense: true,
              hintText: tr('ابحث بالعنوان أو المؤلف…', 'Search title or author…'),
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: ContentRepo.bookCats.map((c) {
              final sel = c.key == _cat;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(AppState.I.loc(c.label)),
                  selected: sel,
                  onSelected: (_) => setState(() => _cat = c.key),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: books.isEmpty
              ? Center(child: Text(tr('لا نتائج', 'No results')))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: books.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _BookTile(books[i], onChanged: () => setState(() {})),
                ),
        ),
      ],
    );
  }
}

class _BookTile extends StatelessWidget {
  final Book book;
  final VoidCallback onChanged;
  const _BookTile(this.book, {required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final saved = Prefs.isBookmarked(book.id);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)));
          onChanged();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.sage100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf_outlined,
                    color: AppColors.sage700),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppState.I.loc(book.title),
                        style: const TextStyle(
                            fontSize: 15.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(AppState.I.loc(book.author),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12.5,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6))),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        _tag('${book.pages} ${tr('صفحة', 'pp')}'),
                        _tag(book.size),
                        if (book.bilingual) _tag(tr('عربي/إنجليزي', 'AR/EN')),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border,
                    color: saved ? AppColors.sage600 : null),
                onPressed: () async {
                  await Prefs.setBookmark(book.id, !saved);
                  onChanged();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.sage100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(s,
            style: const TextStyle(fontSize: 11, color: AppColors.sage700)),
      );
}
