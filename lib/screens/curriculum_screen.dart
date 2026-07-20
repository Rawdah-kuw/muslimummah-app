import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/content.dart';
import '../widgets/scene.dart';
import 'science_screen.dart';

class CurriculumScreen extends StatelessWidget {
  const CurriculumScreen({super.key});

  static const _scenes = [
    Scenes.pine,
    Scenes.sage,
    Scenes.sky,
    Scenes.night,
    Scenes.dusk,
    Scenes.dawn,
    Scenes.pearl,
  ];

  @override
  Widget build(BuildContext context) {
    final sciences = ContentRepo.plCats.where((c) => c.key != 'all').toList();
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: List.generate(sciences.length, (i) {
        final c = sciences[i];
        final scene = _scenes[i % _scenes.length];
        final count = ContentRepo.playlistCountBySci(c.key);
        return GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ScienceScreen(sci: c.key, label: c.label))),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: scene.colors,
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(child: PearlBackdrop(scene)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(AppState.I.loc(c.label),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: scene.onColor)),
                      const SizedBox(height: 4),
                      Text(
                          tr('$count قائمة',
                              '$count playlist${count == 1 ? '' : 's'}'),
                          style:
                              TextStyle(fontSize: 12.5, color: scene.subColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
