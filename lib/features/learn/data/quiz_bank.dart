import '../../../core/localized_text.dart';
import '../model/learn_content.dart';
import 'lessons.dart';

/// Standalone quiz questions, on top of the check question each lesson carries.
///
/// Several are written around the mistake rather than the fact — "what should
/// you *not* do" catches the folk remedies that get repeated at family
/// gatherings, which is where most first-aid misinformation actually comes from.
const List<QuizQuestion> kQuizExtras = <QuizQuestion>[
  QuizQuestion(
    id: 'q_burn_ice',
    topicId: 'burns',
    prompt: LocalizedText(
      en: 'Which of these should never go on a burn?',
      ar: 'إيه اللي ماينفعش يتحط على الحرق أبدًا؟',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'Cool running water', ar: 'ميّه جارية باردة'),
      LocalizedText(en: 'Ice', ar: 'تلج'),
      LocalizedText(en: 'Cling film, laid on loosely', ar: 'فيلم بلاستيك متحطوط بخفة'),
      LocalizedText(en: 'A clean, non-fluffy cloth', ar: 'قماشة نضيفة من غير وبر'),
    ],
    answerIndex: 1,
    explanation: LocalizedText(
      en: 'Ice causes a second, cold injury on top of the burn. Cool water only.',
      ar: 'التلج بيعمل إصابة تانية بالبرودة فوق الحرق. ميّه باردة وبس.',
    ),
  ),
  QuizQuestion(
    id: 'q_poison_vomit',
    topicId: 'poisoning',
    prompt: LocalizedText(
      en: 'Someone has swallowed a household cleaner. What do you do?',
      ar: 'حد بلع منظّف من بتوع البيت. تعمل إيه؟',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'Make them vomit it back up', ar: 'تخليه يترجّعه'),
      LocalizedText(en: 'Give milk to neutralise it', ar: 'تديله لبن يعادله'),
      LocalizedText(
        en: 'Keep the container and call for help',
        ar: 'تحتفظ بالعبوة وتطلب النجدة',
      ),
      LocalizedText(en: 'Wait to see if they get ill', ar: 'تستنى تشوف هيتعب ولا لأ'),
    ],
    answerIndex: 2,
    explanation: LocalizedText(
      en: 'Many substances burn twice as much on the way back up. The container tells the hospital exactly what to treat.',
      ar: 'في مواد كتير بتحرق مرتين وهي طالعة. والعبوة بتقول للمستشفى بالظبط بيعالجوا إيه.',
    ),
  ),
  QuizQuestion(
    id: 'q_seizure_mouth',
    topicId: 'seizures',
    prompt: LocalizedText(
      en: 'During a seizure, what should you put in the person\'s mouth?',
      ar: 'أثناء التشنج، تحط إيه في بق الشخص؟',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'A spoon', ar: 'معلقة'),
      LocalizedText(en: 'A folded cloth', ar: 'قماشة مطوية'),
      LocalizedText(en: 'Your fingers, to hold the tongue', ar: 'صوابعك عشان تمسك اللسان'),
      LocalizedText(en: 'Nothing at all', ar: 'ولا حاجة خالص'),
    ],
    answerIndex: 3,
    explanation: LocalizedText(
      en: 'Nobody swallows their tongue. Anything in the mouth breaks teeth, blocks the airway, or costs you a finger.',
      ar: 'محدش بيبلع لسانه. أي حاجة في البق بتكسر سنان أو تسد مجرى الهوا أو تكلّفك صباع.',
    ),
  ),
  QuizQuestion(
    id: 'q_snake_cut',
    topicId: 'snake_bite',
    prompt: LocalizedText(
      en: 'After a snake bite on the arm, what helps?',
      ar: 'بعد لدغة تعبان في الذراع، إيه اللي بيفيد؟',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'Cutting and sucking the wound', ar: 'تقطع الجرح وتمصّه'),
      LocalizedText(en: 'A tight tourniquet above it', ar: 'رباط ضاغط قوي فوقها'),
      LocalizedText(
        en: 'Keeping the arm still and below the heart',
        ar: 'تثبيت الذراع تحت مستوى القلب',
      ),
      LocalizedText(en: 'Packing it with ice', ar: 'تحطها في تلج'),
    ],
    answerIndex: 2,
    explanation: LocalizedText(
      en: 'Cutting, sucking, tourniquets and ice all cause extra damage without removing venom. Stillness slows its spread.',
      ar: 'التقطيع والمص والرباط الضاغط والتلج كلهم بيعملوا ضرر زيادة من غير ما يشيلوا السم. الثبات هو اللي بيبطّئ انتشاره.',
    ),
  ),
  QuizQuestion(
    id: 'q_nosebleed',
    prompt: LocalizedText(
      en: 'How should someone sit during a nosebleed?',
      ar: 'اللي بينزف من مناخيره يقعد إزاي؟',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'Head tipped back', ar: 'راسه مايلة لورا'),
      LocalizedText(en: 'Leaning forward', ar: 'مايل لقدام'),
      LocalizedText(en: 'Lying flat', ar: 'نايم على ضهره'),
      LocalizedText(en: 'It makes no difference', ar: 'مش فارقة'),
    ],
    answerIndex: 1,
    explanation: LocalizedText(
      en: 'Leaning back sends blood down the throat, which causes vomiting. Lean forward and pinch the soft part for ten minutes.',
      ar: 'الميلان لورا بيوصّل الدم للزور وبيسبب ترجيع. ميل لقدام واقرص الجزء الطري عشر دقايق.',
    ),
  ),
  QuizQuestion(
    id: 'q_diabetic_sugar',
    topicId: 'diabetic_coma',
    prompt: LocalizedText(
      en: 'A diabetic person is confused and sweating but awake. You are not sure if their sugar is high or low.',
      ar: 'مريض سكر مشوّش وبيعرق بس واعي. مش متأكد سكره عالي ولا واطي.',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'Give something sweet', ar: 'تديله حاجة سكر'),
      LocalizedText(en: 'Give insulin', ar: 'تديله أنسولين'),
      LocalizedText(en: 'Give plain water only', ar: 'تديله ميّه بس'),
      LocalizedText(en: 'Wait and watch', ar: 'تستنى وتراقب'),
    ],
    answerIndex: 0,
    explanation: LocalizedText(
      en: 'Low sugar kills far faster than high sugar. If you are wrong, a little sugar does almost no harm.',
      ar: 'السكر الواطي بيقتل أسرع بكتير من العالي. ولو كنت غلطان، شوية سكر مش هيضروا تقريبًا.',
    ),
  ),
  QuizQuestion(
    id: 'q_anaphylaxis_site',
    topicId: 'anaphylaxis',
    prompt: LocalizedText(
      en: 'Where does an adrenaline auto-injector go?',
      ar: 'قلم الأدرينالين بيتحط فين؟',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'The upper arm', ar: 'أعلى الذراع'),
      LocalizedText(en: 'The outer thigh', ar: 'الفخذ من برّه'),
      LocalizedText(en: 'Under the tongue', ar: 'تحت اللسان'),
      LocalizedText(en: 'Into a vein', ar: 'في الوريد'),
    ],
    answerIndex: 1,
    explanation: LocalizedText(
      en: 'The outer middle of the thigh, at a right angle, through clothing if you have to.',
      ar: 'وسط الفخذ من برّه، عمودي، ومن فوق الهدوم لو اضطريت.',
    ),
  ),
  QuizQuestion(
    id: 'q_anaphylaxis_after',
    topicId: 'anaphylaxis',
    prompt: LocalizedText(
      en: 'After the injection the person looks much better. What now?',
      ar: 'بعد الحقنة الشخص بقى أحسن بكتير. تعمل إيه؟',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'Send them home to rest', ar: 'تبعته البيت يرتاح'),
      LocalizedText(en: 'Call an ambulance anyway', ar: 'تتصل بالإسعاف برضه'),
      LocalizedText(en: 'Give a second injection now', ar: 'تديله حقنة تانية دلوقتي'),
      LocalizedText(en: 'Wait an hour and decide', ar: 'تستنى ساعة وتقرر'),
    ],
    answerIndex: 1,
    explanation: LocalizedText(
      en: 'Anaphylaxis can come back when the adrenaline wears off. Hospital is not optional, however well they look.',
      ar: 'الحساسية المفرطة ممكن ترجع لما مفعول الأدرينالين يخلص. المستشفى مش اختيارية مهما كان شكله كويس.',
    ),
  ),
  QuizQuestion(
    id: 'q_electric',
    topicId: 'electric_shock',
    prompt: LocalizedText(
      en: 'Someone is still touching a live wire. What do you do first?',
      ar: 'حد لسه ماسك سلك كهربا مكشوف. تعمل إيه الأول؟',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'Pull them off quickly', ar: 'تشدّه بسرعة'),
      LocalizedText(en: 'Switch the power off', ar: 'تقطع الكهربا'),
      LocalizedText(en: 'Throw water on it', ar: 'ترمي ميّه'),
      LocalizedText(en: 'Start compressions', ar: 'تبدأ ضغطات الصدر'),
    ],
    answerIndex: 1,
    explanation: LocalizedText(
      en: 'Touching them makes you part of the circuit. Power off first; if you cannot, push the source away with something dry and wooden.',
      ar: 'لو لمسته هتبقى جزء من الدايرة. اقطع الكهربا الأول؛ ولو مقدرتش، ابعد المصدر بحاجة خشب ناشفة.',
    ),
  ),
  QuizQuestion(
    id: 'q_fracture_straighten',
    topicId: 'fracture',
    prompt: LocalizedText(
      en: 'A forearm is bent at an obvious wrong angle. What do you do?',
      ar: 'ساعد متعوّج بزاوية باين إنها غلط. تعمل إيه؟',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'Straighten it gently', ar: 'تعدّله برفق'),
      LocalizedText(en: 'Support it as you found it', ar: 'تثبّته زي ما لقيته'),
      LocalizedText(en: 'Pull on it to realign', ar: 'تشدّه عشان يترصّ'),
      LocalizedText(en: 'Massage the area', ar: 'تدلّك المكان'),
    ],
    answerIndex: 1,
    explanation: LocalizedText(
      en: 'Moving a broken bone can cut nerves and vessels that the break itself missed.',
      ar: 'تحريك العضمة المكسورة ممكن يقطع أعصاب وأوعية الكسر نفسه ماوصلهاش.',
    ),
  ),
  QuizQuestion(
    id: 'q_heat_signs',
    topicId: 'heat_stroke',
    prompt: LocalizedText(
      en: 'Which sign is the most worrying in someone who has been out in the heat?',
      ar: 'إيه أخطر علامة في حد قعد في الحر؟',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'Heavy sweating', ar: 'عرق غزير'),
      LocalizedText(en: 'Thirst', ar: 'عطش'),
      LocalizedText(en: 'Confusion', ar: 'تشوّش'),
      LocalizedText(en: 'Tiredness', ar: 'إرهاق'),
    ],
    answerIndex: 2,
    explanation: LocalizedText(
      en: 'Confusion means the brain is affected — that is heat stroke, not heat exhaustion, and it is an emergency.',
      ar: 'التشوّش معناه المخ اتأثر — دي ضربة شمس مش إجهاد حراري، ودي حالة طارئة.',
    ),
  ),
  QuizQuestion(
    id: 'q_fainting',
    topicId: 'fainting',
    prompt: LocalizedText(
      en: 'Someone has just fainted and is coming round. What helps?',
      ar: 'حد أُغمي عليه وبيفوق دلوقتي. إيه اللي بيفيد؟',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'Sit them up quickly', ar: 'تقعّده بسرعة'),
      LocalizedText(en: 'Keep them flat with legs raised', ar: 'تسيبه نايم ورجليه مرفوعة'),
      LocalizedText(en: 'Splash cold water on the face', ar: 'ترش ميّه باردة على وشه'),
      LocalizedText(en: 'Give them coffee', ar: 'تديله قهوة'),
    ],
    answerIndex: 1,
    explanation: LocalizedText(
      en: 'Blood needs to reach the brain again. Standing up too fast simply drops them a second time.',
      ar: 'الدم محتاج يوصل للمخ تاني. والقيام بسرعة بيوقّعه مرة تانية وبس.',
    ),
  ),
  QuizQuestion(
    id: 'q_drowning_after',
    topicId: 'drowning',
    prompt: LocalizedText(
      en: 'A child is pulled from a pool, coughs, and then seems completely fine. What now?',
      ar: 'طفل اتشال من حمام سباحة وكحّ وبعدين بقى كويس تمامًا. تعمل إيه؟',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'Carry on with the day', ar: 'تكمّل يومك عادي'),
      LocalizedText(en: 'Have them checked by a doctor', ar: 'تعرضه على دكتور'),
      LocalizedText(en: 'Make them cough more', ar: 'تخليه يكحّ أكتر'),
      LocalizedText(en: 'Press on their stomach', ar: 'تضغط على بطنه'),
    ],
    answerIndex: 1,
    explanation: LocalizedText(
      en: 'Breathing can deteriorate hours after water enters the lungs. Any near-drowning needs to be seen.',
      ar: 'التنفس ممكن يسوء بعد ساعات من دخول الميّه للرئة. أي حالة قرب غرق لازم تتشاف.',
    ),
  ),
  QuizQuestion(
    id: 'q_call_speaker',
    prompt: LocalizedText(
      en: 'What is the first thing to say on an emergency call?',
      ar: 'أول حاجة تقولها في مكالمة الطوارئ إيه؟',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'Your name', ar: 'اسمك'),
      LocalizedText(en: 'Your exact location', ar: 'مكانك بالظبط'),
      LocalizedText(en: 'What happened, in detail', ar: 'اللي حصل بالتفصيل'),
      LocalizedText(en: 'Your phone number', ar: 'رقم تليفونك'),
    ],
    answerIndex: 1,
    explanation: LocalizedText(
      en: 'If the line drops after the address, help is already on the way. Everything else can be filled in later.',
      ar: 'لو الخط قطع بعد العنوان، النجدة بتكون في طريقها. وأي حاجة تانية ممكن تتقال بعدين.',
    ),
  ),
  QuizQuestion(
    id: 'q_shock',
    prompt: LocalizedText(
      en: 'Pale, cold, clammy skin with fast shallow breathing suggests what?',
      ar: 'جلد شاحب وبارد ومبلول مع نَفَس سريع وسطحي — ده معناه إيه؟',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'Shock', ar: 'صدمة'),
      LocalizedText(en: 'Fever', ar: 'سخونية'),
      LocalizedText(en: 'Dehydration only', ar: 'جفاف بس'),
      LocalizedText(en: 'Nothing serious', ar: 'مافيش حاجة خطيرة'),
    ],
    answerIndex: 0,
    explanation: LocalizedText(
      en: 'Shock means the circulation is failing. Lay them down, raise the legs, keep them warm, and call for help.',
      ar: 'الصدمة معناها الدورة الدموية بتفشل. نيّمه وارفع رجليه ودفّيه واطلب النجدة.',
    ),
  ),
  QuizQuestion(
    id: 'q_button_battery',
    prompt: LocalizedText(
      en: 'A toddler has swallowed a button battery but seems fine. How urgent is it?',
      ar: 'طفل صغير بلع بطارية ساعة بس شكله كويس. الموضوع مستعجل قد إيه؟',
    ),
    options: <LocalizedText>[
      LocalizedText(en: 'Watch them for a few days', ar: 'تراقبه كام يوم'),
      LocalizedText(en: 'See a doctor next week', ar: 'تشوف دكتور الأسبوع الجاي'),
      LocalizedText(en: 'Go to hospital immediately', ar: 'تروح المستشفى فورًا'),
      LocalizedText(en: 'Give food to help it pass', ar: 'تديله أكل يساعده يعدّي'),
    ],
    answerIndex: 2,
    explanation: LocalizedText(
      en: 'A button battery starts burning through tissue within hours, long before the child looks unwell.',
      ar: 'بطارية الساعة بتبدأ تحرق الأنسجة خلال ساعات، قبل ما الطفل يبان تعبان بكتير.',
    ),
  ),
];

/// Every question the quiz can draw from: the lesson checks plus the extras.
List<QuizQuestion> get kQuizBank => <QuizQuestion>[
      for (final Lesson lesson in kLessons) lesson.check,
      ...kQuizExtras,
    ];
