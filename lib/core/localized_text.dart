import 'package:flutter/widgets.dart';

/// A tiny value object holding one string in both supported languages.
///
/// Long-form medical content lives in typed Dart data (not `.arb` files, which
/// are better suited to short UI labels), so every piece of content carries its
/// Arabic and English variants and resolves the right one for the active
/// [Locale] at render time.
@immutable
class LocalizedText {
  const LocalizedText({required this.en, required this.ar});

  final String en;
  final String ar;

  /// Returns the Arabic string for the `ar` locale and English otherwise.
  String resolve(Locale locale) => locale.languageCode == 'ar' ? ar : en;

  /// Whether both language variants are non-empty — used by data-integrity tests.
  bool get isComplete => en.trim().isNotEmpty && ar.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizedText && other.en == en && other.ar == ar;

  @override
  int get hashCode => Object.hash(en, ar);

  @override
  String toString() => 'LocalizedText(en: "$en", ar: "$ar")';
}
