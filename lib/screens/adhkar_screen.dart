import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../data/content.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AdhkarScreen extends StatelessWidget {
  final int initialTab;
  const AdhkarScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('أذكار الصباح والمساء', 'Morning & Evening Adhkar')),
          bottom: TabBar(
            labelColor: AppColors.sage700,
            indicatorColor: AppColors.sage600,
            tabs: [
              Tab(text: tr('الصباح', 'Morning')),
              Tab(text: tr('المساء', 'Evening')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AdhkarList(ContentRepo.adhkarMorning),
            _AdhkarList(ContentRepo.adhkarEvening),
          ],
        ),
      ),
    );
  }
}

class _AdhkarList extends StatelessWidget {
  final List<Dhikr> items;
  const _AdhkarList(this.items);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _DhikrCard(items[i], i + 1, items.length),
    );
  }
}

class _DhikrCard extends StatefulWidget {
  final Dhikr d;
  final int index;
  final int total;
  const _DhikrCard(this.d, this.index, this.total);
  @override
  State<_DhikrCard> createState() => _DhikrCardState();
}

class _DhikrCardState extends State<_DhikrCard> {
  int _done = 0;

  void _tap() {
    if (_done >= widget.d.count) return;
    HapticFeedback.lightImpact();
    setState(() => _done++);
    if (_done == widget.d.count) HapticFeedback.mediumImpact();
  }

  void _share() {
    final d = widget.d;
    final english = AppState.I.lang == 'en';
    final benefit = english && d.noteEn.isNotEmpty ? d.noteEn : d.note;
    final src = english && d.sourceEn.isNotEmpty ? d.sourceEn : d.source;
    final text = [
      if (d.prefix.isNotEmpty) d.prefix,
      d.ar,
      if (english && d.en.isNotEmpty) d.en,
      if (src.isNotEmpty) src,
      if (benefit.isNotEmpty) benefit,
      '',
      english ? 'Muslim Ummah' : 'أمة الإسلام',
      kSiteUrl,
    ].join('\n');
    shareText(text);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    final complete = _done >= d.count;
    final english = AppState.I.lang == 'en';
    final benefit = english && d.noteEn.isNotEmpty ? d.noteEn : d.note;
    final src = english && d.sourceEn.isNotEmpty ? d.sourceEn : d.source;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _tap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.sage100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${widget.index} / ${widget.total}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.sage700)),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _share,
                    icon: const Icon(Icons.ios_share, size: 20),
                    color: AppColors.sage700,
                    tooltip: tr('مشاركة', 'Share'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: complete ? AppColors.sage600 : AppColors.sage100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      complete ? '✓ ${d.count}' : '$_done / ${d.count}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: complete ? Colors.white : AppColors.sage700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Basmala / isti'adha on its own centred line — it is not a verse.
              if (d.prefix.isNotEmpty) ...[
                Text(
                  d.prefix,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      height: 1.9,
                      fontFamily: 'Amiri',
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                d.ar,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 21, height: 2.1, fontFamily: 'Amiri'),
              ),
              // English translation (shown in the English app).
              if (english && d.en.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  d.en,
                  textAlign: TextAlign.left,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                      fontSize: 15,
                      height: 1.55,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.82)),
                ),
              ],
              if (src.isNotEmpty || benefit.isNotEmpty) ...[
                const SizedBox(height: 10),
                if (benefit.isNotEmpty)
                  Text(benefit,
                      style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.sage700,
                          height: 1.6)),
                if (src.isNotEmpty)
                  Text(src,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.55))),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
