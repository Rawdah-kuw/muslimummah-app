import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/content.dart';
import '../models/models.dart';
import '../services/prefs.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ScienceScreen extends StatefulWidget {
  final String sci;
  final Map<String, dynamic> label;
  const ScienceScreen({super.key, required this.sci, required this.label});

  @override
  State<ScienceScreen> createState() => _ScienceScreenState();
}

class _ScienceScreenState extends State<ScienceScreen> {
  late Set<int> _done;

  @override
  void initState() {
    super.initState();
    _done = Prefs.completedPlaylists();
  }

  void _toggle(int id) {
    setState(() {
      if (_done.contains(id)) {
        _done.remove(id);
      } else {
        _done.add(id);
      }
    });
    Prefs.setPlaylistDone(id, _done.contains(id));
  }

  @override
  Widget build(BuildContext context) {
    final items = ContentRepo.playlistsBySci(widget.sci)
      ..sort((a, b) => a.level.compareTo(b.level));
    final doneHere = items.where((p) => _done.contains(p.id)).length;
    final pct = items.isEmpty ? 0.0 : doneHere / items.length;

    return Scaffold(
      appBar: AppBar(title: Text(AppState.I.loc(widget.label))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr('التقدّم', 'Progress'),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('$doneHere / ${items.length}',
                        style: TextStyle(color: AppColors.sage700)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: AppColors.sage100,
                    color: AppColors.sage600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final p = items[i];
                final done = _done.contains(p.id);
                final level =
                    ContentRepo.plLevels[p.level.toString()] ?? const {};
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: done,
                              onChanged: (_) => _toggle(p.id),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppState.I.loc(p.title),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(AppState.I.loc(level),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.sage700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: p.sources.map((s) {
                            final ch = ContentRepo.plChannels[s.ch] ?? const {};
                            return OutlinedButton.icon(
                              onPressed: () => openUrl(context, s.url),
                              icon: const Icon(Icons.play_arrow, size: 18),
                              label: Text(AppState.I.loc(ch),
                                  style: const TextStyle(fontSize: 12)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
