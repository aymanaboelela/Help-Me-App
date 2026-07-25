// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Help Me';

  @override
  String get appTagline => 'First aid in your pocket';

  @override
  String get navHome => 'Home';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navEmergency => 'Emergency';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeGreetingTitle => 'What happened?';

  @override
  String get homeGreetingSubtitle =>
      'Choose a condition for clear, calm first-aid steps.';

  @override
  String get searchHint => 'Search a condition';

  @override
  String get searchNoResults => 'No conditions match your search.';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryBreathing => 'Airway & breathing';

  @override
  String get categoryCardiac => 'Heart';

  @override
  String get categoryBleeding => 'Bleeding';

  @override
  String get categoryTrauma => 'Injuries';

  @override
  String get categoryEnvironmental => 'Environmental';

  @override
  String get categoryMedical => 'Medical';

  @override
  String get sectionAllConditions => 'All conditions';

  @override
  String conditionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conditions',
      one: '1 condition',
      zero: 'No conditions',
    );
    return '$_temp0';
  }

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptyBody =>
      'Tap the heart on any condition to keep it here for quick access.';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get emergencyTitle => 'Emergency numbers';

  @override
  String get emergencyCritical => 'Critical services';

  @override
  String get emergencyOther => 'Other services';

  @override
  String get emergencyNote => 'Numbers apply to Egypt. Tap a number to dial.';

  @override
  String get callAction => 'Call';

  @override
  String get callAmbulance => 'Call ambulance';

  @override
  String get sosBannerTitle => 'Life-threatening emergency?';

  @override
  String get sosBannerBody => 'Do not wait — call the ambulance now.';

  @override
  String get sosCall => 'Call 123';

  @override
  String get detailStepsTitle => 'Steps';

  @override
  String get calloutDanger => 'Danger';

  @override
  String get calloutWarning => 'Caution';

  @override
  String get calloutTip => 'Tip';

  @override
  String get detailDisclaimer =>
      'This guide does not replace professional medical care.';

  @override
  String get callError => 'Could not start the call on this device.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsRate => 'Rate the app';

  @override
  String get settingsShare => 'Share the app';

  @override
  String get settingsAbout => 'About & notice';

  @override
  String get shareMessage =>
      'Help Me — a free, offline first-aid guide in Arabic and English. Be ready for emergencies.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutBody =>
      'Help Me is a free, bilingual first-aid guide that works fully offline, so clear, calm emergency steps are always within reach.';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutDisclaimerTitle => 'Medical disclaimer';

  @override
  String get aboutCreditsTitle => 'Credits';

  @override
  String get aboutCredits =>
      'Original concept by Ayman Abo El Ela. Rebuilt with a new design, bilingual content, and expanded first-aid topics.';

  @override
  String get disclaimerTitle => 'Before you start';

  @override
  String get disclaimerBody =>
      'Help Me provides general first-aid information for educational purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment. In any emergency, call your local emergency number immediately, and always seek the guidance of qualified health professionals.';

  @override
  String get disclaimerAccept => 'I understand';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get rateTitle => 'Enjoying Help Me?';

  @override
  String get rateBody => 'Your rating helps more people find first-aid help.';

  @override
  String get rateThanks => 'Thank you for your feedback!';

  @override
  String get listen => 'Listen';

  @override
  String get stopListening => 'Stop';

  @override
  String get focusMode => 'Focus mode';

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get metronomeTitle => 'CPR rhythm';

  @override
  String get metronomeStart => 'Start';

  @override
  String get metronomeStop => 'Stop';

  @override
  String get metronomePush => 'Push';

  @override
  String get metronomeRate => '100–120 / min';

  @override
  String get metronomeHint =>
      'Tap start, then push on the chest with each beat.';

  @override
  String get timerTitle => 'Emergency timer';

  @override
  String get timerStart => 'Start';

  @override
  String get timerReset => 'Reset';

  @override
  String get timerAlert =>
      '5 minutes passed — consider calling emergency services.';

  @override
  String get contactsTitle => 'My emergency contacts';

  @override
  String get contactsEmpty =>
      'Add a personal contact for one-tap calling in an emergency.';

  @override
  String get contactAdd => 'Add contact';

  @override
  String get contactName => 'Name';

  @override
  String get contactNumber => 'Number';

  @override
  String get contactFull => 'You can save up to 5 contacts.';

  @override
  String get countryLabel => 'Country';

  @override
  String get countryPick => 'Select country';

  @override
  String get nearestHospital => 'Nearest hospital';

  @override
  String get recentTitle => 'Recently viewed';

  @override
  String get commonSave => 'Save';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonDelete => 'Delete';

  @override
  String get watchTitle => 'Watch';

  @override
  String get watchNote =>
      'Opens in YouTube. Published by recognised first-aid and health organisations.';

  @override
  String get videoNeedsInternet => 'Preview needs internet';

  @override
  String get videoOpenError => 'Could not open the video on this device.';

  @override
  String get creditsTitle => 'Image & video credits';

  @override
  String get creditsIllustrationsTitle => 'Step illustrations';

  @override
  String get creditsIllustrationsBody =>
      'Every step drawing was made for Help Me. No third-party artwork was used, so no outside copyright applies to any of them.';

  @override
  String get creditsCategoryArtTitle => 'Category artwork';

  @override
  String get creditsCategoryArtBody =>
      'Category illustrations come from unDraw by Katerina Limpitsouni, recoloured to each category\'s accent. unDraw allows commercial use without attribution; it is credited here anyway.';

  @override
  String get creditsVideosTitle => 'Videos';

  @override
  String get creditsVideosBody =>
      'The app links to public videos on YouTube and does not host or copy them. Every video was checked against YouTube\'s public data before being added, so the channel shown here is the channel that published it.';

  @override
  String get creditsFontTitle => 'Font';

  @override
  String get creditsFontBody =>
      'Cairo © The Cairo Project Authors, released under the SIL Open Font License 1.1.';
}
