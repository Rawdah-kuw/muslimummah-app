import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/content.dart';
import '../models/models.dart';
import '../theme.dart';
import 'book_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _cat = 'all';

  @override
  Widget build(BuildContext context) {
    final books = ContentRepo.booksByCat(_cat);
    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _BookTile(books[i]),
          ),
        ),
      ],
    );
  }
}

class _BookTile extends StatelessWidget {
  final Book book;
  const _BookTile(this.book);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => BookDetailScreen(book: book))),
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
