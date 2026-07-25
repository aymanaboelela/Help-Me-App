import '../../../core/localized_text.dart';
import '../../../core/media/topic_media.dart';
import '../model/first_aid_topic.dart';

/// Illustrations and videos for each first-aid topic, keyed by [FirstAidTopic.id].
///
/// Coverage is deliberately allowed to be partial: a topic missing from this map,
/// or holding only images, renders perfectly well without the rest. Two topics
/// (drowning, electric shock) currently have no video because no recognised
/// first-aid body publishes one we could verify — an unverified video is worse
/// than no video.
///
/// Every video id below was confirmed through YouTube's public oEmbed endpoint,
/// which is also the source of each [TopicVideo.channel].
const Map<String, TopicMedia> kTopicMedia = <String, TopicMedia>{
  // ---------------------------------------------------------------- breathing
  'cpr': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/photos/cpr.jpg',
        caption: LocalizedText(
          en: 'Hands on the centre of the chest with arms straight — compressions on a training manikin.',
          ar: 'الإيدين في منتصف الصدر والذراع مفرودة — ضغطات على مجسّم تدريب.',
        ),
        credit: PhotoCredit(
          photographer: 'Tahir Xəlfəquliyev',
          photographerUrl: 'https://www.pexels.com/@tahir',
          sourceUrl: 'https://www.pexels.com/photo/cpr-training-with-mannequin-dummy-indoors-33862096/',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/cpr_hand_position.svg',
        caption: LocalizedText(
          en: 'Heel of one hand on the centre of the chest, the other hand on top, fingers interlocked and lifted.',
          ar: 'كعب اليد في منتصف الصدر، واليد التانية فوقها، والأصابع متشابكة ومرفوعة.',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/cpr_compressions.svg',
        caption: LocalizedText(
          en: 'Shoulders directly over your hands, arms locked straight, pressing 5–6 cm deep.',
          ar: 'كتفك فوق إيدك مباشرة، وذراعك مفرودة، واضغط لعمق ٥–٦ سم.',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/cpr_head_tilt.svg',
        caption: LocalizedText(
          en: 'Palm on the forehead, two fingertips lifting the chin — this opens the airway.',
          ar: 'راحة إيدك على الجبهة، وطرف صباعين يرفعوا الدقن — كده مجرى الهواء يفتح.',
        ),
      ),
    ],
    videos: <TopicVideo>[
      TopicVideo(
        youtubeId: 'ye3IJWHaVEo',
        title: LocalizedText(
          en: 'Hands-only CPR, explained in Arabic',
          ar: 'الإنعاش القلبي الرئوي باليدين فقط — بالعربي',
        ),
        channel: 'American Heart Association',
        languageCode: 'ar',
        duration: Duration(minutes: 1, seconds: 11),
      ),
      TopicVideo(
        youtubeId: 'BQNNOh8c8ks',
        title: LocalizedText(en: 'How to do CPR on an adult', ar: 'الإنعاش القلبي الرئوي للبالغين'),
        channel: 'St John Ambulance',
        languageCode: 'en',
        duration: Duration(minutes: 3, seconds: 56),
      ),
      TopicVideo(
        youtubeId: 'avYRvVHAvfM',
        title: LocalizedText(en: 'How to give CPR to a baby', ar: 'الإنعاش القلبي الرئوي للرضّع'),
        channel: 'St John Ambulance',
        languageCode: 'en',
        duration: Duration(minutes: 3, seconds: 5),
      ),
    ],
  ),
  'choking': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/steps/choking_back_blows.svg',
        caption: LocalizedText(
          en: 'Lean them well forward and give five firm blows between the shoulder blades.',
          ar: 'ميّله لقدام كويس واضربه خمس ضربات قوية بين لوحي الكتف.',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/choking_abdominal_thrusts.svg',
        caption: LocalizedText(
          en: 'From behind, fist just above the navel, and pull sharply inwards and upwards.',
          ar: 'من ورا، حط قبضة إيدك فوق السرّة على طول، واشدّ بقوة لجوه ولفوق.',
        ),
      ),
    ],
    videos: <TopicVideo>[
      TopicVideo(
        youtubeId: '6E9AXXRdkfE',
        title: LocalizedText(en: 'Helping someone who is choking', ar: 'إسعاف شخص بيختنق'),
        channel: 'British Red Cross',
        languageCode: 'en',
        duration: Duration(minutes: 1, seconds: 15),
      ),
      TopicVideo(
        youtubeId: 'HGBBu4zr8sM',
        title: LocalizedText(en: 'Choking: full first-aid training', ar: 'الاختناق: تدريب إسعافي كامل'),
        channel: 'St John Ambulance',
        languageCode: 'en',
        duration: Duration(minutes: 2, seconds: 22),
      ),
    ],
  ),
  'drowning': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/photos/drowning.jpg',
        caption: LocalizedText(
          en: 'A lifeguard treating a swimmer at the poolside.',
          ar: 'منقذ بيسعف سبّاح جنب حمام السباحة.',
        ),
        credit: PhotoCredit(
          photographer: 'Bombeiros MT',
          photographerUrl: 'https://www.pexels.com/@bombeirosmt',
          sourceUrl: 'https://www.pexels.com/photo/lifeguard-performing-rescue-operation-by-poolside-33425559/',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/drowning_check_breathing.svg',
        caption: LocalizedText(
          en: 'Cheek over their mouth for ten seconds: look along the chest, listen, feel.',
          ar: 'قرّب خدّك من بقّه عشر ثواني: بصّ على صدره، اسمع، وحسّ.',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/recovery_position.svg',
        caption: LocalizedText(
          en: 'Breathing but unresponsive: turn them on their side so water and vomit drain out.',
          ar: 'لو بيتنفس ومش واعي: لفّه على جنبه عشان الميّه والقيء يخرجوا.',
        ),
      ),
    ],
  ),
  'swallowed_tongue': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/photos/swallowed_tongue.jpg',
        caption: LocalizedText(
          en: 'A paramedic tilting an unresponsive man\'s head back to open the airway.',
          ar: 'مسعف بيميّل راس رجل فاقد الوعي لورا عشان يفتح مجرى الهوا.',
        ),
        credit: PhotoCredit(
          photographer: 'RDNE Stock project',
          photographerUrl: 'https://www.pexels.com/@rdne',
          sourceUrl: 'https://www.pexels.com/photo/paramedic-checking-on-man-6520214/',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/cpr_head_tilt.svg',
        caption: LocalizedText(
          en: 'Tilting the head back lifts the tongue off the back of the throat.',
          ar: 'إمالة الرأس لورا بترفع اللسان من على آخر الزور.',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/recovery_position.svg',
        caption: LocalizedText(
          en: 'Once they are breathing, the recovery position keeps the airway clear.',
          ar: 'أول ما يتنفس، وضع الإفاقة بيخلّي مجرى الهواء فاضي.',
        ),
      ),
    ],
    videos: <TopicVideo>[
      TopicVideo(
        youtubeId: 'GmqXqwSV3bo',
        title: LocalizedText(en: 'The recovery position, step by step', ar: 'وضع الإفاقة خطوة بخطوة'),
        channel: 'St John Ambulance',
        languageCode: 'en',
        duration: Duration(minutes: 2, seconds: 32),
      ),
      TopicVideo(
        youtubeId: 'dlkgjYvHx-U',
        title: LocalizedText(
          en: 'Unresponsive and not breathing: what to do',
          ar: 'فاقد الوعي ومش بيتنفس: تعمل إيه',
        ),
        channel: 'British Red Cross',
        languageCode: 'en',
        duration: Duration(minutes: 1, seconds: 10),
      ),
    ],
  ),

  // ------------------------------------------------------------------ cardiac
  'heart_attack': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/photos/heart_attack.jpg',
        caption: LocalizedText(
          en: 'A hand pressed flat to the middle of the chest — the commonest way heart pain shows.',
          ar: 'إيد مضغوطة على نص الصدر — أشهر شكل بيظهر بيه ألم القلب.',
        ),
        credit: PhotoCredit(
          photographer: 'Towfiqu barbhuiya',
          photographerUrl: 'https://www.pexels.com/@towfiqu-barbhuiya-3440682',
          sourceUrl: 'https://www.pexels.com/photo/close-up-of-a-man-in-blue-polo-shirt-with-hands-on-chest-14569658/',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/heart_attack_position.svg',
        caption: LocalizedText(
          en: 'Sit them on the floor, back supported, knees drawn up — it eases the strain on the heart.',
          ar: 'قعّده على الأرض وضهره مسنود ورُكبه مثنية — ده بيخفف الحمل على القلب.',
        ),
      ),
    ],
    videos: <TopicVideo>[
      TopicVideo(
        youtubeId: 'gDwt7dD3awc',
        title: LocalizedText(
          en: 'Heart attack: symptoms and what to do',
          ar: 'الأزمة القلبية: الأعراض وتعمل إيه',
        ),
        channel: 'St John Ambulance',
        languageCode: 'en',
        duration: Duration(minutes: 3, seconds: 17),
      ),
      TopicVideo(
        youtubeId: 'vYWFVebej5A',
        title: LocalizedText(en: 'First aid for a heart attack', ar: 'الإسعاف الأولي للأزمة القلبية'),
        channel: 'British Red Cross',
        languageCode: 'en',
        duration: Duration(minutes: 4, seconds: 26),
      ),
    ],
  ),
  'stroke': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/steps/stroke_face_droop.svg',
        caption: LocalizedText(
          en: 'Ask them to smile and compare the two sides — one side falling is a warning sign.',
          ar: 'اطلب منه يبتسم وقارن الناحيتين — لو ناحية واقعة دي علامة خطر.',
        ),
      ),
    ],
    videos: <TopicVideo>[
      TopicVideo(
        youtubeId: 'PhH9a0kIwmk',
        title: LocalizedText(en: 'Stroke: signs and what to do', ar: 'السكتة الدماغية: العلامات وتعمل إيه'),
        channel: 'St John Ambulance',
        languageCode: 'en',
        duration: Duration(minutes: 1, seconds: 58),
      ),
      TopicVideo(
        youtubeId: '2p0rUIKkX50',
        title: LocalizedText(en: 'Act FAST: face, arm, speech, time', ar: 'اتصرّف بسرعة: الوش، الذراع، الكلام، الوقت'),
        channel: 'NHS',
        languageCode: 'en',
        duration: Duration(seconds: 30),
      ),
      TopicVideo(
        youtubeId: 'yFFptA_IWS0',
        title: LocalizedText(en: 'Stroke: first-aid steps', ar: 'السكتة الدماغية: خطوات الإسعاف'),
        channel: 'British Red Cross',
        languageCode: 'en',
        duration: Duration(minutes: 1, seconds: 23),
      ),
    ],
  ),
  'fainting': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/photos/fainting.jpg',
        caption: LocalizedText(
          en: 'Light-headed and needing to lie down before the faint arrives.',
          ar: 'دوخة ولازم ينام قبل ما يقع.',
        ),
        credit: PhotoCredit(
          photographer: 'RDNE Stock project',
          photographerUrl: 'https://www.pexels.com/@rdne',
          sourceUrl: 'https://www.pexels.com/photo/a-tired-woman-sitting-on-a-couch-5591897/',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/fainting_legs_raised.svg',
        caption: LocalizedText(
          en: 'Lay them flat and raise the legs — blood returns to the brain within seconds.',
          ar: 'نيّمه على ضهره وارفع رجليه — الدم بيرجع للمخ في ثواني.',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/recovery_position.svg',
        caption: LocalizedText(
          en: 'If they do not come round quickly, turn them on their side and call for help.',
          ar: 'لو مافاقش بسرعة، لفّه على جنبه واطلب المساعدة.',
        ),
      ),
    ],
    videos: <TopicVideo>[
      TopicVideo(
        youtubeId: 'ddHKwkMwNyI',
        title: LocalizedText(en: 'Fainting: causes and treatment', ar: 'الإغماء: الأسباب والإسعاف'),
        channel: 'St John Ambulance',
        languageCode: 'en',
        duration: Duration(minutes: 2, seconds: 16),
      ),
    ],
  ),

  // ----------------------------------------------------------------- bleeding
  'bleeding': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/photos/bleeding.jpg',
        caption: LocalizedText(
          en: 'Gloved hands pressing a dressing onto a bleeding wrist.',
          ar: 'إيدين بقفازات بيضغطوا شاش على رسغ بينزف.',
        ),
        credit: PhotoCredit(
          photographer: 'RDNE Stock project',
          photographerUrl: 'https://www.pexels.com/@rdne',
          sourceUrl: 'https://www.pexels.com/photo/person-with-white-bandage-on-left-hand-6520110/',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/bleeding_direct_pressure.svg',
        caption: LocalizedText(
          en: 'Press hard and directly on the wound through a clean pad, and do not let go to look.',
          ar: 'اضغط بقوة على الجرح نفسه من فوق شاش نضيف، وماترفعش إيدك عشان تبصّ.',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/bleeding_tourniquet.svg',
        caption: LocalizedText(
          en: 'Life-threatening limb bleeding only: a tourniquet goes above the wound, never on a joint.',
          ar: 'في النزيف المهدد للحياة في طرف بس: الرباط الضاغط يتحط فوق الجرح، ومطلقًا مش على مفصل.',
        ),
      ),
    ],
    videos: <TopicVideo>[
      TopicVideo(
        youtubeId: 'NxO5LvgqZe0',
        title: LocalizedText(en: 'How to treat severe bleeding', ar: 'إسعاف النزيف الشديد'),
        channel: 'St John Ambulance',
        languageCode: 'en',
        duration: Duration(minutes: 4, seconds: 28),
      ),
      TopicVideo(
        youtubeId: '6jmnMC76oF4',
        title: LocalizedText(en: 'Caring for severe bleeding', ar: 'التعامل مع النزيف الشديد'),
        channel: 'American Red Cross',
        languageCode: 'en',
        duration: Duration(minutes: 1, seconds: 51),
      ),
    ],
  ),

  // ------------------------------------------------------------------- trauma
  'burns': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/photos/burns.jpg',
        caption: LocalizedText(
          en: 'Cool running water over the skin, straight away and for a long time.',
          ar: 'ميّه جارية باردة على الجلد، فورًا ولمدة طويلة.',
        ),
        credit: PhotoCredit(
          photographer: 'Vlada Karpovich',
          photographerUrl: 'https://www.pexels.com/@vlada-karpovich',
          sourceUrl: 'https://www.pexels.com/photo/a-person-in-white-bathrobe-washing-hand-6634838/',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/burns_cool_water.svg',
        caption: LocalizedText(
          en: 'Cool running water over the burn for at least 20 minutes. Nothing else on it — no ice, no toothpaste.',
          ar: 'ميّه جارية باردة على الحرق ٢٠ دقيقة على الأقل. وبس — لا تلج ولا معجون أسنان.',
        ),
      ),
    ],
    videos: <TopicVideo>[
      TopicVideo(
        youtubeId: 'LIaqKI7B8EI',
        title: LocalizedText(en: 'How to treat a minor burn', ar: 'إسعاف الحروق البسيطة'),
        channel: 'Mayo Clinic',
        languageCode: 'en',
        duration: Duration(minutes: 1, seconds: 31),
      ),
      TopicVideo(
        youtubeId: '6i7ov4vbxUc',
        title: LocalizedText(en: 'How to treat burns', ar: 'إسعاف الحروق'),
        channel: 'St John Ambulance Kenya',
        languageCode: 'en',
        duration: Duration(minutes: 3, seconds: 26),
      ),
    ],
  ),
  'fracture': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/photos/fracture.jpg',
        caption: LocalizedText(
          en: 'A leg in a cast: the limb ends up supported and kept still.',
          ar: 'رِجل في جبس: الطرف بيبقى مسنود وثابت.',
        ),
        credit: PhotoCredit(
          photographer: 'Vika Glitter',
          photographerUrl: 'https://www.pexels.com/@vika-glitter-392079',
          sourceUrl: 'https://www.pexels.com/photo/young-woman-in-pain-in-leg-in-cast-4497804/',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/fracture_immobilize.svg',
        caption: LocalizedText(
          en: 'Support the limb exactly as you found it, and tie above and below the break — never over it.',
          ar: 'ثبّت الطرف زي ما هو بالظبط، واربط فوق الكسر وتحته — أبدًا مش عليه.',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/fracture_sling.svg',
        caption: LocalizedText(
          en: 'An arm injury is carried in a sling, wrist a little higher than the elbow.',
          ar: 'إصابة الذراع بتتحمل في حمّالة، والرسغ أعلى شوية من الكوع.',
        ),
      ),
    ],
    videos: <TopicVideo>[
      TopicVideo(
        youtubeId: '2v8vlXgGXwE',
        title: LocalizedText(en: 'How to treat a fracture', ar: 'إسعاف الكسور'),
        channel: 'St John Ambulance',
        languageCode: 'en',
        duration: Duration(minutes: 2, seconds: 52),
      ),
      TopicVideo(
        youtubeId: 'eLQr6sHN8bo',
        title: LocalizedText(en: 'Helping a child with a broken bone', ar: 'إسعاف طفل عنده كسر'),
        channel: 'British Red Cross',
        languageCode: 'en',
        duration: Duration(minutes: 1, seconds: 3),
      ),
    ],
  ),
  'electric_shock': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/photos/electric_shock.jpg',
        caption: LocalizedText(
          en: 'Power at the wall — switch it off before you touch anyone.',
          ar: 'الكهربا في الفيشة — اقطعها قبل ما تلمس أي حد.',
        ),
        credit: PhotoCredit(
          photographer: 'Markus Spiske',
          photographerUrl: 'https://www.pexels.com/@markusspiske',
          sourceUrl: 'https://www.pexels.com/photo/black-and-white-electric-plug-218445/',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/electric_shock_cut_power.svg',
        caption: LocalizedText(
          en: 'Switch the power off first. If you cannot, push the source away with something dry and wooden.',
          ar: 'اقطع الكهرباء الأول. لو مقدرتش، ابعد المصدر بحاجة خشب ناشفة.',
        ),
      ),
    ],
  ),

  // ------------------------------------------------------------ environmental
  'heat_stroke': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/photos/heat_stroke.jpg',
        caption: LocalizedText(
          en: 'Fluid in and heat out — the two things a heat casualty needs.',
          ar: 'مايه تدخل وحرارة تخرج — دول أهم حاجتين للمصاب بالحر.',
        ),
        credit: PhotoCredit(
          photographer: 'BOOM 💥 Photography',
          photographerUrl: 'https://www.pexels.com/@boom',
          sourceUrl: 'https://www.pexels.com/photo/a-man-drinking-water-12585554/',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/heat_stroke_cool.svg',
        caption: LocalizedText(
          en: 'Shade, loosened clothing, and cool wet cloths at the neck, armpits and groin.',
          ar: 'ضلّ، وهدوم مفكوكة، وفوط مبلولة باردة على الرقبة وتحت الإبط وبين الفخذين.',
        ),
      ),
    ],
    videos: <TopicVideo>[
      TopicVideo(
        youtubeId: 'W-Us9IP33Gs',
        title: LocalizedText(en: 'First aid for heat exhaustion', ar: 'إسعاف الإجهاد الحراري'),
        channel: 'British Red Cross',
        languageCode: 'en',
        duration: Duration(minutes: 3, seconds: 22),
      ),
      TopicVideo(
        youtubeId: 'R6VdoV8dZRc',
        title: LocalizedText(en: 'Heat exhaustion: signs and treatment', ar: 'الإجهاد الحراري: العلامات والإسعاف'),
        channel: 'St John Ambulance',
        languageCode: 'en',
        duration: Duration(minutes: 2, seconds: 12),
      ),
    ],
  ),
  'snake_bite': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/photos/snake_bite.jpg',
        caption: LocalizedText(
          en: 'An adder in undergrowth — most bites happen where the snake was never seen.',
          ar: 'تعبان سام بين الحشايش — أغلب اللدغات بتحصل في مكان التعبان مكانش باين فيه.',
        ),
        credit: PhotoCredit(
          photographer: 'Muhammet MIRIK',
          photographerUrl: 'https://www.pexels.com/@muhammet-mirik-386428358',
          sourceUrl: 'https://www.pexels.com/photo/close-up-photo-of-a-snake-14747265/',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/snake_bite_immobilize.svg',
        caption: LocalizedText(
          en: 'Keep the limb still and lower than the heart. Do not cut, suck, or apply ice.',
          ar: 'خلّي الطرف ثابت وأوطى من مستوى القلب. ماتقطعش ولا تمصّ ولا تحط تلج.',
        ),
      ),
    ],
    videos: <TopicVideo>[
      TopicVideo(
        youtubeId: '7Fh3v5c6FY4',
        title: LocalizedText(en: 'Bites and stings', ar: 'العضّات واللدغات'),
        channel: 'St John Ambulance',
        languageCode: 'en',
        duration: Duration(minutes: 2, seconds: 35),
      ),
    ],
  ),

  // ------------------------------------------------------------------ medical
  'seizures': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/photos/seizures.jpg',
        caption: LocalizedText(
          en: 'Paramedics with a patient — what happens once the seizure has stopped.',
          ar: 'مسعفين مع مريض — اللي بيحصل بعد ما التشنج يقف.',
        ),
        credit: PhotoCredit(
          photographer: 'RDNE Stock project',
          photographerUrl: 'https://www.pexels.com/@rdne',
          sourceUrl: 'https://www.pexels.com/photo/people-inside-an-ambulance-6520213/',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/seizure_protect_head.svg',
        caption: LocalizedText(
          en: 'Pad the head, move hard objects away, and time it. Never hold them down or put anything in the mouth.',
          ar: 'حط حاجة طرية تحت راسه، وبعّد الحاجات الصلبة، واحسب الوقت. ماتمسكوش ولا تحط أي حاجة في بقّه.',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/recovery_position.svg',
        caption: LocalizedText(
          en: 'When the shaking stops, turn them on their side.',
          ar: 'أول ما التشنج يقف، لفّه على جنبه.',
        ),
      ),
    ],
    videos: <TopicVideo>[
      TopicVideo(
        youtubeId: 'Ovsw7tdneqE',
        title: LocalizedText(en: 'What to do if someone has a seizure', ar: 'تعمل إيه لو حد جاله تشنج'),
        channel: 'St John Ambulance',
        languageCode: 'en',
        duration: Duration(minutes: 2, seconds: 36),
      ),
      TopicVideo(
        youtubeId: 'YWPhudRkTxM',
        title: LocalizedText(en: 'Seizures: first-aid steps', ar: 'التشنجات: خطوات الإسعاف'),
        channel: 'British Red Cross',
        languageCode: 'en',
        duration: Duration(minutes: 1, seconds: 10),
      ),
    ],
  ),
  'diabetic_coma': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/photos/diabetic_coma.jpg',
        caption: LocalizedText(
          en: 'A blood glucose check: a diabetic emergency turns on this number.',
          ar: 'قياس السكر في الدم: حالة السكر الطارئة بتتحدد بالرقم ده.',
        ),
        credit: PhotoCredit(
          photographer: 'Mehmet BALCI',
          photographerUrl: 'https://www.pexels.com/@mehmet-balci-166052147',
          sourceUrl: 'https://www.pexels.com/photo/blood-glucose-monitoring-at-health-fair-30367056/',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/diabetic_give_sugar.svg',
        caption: LocalizedText(
          en: 'Awake and able to swallow: something sweet, straight away. Never give anything by mouth to someone drowsy.',
          ar: 'واعي وقادر يبلع: حاجة سكر على طول. وماتديش أي حاجة بالبق لحد تعبان أو نعسان.',
        ),
      ),
    ],
    videos: <TopicVideo>[
      TopicVideo(
        youtubeId: 'sWYxsU53ZCo',
        title: LocalizedText(en: 'First aid for diabetic emergencies', ar: 'إسعاف حالات السكر الطارئة'),
        channel: 'British Red Cross',
        languageCode: 'en',
        duration: Duration(minutes: 4, seconds: 27),
      ),
      TopicVideo(
        youtubeId: 'wj5_ruu6MYc',
        title: LocalizedText(en: 'Helping someone with a diabetic emergency', ar: 'إسعاف حد عنده هبوط سكر'),
        channel: 'British Red Cross',
        languageCode: 'en',
        duration: Duration(minutes: 1, seconds: 48),
      ),
    ],
  ),
  'anaphylaxis': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/steps/anaphylaxis_epipen.svg',
        caption: LocalizedText(
          en: 'The auto-injector goes at a right angle into the outer middle of the thigh — through clothing if you have to.',
          ar: 'القلم بيتحط عمودي في وسط الفخذ من برّه — ومن فوق الهدوم لو اضطريت.',
        ),
      ),
    ],
    videos: <TopicVideo>[
      TopicVideo(
        youtubeId: '8EyYTW-1EP0',
        title: LocalizedText(
          en: 'First aid for a severe allergic reaction',
          ar: 'إسعاف الحساسية المفرطة',
        ),
        channel: 'British Red Cross',
        languageCode: 'en',
        duration: Duration(minutes: 3, seconds: 49),
      ),
      TopicVideo(
        youtubeId: 'O-8pPTVql5k',
        title: LocalizedText(en: 'Anaphylaxis: symptoms and treatment', ar: 'صدمة الحساسية: الأعراض والإسعاف'),
        channel: 'American Red Cross',
        languageCode: 'en',
        duration: Duration(minutes: 1, seconds: 52),
      ),
    ],
  ),
  'poisoning': TopicMedia(
    images: <TopicImage>[
      TopicImage(
        asset: 'assets/photos/poisoning.jpg',
        caption: LocalizedText(
          en: 'Household cleaners: the commonest poisons in any home.',
          ar: 'منظفات البيت: أشهر مواد سامة في أي بيت.',
        ),
        credit: PhotoCredit(
          photographer: 'Anna Shvets',
          photographerUrl: 'https://www.pexels.com/@shvetsa',
          sourceUrl: 'https://www.pexels.com/photo/composition-of-detergents-on-table-5217889/',
        ),
      ),
      TopicImage(
        asset: 'assets/steps/poisoning_keep_container.svg',
        caption: LocalizedText(
          en: 'Keep the container and call before you do anything. Never make them vomit.',
          ar: 'احتفظ بالعبوة واتصل قبل ما تعمل أي حاجة. وماتخليهوش يترجّع أبدًا.',
        ),
      ),
    ],
    videos: <TopicVideo>[
      TopicVideo(
        youtubeId: 'b2ieb8BZJuY',
        title: LocalizedText(en: 'How to treat poisoning', ar: 'إسعاف حالات التسمم'),
        channel: 'St John Ambulance',
        languageCode: 'en',
        duration: Duration(minutes: 1, seconds: 47),
      ),
      TopicVideo(
        youtubeId: 'L4o6D10AkMg',
        title: LocalizedText(
          en: 'If someone has swallowed something harmful',
          ar: 'لو حد بلع حاجة ضارة',
        ),
        channel: 'British Red Cross',
        languageCode: 'en',
        duration: Duration(minutes: 1, seconds: 44),
      ),
    ],
  ),
};

