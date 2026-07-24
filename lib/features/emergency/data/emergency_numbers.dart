import 'package:flutter/material.dart';

import '../../../core/localized_text.dart';

/// A single dialable emergency / utility hotline (Egypt).
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

/// The single most important number — used by the SOS button.
const EmergencyNumber kAmbulance = EmergencyNumber(
  name: LocalizedText(en: 'Ambulance', ar: 'الإسعاف'),
  number: '123',
  icon: Icons.emergency,
  critical: true,
);

/// Official Egyptian emergency and utility numbers.
const List<EmergencyNumber> kEmergencyNumbers = <EmergencyNumber>[
  kAmbulance,
  EmergencyNumber(
    name: LocalizedText(en: 'Police', ar: 'النجدة (الشرطة)'),
    number: '122',
    icon: Icons.local_police,
    critical: true,
  ),
  EmergencyNumber(
    name: LocalizedText(en: 'Fire & rescue', ar: 'المطافئ والإنقاذ'),
    number: '180',
    icon: Icons.fire_truck,
    critical: true,
  ),
  EmergencyNumber(
    name: LocalizedText(en: 'Tourist police', ar: 'شرطة السياحة'),
    number: '126',
    icon: Icons.travel_explore,
  ),
  EmergencyNumber(
    name: LocalizedText(en: 'Traffic police', ar: 'شرطة المرور'),
    number: '128',
    icon: Icons.traffic,
  ),
  EmergencyNumber(
    name: LocalizedText(en: 'Electricity faults', ar: 'أعطال الكهرباء'),
    number: '121',
    icon: Icons.electrical_services,
  ),
  EmergencyNumber(
    name: LocalizedText(en: 'Water faults', ar: 'أعطال المياه'),
    number: '125',
    icon: Icons.water_drop,
  ),
  EmergencyNumber(
    name: LocalizedText(en: 'Natural gas emergency', ar: 'طوارئ الغاز الطبيعي'),
    number: '129',
    icon: Icons.gas_meter,
  ),
  EmergencyNumber(
    name: LocalizedText(en: 'Cyber crime', ar: 'مباحث الإنترنت'),
    number: '15008',
    icon: Icons.security,
  ),
  EmergencyNumber(
    name: LocalizedText(en: 'Consumer protection', ar: 'حماية المستهلك'),
    number: '19588',
    icon: Icons.shopping_bag,
  ),
];
