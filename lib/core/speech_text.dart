/// Rewrites written first-aid copy into something a phone's speech engine can
/// actually say out loud.
///
/// The steps are written to be read with the eye, and a surprising amount of
/// that survives the trip to the ear badly. `(123)` is spoken as "one hundred
/// and twenty-three" instead of an emergency number. The English gloss in
/// `الوجه (Face)` makes an Arabic voice spell out Latin letters one at a time.
/// `5 سم` comes out as the word for poison rather than centimetres. Every rule
/// below exists because of one of those.
library;

const String _arabicComma = '،';

/// Unit abbreviations, longest first so the alternation matches greedily.
const Map<String, String> _arabicUnits = <String, String>{
  'كجم': 'كيلوجرام',
  'كغم': 'كيلوجرام',
  'كغ': 'كيلوجرام',
  'سم': 'سنتيمتر',
  'مم': 'مليمتر',
  'جم': 'جرام',
  'مل': 'مليلتر',
};

const Map<String, String> _englishUnits = <String, String>{
  'cm': 'centimetres',
  'mm': 'millimetres',
  'ml': 'millilitres',
  'kg': 'kilograms',
};

/// Matches a unit only when a number comes right before it. Bare `مل` is an
/// ordinary Arabic word; `5 مل` is millilitres. The trailing lookahead stands
/// in for `\b`, which only understands ASCII.
final RegExp _arabicUnitPattern = RegExp(
  '(?<=[0-9٠-٩])\\s*(${_arabicUnits.keys.join('|')})(?![\\u0600-\\u06FF])',
);

final RegExp _englishUnitPattern = RegExp(
  '(?<=[0-9])\\s*(${_englishUnits.keys.join('|')})\\b',
  caseSensitive: false,
);

/// A parenthesised group with no nesting — every bracket in the corpus is flat.
final RegExp _parenthetical = RegExp(r'\s*\(([^()]*)\)');

/// Three or more digits in brackets. In this corpus that is always an emergency
/// number, and emergency numbers must be read digit by digit. Bare numbers are
/// left alone on purpose: "100 إلى 120 ضغطة" is a count, not a phone number.
final RegExp _bracketedNumber = RegExp(r'\(\s*([0-9]{3,6})\s*\)');

final RegExp _latin = RegExp(r'[A-Za-z]');
final RegExp _arabicLetters = RegExp(r'[؀-ۿ]');

/// A dash sitting between two numbers is a range, not a pause.
final RegExp _numericRange = RegExp(
  r'(?<=[0-9٠-٩])\s*[‒–—−-]\s*(?=[0-9٠-٩])',
);

final RegExp _remainingDashes = RegExp(r'\s*[‒–—−]\s*');
final RegExp _quotes = RegExp('["“”„«»]');
final RegExp _spaceBeforePunctuation = RegExp(r'\s+([،,.؛;:!؟?])');
final RegExp _repeatedSeparators = RegExp(r'([،,])(\s*[،,])+');
final RegExp _whitespace = RegExp(r'\s+');
final RegExp _danglingPunctuation = RegExp(r'^[\s،,.:؛;]+');

/// Returns [text] rewritten for the speech engine of [languageCode].
///
/// Safe to call on any string; text with nothing to fix comes back unchanged
/// apart from whitespace tidying.
String speakable(String text, String languageCode) {
  final bool arabic = languageCode == 'ar';
  String out = _spellOutEmergencyNumbers(text, arabic: arabic);
  out = _dropForeignGlosses(out, arabic: arabic);
  out = _expandUnits(out, arabic: arabic);
  out = _softenPunctuation(out, arabic: arabic);
  return _tidy(out);
}

/// `(123)` → `1، 2، 3`, so the engine reads it the way you would dial it.
String _spellOutEmergencyNumbers(String text, {required bool arabic}) {
  final String separator = arabic ? '$_arabicComma ' : ', ';
  return text.replaceAllMapped(
    _bracketedNumber,
    (Match m) => ' ${m[1]!.split('').join(separator)}',
  );
}

/// Removes the other script's gloss: `الوجه (Face)` → `الوجه`.
///
/// The bracketed term is always a translation of the words right before it, so
/// dropping it costs no meaning — and saves an Arabic voice from spelling
/// "F-A-C-E" letter by letter.
String _dropForeignGlosses(String text, {required bool arabic}) {
  return text.replaceAllMapped(_parenthetical, (Match m) {
    final String inner = m[1]!;
    final bool hasLatin = _latin.hasMatch(inner);
    final bool hasArabic = _arabicLetters.hasMatch(inner);
    if (arabic && hasLatin && !hasArabic) return '';
    if (!arabic && hasArabic && !hasLatin) return '';
    return m[0]!;
  });
}

String _expandUnits(String text, {required bool arabic}) {
  final RegExp pattern = arabic ? _arabicUnitPattern : _englishUnitPattern;
  final Map<String, String> units = arabic ? _arabicUnits : _englishUnits;
  return text.replaceAllMapped(pattern, (Match m) {
    final String unit = arabic ? m[1]! : m[1]!.toLowerCase();
    return ' ${units[unit] ?? m[1]!}';
  });
}

String _softenPunctuation(String text, {required bool arabic}) {
  final String comma = arabic ? _arabicComma : ',';
  return text
      .replaceAll(_numericRange, arabic ? ' إلى ' : ' to ')
      .replaceAll(_remainingDashes, '$comma ')
      .replaceAll(_quotes, '')
      .replaceAll('…', '.');
}

String _tidy(String text) {
  return text
      .replaceAll(_whitespace, ' ')
      .replaceAllMapped(_spaceBeforePunctuation, (Match m) => m[1]!)
      .replaceAllMapped(_repeatedSeparators, (Match m) => m[1]!)
      .replaceFirst(_danglingPunctuation, '')
      .trim();
}