/// Images that replace a topic's own when a particular age is selected.
///
/// Keyed `'<topicId>:<age.name>'`, matching the by-id keying of [kTopicMedia].
///
/// An **empty list is meaningful and is not the same as no entry**: it says "no
/// correct picture for this age exists yet, so show none". Falling back would
/// put adult hand-position diagrams under an infant banner, which teaches the
/// wrong thing more convincingly than words could.
const Map<String, List<TopicImage>> kTopicImagesByAge =
    <String, List<TopicImage>>{
  'cpr:child': <TopicImage>[],
  'cpr:infant': <TopicImage>[],
  'choking:infant': <TopicImage>[
    TopicImage(
      asset: 'assets/steps/choking_infant.svg',
      caption: LocalizedText(
        en: 'A baby goes face down along your forearm, head lower than the chest.',
        ar: 'الرضيع يبقى على وشه على طول ذراعك، ورأسه أوطى من صدره.',
      ),
    ),
  ],
};

/// The illustrations to show for [topicId] at [age].
///
/// An explicit by-age entry always wins, including an empty one. Everything
/// else falls back to the topic's own images, which is right for age-neutral
/// pictures like cooling a burn.
List<TopicImage> imagesFor(String topicId, AgeGroup age) =>
    kTopicImagesByAge['$topicId:${age.name}'] ??
    kTopicMedia[topicId]?.images ??
    const <TopicImage>[];
