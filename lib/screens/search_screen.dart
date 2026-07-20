import 'package:flutter/material.dart';
import '../app_state.dart';
import '../config.dart';
import '../data/content.dart';
import '../services/ask_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'book_detail_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: AppColors.sage700,
            indicatorColor: AppColors.sage600,
            tabs: [
              Tab(text: tr('اسأل المكتبة', 'Ask the Library')),
              Tab(text: tr('مواقع موثوقة', 'Trusted Sites')),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [_AskTab(), _TrustedTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _AskTab extends StatefulWidget {
  const _AskTab();
  @override
  State<_AskTab> createState() => _AskTabState();
}

class _AskTabState extends State<_AskTab> {
  final _c = TextEditingController();
  bool _loading = false;
  AskResult? _result;
  String? _error;

  final _suggestions = const [
    ['ما شروط لا إله إلا الله؟', 'What are the conditions of the shahada?'],
    ['كيف أطلب العلم الشرعي؟', 'How do I begin seeking knowledge?'],
    ['ما فضل العشر من ذي الحجة؟', 'What is the virtue of the ten days of Dhul-Hijjah?'],
  ];

  Future<void> _run(String q) async {
    if (q.trim().isEmpty) return;
    _c.text = q;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final r = await AskService.ask(q.trim(), AppState.I.lang);
      setState(() => _result = r);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openSource(AskSource s) {
    for (final b in ContentRepo.books) {
      if (b.slug == s.slug) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => BookDetailScreen(book: b)));
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _c,
          textInputAction: TextInputAction.search,
          onSubmitted: _run,
          decoration: InputDecoration(
            hintText: tr('اكتب سؤالك…', 'Type your question…'),
            filled: true,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
                icon: const Icon(Icons.send), onPressed: () => _run(_c.text)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.info_outline, size: 15),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              tr('إجابات استرشادية من نصوص الكتب — ليست فتوى. (Beta)',
                  'Guidance drawn from the books — not a fatwa. (Beta)'),
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6)),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestions
              .map((s) => ActionChip(
                    label: Text(tr(s[0], s[1]),
                        style: const TextStyle(fontSize: 12)),
                    onPressed: () => _run(tr(s[0], s[1])),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        if (_loading) const Center(child: CircularProgressIndicator()),
        if (_error != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          ),
        if (_result != null) _answer(_result!),
      ],
    );
  }

  Widget _answer(AskResult r) {
    if (r.notFound || r.answer.trim().isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(tr('لم أجد إجابة في الكتب المتاحة.',
              'I did not find an answer in the available books.')),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.answer, style: const TextStyle(fontSize: 15, height: 1.8)),
            if (r.sources.isNotEmpty) ...[
              const Divider(height: 26),
              Text(tr('المصادر', 'Sources'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              ...r.sources.map((s) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading:
                        const Icon(Icons.menu_book_outlined, size: 20),
                    title: Text(s.title,
                        style: const TextStyle(fontSize: 13.5)),
                    subtitle: s.page == null
                        ? null
                        : Text(tr('صفحة ${s.page}', 'page ${s.page}')),
                    onTap: () => _openSource(s),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrustedTab extends StatefulWidget {
  const _TrustedTab();
  @override
  State<_TrustedTab> createState() => _TrustedTabState();
}

class _TrustedTabState extends State<_TrustedTab> {
  final _c = TextEditingController();

  void _search() {
    final q = _c.text.trim();
    if (q.isEmpty) return;
    final sites = Config.approvedSites.map((s) => 'site:$s').join(' OR ');
    final url =
        'https://www.google.com/search?q=${Uri.encodeComponent('$q ($sites)')}';
    openUrl(context, url);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _c,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            hintText: tr('ابحث في المواقع الموثوقة…', 'Search trusted sites…'),
            filled: true,
            prefixIcon: const Icon(Icons.travel_explore),
            suffixIcon: IconButton(
                icon: const Icon(Icons.send), onPressed: _search),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        Text(tr('المواقع المعتمدة', 'Approved sites'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 8),
        ...Config.approvedSites.map((s) => Card(
              child: ListTile(
                leading: const Icon(Icons.public, color: AppColors.sage700),
                title: Text(s),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => openUrl(context, 'https://$s'),
              ),
            )),
      ],
    );
  }
}
