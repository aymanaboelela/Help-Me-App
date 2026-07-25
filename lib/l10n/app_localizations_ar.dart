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
  String get commonBack => 'رجوع';

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
  String get ttsUnavailable =>
      'الموبايل ده مفيهوش صوت مثبّت للغة التطبيق. تقدر تضيفه من إعدادات النطق في النظام.';

  @override
  String speechStep(int number) {
    return 'الخطوة $number.';
  }

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
  String get contactFromPhonebook => 'اختر من جهات الاتصال';

  @override
  String get contactManual => 'اكتب الرقم يدويًا';

  @override
  String get contactImportFailed => 'تعذّر فتح جهات الاتصال.';

  @override
  String get contactImportNoNumber =>
      'لا يوجد رقم هاتف محفوظ لجهة الاتصال هذه.';

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
  String get watchNote => 'بيشتغل جوه التطبيق. من جهات إسعاف وصحة معترف بها.';

  @override
  String get videoSourceNote =>
      'بيتشغّل من يوتيوب. «ساعِدني» لا يستضيف الفيديو ولا يعدّل فيه.';

  @override
  String get videoPlay => 'تشغيل';

  @override
  String get videoPause => 'إيقاف مؤقت';

  @override
  String get videoRestart => 'من الأول';

  @override
  String get videoBackTen => 'رجوع ١٠ ثوانٍ';

  @override
  String get videoForwardTen => 'تقديم ١٠ ثوانٍ';

  @override
  String get videoFullscreen => 'ملء الشاشة';

  @override
  String get videoNeedsInternet => 'المعاينة تحتاج إنترنت';

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

  @override
  String get navHealth => 'صحتي';

  @override
  String get navMore => 'المزيد';

  @override
  String get navLearn => 'تعلّم';

  @override
  String get learnTitle => 'تعلّم';

  @override
  String get learnIntro =>
      'دقيقة في اليوم. المعلومة اللي بتدوّر عليها وانت مرعوب مش معلومة عندك.';

  @override
  String learnStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم ورا بعض',
      few: '$count أيام ورا بعض',
      two: 'يومين ورا بعض',
      one: 'يوم واحد ورا بعض',
      zero: 'مافيش سلسلة لسه',
    );
    return '$_temp0';
  }

  @override
  String learnBestStreak(int count) {
    return 'أطول سلسلة: $count';
  }

  @override
  String get tipOfTheDay => 'نصيحة النهارده';

  @override
  String get tipReminder => 'تذكير يومي';

  @override
  String get tipReminderOff => 'مقفول';

  @override
  String get tipReminderTitle => 'نصيحة الإسعاف بتاعت النهارده';

  @override
  String get lessonsTitle => 'الدروس';

  @override
  String lessonsProgress(int done, int total) {
    return 'خلّصت $done من $total';
  }

  @override
  String get lessonStart => 'ابدأ';

  @override
  String get lessonReview => 'راجع';

  @override
  String get lessonNext => 'التالي';

  @override
  String get lessonCheckTitle => 'سؤال سريع';

  @override
  String get lessonDone => 'خلّصت الدرس';

  @override
  String lessonCardOf(int current, int total) {
    return '$current / $total';
  }

  @override
  String get learnOpenTopic => 'اقرا الخطوات كاملة';

  @override
  String get quizTitle => 'اختبار';

  @override
  String get quizSubtitle => 'تمن أسئلة، ومع كل إجابة سبب.';

  @override
  String get quizStart => 'ابدأ الاختبار';

  @override
  String quizQuestionOf(int current, int total) {
    return 'سؤال $current من $total';
  }

  @override
  String get quizCorrect => 'إجابة صحيحة';

  @override
  String get quizWrong => 'مش بالظبط';

  @override
  String get quizNext => 'السؤال اللي بعده';

  @override
  String get quizSeeResult => 'شوف النتيجة';

  @override
  String quizScore(int score, int total) {
    return '$score من $total';
  }

  @override
  String get quizAgain => 'جرّب تاني';

  @override
  String quizBest(int score) {
    return 'أحسن نتيجة: $score';
  }

  @override
  String get quizPerfect => 'كلها صح.';

  @override
  String get quizGood => 'كويس. راجع اللي غلطت فيه.';

  @override
  String get quizKeepGoing => 'تستاهل نظرة تانية على الدروس.';

  @override
  String get badgesTitle => 'الشارات';

  @override
  String get badgeLocked => 'لسه';

  @override
  String get healthTitle => 'صحتي';

  @override
  String get healthPrivacyNote =>
      'محفوظة على الموبايل ده بس ومشفّرة. مفيش أي حاجة بتترفع، ومش محتاج حساب.';

  @override
  String get healthCardsTitle => 'البطاقات الطبية';

  @override
  String get healthCardsSubtitle =>
      'فصيلة الدم والحساسية والأمراض — جاهزة للعرض';

  @override
  String get healthMedicinesTitle => 'خزنة الأدوية';

  @override
  String get healthMedicinesSubtitle =>
      'تنبيه قبل انتهاء الصلاحية ومواعيد الجرعات';

  @override
  String get healthKitTitle => 'شنطة الإسعاف';

  @override
  String get healthKitSubtitle => 'اللي المفروض يكون في البيت، بالعلامات';

  @override
  String healthExpiryAlert(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أدوية محتاجة انتباه',
      one: 'دوا محتاج انتباه',
    );
    return '$_temp0';
  }

  @override
  String get profilesEmptyTitle => 'مفيش بطاقات لسه';

  @override
  String get profilesEmptyBody =>
      'اعمل بطاقة ليك ولكل حد بتاخد باله منه. وقت الطوارئ تتعرض من غير ما حد يفتح أي حاجة تانية.';

  @override
  String get profileAdd => 'أضف بطاقة';

  @override
  String get profileEdit => 'تعديل البطاقة';

  @override
  String get profileName => 'الاسم';

  @override
  String get profileBloodType => 'فصيلة الدم';

  @override
  String get profileBirthDate => 'تاريخ الميلاد';

  @override
  String get profileAllergies => 'الحساسية';

  @override
  String get profileConditions => 'الأمراض المزمنة';

  @override
  String get profileMedications => 'الأدوية المنتظمة';

  @override
  String get profileDoctorName => 'الطبيب';

  @override
  String get profileDoctorPhone => 'رقم الطبيب';

  @override
  String get profileInsurance => 'التأمين';

  @override
  String get profileNotes => 'ملاحظات';

  @override
  String get profileListHint => 'كل واحدة في سطر';

  @override
  String get profileUnset => 'غير محدّد';

  @override
  String get profileFull => 'تقدر تحتفظ بحد أقصى 6 بطاقات.';

  @override
  String get profileNameRequired => 'البطاقة محتاجة اسم.';

  @override
  String get profileDeleteConfirm => 'تحذف البطاقة دي؟ مش هينفع ترجع فيها.';

  @override
  String profileAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سنة',
      few: '$count سنوات',
      two: 'سنتان',
      one: 'سنة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get emergencyCardOpen => 'بطاقة الطوارئ';

  @override
  String get emergencyCardHint =>
      'ارفع الموبايل. أي حد يقدر يقرا الكود بالكاميرا.';

  @override
  String get emergencyCardNone => 'مفيش مسجّل';

  @override
  String get medicinesEmptyTitle => 'الخزنة فاضية';

  @override
  String get medicinesEmptyBody =>
      'سجّل اللي موجود فعلًا في البيت. التطبيق هينبّهك قبل انتهاء الصلاحية بشهر — وده بالظبط سبب إن الشنطة بتخذل الناس وقت الحاجة.';

  @override
  String get medicineAdd => 'أضف دوا';

  @override
  String get medicineEdit => 'تعديل الدوا';

  @override
  String get medicineName => 'الاسم';

  @override
  String get medicineDose => 'الجرعة';

  @override
  String get medicineDoseHint => '٥٠٠ مجم، بخّة واحدة، ٥ مل…';

  @override
  String get medicineExpiry => 'تاريخ الانتهاء';

  @override
  String get medicineNoExpiry => 'بدون تاريخ انتهاء';

  @override
  String get medicineExpired => 'منتهي';

  @override
  String medicineExpiresInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'باقي $count يوم',
      few: 'باقي $count أيام',
      two: 'باقي يومين',
      one: 'باقي يوم',
      zero: 'بينتهي النهارده',
    );
    return '$_temp0';
  }

  @override
  String get medicineDoseTimes => 'تنبيهات الجرعات';

  @override
  String get medicineAddTime => 'أضف معاد';

  @override
  String get medicineNameRequired => 'الدوا محتاج اسم.';

  @override
  String get medicineDeleteConfirm => 'تشيل الدوا ده؟';

  @override
  String get medicineReminderTitle => 'معاد الجرعة';

  @override
  String get medicineExpiryReminderTitle => 'في دوا قرّب ينتهي';

  @override
  String get notificationsBlocked =>
      'الإشعارات مقفولة، فالتنبيهات مش هتظهر. تقدر تفتحها من إعدادات الموبايل.';

  @override
  String get settingsNotifications => 'التنبيهات';

  @override
  String get notifyDoses => 'مواعيد الدوا';

  @override
  String get notifyDosesHint => 'تنبيه في كل ميعاد جرعة بتحدده.';

  @override
  String get notifyExpiry => 'تنبيه قرب انتهاء الصلاحية';

  @override
  String get notifyExpiryHint => 'قبل انتهاء صلاحية أي دوا عندك بشهر.';

  @override
  String get notifyTipTime => 'ميعاد النصيحة';

  @override
  String get notifyTest => 'ابعت تنبيه تجربة';

  @override
  String get notifyTestBody => 'التنبيهات شغّالة على الموبايل ده.';

  @override
  String get notifyTestSent => 'اتبعت — بصّ على الإشعارات.';

  @override
  String kitProgress(int done, int total) {
    return '$done من $total جاهزة';
  }

  @override
  String get kitSectionDressings => 'الضمادات';

  @override
  String get kitSectionTools => 'الأدوات';

  @override
  String get kitSectionMedicines => 'الأدوية';

  @override
  String get kitSectionProtection => 'الحماية';

  @override
  String get kitSectionEssentials => 'أساسيات';

  @override
  String get kitPerishable => 'ليه صلاحية';

  @override
  String get kitPerishableNote =>
      'الحاجات اللي عليها علامة ساعة ليها تاريخ انتهاء. ضيفها في خزنة الأدوية والتطبيق هينبّهك قبل ما تنتهي.';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonDone => 'تم';

  @override
  String get commonNotSet => 'غير محدّد';

  @override
  String get nearbyTitle => 'قرب مني';

  @override
  String get nearbySubtitle =>
      'بيفتح تطبيق الخرائط بتاعك. «ساعِدني» لا يقرأ موقعك ولا يحفظه.';

  @override
  String get nearbyHospital => 'مستشفيات';

  @override
  String get nearbyPharmacy => 'صيدليات';

  @override
  String get nearbyBloodBank => 'بنوك دم';

  @override
  String get nearbyClinic => 'عيادات';

  @override
  String get nearbyFailed => 'تعذّر فتح تطبيق خرائط على هذا الجهاز.';

  @override
  String get donationTitle => 'التبرع بالدم';

  @override
  String get donationNoRecord => 'مفيش تبرع مسجّل';

  @override
  String get donationAddDate => 'سجّل تبرع';

  @override
  String get donationEligible => 'تقدر تتبرع';

  @override
  String donationWaitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'باقي $count يوم',
      few: 'باقي $count أيام',
      two: 'باقي يومين',
      one: 'باقي يوم',
    );
    return '$_temp0';
  }

  @override
  String donationLast(String date) {
    return 'آخر تبرع $date';
  }

  @override
  String get donationReadyTitle => 'تقدر تتبرع بالدم تاني';

  @override
  String get donationIntervalNote =>
      'المدة بين التبرع بالدم الكامل والتاني ٩٠ يوم.';
}
