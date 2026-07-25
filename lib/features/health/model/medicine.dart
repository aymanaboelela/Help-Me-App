import 'package:flutter/foundation.dart';

/// A medicine the household keeps, with when it runs out and when to take it.
///
/// This is the thing that earns the app a place on a home screen: an expiry date
/// nobody tracks is the reason a first-aid kit fails on the day it is needed.
@immutable
class Medicine {
  const Medicine({
    required this.id,
    required this.name,
    this.dose = '',
    this.expiry,
    this.dailyTimes = const <int>[],
    this.forProfileId,
  });

  final String id;
  final String name;

  /// Free text — "500 mg", "5 ml", "one puff". Deliberately not parsed.
  final String dose;

  final DateTime? expiry;

  /// Times of day for a dose reminder, as minutes after midnight.
  final List<int> dailyTimes;

  /// Which family member this belongs to, if any.
  final String? forProfileId;

  /// Days until expiry; negative once expired, null when no date is set.
  int? get daysUntilExpiry {
    final DateTime? end = expiry;
    if (end == null) return null;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return DateTime(end.year, end.month, end.day).difference(today).inDays;
  }

  bool get isExpired => (daysUntilExpiry ?? 1) < 0;

  /// Close enough to expiry to be worth replacing before you need it.
  bool get expiresSoon {
    final int? days = daysUntilExpiry;
    return days != null && days >= 0 && days <= expiryWarningDays;
  }

  static const int expiryWarningDays = 30;

  Medicine copyWith({
    String? name,
    String? dose,
    DateTime? expiry,
    List<int>? dailyTimes,
    String? forProfileId,
  }) {
    return Medicine(
      id: id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      expiry: expiry ?? this.expiry,
      dailyTimes: dailyTimes ?? this.dailyTimes,
      forProfileId: forProfileId ?? this.forProfileId,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'dose': dose,
        'expiry': expiry?.toIso8601String(),
        'dailyTimes': dailyTimes,
        'forProfileId': forProfileId,
      };

  static Medicine fromJson(Map<String, dynamic> json) => Medicine(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        dose: json['dose'] as String? ?? '',
        expiry: json['expiry'] is String
            ? DateTime.tryParse(json['expiry'] as String)
            : null,
        dailyTimes: json['dailyTimes'] is List
            ? (json['dailyTimes'] as List<Object?>)
                .whereType<num>()
                .map((num n) => n.toInt())
                .where((int m) => m >= 0 && m < 1440)
                .toList()
            : const <int>[],
        forProfileId: json['forProfileId'] as String?,
      );
}
