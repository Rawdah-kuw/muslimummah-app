# Muslim Ummah — ملف التسليم الشامل (HANDOVER)

> **اقرأ هذا الملف كاملاً في بداية أي جلسة.** هو المرجع الوحيد لمتابعة العمل من **أي جهاز وأي محادثة جديدة** دون الرجوع لمحادثة سابقة. مُحدَّث حتى **2026-08-27**.
>
> ⚠️ هذا المستودع **عام (public)** — لا تُكتب فيه أسرار (كلمات مرور، مفاتيح، رموز). الأسرار مذكورة **مواضعها فقط** في القسم (٤).

---

## 0) نظرة عامة
- **التطبيق:** «أمة الإسلام / Muslim Ummah» — شبكة معرفة إسلامية: مكتبة كتب PDF، منهج فيديوهات، بحث ذكي، مجالس روضة، مواقيت صلاة، أذكار، سبحة، ورد اليوم، اقتباس اليوم، تنبيهات.
- **المالكة:** د. أنوار الكندري (`a.alkandari@ktech.edu.kw`) — غير مبرمجة؛ تحتاج خطوات نقر واضحة، وتنفيذ الكود كاملاً، وإرسال ملفات جاهزة.
- **الرسالة:** صدقة جارية عن **علي عبد العزيز الصدّيقي رحمه الله** (شقيق زوجها / صاحب القناة والكتب).
- **اللغتان:** العربية (الأساس) والإنجليزية، مع تبديل داخل التطبيق.

## 1) المشروعان (Codebases)
| | التطبيق (Flutter) | الموقع (Next.js) |
|---|---|---|
| المستودع | `github.com/Rawdah-kuw/muslimummah-app` فرع `main` | `github.com/Rawdah-kuw/muslim-ummah-network` فرع `main` |
| النسخة المحلية على جهاز المالكة | `~/Desktop/muslimummah-app` | `~/Desktop/muslim ummah/muslim-ummah-next` |
| النشر | **Codemagic** يبني iOS + Android (يدوي: Start new build) | **Vercel** ينشر تلقائياً عند git push إلى `main` → `muslimummah.app` |
| اللغة | Dart / Flutter **3.29.3** (لا تُغيّرها) | Next.js App Router (`app/[lang]/...`) |

> ملاحظة: مجلد `Desktop/muslim ummah/` القديم فيه نسخة React ويب سابقة — الموقع الحيّ هو `muslim-ummah-next` فقط.

## 2) الحسابات والمعرّفات (غير سرّية)
| العنصر | القيمة |
|---|---|
| الموقع | `https://muslimummah.app` (يستضيف كتب PDF `/books/...` و API `/api/ask` ولوحة `/[lang]/admin`) |
| iOS Bundle ID | `app.muslimummah` |
| iOS namespace | `app.muslimummah` |
| App Store Connect Apple ID | `6797816912` — اسم التطبيق **Muslim Ummah**، لغة أساسية العربية |
| Android applicationId | `app.muslimummah.twa` (نفس حزمة Google Play الحالية) |
| Codemagic App ID | `6a71c189be7fcf0b095ca8c4` |
| Codemagic Team ID | `6a71c069ebfde78d8c819575` (Personal Account) |
| Codemagic App Store integration | `CodemagicAppStore` |
| Codemagic env group | `ios_signing` (فيه `CERTIFICATE_PRIVATE_KEY`) + كي‑ستور أندرويد باسم `muslimummah_keystore` |
| Supabase URL | `https://buvsgjiqtaftyexjvyzw.supabase.co` |
| Supabase anon key (عام، آمن للعميل) | `sb_publishable_kRtGr0a2Tun1CQweltlxjw_qfQRQGTr` |
| Google Play — Developer account ID | `9146729163253851378` (Personal) · **App ID** `4975958435488470398` |
| بريد التواصل داخل التطبيق | `muslimsummah.app@gmail.com` |
| يوتيوب الشيخ علي | `https://www.youtube.com/@For_AliAlseddiqi` |
| واتساب روضة | `https://chat.whatsapp.com/J394CWBV7zw3aIexoulZAQ` |

