import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'speech_text.dart';

/// Reads first-aid steps aloud in the language the app is currently in.
///
/// Three things separate this from a bare `setLanguage` call, and all three are
/// audible.
///
/// **The engine.** On Android the system default is often the manufacturer's
/// own — Samsung's Arabic voice in particular is close to unusable. Google's
/// engine is picked when it is installed.
///
/// **The voice.** Setting only a language leaves the engine free to grab its
/// first matching voice, which is usually the smallest and flattest one it has.
/// [_selectVoice] ranks every installed voice and picks deliberately: highest
/// quality first, Egyptian Arabic ahead of other dialects.
///
/// **Offline only.** The best-sounding voices on Android stream from Google's
/// servers, and they are skipped here regardless of how good they sound. A
/// first-aid app that goes silent when the signal drops has failed at the one
/// moment it exists for.
///
/// If the phone has no voice for the language at all, [speakLines] says so
/// rather than reading Arabic text with an English voice, which is worse than
/// silence.
class Speech {
  Speech([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  String? _configuredFor;
  bool _engineChecked = false;
  bool _iosConfigured = false;
  bool _stopped = false;

  /// Guards against an in-flight [speakLines] outliving a newer one.
  int _session = 0;

  static const String _googleEngine = 'com.google.android.tts';

  /// A beat between steps. Long enough to hear where one ends and the next
  /// begins, short enough not to feel like the app has hung.
  static const Duration _gap = Duration(milliseconds: 380);

  /// flutter_tts normalises rate across platforms: 0.5 is ordinary speed on
  /// both. Arabic voices clip their vowels at speed, so they get a touch under.
  static const double _arabicRate = 0.46;
  static const double _englishRate = 0.5;

  /// Ordered by how likely an Egyptian or Gulf device is to have it, which
  /// doubles as the dialect preference when ranking voices.
  static const Map<String, List<String>> _candidates = <String, List<String>>{
    'ar': <String>['ar-EG', 'ar-SA', 'ar-AE', 'ar'],
    'en': <String>['en-US', 'en-GB', 'en'],
  };

  /// Android reports `very_high`…`very_low`; iOS reports `premium`, `enhanced`
  /// or `default`. Both scales collapse onto this one.
  static const Map<String, int> _qualityScore = <String, int>{
    'premium': 500,
    'enhanced': 400,
    'very_high': 400,
    'high': 300,
    'normal': 200,
    'default': 200,
    'low': 100,
    'very_low': 0,
  };

  /// Speaks [lines] one at a time, pausing between them, calling [onLine] with
  /// the index of each line as it starts.
  ///
  /// Returns false — without speaking — when the phone has no voice for
  /// [locale]. Returns true once the last line finishes or [stop] interrupts.
  Future<bool> speakLines(
    List<String> lines,
    Locale locale, {
    ValueChanged<int>? onLine,
  }) async {
    if (!await _configure(locale)) return false;

    _stopped = false;
    final int session = ++_session;
    // Without this, speak() returns as soon as the utterance is queued and the
    // whole script would be fired off at once, on top of itself.
    await _invoke(() => _tts.awaitSpeakCompletion(true));

    for (int i = 0; i < lines.length; i++) {
      if (_stopped || session != _session) return true;
      final String line = speakable(lines[i], locale.languageCode);
      if (line.isEmpty) continue;
      onLine?.call(i);
      final bool spoke = await _invoke(() => _tts.speak(line));
      if (!spoke) return true;
      if (_stopped || session != _session) return true;
      await Future<void>.delayed(_gap);
    }
    return true;
  }

  Future<void> stop() async {
    _stopped = true;
    _session++;
    await _invoke(() => _tts.stop());
  }

  Future<bool> _configure(Locale locale) async {
    await _configureIos();
    final String code = locale.languageCode;
    if (_configuredFor == code) return true;

    await _preferGoogleEngine();
    final String? language = await _selectLanguage(code);
    if (language == null) return false;

    await _selectVoice(code);
    await _invoke(() => _tts.setSpeechRate(code == 'ar' ? _arabicRate : _englishRate));
    await _invoke(() => _tts.setPitch(1.0));
    await _invoke(() => _tts.setVolume(1.0));
    _configuredFor = code;
    return true;
  }

  Future<void> _configureIos() async {
    if (_iosConfigured || kIsWeb || !Platform.isIOS) return;
    _iosConfigured = true;
    // Without a shared audio session iOS refuses to speak while the phone is on
    // silent, which is exactly when someone is reading steps in a hospital.
    await _invoke(() => _tts.setSharedInstance(true));
    await _invoke(
      () => _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        <IosTextToSpeechAudioCategoryOptions>[
          IosTextToSpeechAudioCategoryOptions.duckOthers,
        ],
      ),
    );
  }

  Future<void> _preferGoogleEngine() async {
    if (_engineChecked || kIsWeb || !Platform.isAndroid) return;
    _engineChecked = true;
    final List<String> engines = await _stringList(() => _tts.getEngines);
    if (!engines.contains(_googleEngine)) return;
    final Object? current = await _read(() => _tts.getDefaultEngine);
    if (current == _googleEngine) return;
    await _invoke(() => _tts.setEngine(_googleEngine));
  }

  /// Returns the locale tag the device accepted, or null if it has none.
  ///
  /// Asking for `ar-SA` on a phone that ships `ar-EG` silently falls back to
  /// English on many engines, so each language gets a chain of candidates and
  /// the first one actually installed wins.
  Future<String?> _selectLanguage(String code) async {
    for (final String candidate in _candidates[code] ?? <String>[code]) {
      final Object? available = await _read(() => _tts.isLanguageAvailable(candidate));
      if (available != true) continue;
      await _invoke(() => _tts.setLanguage(candidate));
      return candidate;
    }
    return null;
  }

  Future<void> _selectVoice(String code) async {
    final Object? raw = await _read(() => _tts.getVoices);
    if (raw is! List) return;

    Map<String, String>? best;
    int bestScore = -1;
    for (final Object? entry in raw) {
      if (entry is! Map) continue;
      final Map<String, String> voice = <String, String>{
        for (final MapEntry<Object?, Object?> e in entry.entries)
          e.key.toString(): e.value?.toString() ?? '',
      };
      final int score = _voiceScore(voice, code);
      if (score > bestScore) {
        bestScore = score;
        best = voice;
      }
    }
    if (best == null) return;

    // Android matches on name + locale; iOS prefers the identifier when it has
    // one. Sending all three lets each platform use what it wants.
    final Map<String, String> selection = <String, String>{
      'name': best['name'] ?? '',
      'locale': best['locale'] ?? '',
    };
    final String identifier = best['identifier'] ?? '';
    if (identifier.isNotEmpty) selection['identifier'] = identifier;
    await _invoke(() => _tts.setVoice(selection));
  }

  /// Ranks one voice for [code]. Negative means "do not use this one".
  int _voiceScore(Map<String, String> voice, String code) {
    final String locale = (voice['locale'] ?? '').toLowerCase().replaceAll('_', '-');
    if (!locale.startsWith(code)) return -1;
    // Android flags the voices whose audio is synthesised server-side.
    if (voice['network_required'] == '1') return -1;

    final String name = (voice['name'] ?? '').toLowerCase();
    // Google names its streamed voices `…-network` even where the flag above
    // is unset, and they fall back to a robotic local voice when offline.
    if (name.contains('network')) return -1;

    int score = _qualityScore[(voice['quality'] ?? '').toLowerCase()] ?? 150;

    // Dialect, weighted below quality: a crisp ar-SA voice beats a muddy ar-EG
    // one, but between two equals the closer dialect wins.
    final List<String> order = _candidates[code] ?? const <String>[];
    final int rank = order.indexWhere((String l) => l.toLowerCase() == locale);
    if (rank >= 0) score += (order.length - rank) * 40;

    // Google tags Egyptian Arabic voices with the `arz` language subtag.
    if (code == 'ar' && name.contains('arz')) score += 100;

    return score;
  }

  /// Runs a platform call, reporting whether it got through. Speech is a
  /// convenience layered on top of the written steps — an engine that refuses
  /// should never take the screen down with it.
  Future<bool> _invoke(Future<dynamic> Function() call) async {
    try {
      await call();
      return true;
    } catch (error, stack) {
      debugPrint('Speech: $error\n$stack');
      return false;
    }
  }

  Future<Object?> _read(Future<dynamic> Function() call) async {
    try {
      return await call() as Object?;
    } catch (error) {
      debugPrint('Speech: $error');
      return null;
    }
  }

  Future<List<String>> _stringList(Future<dynamic> Function() call) async {
    final Object? value = await _read(call);
    if (value is! List) return const <String>[];
    return value.map((Object? e) => e.toString()).toList();
  }
}
