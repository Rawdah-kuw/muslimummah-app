import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../services/prefs.dart';
import '../theme.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});
  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _Preset {
  final String ar, en;
  final int target;
  const _Preset(this.ar, this.en, this.target);
}

class _TasbihScreenState extends State<TasbihScreen> {
  static const _presets = [
    _Preset('سُبْحَانَ الله', 'SubhanAllah', 33),
    _Preset('الْحَمْدُ لله', 'Alhamdulillah', 33),
    _Preset('اللهُ أَكْبَر', 'Allahu Akbar', 34),
    _Preset('لَا إِلَهَ إِلَّا الله', 'La ilaha illa Allah', 100),
    _Preset('أَسْتَغْفِرُ الله', 'Astaghfirullah', 100),
    _Preset('لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِالله', 'La hawla wa la quwwata illa billah', 100),
  ];

  int _i = 0;
  int _count = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _total = Prefs.tasbihTotal();
  }

  void _tap() {
    HapticFeedback.lightImpact();
    setState(() {
      _count++;
      _total++;
    });
    if (_count == _presets[_i].target) HapticFeedback.mediumImpact();
    Prefs.setTasbihTotal(_total);
  }

  void _resetCount() => setState(() => _count = 0);

  @override
  Widget build(BuildContext context) {
    final p = _presets[_i];
    final dark = Theme.of(context).brightness == Brightness.dark;
    final reached = _count >= p.target;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('السبحة', 'Tasbih')),
        actions: [
          IconButton(
              onPressed: _resetCount,
              icon: const Icon(Icons.refresh),
              tooltip: tr('تصفير', 'Reset')),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            height: 46,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _presets.length,
              itemBuilder: (_, idx) {
                final sel = idx == _i;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(_presets[idx].ar),
                    selected: sel,
                    onSelected: (_) => setState(() {
                      _i = idx;
                      _count = 0;
                    }),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(AppState.I.lang == 'ar' ? p.ar : p.en,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: dark ? AppColors.darkHeading : AppColors.pine800)),
          Text('${tr('الهدف', 'Target')}: ${p.target}',
              style: TextStyle(color: AppColors.sage700)),
          Expanded(
            child: GestureDetector(
              onTap: _tap,
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: reached
                        ? AppColors.sage600
                        : (dark ? const Color(0xFF1B2820) : AppColors.sage100),
                    border: Border.all(
                        color: AppColors.sage600,
                        width: 3),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$_count',
                            style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w800,
                                color: reached
                                    ? Colors.white
                                    : (dark
                                        ? AppColors.darkHeading
                                        : AppColors.pine800))),
                        Text(tr('اضغط', 'tap'),
                            style: TextStyle(
                                color: reached
                                    ? Colors.white70
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${tr('الإجمالي', 'Total')}: $_total',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
