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
}