## 3) البنية التقنية
- **Flutter 3.29.3 ثابتة** — لا تُحدَّث (نسخ أحدث كسرت iOS: خطأ `FlutterSceneDelegate`). Dart 3.7.2.
- **`pubspec.lock` مرفوع في المستودع** → البناء متكرّر وثابت. **لا تحذفه.** لتحديث حزمة: عدّل `pubspec.yaml` ثم `flutter pub get` وارفع `pubspec.lock`.
- **`pdfx` مثبّت `>=2.6.0 <2.10.0`** (نسخة 2.9.2) — لأن 2.10.0+ تستخدم `Matrix4.translateByDouble` غير الموجودة في vector_math المرفق مع 3.29.3.
- **الاعتماديات:** supabase_flutter, http, url_launcher, shared_preferences, webview_flutter, share_plus **^10.x** (استخدم `Share.share`/`Share.shareXFiles`، لا `SharePlus.instance`), path_provider, pdfx, flutter_local_notifications ^17.2.4, timezone, geolocator, sensors_plus, flutter_localizations. الخطوط: Tajawal + Amiri في `assets/fonts/`.
- **Flutter محلياً على جهاز المالكة:** مُثبّت في `~/flutter` (النسخة 3.29.3). للاستخدام: `export PATH="$HOME/flutter/bin:$PATH"`. (Intel Mac، بلا Homebrew، أدوات Xcode CLT فقط.)
- **بنية `lib/`:** main.dart (تهيئة + جدولة تنبيهات بعد runApp)، config.dart، app_state.dart (اللغة/tr)، theme.dart (AppColors)، models/models.dart، data/content.dart (ContentRepo)، widgets/ (root_nav, scene, common)، screens/ (home, library, book_detail, reader, curriculum, rawdah, prayer, adhkar, tasbih, notifications, quote, search, accounts, bookmarks, privacy, about, qibla[غير مربوطة])، services/ (prayer, notification, rawdah, ask, wird_image, quote_image, adhkar_image, lesson_image, schedule_image, prefs).
- **بيانات `assets/data/`:** books.json، curriculum.json (57 قائمة)، wird.json (44، مع أرقام آيات)، quotes.json (**97**)، adhkar.json (صباح 24 + مساء 22، **ثنائية اللغة كاملة** بمفاتيح ar/en/prefix/prefixEn/source/sourceEn/note/noteEn/count)، accounts.json.

## 4) الأسرار — أماكنها فقط (لا تُكتب قيمها هنا)
- **كي‑ستور أندرويد + كلمة مروره + Alias:** ملفات المالكة `~/Downloads/muslimummah-upload.keystore` و`muslimummah-upload-certificate.pem`؛ والقيم في ملف التسليم الأصلي عند المالكة (`~/Downloads/HANDOVER.md`). الكي‑ستور مرفوع في Codemagic باسم **`muslimummah_keystore`** (لا حاجة لإعادة رفعه).
- **توقيع iOS:** `CERTIFICATE_PRIVATE_KEY` في Codemagic env group `ios_signing` + integration `CodemagicAppStore`.
- **أسرار الموقع (Vercel env):** `SUPABASE_SERVICE_KEY` (يبدأ `sb_secret_…` — للكتابة في Supabase server-side)، `ADMIN_PASSWORD` (لوحة روضة — غيّرتها المالكة 2026-08-07، تعرفها)، `ANTHROPIC_API_KEY` (لتحليل الملصقات)، `TELEGRAM_*`.
- **دخول git (GitHub PAT):** محفوظ في **keychain** على جهاز المالكة (osxkeychain). على جهاز جديد: أول `git push` سيطلب Username = `Rawdah-kuw` وPassword = رمز PAT جديد (تنشئه من github.com/settings/tokens مع صلاحية **`repo`**؛ وأضف **`workflow`** لو أردت تعديل `.github/workflows/`).
- ⚠️ **أمان مفتوح:** رابط git لمستودع الموقع فيه رمز PAT مكتوب صريحاً — يُفضّل تدويره. وثغرة RLS في Supabase أُقفلت (العام للقراءة فقط).

