import 'package:flutter/material.dart';
import '../app_state.dart';
import '../config.dart';
import '../widgets/common.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('سياسة الخصوصية', 'Privacy Policy'))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _h(tr('خصوصيتك', 'Your privacy')),
          _p(tr(
            'لا نجمع أي بيانات شخصية، ولا نطلب تسجيل حساب. لا نستخدم إعلانات ولا نتتبّعك.',
            'We do not collect any personal data and do not require an account. There are no ads and no tracking.',
          )),
          _h(tr('ما يُحفظ على جهازك', 'What is stored on your device')),
          _p(tr(
            'يُحفظ تقدّمك في المنهج واختيارك للّغة والوضع الليلي على جهازك فقط (تخزين محلي)، ولا يُرسل إلى أي خادم.',
            'Your curriculum progress, language choice, and dark-mode preference are saved only on your device (local storage) and are never sent to any server.',
          )),
          _h(tr('المحتوى الخارجي', 'External content')),
          _p(tr(
            'عند فتح كتاب أو مقطع، قد يتصل التطبيق بموقعنا muslimummah.app أو بخدمات مثل يوتيوب وإنستغرام لعرض المحتوى. تخضع تلك الخدمات لسياساتها الخاصة.',
            'When you open a book or a video, the app may connect to our site muslimummah.app or to services such as YouTube and Instagram to show the content. Those services have their own policies.',
          )),
          _h(tr('البحث الذكي', 'Smart search')),
          _p(tr(
            'يُرسَل نصّ سؤالك في «اسأل المكتبة» إلى خادمنا للإجابة عنه من نصوص الكتب فقط، ولا يُربط بهويتك.',
            'The text of your question in "Ask the Library" is sent to our server to be answered from the book texts only, and is not linked to your identity.',
          )),
          _h(tr('التواصل', 'Contact')),
          _p(tr('لأي استفسار حول الخصوصية:', 'For any privacy question:')),
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

  Widget _h(String t) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 6),
        child: Text(t,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      );

  Widget _p(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: const TextStyle(fontSize: 15, height: 1.8)),
      );
}
