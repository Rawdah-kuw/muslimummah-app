import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/content.dart';
import '../models/models.dart';
import '../theme.dart';
import 'science_screen.dart';

class CurriculumScreen extends StatelessWidget {
  const CurriculumScreen({super.key});

  IconData _iconFor(String key) {
    switch (key) {
      case 'worship':
        return Icons.volunteer_activism_outlined;
      case 'knowledge':
        return Icons.lightbulb_outline;
      case 'aqeedah':
        return Icons.shield_outlined;
      case 'hadith':
        return Icons.format_quote_outlined;
      case 'tafsir':
        return Icons.auto_stories_outlined;
      case 'fiqh':
        return Icons.balance_outlined;
      case 'seerah':
        return Icons.route_outlined;
      case 'tajweed':
        return Icons.record_voice_over_outlined;
      case 'arabic':
        return Icons.translate_outlined;
      default:
        return Icons.school_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sciences =
        ContentRepo.plCats.where((c) => c.key != 'all').toList();
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: sciences.map((c) {
        final count = ContentRepo.playlistCountBySci(c.key);
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ScienceScreen(sci: c.key, label: c.label))),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(_iconFor(c.key), size: 30, color: AppColors.sage600),
                  const Spacer(),
                  Text(AppState.I.loc(c.label),
                      style: const TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                      tr('$count قائمة', '$count playlist${count == 1 ? '' : 's'}'),
                      style: TextStyle(
                          fontSize: 12.5,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6))),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