## 5) قواعد المحتوى الديني (حرجة — لا تتجاوزها)
1. **لا تترجم أي نص ديني (آية/حديث/ذكر/ورد) من معرفتك.** خذه من مصدر موثوق واذكر التخريج.
2. **الآيات:** ترجمة **Sahih International** (تحقّق: `api.alquran.cloud/v1/ayah/{sura}:{aya}/en.sahih`).
3. **الأحاديث:** من `sunnah.com`. **الأذكار:** من «حصن المسلم».
4. **اقتباس اليوم:** من كتب الشيخ علي فقط. `verbatim` (حرفي، عربي+إنجليزي) و`adapted` (بتصرّف، عربي فقط، بوسم). أقوال العلماء المنقولة تُنسب لقائلها الحقيقي (`cited:true` + «مقتبَس من كتاب…»). المالكة ترفض أي نبرة سلبية.
5. **المالكة تراجع وتعتمد كل محتوى قبل النشر** — «المراجعة قبل النشر» مبدأ ثابت.
- كتب الشيخ الثلاثة في المكتبة: id **102** (الإسلام والعلم)، **9** (علم الحديث)، **101** (العشر الأوائل). نصوص DOCX نظيفة عند المالكة في `~/Desktop/Ali Alseddiqi Book/`.

## 6) ما أُنجز (النسخة الحالية `1.2.0+27` على GitHub — لم تُبنَ/تُنشر بعد)
منذ `+14`: تحسينات الاقتباس/الورد/الجدول · اسم إنجليزي «Muslim Ummah» على الجهاز · 12 اقتباس حديث (6 للشيخ + 6 علماء منسوبة) · تصحيح روابط فيديوهات علي (الفاتحة `6Uy7S27V2vA`، الصلاة الإبراهيمية `eoM8Z2kLEWs`، التكبيرات `tAPqFMsfy7Q`) · **إصلاح حرج (+21): تجمّد التطبيق عند تفعيل التنبيهات** (نُقلت الجدولة بعد runApp داخل try/catch) · **الكتاب الإنجليزي يفتح النسخة الإنجليزية** · **الصلوات: الضغط على صلاة ينقل عدّها التنازلي للأعلى** · **أرقام آيات السور في الأذكار** · **أذكار الصباح والمساء كاملة بالإنجليزية** · **مشاركة كل ذكر كصورة** (adhkar_image) · **الاقتباس بلغة التطبيق** (الإنجليزية تعرض فقط ما له نص إنجليزي) · نسبة أقوال العلماء القديمة لقائليها · **ضبط قياس صور المشاركة** (خط يملأ البطاقة، إطار داخلي كي لا يقصّه إنستغرام) · **تثبيت pdfx + pubspec.lock**.
- **الموقع (منشور):** مشاركة الورد عربي+إنجليزي معاً · قسم «اقتباس اليوم» + تحميله كصورة · **صفحة `/adhkar`** (صباح/مساء، ثنائية اللغة، تحميل كل ذكر كصورة) + رابط في القائمة · تحسين استخراج الملصقات (اليوم من اسمه المكتوب + التواريخ الهجرية).

## 7) الخطوة التالية / المهام المعلّقة
1. **بناء ورفع `1.2.0+27`** (البناء السابق فشل بسبب pdfx، أُصلح الآن):
   - **أندرويد:** Codemagic → Start new build → فرع `main` → ورك‑فلو **`android-googleplay`** → نزّل `.aab` → Play Console → Test and release → **Closed testing** → Create new release → ارفع الـ AAB → Start rollout.
   - **iOS:** Codemagic → **`ios-testflight`** → يرفع تلقائياً لـ App Store Connect → **TestFlight** → أضف للمختبِرين.
   - versionCode 27 أعلى من 15 المرفوع سابقاً ✅.
2. **الاختبار المغلق (Google Play):** الحساب شخصي جديد → يجب **١٢+ مختبِراً حقيقياً يفتحون التطبيق فعلاً ١٤ يوماً متواصلة** + نشر تحديثات أثناء الفترة، ثم Apply for production. قائمة المختبِرين: `~/Desktop/muslim ummah/testers.csv` (~27 إيميلاً).
3. **iOS:** التأكد أن التنبيهات تظهر بعد بناء 3.29.3.
4. **App Store Connect:** Test Information + توطين عربي + Submit for review.
5. **التحقّق على الجهاز** (لم أستطع المعاينة محلياً): أرقام الآيات، أطر/قياس صور المشاركة.
6. **الأذكار — الترجمة أُنجزت.** باقٍ اختياري: مراجعة/تحسين ملخّصات «بتصرّف»، لغات إضافية (أردو/فرنسي…)، سبحة صوتية (تحتاج plugin — مؤجّل)، بطاقات مرجعية من جداول Excel، القبلة (أُزيلت؛ تحتاج بوصلة دقيقة لو رجعت).

