import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/core/localized_text.dart';

void main() {
  group('LocalizedText', () {
    const LocalizedText text = LocalizedText(en: 'Hello', ar: 'مرحبا');

    test('Given ar locale, When resolve, Then returns Arabic', () {
      expect(text.resolve(const Locale('ar')), 'مرحبا');
    });

    test('Given en locale, When resolve, Then returns English', () {
      expect(text.resolve(const Locale('en')), 'Hello');
    });

    test('Given an unsupported locale, When resolve, Then falls back to English', () {
      expect(text.resolve(const Locale('fr')), 'Hello');
    });

    test('Given both variants filled, Then isComplete is true', () {
      expect(text.isComplete, isTrue);
    });

    test('Given an empty variant, Then isComplete is false', () {
      expect(const LocalizedText(en: 'Hi', ar: '  ').isComplete, isFalse);
    });

    test('Given equal content, Then equality and hashCode match', () {
      expect(text, const LocalizedText(en: 'Hello', ar: 'مرحبا'));
      expect(text.hashCode, const LocalizedText(en: 'Hello', ar: 'مرحبا').hashCode);
    });
  });
}
