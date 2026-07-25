import 'package:flutter/foundation.dart';

/// The blood groups, in the order people expect to see them listed.
enum BloodType {
  unknown('—'),
  oNeg('O−'),
  oPos('O+'),
  aNeg('A−'),
  aPos('A+'),
  bNeg('B−'),
  bPos('B+'),
  abNeg('AB−'),
  abPos('AB+');

  const BloodType(this.label);

  /// Written the same way in both languages, so it needs no translation.
  final String label;

  static BloodType fromName(String? name) => BloodType.values.firstWhere(
        (BloodType t) => t.name == name,
        orElse: () => BloodType.unknown,
      );
}

/// What a paramedic would want to know about one person, in the ninety seconds
/// they have to find it out.
///
/// Held only on this device, encrypted at rest. Every field is optional: a card
/// with nothing but a blood type is still worth having.
@immutable
class MedicalProfile {
  const MedicalProfile({
    required this.id,
    required this.name,
    this.bloodType = BloodType.unknown,
    this.birthDate,
    this.allergies = const <String>[],
    this.conditions = const <String>[],
    this.medications = const <String>[],
    this.doctorName = '',
    this.doctorPhone = '',
    this.insurance = '',
    this.notes = '',
    this.lastDonation,
  });

  final String id;
  final String name;
  final BloodType bloodType;
  final DateTime? birthDate;

  /// The line that matters most in an emergency, so it is stored first-class
  /// rather than buried in free text.
  final List<String> allergies;
  final List<String> conditions;
  final List<String> medications;

  final String doctorName;
  final String doctorPhone;
  final String insurance;
  final String notes;

  /// Last blood donation, used for the eligibility countdown.
  final DateTime? lastDonation;

  int? get age {
    final DateTime? born = birthDate;
    if (born == null) return null;
    final DateTime now = DateTime.now();
    int years = now.year - born.year;
    if (now.month < born.month || (now.month == born.month && now.day < born.day)) {
      years--;
    }
    return years < 0 ? null : years;
  }

  MedicalProfile copyWith({
    String? name,
    BloodType? bloodType,
    DateTime? birthDate,
    List<String>? allergies,
    List<String>? conditions,
    List<String>? medications,
    String? doctorName,
    String? doctorPhone,
    String? insurance,
    String? notes,
    DateTime? lastDonation,
  }) {
    return MedicalProfile(
      id: id,
      name: name ?? this.name,
      bloodType: bloodType ?? this.bloodType,
      birthDate: birthDate ?? this.birthDate,
      allergies: allergies ?? this.allergies,
      conditions: conditions ?? this.conditions,
      medications: medications ?? this.medications,
      doctorName: doctorName ?? this.doctorName,
      doctorPhone: doctorPhone ?? this.doctorPhone,
      insurance: insurance ?? this.insurance,
      notes: notes ?? this.notes,
      lastDonation: lastDonation ?? this.lastDonation,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'bloodType': bloodType.name,
        'birthDate': birthDate?.toIso8601String(),
        'allergies': allergies,
        'conditions': conditions,
        'medications': medications,
        'doctorName': doctorName,
        'doctorPhone': doctorPhone,
        'insurance': insurance,
        'notes': notes,
        'lastDonation': lastDonation?.toIso8601String(),
      };

  static MedicalProfile fromJson(Map<String, dynamic> json) => MedicalProfile(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        bloodType: BloodType.fromName(json['bloodType'] as String?),
        birthDate: _date(json['birthDate']),
        allergies: _strings(json['allergies']),
        conditions: _strings(json['conditions']),
        medications: _strings(json['medications']),
        doctorName: json['doctorName'] as String? ?? '',
        doctorPhone: json['doctorPhone'] as String? ?? '',
        insurance: json['insurance'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        lastDonation: _date(json['lastDonation']),
      );

  static DateTime? _date(Object? raw) =>
      raw is String ? DateTime.tryParse(raw) : null;

  static List<String> _strings(Object? raw) => raw is List
      ? raw.whereType<String>().where((String s) => s.trim().isNotEmpty).toList()
      : const <String>[];
}
