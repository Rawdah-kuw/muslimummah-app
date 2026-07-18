import 'package:flutter/material.dart';
import '../app_state.dart';
import '../config.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('عن الموقع', 'About'))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Center(child: PearlMark(size: 44)),
          const SizedBox(height: 14),
          Text(
            tr('صدقة جارية عن علي عبد العزيز الصدّيقي رحمه الله',
                'An ongoing charity for Ali Abdulaziz Alseddiqi, may Allah have mercy on him'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          _p(tr(
            'أُنشئت هذه المنصّة صدقةً جارية عن علي عبد العزيز الصدّيقي رحمه الله، جمعًا لما ينفع طالب العلم: مكتبة كتب موثوقة، ومنهج تعلّم متدرّج عبر قوائم مختارة، وبحث ذكي يجيب من نصوص الكتب، ودليلٍ لمجالس ودروس الذكر «روضة».',
            'This platform was built as an ongoing charity (sadaqah jariyah) for Ali Abdulaziz Alseddiqi, may Allah have mercy on him — gathering what benefits the seeker of knowledge: a trusted book library, a graded learning curriculum through selected playlists, a smart search that answers from the books, and the "Rawdah" guide to dhikr gatherings.',
          )),
          _p(tr(
            'كان حلمه أن يَسهُل على الناس الوصول إلى العلم النافع الصحيح، فجُعل هذا العمل امتدادًا لأثره، نسأل الله أن يتقبّله وأن يجعله في ميزان حسناته.',
            'His hope was to make beneficial, authentic knowledge easy to reach. This work is made an extension of his legacy — we ask Allah to accept it and to place it in the scale of his good deeds.',
          )),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.sage100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  tr('«إِذَا مَاتَ الإِنْسَانُ انْقَطَعَ عَنْهُ عَمَلُهُ إِلَّا مِنْ ثَلَاثٍ: صَدَقَةٍ جَارِيَةٍ، أَوْ عِلْمٍ يُنْتَفَعُ بِهِ، أَوْ وَلَدٍ صَالِحٍ يَدْعُو لَهُ»',
                      'When a person dies, his deeds end except for three: an ongoing charity, knowledge that is benefited from, or a righteous child who prays for him.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, height: 1.9),
                ),
                const SizedBox(height: 8),
                Text(tr('رواه مسلم', 'Muslim'),
                    style: TextStyle(fontSize: 12, color: AppColors.sage700)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: TextButton.icon(
              onPressed: () => openUrl(context, Config.aliYoutube),
              icon: const Icon(Icons.play_circle_outline),
              label: Text(tr('قناة علي على يوتيوب', "Ali's YouTube channel")),
            ),
          ),
          Center(
            child: TextButton.icon(
              onPressed: () =>
                  openUrl(context, 'mailto:${Config.contactEmail}'),
              icon: const Icon(Icons.mail_outline),
              label: Text(Config.contactEmail),
            ),
          ),
        ],
      ),
    );
  }

  Widget _p(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(text, style: const TextStyle(fontSize: 15, height: 1.9)),
      );
}
