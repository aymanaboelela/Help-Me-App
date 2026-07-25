// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ساعِدني';

  @override
  String get appTagline => 'الإسعافات الأولية في جيبك';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navEmergency => 'الطوارئ';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get homeGreetingTitle => 'ماذا حدث؟';

  @override
  String get homeGreetingSubtitle =>
      'اختر الحالة لتحصل على خطوات إسعاف واضحة وهادئة.';

  @override
  String get searchHint => 'ابحث عن حالة';

  @override
  String get searchNoResults => 'لا توجد حالات مطابقة لبحثك.';

  @override
  String get categoryAll => 'الكل';

  @override
  String get categoryBreathing => 'التنفس ومجرى الهواء';

  @override
  String get categoryCardiac => 'القلب';

  @override
  String get categoryBleeding => 'النزيف';

  @override
  String get categoryTrauma => 'الإصابات';

  @override
  String get categoryEnvironmental => 'البيئية';

  @override
  String get categoryMedical => 'طبية';

  @override
  String get sectionAllConditions => 'كل الحالات';

  @override
  String conditionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حالة',
      many: '$count حالة',
      few: '$count حالات',
      two: 'حالتان',
      one: 'حالة واحدة',
      zero: 'لا توجد حالات',
    );
    return '$_temp0';
  }

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get favoritesEmptyTitle => 'لا توجد حالات مفضلة بعد';

  @override
  String get favoritesEmptyBody =>
      'اضغط على القلب في أي حالة لحفظها هنا للوصول السريع.';

  @override
  String get addFavorite => 'أضف إلى المفضلة';

  @override
  String get removeFavorite => 'أزل من المفضلة';

  @override
  String get emergencyTitle => 'أرقام الطوارئ';

  @override
  String get emergencyCritical => 'الخدمات الأهم';

  @override
  String get emergencyOther => 'خدمات أخرى';

  @override
  String get emergencyNote => 'الأرقام خاصة بمصر. اضغط على الرقم للاتصال.';

  @override
  String get callAction => 'اتصال';

  @override
  String get callAmbulance => 'اتصل بالإسعاف';

  @override
  String get sosBannerTitle => 'حالة تهدد الحياة؟';

  @override
  String get sosBannerBody => 'لا تنتظر — اتصل بالإسعاف الآن.';

  @override
  String get sosCall => 'اتصل بـ 123';

  @override
  String get detailStepsTitle => 'الخطوات';

  @override
  String get calloutDanger => 'خطر';

  @override
  String get calloutWarning => 'تحذير';

  @override
  String get calloutTip => 'نصيحة';

  @override
  String get detailDisclaimer =>
      'هذا الدليل لا يُغني عن الرعاية الطبية المتخصصة.';

  @override
  String get callError => 'تعذّر بدء الاتصال على هذا الجهاز.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get themeSystem => 'تلقائي';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get settingsRate => 'قيّم التطبيق';

  @override
  String get settingsShare => 'شارك التطبيق';

  @override
  String get settingsAbout => 'حول التطبيق والتنبيه';

  @override
  String get shareMessage =>
      'ساعِدني — دليل مجاني للإسعافات الأولية بالعربية والإنجليزية يعمل دون إنترنت. كن مستعدًا للطوارئ.';

  @override
  String get aboutTitle => 'حول التطبيق';

  @override
  String get aboutBody =>
      'ساعِدني دليل مجاني للإسعافات الأولية بلغتين يعمل دون إنترنت بالكامل، حتى تكون خطوات الطوارئ الواضحة والهادئة في متناول يدك دائمًا.';

  @override
  String get aboutVersion => 'الإصدار';

  @override
  String get aboutDisclaimerTitle => 'تنبيه طبي';

  @override
  String get aboutCreditsTitle => 'المساهمون';

  @override
  String get aboutCredits =>
      'الفكرة الأصلية لأيمن أبو العلا. أُعيد بناء التطبيق بتصميم جديد ومحتوى بلغتين وحالات إسعاف موسّعة.';

  @override
  String get disclaimerTitle => 'قبل أن تبدأ';

  @override
  String get disclaimerBody =>
      'يقدّم تطبيق ساعِدني معلومات عامة عن الإسعافات الأولية لأغراض تعليمية فقط، وهو لا يُغني عن الاستشارة أو التشخيص أو العلاج الطبي المتخصص. في أي حالة طارئة اتصل برقم الطوارئ فورًا، واحرص دائمًا على استشارة مختصي الرعاية الصحية المؤهلين.';

  @override
  String get disclaimerAccept => 'فهمت';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get rateTitle => 'يعجبك تطبيق ساعِدني؟';

  @override
  String get rateBody =>
      'تقييمك يساعد المزيد من الناس على إيجاد الإسعافات الأولية.';

  @override
  String get rateThanks => 'شكرًا لتقييمك!';

  @override
  String get listen => 'استمع';

  @override
  String get stopListening => 'إيقاف';

  @override
  String get focusMode => 'وضع التركيز';

  @override
  String stepOf(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get metronomeTitle => 'إيقاع الإنعاش';

  @override
  String get metronomeStart => 'ابدأ';

  @override
  String get metronomeStop => 'إيقاف';

  @override
  String get metronomePush => 'اضغط';

  @override
  String get metronomeRate => '100–120 / دقيقة';

  @override
  String get metronomeHint => 'اضغط ابدأ، ثم اضغط على الصدر مع كل نبضة.';

  @override
  String get timerTitle => 'مؤقّت الطوارئ';

  @override
  String get timerStart => 'ابدأ';

  @override
  String get timerReset => 'تصفير';

  @override
  String get timerAlert => 'مرّت 5 دقائق — فكّر في الاتصال بخدمات الطوارئ.';

  @override
  String get contactsTitle => 'جهات اتصال الطوارئ';

  @override
  String get contactsEmpty =>
      'أضف جهة اتصال شخصية للاتصال بضغطة واحدة وقت الطوارئ.';

  @override
  String get contactAdd => 'أضف جهة اتصال';

  @override
  String get contactName => 'الاسم';

  @override
  String get contactNumber => 'الرقم';

  @override
  String get contactFull => 'يمكنك حفظ حتى 5 جهات اتصال.';

  @override
  String get countryLabel => 'الدولة';

  @override
  String get countryPick => 'اختر الدولة';

  @override
  String get nearestHospital => 'أقرب مستشفى';

  @override
  String get recentTitle => 'شوهدت مؤخرًا';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonAdd => 'إضافة';

  @override
  String get commonDelete => 'حذف';

  @override
  String get watchTitle => 'شاهد';

  @override
  String get watchNote => 'يفتح في يوتيوب. من جهات إسعاف وصحة معترف بها.';

  @override
  String get videoNeedsInternet => 'المعاينة تحتاج إنترنت';

  @override
  String get videoOpenError => 'تعذّر فتح الفيديو على هذا الجهاز.';

  @override
  String get creditsTitle => 'مصادر الصور والفيديو';

  @override
  String get creditsIllustrationsTitle => 'رسومات الخطوات';

  @override
  String get creditsIllustrationsBody =>
      'كل رسمة خطوة اتعملت خصيصًا لتطبيق ساعِدني. مفيش أي عمل فني لطرف تاني، وبالتالي مفيش حقوق نشر خارجية على أي منها.';

  @override
  String get creditsCategoryArtTitle => 'رسومات الفئات';

  @override
  String get creditsCategoryArtBody =>
      'رسومات الفئات من unDraw لكاترينا ليمبيتسوني، معاد تلوينها بلون كل فئة. رخصة unDraw تسمح بالاستخدام التجاري بدون نسب، ومذكورة هنا على أي حال.';

  @override
  String get creditsVideosTitle => 'الفيديوهات';

  @override
  String get creditsVideosBody =>
      'التطبيق بيوصّل لفيديوهات عامة على يوتيوب ولا يستضيفها ولا ينسخها. كل فيديو اتأكدنا منه من بيانات يوتيوب العامة قبل إضافته، فالقناة الظاهرة هنا هي القناة اللي نشرته فعلًا.';

  @override
  String get creditsFontTitle => 'الخط';

  @override
  String get creditsFontBody =>
      'خط Cairo © مؤلفو مشروع Cairo، منشور برخصة SIL Open Font License 1.1.';
}
