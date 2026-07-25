import 'package:flutter/material.dart';

import '../../../core/localized_text.dart';

/// A single dialable emergency / utility hotline.
@immutable
class EmergencyNumber {
  const EmergencyNumber({
    required this.name,
    required this.number,
    required this.icon,
    this.critical = false,
  });

  final LocalizedText name;
  final String number;
  final IconData icon;

  /// Life-critical services (ambulance / police / fire) are surfaced first.
  final bool critical;
}

/// A country and its emergency numbers.
@immutable
class EmergencyCountry {
  const EmergencyCountry({
    required this.code,
    required this.name,
    required this.flag,
    required this.ambulance,
    required this.numbers,
  });

  final String code;
  final LocalizedText name;
  final String flag;

  /// The number dialed by the SOS button.
  final EmergencyNumber ambulance;

  /// The full list shown on the emergency screen (includes [ambulance]).
  final List<EmergencyNumber> numbers;
}

// ---------------------------------------------------------------------------
// Egypt (default)
// ---------------------------------------------------------------------------
const EmergencyNumber _egAmbulance = EmergencyNumber(
  name: LocalizedText(en: 'Ambulance', ar: 'الإسعاف'),
  number: '123',
  icon: Icons.emergency,
  critical: true,
);

const List<EmergencyNumber> _egNumbers = <EmergencyNumber>[
  _egAmbulance,
  EmergencyNumber(name: LocalizedText(en: 'Police', ar: 'النجدة (الشرطة)'), number: '122', icon: Icons.local_police, critical: true),
  EmergencyNumber(name: LocalizedText(en: 'Fire & rescue', ar: 'المطافئ والإنقاذ'), number: '180', icon: Icons.fire_truck, critical: true),
  EmergencyNumber(name: LocalizedText(en: 'Tourist police', ar: 'شرطة السياحة'), number: '126', icon: Icons.travel_explore),
  EmergencyNumber(name: LocalizedText(en: 'Traffic police', ar: 'شرطة المرور'), number: '128', icon: Icons.traffic),
  EmergencyNumber(name: LocalizedText(en: 'Electricity faults', ar: 'أعطال الكهرباء'), number: '121', icon: Icons.electrical_services),
  EmergencyNumber(name: LocalizedText(en: 'Water faults', ar: 'أعطال المياه'), number: '125', icon: Icons.water_drop),
  EmergencyNumber(name: LocalizedText(en: 'Natural gas emergency', ar: 'طوارئ الغاز الطبيعي'), number: '129', icon: Icons.gas_meter),
  EmergencyNumber(name: LocalizedText(en: 'Cyber crime', ar: 'مباحث الإنترنت'), number: '15008', icon: Icons.security),
  EmergencyNumber(name: LocalizedText(en: 'Consumer protection', ar: 'حماية المستهلك'), number: '19588', icon: Icons.shopping_bag),
];

const EmergencyCountry kEgypt = EmergencyCountry(
  code: 'EG',
  name: LocalizedText(en: 'Egypt', ar: 'مصر'),
  flag: '🇪🇬',
  ambulance: _egAmbulance,
  numbers: _egNumbers,
);

// ---------------------------------------------------------------------------
// Saudi Arabia
// ---------------------------------------------------------------------------
const EmergencyCountry kSaudiArabia = EmergencyCountry(
  code: 'SA',
  name: LocalizedText(en: 'Saudi Arabia', ar: 'السعودية'),
  flag: '🇸🇦',
  ambulance: EmergencyNumber(name: LocalizedText(en: 'Ambulance (Red Crescent)', ar: 'الإسعاف (الهلال الأحمر)'), number: '997', icon: Icons.emergency, critical: true),
  numbers: <EmergencyNumber>[
    EmergencyNumber(name: LocalizedText(en: 'Ambulance (Red Crescent)', ar: 'الإسعاف (الهلال الأحمر)'), number: '997', icon: Icons.emergency, critical: true),
    EmergencyNumber(name: LocalizedText(en: 'Police', ar: 'الشرطة'), number: '999', icon: Icons.local_police, critical: true),
    EmergencyNumber(name: LocalizedText(en: 'Civil Defense (fire)', ar: 'الدفاع المدني (الإطفاء)'), number: '998', icon: Icons.fire_truck, critical: true),
    EmergencyNumber(name: LocalizedText(en: 'Unified emergency', ar: 'الطوارئ الموحّد'), number: '911', icon: Icons.sos),
    EmergencyNumber(name: LocalizedText(en: 'Traffic police', ar: 'المرور'), number: '993', icon: Icons.traffic),
    EmergencyNumber(name: LocalizedText(en: 'Highway patrol', ar: 'أمن الطرق'), number: '996', icon: Icons.add_road),
  ],
);

// ---------------------------------------------------------------------------
// United Arab Emirates
// ---------------------------------------------------------------------------
const EmergencyCountry kUae = EmergencyCountry(
  code: 'AE',
  name: LocalizedText(en: 'United Arab Emirates', ar: 'الإمارات'),
  flag: '🇦🇪',
  ambulance: EmergencyNumber(name: LocalizedText(en: 'Ambulance', ar: 'الإسعاف'), number: '998', icon: Icons.emergency, critical: true),
  numbers: <EmergencyNumber>[
    EmergencyNumber(name: LocalizedText(en: 'Ambulance', ar: 'الإسعاف'), number: '998', icon: Icons.emergency, critical: true),
    EmergencyNumber(name: LocalizedText(en: 'Police', ar: 'الشرطة'), number: '999', icon: Icons.local_police, critical: true),
    EmergencyNumber(name: LocalizedText(en: 'Fire (Civil Defense)', ar: 'الإطفاء (الدفاع المدني)'), number: '997', icon: Icons.fire_truck, critical: true),
    EmergencyNumber(name: LocalizedText(en: 'Unified emergency', ar: 'الطوارئ الموحّد'), number: '112', icon: Icons.sos),
  ],
);

// ---------------------------------------------------------------------------
// International fallback
// ---------------------------------------------------------------------------
const EmergencyCountry kInternational = EmergencyCountry(
  code: 'INT',
  name: LocalizedText(en: 'International', ar: 'دولي'),
  flag: '🌍',
  ambulance: EmergencyNumber(name: LocalizedText(en: 'Emergency (GSM)', ar: 'الطوارئ (GSM)'), number: '112', icon: Icons.sos, critical: true),
  numbers: <EmergencyNumber>[
    EmergencyNumber(name: LocalizedText(en: 'Emergency (GSM/EU)', ar: 'الطوارئ (GSM/أوروبا)'), number: '112', icon: Icons.sos, critical: true),
    EmergencyNumber(name: LocalizedText(en: 'Emergency (US/Canada)', ar: 'الطوارئ (أمريكا/كندا)'), number: '911', icon: Icons.sos, critical: true),
    EmergencyNumber(name: LocalizedText(en: 'Emergency (UK)', ar: 'الطوارئ (بريطانيا)'), number: '999', icon: Icons.sos, critical: true),
  ],
);

/// All supported countries.
const List<EmergencyCountry> kCountries = <EmergencyCountry>[
  kEgypt,
  kSaudiArabia,
  kUae,
  kInternational,
];

/// Returns the country for [code], defaulting to Egypt.
EmergencyCountry countryByCode(String? code) {
  for (final EmergencyCountry c in kCountries) {
    if (c.code == code) return c;
  }
  return kEgypt;
}

/// Backwards-compatible defaults (Egypt) used by the SOS fallback and tests.
const EmergencyNumber kAmbulance = _egAmbulance;
const List<EmergencyNumber> kEmergencyNumbers = _egNumbers;
