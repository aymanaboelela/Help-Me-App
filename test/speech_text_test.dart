import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/core/speech_text.dart';

void main() {
  group('speakable, Arabic', () {
    test('Given a bracketed emergency number, Then it is spelled out', () {
      expect(
        speakable('اتصل بالإسعاف (123) وأحضر جهاز صدمات.', 'ar'),
        'اتصل بالإسعاف 1، 2، 3 وأحضر جهاز صدمات.',
      );
    });

    test('Given a count, Then the digits are left intact', () {
      expect(
        speakable('بمعدل 100 إلى 120 ضغطة في الدقيقة.', 'ar'),
        'بمعدل 100 إلى 120 ضغطة في الدقيقة.',
      );
    });

    test('Given an English gloss in brackets, Then it is dropped', () {
      expect(
        speakable('الوجه (Face): اطلب من الشخص أن يبتسم.', 'ar'),
        'الوجه: اطلب من الشخص أن يبتسم.',
      );
      expect(
        speakable('إذا توفر جهاز الصدمات (AED) فشغّله.', 'ar'),
        'إذا توفر جهاز الصدمات فشغّله.',
      );
    });

    test('Given an Arabic parenthetical, Then it is kept', () {
      expect(
        speakable('الاختناق (الشرقة) خطر.', 'ar'),
        'الاختناق (الشرقة) خطر.',
      );
    });

    test('Given a unit abbreviation after a number, Then it is expanded', () {
      expect(
        speakable('بعمق حوالي 5 إلى 6 سم.', 'ar'),
        'بعمق حوالي 5 إلى 6 سنتيمتر.',
      );
      expect(speakable('أعطِ 10 مل.', 'ar'), 'أعطِ 10 مليلتر.');
    });

    test('Given a bare word that looks like a unit, Then it is left alone', () {
      expect(speakable('مل من الانتظار.', 'ar'), 'مل من الانتظار.');
    });

    test('Given an em dash, Then it becomes a pause', () {
      expect(
        speakable('اطلب من الشخص أن يبتسم — هل تدلّى أحد جانبي الوجه؟', 'ar'),
        'اطلب من الشخص أن يبتسم، هل تدلّى أحد جانبي الوجه؟',
      );
    });

    test('Given a dash between numbers, Then it becomes a range', () {
      expect(speakable('100–120 ضغطة', 'ar'), '100 إلى 120 ضغطة');
    });

    test('Given quotes, Then they are stripped', () {
      expect(speakable('اسأل: "هل تختنق؟"', 'ar'), 'اسأل: هل تختنق؟');
    });
  });

  group('speakable, English', () {
    test('Given an Arabic gloss in brackets, Then it is dropped', () {
      expect(speakable('The FAST test (اختبار فاست)', 'en'), 'The FAST test');
    });

    test('Given an acronym in brackets, Then it is kept', () {
      expect(speakable('Fetch a defibrillator (AED).', 'en'), 'Fetch a defibrillator (AED).');
    });

    test('Given a unit abbreviation after a number, Then it is expanded', () {
      expect(speakable('Press 5 to 6 cm deep.', 'en'), 'Press 5 to 6 centimetres deep.');
    });

    test('Given a bracketed emergency number, Then it is spelled out', () {
      expect(speakable('Call the ambulance (123).', 'en'), 'Call the ambulance 1, 2, 3.');
    });

    test('Given an em dash, Then it becomes a pause', () {
      expect(
        speakable('Push hard and fast — do not stop.', 'en'),
        'Push hard and fast, do not stop.',
      );
    });
  });

  test('Given text with nothing to fix, Then it is returned unchanged', () {
    const String text = 'اركع بجانب الشخص وضع كعب يدك في منتصف الصدر.';
    expect(speakable(text, 'ar'), text);
  });
}
