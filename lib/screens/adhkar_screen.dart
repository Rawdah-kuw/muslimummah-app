import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../data/content.dart';
import '../models/models.dart';
import '../theme.dart';

class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
      itemBuilder: (_, i) => _DhikrCard(items[i], i + 1),
    );
  }
}

class _DhikrCard extends StatefulWidget {
  final Dhikr d;
  final int index;
  const _DhikrCard(this.d, this.index);
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

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    final complete = _done >= d.count;
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
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.sage100,
                    child: Text('${widget.index}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.sage700)),
                  ),
                  const Spacer(),
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
              Text(
                d.ar,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 20, height: 2.1),
              ),
              if (d.source.isNotEmpty || d.note.isNotEmpty) ...[
                const SizedBox(height: 10),
                if (d.note.isNotEmpty)
                  Text(d.note,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.sage700,
                          height: 1.6)),
                if (d.source.isNotEmpty)
                  Text(d.source,
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
