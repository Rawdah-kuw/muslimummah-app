import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/content.dart';
import '../models/models.dart';
import '../services/quote_image.dart';
import '../theme.dart';
import 'book_detail_screen.dart';

/// "Quote of the Day" (اقتباس اليوم) — verbatim excerpts from the library
/// books, prioritising the works of Sheikh Ali Abdulaziz Alseddiqi (may Allah
/// have mercy on him). Dark-green background matching the app logo (#16302A).
class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});
  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  static const _bg = Color(0xFF16302A); // logo background
  static const _gold = Color(0xFFC8A86B); // muted gold for the author's name
  late int _i;

  /// Quotes for the current language. The English app shows only quotes that
  /// have an English text (verbatim excerpts from the book itself), never the
  /// Arabic-only adapted summaries.
  List<Quote> _quotes() {
    final all = ContentRepo.quotes;
    if (AppState.I.lang == 'ar') return all;
    return all.where((q) => q.en.isNotEmpty).toList();
  }

  @override
  void initState() {
    super.initState();
    final list = _quotes();
    final today = ContentRepo.quoteOfToday();
    var idx = today == null ? -1 : list.indexOf(today);
    if (idx < 0 && list.isNotEmpty) {
      final d = DateTime.now();
      final doy = d.difference(DateTime(d.year, 1, 1)).inDays;
      idx = (doy + 3) % list.length;
    }
    _i = idx < 0 ? 0 : idx;
  }

  void _next() {
    final list = _quotes();
    if (list.isEmpty) return;
    setState(() => _i = (_i + 1) % list.length);
  }

  @override
  Widget build(BuildContext context) {
    final ar = AppState.I.lang == 'ar';
    final quotes = _quotes();
    final q = quotes.isEmpty ? null : quotes[_i % quotes.length];
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: AppColors.pearl50,
        elevation: 0,
        // The global AppBar theme forces a dark-green title colour, which is
        // invisible on this dark-green screen — override it to a light cream.
        titleTextStyle: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppColors.pearl50,
        ),
        title: Text(tr('اقتباس اليوم', 'Quote of the Day')),
        actions: [
          if (q != null)
            IconButton(
              tooltip: tr('مشاركة', 'Share'),
              icon: const Icon(Icons.ios_share),
              onPressed: () => QuoteImage.share(q),
            ),
        ],
      ),
      body: q == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  tr('سيتم إضافة الاقتباسات قريباً بإذن الله.',
                      'Quotes will be added soon, in shaa Allah.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.pearl50, fontSize: 16),
                ),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  children: [
                    Expanded(child: _card(context, q, ar)),
                    const SizedBox(height: 16),
                    // "Read the book" — opens the source book in the library.
                    _readBookButton(context, q),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _next,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.pearl50,
                            side: BorderSide(
                                color: AppColors.pearl50.withValues(alpha: 0.4)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(tr('اقتباس آخر', 'Another quote')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Invites the reader to open the source book in the library.
  Widget _readBookButton(BuildContext context, Quote q) {
    final id = q.source['bookId'];
    final book = id is int ? ContentRepo.bookById(id) : null;
    if (book == null) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.sage600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
        ),
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => BookDetailScreen(book: book))),
        icon: const Icon(Icons.menu_book_outlined, size: 19),
        label: Text(tr('اقرأ الكتاب كاملاً', 'Read the full book')),
      ),
    );
  }

  String _author(Quote q, bool ar) =>
      (ar ? q.source['authorAr'] : q.source['authorEn'])?.toString() ?? '';

  Widget _card(BuildContext context, Quote q, bool ar) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('❝',
                style: TextStyle(
                    fontSize: 64,
                    height: 0.8,
                    color: AppColors.sage300.withValues(alpha: 0.6))),
            const SizedBox(height: 8),
            // One language per app language: Arabic page → Arabic; English
            // page → the book's English text.
            if (ar && q.ar.isNotEmpty)
              Text(q.ar,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      color: AppColors.pearl50,
                      fontSize: 24,
                      height: 1.9,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Amiri')),
            if (!ar && q.en.isNotEmpty)
              Text(q.en,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                      color: AppColors.pearl50,
                      fontSize: 20,
                      height: 1.7,
                      fontWeight: FontWeight.w500)),
            const SizedBox(height: 22),
            // Attribution. For a cited scholar-saying, show the speaker first
            // (in gold), then a small "Quoted from the book …" line beneath —
            // so the words are attributed to their real author, not the book's.
            if (q.source['cited'] == true) ...[
              if (_author(q, ar).isNotEmpty)
                Text(_author(q, ar),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: _gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                  ar
                      ? 'مقتبَس من كتاب «${AppState.I.loc(q.source)}»'
                      : 'Quoted from “${AppState.I.loc(q.source)}”',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.sage300,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ] else ...[
              // Book title on one line …
              Text(AppState.I.loc(q.source),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.sage300,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600)),
              // … and the author (Sheikh Ali) on his own line beneath, in a
              // muted gold so his name is distinct from the green book title.
              if (_author(q, ar).isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(_author(q, ar),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: _gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ],
            // Transparency tag for adapted/summarised excerpts.
            if (q.source['adapted'] == true) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sage300.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tr('مقتبَس بتصرّف من الكتاب', 'Adapted excerpt from the book'),
                  style: TextStyle(
                      color: AppColors.sage300.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