## 8) حالة توقيع أندرويد (مكتملة)
- **إعادة ضبط مفتاح الرفع: معتمَدة** (2026-08-10). مفتاح الرفع المسجّل في Play الآن SHA‑1 = **`0D:24:C4:FD:65:10:0A:B3:2C:FF:3C:BE:D5:C8:A6:1A:AA:CB:CA:75`** = مفتاحنا. أي AAB موقّع بـ `muslimummah-upload.keystore` يُقبل.
- الكي‑ستور مرفوع في Codemagic (`muslimummah_keystore`)، ومجلد `android/` مضبوط لـ 3.29.3 (Gradle 8.10.2 / AGP 8.7.3 / Kotlin 2.1.0 — لو أُعيد توليده، أعِد هذه النسخ).
- صفحة توقيع Play مخفية في القوائم: تُفتح عبر **Protected with Play → App signing** (عنصر «App integrity» يعرض لافتة «moved» فقط).

## 9) روضة (Rawdah) — لوحة الإدارة والبيانات
- الدروس في جدول **Supabase `lessons`** (حقول: title, teacher, gender[نساء/رجال], day[اسم يوم عربي], time, area, location, types[], lesson_date[YYYY-MM-DD], is_recurring, is_paused, is_published, channel_link, zoom_link…).
- **لوحة الإدارة على الموقع:** `muslimummah.app/ar/admin` (محميّة بـ `ADMIN_PASSWORD`)، تكتب عبر `app/api/rawdah/lessons` بمفتاح الخدمة server-side. تُفتح من الجوّال (أُضيف لها manifest خاص فأيقونة الشاشة الرئيسية تفتحها مباشرة).
- ميزات أُضيفت: زر **«دمج المكرّرات»** (يوحّد دروس نفس الداعية+اليوم+الوقت)، **رفع ملصقات ذكي** (يحدّث موضوع المجلس القائم بدل التكرار)، تحسين قراءة **التواريخ الهجرية**. الدروس الموضوعة خطأً تُصحَّح يدوياً (تعديل → اليوم).
- 2026-08-07: حُذفت كل الدروس المتكرّرة (107) لبداية نظيفة (نسخة احتياطية في `~/Downloads/rawdah-recurring-backup.json`)، وأُقفلت ثغرة RLS.

## 10) كيف تُكمل في جلسة جديدة (من أي جهاز)
1. `git clone https://github.com/Rawdah-kuw/muslimummah-app.git` (وللموقع `muslim-ummah-network`).
2. اقرأ هذا الملف (`HANDOVER.md`) كاملاً + ذاكرة Claude المحلية إن وُجدت.
3. أول `git push` سيطلب دخول GitHub (username `Rawdah-kuw` + رمز PAT).
4. للبناء: كل شيء عبر Codemagic (لا يحتاج Flutter محلياً). للتعديل والفحص: Flutter 3.29.3 (في `~/flutter` على جهاز المالكة، أو ثبّته: `git clone https://github.com/flutter/flutter.git -b 3.29.3 --depth 1 ~/flutter`).
5. بعد أي تعديل كود: ارفع النسخة `versionCode` في `pubspec.yaml` (+1) وادفع إلى `main`.
- ملف التسليم الأصلي المفصّل (بالأسرار) عند المالكة: `~/Downloads/HANDOVER.md`. ذاكرة Claude على جهازها: `~/.claude/projects/-Users-anwaaralkandari-Desktop-muslim-ummah/memory/`.

## 11) ملاحظات سلوكية مع المالكة
- غير تقنية → خطوات نقر واضحة، نفّذ الكود كاملاً، أرسل ملفات جاهزة، واشرح بالعربي.
- حسّاسة جداً لدقة النصوص الدينية ونسبتها — لا اجتهاد في الترجمة، ولا نبرة تُساء قراءتها.
- تفضّل الشكل الأنيق البسيط؛ خلفية اقتباس اليوم خضراء غامقة **#16302A** (لون اللوقو).
- **راجع قبل النشر دائماً.**
