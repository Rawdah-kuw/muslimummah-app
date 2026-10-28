import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../data/content.dart';
import '../models/models.dart';
import '../theme.dart';
import '../services/adhkar_image.dart';

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
            _AdhkarPager(ContentRepo.adhkarMorning),
            _AdhkarPager(ContentRepo.adhkarEvening),
          ],
        ),
      ),
    );
  }
}

/// Horizontal swipeable pager — one dhikr per view, with a peek of the next
/// card and a prominent "next" arrow (mirrors the website's adhkar carousel).
class _AdhkarPager extends StatefulWidget {
  final List<Dhikr> items;
  const _AdhkarPager(this.items);
  @override
  State<_AdhkarPager> createState() => _AdhkarPagerState();
}

class _AdhkarPagerState extends State<_AdhkarPager> {
  late final PageController _pc;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pc = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _go(int i) {
    final n = i.clamp(0, widget.items.length - 1);
    _pc.animateToPage(n,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final ar = AppState.I.lang != 'en';
    final total = widget.items.length;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Text(
            ar
                ? '👆 اضغط للعدّ · اسحب للجنب أو استخدم السهم للذكر التالي'
                : '👆 Tap to count · swipe or use the arrow for the next',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12.5, color: onSurface.withValues(alpha: 0.55)),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pc,
            reverse: ar, // RTL: first dhikr on the right, swipe right→left
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: total,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _DhikrCard(widget.items[i], i + 1, total),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavArrow(
                icon: ar ? Icons.chevron_right : Icons.chevron_left,
                filled: false,
                onTap: _page > 0 ? () => _go(_page - 1) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('${_page + 1} / $total',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: onSurface.withValues(alpha: 0.55))),
              ),
              _NavArrow(
                icon: ar ? Icons.chevron_left : Icons.chevron_right,
                filled: true,
                onTap: _page < total - 1 ? () => _go(_page + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A round navigation arrow. `filled` = the prominent "next" button.
class _NavArrow extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;
  const _NavArrow({required this.icon, required this.filled, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.3,
      child: Material(
        color: filled ? AppColors.sage600 : Colors.white,
        shape: CircleBorder(
            side: filled
                ? BorderSide.none
                : const BorderSide(color: AppColors.pearl200)),
        elevation: enabled ? 2 : 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon,
                size: 30, color: filled ? Colors.white : AppColors.sage700),
          ),
        ),
      ),
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
    if (widget.d.count <= 1 || _done >= widget.d.count) return;
    HapticFeedback.lightImpact();
    setState(() => _done++);
    if (_done == widget.d.count) HapticFeedback.mediumImpact();
  }

  void _share() => AdhkarImage.share(widget.d);

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    final english = AppState.I.lang == 'en';
    final countable = d.count > 1;
    final complete = countable && _done >= d.count;
    final benefit = english && d.noteEn.isNotEmpty ? d.noteEn : d.note;
    final src = english && d.sourceEn.isNotEmpty ? d.sourceEn : d.source;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final counterLabel = _done == 0
        ? '${d.count}×'
        : (complete ? '✓ ${d.count}' : '$_done / ${d.count}');
    return Card(
      color: complete ? AppColors.sage100 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
            color: complete ? AppColors.sage500 : AppColors.pearl200,
            width: complete ? 1.5 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: countable ? _tap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: position (English digits, subtle) + circular repeat counter.
              Row(
                children: [
                  Text('${widget.index} / ${widget.total}',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: onSurface.withValues(alpha: 0.4))),
                  const Spacer(),
                  if (countable)
                    Container(
                      constraints: const BoxConstraints(minWidth: 54),
                      height: 46,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: complete ? AppColors.sage600 : AppColors.pearl100,
                        border: Border.all(
                            color: complete ? AppColors.sage600 : AppColors.sage500,
                            width: 2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(counterLabel,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: complete ? Colors.white : AppColors.sage700)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (d.prefix.isNotEmpty) ...[
                Text(d.prefix,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        height: 1.9,
                        fontFamily: 'Amiri',
                        color: onSurface.withValues(alpha: 0.7))),
                if (english && d.prefixEn.isNotEmpty)
                  Text(d.prefixEn,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: onSurface.withValues(alpha: 0.6))),
                const SizedBox(height: 4),
              ],
              // Dhikr text — centred, matching the website.
              Text(d.ar,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22, height: 2.1, fontFamily: 'Amiri')),
              if (english && d.en.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(d.en,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                        fontSize: 15,
                        height: 1.55,
                        fontStyle: FontStyle.italic,
                        color: onSurface.withValues(alpha: 0.82))),
              ],
              if (src.isNotEmpty || benefit.isNotEmpty) ...[
                const SizedBox(height: 10),
                if (benefit.isNotEmpty)
                  Text(benefit,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.sage700, height: 1.6)),
                if (src.isNotEmpty)
                  Text(src,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: onSurface.withValues(alpha: 0.55))),
              ],
              const SizedBox(height: 14),
              // Share-as-image button, centred, like the website.
              Center(
                child: OutlinedButton.icon(
                  onPressed: _share,
                  icon: const Icon(Icons.ios_share, size: 16),
                  label: Text(tr('شارك كصورة', 'Share as image')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.sage600,
                    side: const BorderSide(color: AppColors.sage300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
