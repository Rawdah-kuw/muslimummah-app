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
  late int _i;

  @override
  void initState() {
    super.initState();
    final q = ContentRepo.quoteOfToday();
    final idx = q == null ? 0 : ContentRepo.quotes.indexOf(q);
    _i = idx < 0 ? 0 : idx;
  }

  void _next() {
    if (ContentRepo.quotes.isEmpty) return;
    setState(() => _i = (_i + 1) % ContentRepo.quotes.length);
  }

  @override
  Widget build(BuildContext context) {
    final ar = AppState.I.lang == 'ar';
    final quotes = ContentRepo.quotes;
    final q = quotes.isEmpty ? null : quotes[_i % quotes.length];
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: AppColors.pearl50,
        elevation: 0,
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
            if (q.ar.isNotEmpty)
              Text(q.ar,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      color: AppColors.pearl50,
                      fontSize: 24,
                      height: 1.9,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Amiri')),
            if (q.ar.isNotEmpty && q.en.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(
                  width: 60,
                  height: 1,
                  color: AppColors.sage300.withValues(alpha: 0.4)),
              const SizedBox(height: 18),
            ],
            if (q.en.isNotEmpty)
              Text(q.en,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                      color: AppColors.pearl50.withValues(alpha: 0.88),
                      fontSize: 17.5,
                      height: 1.6,
                      fontStyle: FontStyle.italic)),
            const SizedBox(height: 22),
            // Book title on one line …
            Text(AppState.I.loc(q.source),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.sage300,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600)),
            // … and the author (Sheikh Ali) on his own line beneath.
            if (_author(q, ar).isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(_author(q, ar),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.sage300.withValues(alpha: 0.85),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500)),
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
