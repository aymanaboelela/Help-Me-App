import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Help Me'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'First aid in your pocket'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get navEmergency;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @homeGreetingTitle.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get homeGreetingTitle;

  /// No description provided for @homeGreetingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a condition for clear, calm first-aid steps.'**
  String get homeGreetingSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a condition'**
  String get searchHint;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No conditions match your search.'**
  String get searchNoResults;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryBreathing.
  ///
  /// In en, this message translates to:
  /// **'Airway & breathing'**
  String get categoryBreathing;

  /// No description provided for @categoryCardiac.
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get categoryCardiac;

  /// No description provided for @categoryBleeding.
  ///
  /// In en, this message translates to:
  /// **'Bleeding'**
  String get categoryBleeding;

  /// No description provided for @categoryTrauma.
  ///
  /// In en, this message translates to:
  /// **'Injuries'**
  String get categoryTrauma;

  /// No description provided for @categoryEnvironmental.
  ///
  /// In en, this message translates to:
  /// **'Environmental'**
  String get categoryEnvironmental;

  /// No description provided for @categoryMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get categoryMedical;

  /// No description provided for @sectionAllConditions.
  ///
  /// In en, this message translates to:
  /// **'All conditions'**
  String get sectionAllConditions;

  /// No description provided for @conditionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No conditions} =1{1 condition} other{{count} conditions}}'**
  String conditionsCount(int count);

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any condition to keep it here for quick access.'**
  String get favoritesEmptyBody;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFavorite;

  /// No description provided for @emergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency numbers'**
  String get emergencyTitle;

  /// No description provided for @emergencyCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical services'**
  String get emergencyCritical;

  /// No description provided for @emergencyOther.
  ///
  /// In en, this message translates to:
  /// **'Other services'**
  String get emergencyOther;

  /// No description provided for @emergencyNote.
  ///
  /// In en, this message translates to:
  /// **'Numbers apply to Egypt. Tap a number to dial.'**
  String get emergencyNote;

  /// No description provided for @callAction.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callAction;

  /// No description provided for @callAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Call ambulance'**
  String get callAmbulance;

  /// No description provided for @sosBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Life-threatening emergency?'**
  String get sosBannerTitle;

  /// No description provided for @sosBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Do not wait — call the ambulance now.'**
  String get sosBannerBody;

  /// No description provided for @sosCall.
  ///
  /// In en, this message translates to:
  /// **'Call 123'**
  String get sosCall;

  /// No description provided for @detailStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get detailStepsTitle;

  /// No description provided for @calloutDanger.
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get calloutDanger;

  /// No description provided for @calloutWarning.
  ///
  /// In en, this message translates to:
  /// **'Caution'**
  String get calloutWarning;

  /// No description provided for @calloutTip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get calloutTip;

  /// No description provided for @detailDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This guide does not replace professional medical care.'**
  String get detailDisclaimer;

  /// No description provided for @callError.
  ///
  /// In en, this message translates to:
  /// **'Could not start the call on this device.'**
  String get callError;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsRate.
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get settingsRate;

  /// No description provided for @settingsShare.
  ///
  /// In en, this message translates to:
  /// **'Share the app'**
  String get settingsShare;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About & notice'**
  String get settingsAbout;

  /// No description provided for @shareMessage.
  ///
  /// In en, this message translates to:
  /// **'Help Me — a free, offline first-aid guide in Arabic and English. Be ready for emergencies.'**
  String get shareMessage;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Help Me is a free, bilingual first-aid guide that works fully offline, so clear, calm emergency steps are always within reach.'**
  String get aboutBody;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical disclaimer'**
  String get aboutDisclaimerTitle;

  /// No description provided for @aboutCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get aboutCreditsTitle;

  /// No description provided for @aboutCredits.
  ///
  /// In en, this message translates to:
  /// **'Original concept by Ayman Abo El Ela. Rebuilt with a new design, bilingual content, and expanded first-aid topics.'**
  String get aboutCredits;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'Help Me provides general first-aid information for educational purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment. In any emergency, call your local emergency number immediately, and always seek the guidance of qualified health professionals.'**
  String get disclaimerBody;

  /// No description provided for @disclaimerAccept.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get disclaimerAccept;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @rateTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying Help Me?'**
  String get rateTitle;

  /// No description provided for @rateBody.
  ///
  /// In en, this message translates to:
  /// **'Your rating helps more people find first-aid help.'**
  String get rateBody;

  /// No description provided for @rateThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get rateThanks;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @stopListening.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopListening;

  /// No description provided for @focusMode.
  ///
  /// In en, this message translates to:
  /// **'Focus mode'**
  String get focusMode;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// No description provided for @metronomeTitle.
  ///
  /// In en, this message translates to:
  /// **'CPR rhythm'**
  String get metronomeTitle;

  /// No description provided for @metronomeStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get metronomeStart;

  /// No description provided for @metronomeStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get metronomeStop;

  /// No description provided for @metronomePush.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get metronomePush;

  /// No description provided for @metronomeRate.
  ///
  /// In en, this message translates to:
  /// **'100–120 / min'**
  String get metronomeRate;

  /// No description provided for @metronomeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap start, then push on the chest with each beat.'**
  String get metronomeHint;

  /// No description provided for @timerTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency timer'**
  String get timerTitle;

  /// No description provided for @timerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get timerStart;

  /// No description provided for @timerReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get timerReset;

  /// No description provided for @timerAlert.
  ///
  /// In en, this message translates to:
  /// **'5 minutes passed — consider calling emergency services.'**
  String get timerAlert;

  /// No description provided for @contactsTitle.
  ///
  /// In en, this message translates to:
  /// **'My emergency contacts'**
  String get contactsTitle;

  /// No description provided for @contactsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add a personal contact for one-tap calling in an emergency.'**
  String get contactsEmpty;

  /// No description provided for @contactAdd.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get contactAdd;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactName;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get contactNumber;

  /// No description provided for @contactFull.
  ///
  /// In en, this message translates to:
  /// **'You can save up to 5 contacts.'**
  String get contactFull;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @countryPick.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get countryPick;

  /// No description provided for @nearestHospital.
  ///
  /// In en, this message translates to:
  /// **'Nearest hospital'**
  String get nearestHospital;

  /// No description provided for @recentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recently viewed'**
  String get recentTitle;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @watchTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watchTitle;

  /// No description provided for @watchNote.
  ///
  /// In en, this message translates to:
  /// **'Opens in YouTube. Published by recognised first-aid and health organisations.'**
  String get watchNote;

  /// No description provided for @videoNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'Preview needs internet'**
  String get videoNeedsInternet;

  /// No description provided for @videoOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the video on this device.'**
  String get videoOpenError;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Image & video credits'**
  String get creditsTitle;

  /// No description provided for @creditsIllustrationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Step illustrations'**
  String get creditsIllustrationsTitle;

  /// No description provided for @creditsIllustrationsBody.
  ///
  /// In en, this message translates to:
  /// **'Every step drawing was made for Help Me. No third-party artwork was used, so no outside copyright applies to any of them.'**
  String get creditsIllustrationsBody;

  /// No description provided for @creditsCategoryArtTitle.
  ///
  /// In en, this message translates to:
  /// **'Category artwork'**
  String get creditsCategoryArtTitle;

  /// No description provided for @creditsCategoryArtBody.
  ///
  /// In en, this message translates to:
  /// **'Category illustrations come from unDraw by Katerina Limpitsouni, recoloured to each category\'s accent. unDraw allows commercial use without attribution; it is credited here anyway.'**
  String get creditsCategoryArtBody;

  /// No description provided for @creditsVideosTitle.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get creditsVideosTitle;

  /// No description provided for @creditsVideosBody.
  ///
  /// In en, this message translates to:
  /// **'The app links to public videos on YouTube and does not host or copy them. Every video was checked against YouTube\'s public data before being added, so the channel shown here is the channel that published it.'**
  String get creditsVideosBody;

  /// No description provided for @creditsFontTitle.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get creditsFontTitle;

  /// No description provided for @creditsFontBody.
  ///
  /// In en, this message translates to:
  /// **'Cairo © The Cairo Project Authors, released under the SIL Open Font License 1.1.'**
  String get creditsFontBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
