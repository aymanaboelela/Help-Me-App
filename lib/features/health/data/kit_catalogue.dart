import '../../../core/localized_text.dart';

/// How the checklist is grouped on screen.
enum KitSection { dressings, tools, medicines, protection, essentials }

/// One thing a home or car first-aid kit should contain.
class KitItem {
  const KitItem({
    required this.id,
    required this.name,
    required this.section,
    this.note,
    this.perishable = false,
  });

  /// Stable id — this is what gets ticked and persisted, so renaming the
  /// English or Arabic text never loses somebody's progress.
  final String id;
  final LocalizedText name;
  final KitSection section;

  /// Why it is on the list, when that is not obvious.
  final LocalizedText? note;

  /// Has a shelf life. Items like these belong in the medicine cabinet too,
  /// which is where expiry dates and their reminders live.
  final bool perishable;
}

/// What a home first-aid kit should hold.
///
/// Follows what first-aid bodies commonly recommend, kept deliberately short:
/// a list nobody finishes is a list nobody starts.
const List<KitItem> kKitCatalogue = <KitItem>[
  // ------------------------------------------------------------- dressings
  KitItem(
    id: 'sterile_gauze',
    name: LocalizedText(en: 'Sterile gauze pads', ar: 'شاش معقّم'),
    section: KitSection.dressings,
    note: LocalizedText(
      en: 'Several sizes. The single most useful thing in the kit.',
      ar: 'مقاسات مختلفة. أهم حاجة في الشنطة كلها.',
    ),
    perishable: true,
  ),
  KitItem(
    id: 'adhesive_bandages',
    name: LocalizedText(en: 'Adhesive plasters', ar: 'بلاستر جروح'),
    section: KitSection.dressings,
    perishable: true,
  ),
  KitItem(
    id: 'roller_bandage',
    name: LocalizedText(en: 'Roller bandages', ar: 'رباط شاش لفّة'),
    section: KitSection.dressings,
  ),
  KitItem(
    id: 'elastic_bandage',
    name: LocalizedText(en: 'Elastic bandage', ar: 'رباط ضاغط مطاطي'),
    section: KitSection.dressings,
    note: LocalizedText(en: 'For sprains and firm support.', ar: 'للالتواءات والتثبيت.'),
  ),
  KitItem(
    id: 'triangular_bandage',
    name: LocalizedText(en: 'Triangular bandage', ar: 'رباط مثلث'),
    section: KitSection.dressings,
    note: LocalizedText(en: 'Becomes an arm sling in seconds.', ar: 'بيتحوّل لحمّالة ذراع في ثواني.'),
  ),
  KitItem(
    id: 'medical_tape',
    name: LocalizedText(en: 'Medical tape', ar: 'شريط لاصق طبي'),
    section: KitSection.dressings,
  ),
  KitItem(
    id: 'burn_dressing',
    name: LocalizedText(en: 'Burn dressing or gel', ar: 'ضمادة أو جل حروق'),
    section: KitSection.dressings,
    perishable: true,
  ),

  // ----------------------------------------------------------------- tools
  KitItem(
    id: 'scissors',
    name: LocalizedText(en: 'Blunt-nosed scissors', ar: 'مقص طبي مدبّب من غير سنّ'),
    section: KitSection.tools,
    note: LocalizedText(en: 'To cut clothing away from a wound.', ar: 'عشان تقص الهدوم من على الجرح.'),
  ),
  KitItem(
    id: 'tweezers',
    name: LocalizedText(en: 'Tweezers', ar: 'ملقاط'),
    section: KitSection.tools,
  ),
  KitItem(
    id: 'thermometer',
    name: LocalizedText(en: 'Thermometer', ar: 'ترمومتر'),
    section: KitSection.tools,
  ),
  KitItem(
    id: 'safety_pins',
    name: LocalizedText(en: 'Safety pins', ar: 'دبابيس مشبك'),
    section: KitSection.tools,
  ),
  KitItem(
    id: 'instant_cold_pack',
    name: LocalizedText(en: 'Instant cold pack', ar: 'كمّادة تبريد فورية'),
    section: KitSection.tools,
    perishable: true,
  ),
  KitItem(
    id: 'torch',
    name: LocalizedText(en: 'Small torch', ar: 'كشاف صغير'),
    section: KitSection.tools,
    note: LocalizedText(
      en: 'With spare batteries — your phone may be the thing calling for help.',
      ar: 'ومعاه بطاريات احتياطي — موبايلك ممكن يكون مشغول بطلب النجدة.',
    ),
  ),

  // ------------------------------------------------------------- medicines
  KitItem(
    id: 'antiseptic',
    name: LocalizedText(en: 'Antiseptic solution or wipes', ar: 'مطهّر أو مناديل مطهّرة'),
    section: KitSection.medicines,
    perishable: true,
  ),
  KitItem(
    id: 'painkiller',
    name: LocalizedText(en: 'Painkiller (paracetamol)', ar: 'مسكّن (باراسيتامول)'),
    section: KitSection.medicines,
    perishable: true,
  ),
  KitItem(
    id: 'antihistamine',
    name: LocalizedText(en: 'Antihistamine', ar: 'مضاد هيستامين للحساسية'),
    section: KitSection.medicines,
    perishable: true,
  ),
  KitItem(
    id: 'ors',
    name: LocalizedText(en: 'Oral rehydration salts', ar: 'أملاح معالجة الجفاف'),
    section: KitSection.medicines,
    perishable: true,
  ),
  KitItem(
    id: 'personal_meds',
    name: LocalizedText(en: 'Your own prescribed medicines', ar: 'أدويتك الموصوفة ليك'),
    section: KitSection.medicines,
    note: LocalizedText(
      en: 'Inhaler, insulin, an adrenaline auto-injector — whatever your household needs.',
      ar: 'بخّاخ، أنسولين، قلم أدرينالين — أي حاجة بيتك محتاجها.',
    ),
    perishable: true,
  ),

  // ------------------------------------------------------------ protection
  KitItem(
    id: 'gloves',
    name: LocalizedText(en: 'Disposable gloves', ar: 'قفازات للاستعمال مرة واحدة'),
    section: KitSection.protection,
    note: LocalizedText(
      en: 'Protects you and the person you are helping.',
      ar: 'بتحميك وبتحمي اللي بتسعفه.',
    ),
  ),
  KitItem(
    id: 'face_shield',
    name: LocalizedText(en: 'CPR face shield', ar: 'واقي وجه للتنفس الصناعي'),
    section: KitSection.protection,
  ),
  KitItem(
    id: 'hand_sanitiser',
    name: LocalizedText(en: 'Hand sanitiser', ar: 'كحول أو معقّم أيدي'),
    section: KitSection.protection,
    perishable: true,
  ),

  // ------------------------------------------------------------ essentials
  KitItem(
    id: 'emergency_numbers',
    name: LocalizedText(en: 'Emergency numbers on paper', ar: 'أرقام الطوارئ مكتوبة على ورق'),
    section: KitSection.essentials,
    note: LocalizedText(
      en: 'A flat phone battery should not be the reason nobody gets called.',
      ar: 'بطارية موبايل فاضية ماينفعش تكون السبب إن محدش اتصل.',
    ),
  ),
  KitItem(
    id: 'medical_cards',
    name: LocalizedText(en: 'Medical cards for the family', ar: 'البطاقات الطبية للعيلة'),
    section: KitSection.essentials,
    note: LocalizedText(
      en: 'Blood types, allergies, chronic conditions.',
      ar: 'فصائل الدم، والحساسية، والأمراض المزمنة.',
    ),
  ),
  KitItem(
    id: 'foil_blanket',
    name: LocalizedText(en: 'Foil emergency blanket', ar: 'بطانية طوارئ حرارية'),
    section: KitSection.essentials,
  ),
  KitItem(
    id: 'water',
    name: LocalizedText(en: 'Bottled water', ar: 'مياه معبّأة'),
    section: KitSection.essentials,
    note: LocalizedText(en: 'For cooling burns and for drinking.', ar: 'لتبريد الحروق وللشرب.'),
  ),
];

/// The catalogue grouped by section, in the order sections are declared.
Map<KitSection, List<KitItem>> get kKitBySection => <KitSection, List<KitItem>>{
      for (final KitSection section in KitSection.values)
        section: kKitCatalogue.where((KitItem i) => i.section == section).toList(),
    };
