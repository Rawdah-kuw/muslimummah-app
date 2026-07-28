import 'package:flutter/material.dart';
import '../app_state.dart';
import '../config.dart';
import '../theme.dart';
import '../widgets/common.dart';

class _Station {
  final IconData icon;
  final String phaseAr, phaseEn;
  final String titleAr, titleEn;
  final String descAr, descEn;
  final bool isFinal;
  final bool accent;
  const _Station(this.icon, this.phaseAr, this.phaseEn, this.titleAr,
      this.titleEn, this.descAr, this.descEn,
      {this.isFinal = false, this.accent = false});
}

const _stations = <_Station>[
  _Station(
      Icons.home_outlined,
      'النشأة',
      'Upbringing',
      'كويتيّ نشأ بين لغتين',
      'A Kuwaiti raised between two languages',
      'وُلد لأسرة كويتية، وكبر وتعلّم في المملكة المتحدة، فأتقن العربية والإنجليزية.',
      'Born to a Kuwaiti family, he grew up and studied in the UK, mastering both Arabic and English.'),
  _Station(
      Icons.school_outlined,
      'الدراسة',
      'Studies',
      'تفوّقٌ وطبٌّ وعلمٌ شرعي',
      'Excellence, medicine, and religious knowledge',
      'تفوّق وسافر ليكمل دراسة الطب، وفي الوقت نفسه يطوّر نفسه في العلم الشرعي.',
      'He excelled and travelled to study medicine, while developing himself in religious knowledge.'),
  _Station(
      Icons.groups_outlined,
      'مجموعة «مسلم أمة»',
      'The “Muslim Ummah” group',
      'دعوةٌ للمهتدين الجدد',
      'Outreach to new Muslims',
      'أسّس مع أخيه محمد مجموعة واتساب وجّهها للمهتدين الجدد ولكل محبٍّ للتعرّف على الإسلام.',
      'With his brother Mohammad he founded a WhatsApp group for new Muslims and anyone wishing to learn about Islam.'),
  _Station(
      Icons.menu_book_outlined,
      'المكتبة الرقمية',
      'The digital library',
      'جمعٌ للعلم النافع',
      'Gathering beneficial knowledge',
      'أنشأ مكتبة رقمية جمع فيها الكتب النافعة للمسلمين الجدد، إلى جانب كتاباته وملاحظاته.',
      'He built a digital library of beneficial books for new Muslims, alongside his own writings and notes.'),
  _Station(
      Icons.search,
      'الحلم',
      'The dream',
      'باحثٌ ذكيٌّ موثوق',
      'A trustworthy smart search',
      'طمح لباحث ذكي يستخلص الإجابة من المصادر الموثوقة فقط، بعد أن لمس قصور الأدوات المتاحة.',
      'He dreamed of a smart search that draws answers only from trusted sources, having seen the limits of available tools.'),
  _Station(
      Icons.nightlight_round,
      'الوداع',
      'Farewell',
      'رحيلٌ عن ٢١ عامًا',
      'Departing at 21',
      'توفّاه الله قبل أن يكتمل المشروع، عن عمرٍ ناهز الواحد والعشرين عامًا، رحمه الله.',
      'Allah took him before the project was complete, at around twenty-one years of age, may Allah have mercy on him.',
      isFinal: true),
  _Station(
      Icons.spa_outlined,
      'إكمال المشوار',
      'Continuing the journey',
      'صدقةٌ جارية',
      'An ongoing charity',
      'نكمل اليوم ما بدأه علي — هذه الشبكة صدقة جارية عنه، نسأل الله أن يتقبّلها ويرفع درجاته.',
      'Today we continue what Ali began — this network is an ongoing charity for him; we ask Allah to accept it and raise his rank.',
      accent: true),
];

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
          const SizedBox(height: 20),
          for (var i = 0; i < _stations.length; i++)
            _stationRow(context, _stations[i], i == _stations.length - 1),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.sage100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  tr('«إِذَا مَاتَ ابْنُ آدَمَ انْقَطَعَ عَنْهُ عَمَلُهُ إِلَّا مِنْ ثَلَاثٍ: صَدَقَةٍ جَارِيَةٍ، أَوْ عِلْمٍ يُنْتَفَعُ بِهِ، أَوْ وَلَدٍ صَالِحٍ يَدْعُو لَهُ»',
                      'When the son of Adam dies, his deeds end except for three: an ongoing charity, knowledge that is benefited from, or a righteous child who prays for him.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, height: 1.9, fontFamily: 'Amiri'),
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

  Widget _stationRow(BuildContext context, _Station s, bool isLast) {
    final circleColor =
        (s.isFinal || s.accent) ? AppColors.pine800 : AppColors.sage600;
    final cardColor = s.accent
        ? AppColors.sage100
        : (s.isFinal ? AppColors.pearl100 : Theme.of(context).cardColor);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: circleColor, shape: BoxShape.circle),
                child: Icon(s.icon, size: 19, color: AppColors.pearl50),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                      width: 2,
                      color: AppColors.sage300.withValues(alpha: 0.7)),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.pearl200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr(s.phaseAr, s.phaseEn),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sage600)),
                  const SizedBox(height: 3),
                  Text(tr(s.titleAr, s.titleEn),
                      style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.pine800)),
                  const SizedBox(height: 5),
                  Text(tr(s.descAr, s.descEn),
                      style: const TextStyle(fontSize: 13, height: 1.6)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
