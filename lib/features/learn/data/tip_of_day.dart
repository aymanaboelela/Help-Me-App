import '../model/learn_content.dart';
import 'daily_tips.dart';

/// The tip for [date] — the same one on every device, with no server deciding it
/// and no history to store.
///
/// Keyed off the day of the year, so a tip cannot come back inside a month while
/// [kDailyTips] stays longer than a month. The day is worked out in UTC because
/// local arithmetic across a daylight-saving change can land a day either side.
DailyTip tipForDate(DateTime date) {
  final int dayOfYear = DateTime.utc(date.year, date.month, date.day)
      .difference(DateTime.utc(date.year))
      .inDays;
  return kDailyTips[dayOfYear % kDailyTips.length];
}
