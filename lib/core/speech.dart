import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Reads first-aid steps aloud in the language the app is currently in.
///
/// The naive version — `setLanguage('ar-SA')` — silently falls back to English
/// on any device that does not have that exact locale installed, which is most
/// of them: Egyptian phones commonly ship `ar-EG` or a bare `ar`. So each
/// language gets a chain of candidates and the first one the device actually
/// has wins. If none of them do, [speak] reports it rather than reading Arabic
/// text with an English voice, which is unintelligible.
class Speech {
  Speech([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  String? _configuredFor;
  bool _iosConfigured = false;

  /// Ordered by how likely an Egyptian or Gulf device is to have it.
  static const Map<String, List<String>> _candidates = <String, List<String>>{
    'ar': <String>['ar-EG', 'ar-SA', 'ar-AE', 'ar'],
    'en': <String>['en-US', 'en-GB', 'en'],
  };

  void onComplete(VoidCallback callback) {
    _tts.setCompletionHandler(callback);
    _tts.setCancelHandler(callback);
  }

  Future<void> _configureIos() async {
    if (_iosConfigured || kIsWeb || !Platform.isIOS) return;
    // Without a shared audio session iOS refuses to speak while the phone is on
    // silent, which is exactly when someone is reading steps in a hospital.
    await _tts.setSharedInstance(true);
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      <IosTextToSpeechAudioCategoryOptions>[
        IosTextToSpeechAudioCategoryOptions.duckOthers,
      ],
    );
    _iosConfigured = true;
  }

  /// Picks the best voice for [locale]. Returns false when the device has no
  /// voice for that language at all.
  Future<bool> _selectLanguage(Locale locale) async {
    final String code = locale.languageCode;
    if (_configuredFor == code) return true;

    for (final String candidate in _candidates[code] ?? <String>[code]) {
      bool available = false;
      try {
        available = await _tts.isLanguageAvailable(candidate) == true;
      } catch (_) {
        available = false;
      }
      if (!available) continue;
      await _tts.setLanguage(candidate);
      _configuredFor = code;
      return true;
    }
    return false;
  }

  /// Speaks [text] in [locale]. Returns false if no voice is installed for it.
  Future<bool> speak(String text, Locale locale) async {
    await _configureIos();
    if (!await _selectLanguage(locale)) return false;
    // Arabic voices run noticeably faster than English ones at the same rate,
    // and these steps are read by someone under stress.
    await _tts.setSpeechRate(locale.languageCode == 'ar' ? 0.45 : 0.5);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
    return true;
  }

  Future<void> stop() => _tts.stop();
}
