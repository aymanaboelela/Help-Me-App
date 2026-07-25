import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localized_text.dart';
import '../model/learn_content.dart';

/// Short lessons, each a handful of cards and one question.
///
/// These are not the reference content restated: the topic pages answer "what
/// do I do right now", these answer "what should I already know". Each one is
/// short enough to finish while the kettle boils, which is the only length
/// anybody actually completes.
const List<Lesson> kLessons = <Lesson>[
  Lesson(
    id: 'lesson_first_minute',
    topicId: 'cpr',
    icon: Icons.timer_outlined,
    color: AppColors.accentRed,
    title: LocalizedText(en: 'The first minute', ar: 'الدقيقة الأولى'),
    summary: LocalizedText(
      en: 'What to do in the sixty seconds before you know anything else.',
      ar: 'تعمل إيه في الستين ثانية الأولى قبل ما تعرف أي حاجة تانية.',
    ),
    cards: <LessonCard>[
      LessonCard(
        title: LocalizedText(en: 'Look before you move', ar: 'بصّ قبل ما تتحرك'),
        body: LocalizedText(
          en: 'Traffic, fire, live wires, gas, water. The first rule of first aid is not becoming the second casualty — you cannot help anyone from the floor next to them.',
          ar: 'عربيات، حريقة، أسلاك مكشوفة، غاز، ميّه. أول قاعدة في الإسعاف إنك ماتبقاش المصاب التاني — مش هتقدر تساعد حد وانت واقع جنبه.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Speak to them', ar: 'كلّمه'),
        body: LocalizedText(
          en: 'Say who you are and squeeze their shoulders. Someone who answers you is breathing and has a pulse — that rules out the two things that kill fastest.',
          ar: 'قوله إنت مين واضغط على كتفيه. اللي بيرد عليك ده بيتنفس وقلبه شغال — وده بيستبعد أخطر حاجتين على طول.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Open the airway', ar: 'افتح مجرى الهوا'),
        image: 'assets/steps/cpr_head_tilt.svg',
        body: LocalizedText(
          en: 'No answer? Tilt the head back with a palm on the forehead and two fingertips under the chin, then look along the chest for ten seconds.',
          ar: 'مافيش رد؟ ميّل راسه لورا براحة إيدك على جبهته وطرف صباعين تحت دقنه، وبعدين بصّ على صدره عشر ثواني.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Then call', ar: 'وبعدين اتصل'),
        body: LocalizedText(
          en: 'Put the phone on speaker so both hands stay free. Give the address first — if the line drops after that, help is already coming.',
          ar: 'حط الموبايل على السماعة الخارجية عشان إيديك تفضل فاضية. قول العنوان الأول — لو الخط قطع بعدها، النجدة بتكون جاية.',
        ),
      ),
    ],
    check: QuizQuestion(
      id: 'q_first_minute',
      topicId: 'cpr',
      prompt: LocalizedText(
        en: 'You find someone collapsed in the street. What comes first?',
        ar: 'لقيت حد واقع في الشارع. تعمل إيه الأول؟',
      ),
      options: <LocalizedText>[
        LocalizedText(en: 'Check the scene is safe', ar: 'تتأكد إن المكان آمن'),
        LocalizedText(en: 'Start chest compressions', ar: 'تبدأ ضغطات الصدر'),
        LocalizedText(en: 'Move them off the road', ar: 'تشيله من على الطريق'),
        LocalizedText(en: 'Give them water', ar: 'تديله ميّه'),
      ],
      answerIndex: 0,
      explanation: LocalizedText(
        en: 'Everything else waits. A rescuer who is hit by a car has doubled the emergency instead of ending it.',
        ar: 'كل حاجة تانية بتستنى. المسعف اللي عربية تخبطه ضاعف الكارثة بدل ما ينهيها.',
      ),
    ),
  ),
  Lesson(
    id: 'lesson_cpr',
    topicId: 'cpr',
    icon: Icons.favorite,
    color: AppColors.accentRed,
    title: LocalizedText(en: 'CPR that works', ar: 'إنعاش بيشتغل فعلًا'),
    summary: LocalizedText(
      en: 'Where the hands go, how deep, how fast, and why the release matters.',
      ar: 'الإيد بتتحط فين، وبتضغط قد إيه، وبأي سرعة، وليه الرفع مهم.',
    ),
    cards: <LessonCard>[
      LessonCard(
        title: LocalizedText(en: 'Centre of the chest', ar: 'منتصف الصدر'),
        image: 'assets/steps/cpr_hand_position.svg',
        body: LocalizedText(
          en: 'Heel of one hand on the lower half of the breastbone, the other hand on top, fingers interlocked and lifted off the ribs.',
          ar: 'كعب إيد واحدة على النص السفلي من عظمة القص، والتانية فوقها، والأصابع متشابكة ومرفوعة عن الضلوع.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Hard and fast', ar: 'بقوة وبسرعة'),
        image: 'assets/steps/cpr_compressions.svg',
        body: LocalizedText(
          en: '5–6 cm deep, 100–120 a minute. Shoulders straight over your hands and arms locked, so the push comes from your body, not your arms — arms tire in ninety seconds.',
          ar: 'عمق ٥–٦ سم، و١٠٠–١٢٠ في الدقيقة. كتفك فوق إيدك مباشرة وذراعك مفرودة، عشان الضغط يجي من جسمك مش من دراعك — الدراع بيتعب في تسعين ثانية.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Let it come back up', ar: 'سيبه يرجع لفوق'),
        body: LocalizedText(
          en: 'The chest refills with blood on the way up, not on the way down. Leaning on it between compressions is the commonest way to make CPR useless.',
          ar: 'الصدر بيمتلي بالدم وهو راجع لفوق، مش وهو نازل. الاتكاء عليه بين الضغطات أشهر سبب بيخلّي الإنعاش من غير فايدة.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Do not stop', ar: 'ماتوقفش'),
        body: LocalizedText(
          en: 'Keep going until help arrives, they start breathing normally, or you physically cannot continue. If someone else is there, swap every two minutes.',
          ar: 'كمّل لحد ما النجدة توصل، أو يبدأ يتنفس طبيعي، أو ماتبقاش قادر جسديًا. ولو في حد تاني معاك، بدّلوا كل دقيقتين.',
        ),
      ),
    ],
    check: QuizQuestion(
      id: 'q_cpr_rate',
      topicId: 'cpr',
      prompt: LocalizedText(
        en: 'How fast should chest compressions be?',
        ar: 'ضغطات الصدر بتبقى بأي سرعة؟',
      ),
      options: <LocalizedText>[
        LocalizedText(en: '40–60 a minute', ar: '٤٠–٦٠ في الدقيقة'),
        LocalizedText(en: '100–120 a minute', ar: '١٠٠–١٢٠ في الدقيقة'),
        LocalizedText(en: '160–180 a minute', ar: '١٦٠–١٨٠ في الدقيقة'),
        LocalizedText(en: 'As fast as you can', ar: 'أسرع ما تقدر'),
      ],
      answerIndex: 1,
      explanation: LocalizedText(
        en: 'About two a second. Faster than that and the chest never refills between pushes.',
        ar: 'حوالي اتنين في الثانية. أسرع من كده والصدر مابيمتليش بين الضغطات.',
      ),
    ),
  ),
  Lesson(
    id: 'lesson_choking',
    topicId: 'choking',
    icon: Icons.air,
    color: AppColors.accentOrange,
    title: LocalizedText(en: 'When someone is choking', ar: 'لما حد يختنق'),
    summary: LocalizedText(
      en: 'The one question that decides what you do next.',
      ar: 'السؤال الوحيد اللي بيحدد هتعمل إيه بعد كده.',
    ),
    cards: <LessonCard>[
      LessonCard(
        title: LocalizedText(en: 'Can they cough?', ar: 'بيقدر يكحّ؟'),
        body: LocalizedText(
          en: 'If they can cough forcefully, stand by and let them. Their own cough moves more air than anything you can do from outside.',
          ar: 'لو بيقدر يكحّ بقوة، قف جنبه وسيبه. الكحة بتاعته بتحرّك هوا أكتر من أي حاجة تقدر تعملها من بره.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Silent means act', ar: 'الصمت معناه اتحرك'),
        image: 'assets/steps/choking_back_blows.svg',
        body: LocalizedText(
          en: 'No sound, no cough, clutching the throat: lean them well forward and give five sharp blows between the shoulder blades with the heel of your hand.',
          ar: 'مافيش صوت ولا كحة وماسك زوره: ميّله لقدام كويس واضربه خمس ضربات قوية بين لوحي الكتف بكعب إيدك.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Then five thrusts', ar: 'وبعدين خمس ضغطات'),
        image: 'assets/steps/choking_abdominal_thrusts.svg',
        body: LocalizedText(
          en: 'Still stuck? Stand behind, fist just above the navel, pull sharply inwards and upwards five times. Then alternate: five blows, five thrusts.',
          ar: 'لسه؟ قف وراه، وحط قبضة إيدك فوق السرّة على طول، واشدّ بقوة لجوه ولفوق خمس مرات. وبعدين بدّل: خمس ضربات وخمس ضغطات.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Babies are different', ar: 'الرضّع مختلفين'),
        image: 'assets/steps/choking_infant.svg',
        body: LocalizedText(
          en: 'A baby goes face down along your forearm, head lower than the chest, for back blows — then chest thrusts, never abdominal ones.',
          ar: 'الرضيع بيتحط على وشه على طول ذراعك وراسه أوطى من صدره للضربات الظهرية — وبعدها ضغطات على الصدر، مش على البطن أبدًا.',
        ),
      ),
    ],
    check: QuizQuestion(
      id: 'q_choking_cough',
      topicId: 'choking',
      prompt: LocalizedText(
        en: 'Someone is choking but coughing loudly. What do you do?',
        ar: 'حد بيختنق بس بيكحّ بصوت عالي. تعمل إيه؟',
      ),
      options: <LocalizedText>[
        LocalizedText(en: 'Five back blows immediately', ar: 'خمس ضربات على ظهره فورًا'),
        LocalizedText(en: 'Encourage them to keep coughing', ar: 'تشجّعه يفضل يكحّ'),
        LocalizedText(en: 'Reach into the mouth', ar: 'تدخّل إيدك في بقّه'),
        LocalizedText(en: 'Give them water to drink', ar: 'تديله ميّه يشربها'),
      ],
      answerIndex: 1,
      explanation: LocalizedText(
        en: 'A forceful cough means air is still moving. Hitting them can dislodge the object into a worse position.',
        ar: 'الكحة القوية معناها الهوا لسه بيتحرك. الضرب ساعتها ممكن يحرّك الجسم لمكان أسوأ.',
      ),
    ),
  ),
  Lesson(
    id: 'lesson_bleeding',
    topicId: 'bleeding',
    icon: Icons.water_drop_outlined,
    color: AppColors.accentCrimson,
    title: LocalizedText(en: 'Stopping bad bleeding', ar: 'إيقاف النزيف الشديد'),
    summary: LocalizedText(
      en: 'Pressure, patience, and the mistake almost everybody makes.',
      ar: 'ضغط وصبر، والغلطة اللي بيقع فيها الناس كلها تقريبًا.',
    ),
    cards: <LessonCard>[
      LessonCard(
        title: LocalizedText(en: 'Press on the wound itself', ar: 'اضغط على الجرح نفسه'),
        image: 'assets/steps/bleeding_direct_pressure.svg',
        body: LocalizedText(
          en: 'Hard, directly on the bleeding point, through a clean pad or your gloved hand. Not around it — on it.',
          ar: 'بقوة، على نقطة النزيف نفسها، من فوق شاش نضيف أو إيدك بالقفاز. مش حواليه — عليه.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Do not look', ar: 'ماترفعش عشان تبصّ'),
        body: LocalizedText(
          en: 'Lifting the pad to check tears away the clot that was forming and restarts the bleeding. This is the commonest mistake there is.',
          ar: 'رفع الشاش عشان تتطمن بيقلع الجلطة اللي كانت بتتكوّن ويرجّع النزيف. دي أشهر غلطة على الإطلاق.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Add, never replace', ar: 'زوّد، ماتبدّلش'),
        body: LocalizedText(
          en: 'Blood soaking through? Put another dressing on top and keep pressing. The first one stays where it is.',
          ar: 'الدم نفذ؟ حط شاش تاني فوقه وفضل ضاغط. الأولاني يفضل مكانه.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Tourniquets are a last resort', ar: 'الرباط الضاغط آخر حل'),
        image: 'assets/steps/bleeding_tourniquet.svg',
        body: LocalizedText(
          en: 'Only for life-threatening bleeding from a limb that pressure will not stop. Above the wound, never on a joint, and note the time.',
          ar: 'بس في النزيف المهدد للحياة من طرف والضغط مش وقّفه. فوق الجرح، ومطلقًا مش على مفصل، وسجّل الوقت.',
        ),
      ),
    ],
    check: QuizQuestion(
      id: 'q_bleeding_soak',
      topicId: 'bleeding',
      prompt: LocalizedText(
        en: 'Blood soaks through the dressing you are pressing on. What now?',
        ar: 'الدم نفذ من الشاش اللي انت ضاغط عليه. تعمل إيه؟',
      ),
      options: <LocalizedText>[
        LocalizedText(en: 'Take it off and use a clean one', ar: 'تشيله وتحط واحد نضيف'),
        LocalizedText(en: 'Add another on top and keep pressing', ar: 'تحط واحد فوقه وتفضل ضاغط'),
        LocalizedText(en: 'Wash the wound first', ar: 'تغسل الجرح الأول'),
        LocalizedText(en: 'Lift the pad to see the wound', ar: 'ترفع الشاش تشوف الجرح'),
      ],
      answerIndex: 1,
      explanation: LocalizedText(
        en: 'Removing the soaked dressing pulls the clot off with it. Everything goes on top.',
        ar: 'شيل الشاش المتشرّب بيقلع الجلطة معاه. كل حاجة بتتحط من فوق.',
      ),
    ),
  ),
  Lesson(
    id: 'lesson_recovery',
    topicId: 'swallowed_tongue',
    icon: Icons.airline_seat_flat,
    color: AppColors.accentTeal,
    title: LocalizedText(en: 'The recovery position', ar: 'وضع الإفاقة'),
    summary: LocalizedText(
      en: 'The single position that saves unconscious people who are breathing.',
      ar: 'الوضع الوحيد اللي بينقذ فاقد الوعي اللي بيتنفس.',
    ),
    cards: <LessonCard>[
      LessonCard(
        title: LocalizedText(en: 'Why on the side', ar: 'ليه على الجنب'),
        image: 'assets/steps/recovery_position.svg',
        body: LocalizedText(
          en: 'On their back, an unconscious person can be killed by their own tongue or their own vomit. On their side, both drain away from the airway.',
          ar: 'على ضهره، فاقد الوعي ممكن يموت من لسانه أو من القيء بتاعه. على جنبه، الاتنين بيبعدوا عن مجرى الهوا.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'The bent knee', ar: 'الرُكبة المثنية'),
        body: LocalizedText(
          en: 'The top knee is bent to a right angle and rests on the ground. That is what stops them rolling face down while you are busy calling.',
          ar: 'الرُكبة العليا بتتثني زاوية قايمة وترتاح على الأرض. دي اللي بتمنعه إنه يلف على وشه وانت مشغول بالاتصال.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Head tipped back', ar: 'الراس مايلة لورا'),
        body: LocalizedText(
          en: 'Rest the cheek on the hand and tilt the head back slightly, so the mouth points down and the airway stays open.',
          ar: 'حط خده على إيده وميّل راسه لورا شوية، عشان بقّه يبقى لتحت ومجرى الهوا يفضل مفتوح.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Keep watching', ar: 'فضل مراقب'),
        body: LocalizedText(
          en: 'Check breathing every minute. If it stops, roll them onto their back and start compressions.',
          ar: 'اتأكد من تنفسه كل دقيقة. لو وقف، لفّه على ضهره وابدأ ضغطات الصدر.',
        ),
      ),
    ],
    check: QuizQuestion(
      id: 'q_recovery_when',
      topicId: 'swallowed_tongue',
      prompt: LocalizedText(
        en: 'Who goes into the recovery position?',
        ar: 'مين اللي بيتحط في وضع الإفاقة؟',
      ),
      options: <LocalizedText>[
        LocalizedText(
          en: 'Anyone unconscious who is breathing',
          ar: 'أي حد فاقد الوعي وبيتنفس',
        ),
        LocalizedText(en: 'Anyone unconscious, breathing or not', ar: 'أي فاقد وعي، بيتنفس أو لأ'),
        LocalizedText(en: 'Anyone with a suspected broken back', ar: 'أي حد يُشتبه في كسر بضهره'),
        LocalizedText(en: 'Anyone who feels dizzy', ar: 'أي حد حاسس بدوخة'),
      ],
      answerIndex: 0,
      explanation: LocalizedText(
        en: 'Breathing is the condition. Someone not breathing needs compressions on their back, not a side position.',
        ar: 'التنفس هو الشرط. اللي مش بيتنفس محتاج ضغطات وهو على ضهره، مش وضع جانبي.',
      ),
    ),
  ),
  Lesson(
    id: 'lesson_burns',
    topicId: 'burns',
    icon: Icons.local_fire_department_outlined,
    color: AppColors.accentOrange,
    title: LocalizedText(en: 'Burns, and the myths', ar: 'الحروق والخرافات'),
    summary: LocalizedText(
      en: 'Twenty minutes of water, and a list of things never to put on a burn.',
      ar: 'عشرين دقيقة ميّه، وقايمة حاجات ماتتحطش على الحرق أبدًا.',
    ),
    cards: <LessonCard>[
      LessonCard(
        title: LocalizedText(en: 'Cool water, twenty minutes', ar: 'ميّه باردة، عشرين دقيقة'),
        image: 'assets/steps/burns_cool_water.svg',
        body: LocalizedText(
          en: 'Running, cool — not iced. Twenty minutes sounds long because it is; a burn keeps cooking after the heat is gone, and this is what stops it.',
          ar: 'جارية وباردة — مش متلجة. العشرين دقيقة بتبان كتير لأنها كده فعلًا؛ الحرق بيفضل بيتمدد بعد ما الحرارة تروح، والميّه هي اللي بتوقّفه.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Take things off early', ar: 'شيل الحاجات بدري'),
        body: LocalizedText(
          en: 'Rings, watches and tight clothing come off before the swelling starts. Anything stuck to the skin stays exactly where it is.',
          ar: 'الخواتم والساعة والهدوم الضيقة تتشال قبل ما الورم يبدأ. وأي حاجة لازقة في الجلد تفضل مكانها بالظبط.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Nothing else goes on it', ar: 'مافيش حاجة تانية تتحط عليه'),
        body: LocalizedText(
          en: 'No ice, no butter, no toothpaste, no flour. Ice causes a second injury; the rest trap heat and have to be scrubbed off later.',
          ar: 'لا تلج ولا زبدة ولا معجون أسنان ولا دقيق. التلج بيعمل إصابة تانية؛ والباقي بيحبس الحرارة ولازم يتشال بالدعك بعدين.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Cover loosely', ar: 'غطّيه بخفة'),
        body: LocalizedText(
          en: 'Cling film or a clean non-fluffy cloth, laid on, not wrapped tight. And never burst a blister.',
          ar: 'فيلم بلاستيك أو قماشة نضيفة من غير وبر، متحطوطة مش مربوطة بشد. وماتفقعش الفقاعات أبدًا.',
        ),
      ),
    ],
    check: QuizQuestion(
      id: 'q_burn_time',
      topicId: 'burns',
      prompt: LocalizedText(
        en: 'How long should a burn be cooled under running water?',
        ar: 'الحرق يتبرد تحت الميّه الجارية قد إيه؟',
      ),
      options: <LocalizedText>[
        LocalizedText(en: 'Until it stops hurting', ar: 'لحد ما الوجع يروح'),
        LocalizedText(en: 'About one minute', ar: 'حوالي دقيقة'),
        LocalizedText(en: 'At least twenty minutes', ar: 'عشرين دقيقة على الأقل'),
        LocalizedText(en: 'Five minutes, then ice', ar: 'خمس دقايق وبعدين تلج'),
      ],
      answerIndex: 2,
      explanation: LocalizedText(
        en: 'The pain often eases long before the tissue has stopped burning. Twenty minutes is the number to remember.',
        ar: 'الوجع بيهدى غالبًا قبل ما النسيج يبطّل يحترق بكتير. العشرين دقيقة هي الرقم اللي تفتكره.',
      ),
    ),
  ),
  Lesson(
    id: 'lesson_stroke',
    topicId: 'stroke',
    icon: Icons.psychology_outlined,
    color: AppColors.accentIndigo,
    title: LocalizedText(en: 'Spotting a stroke', ar: 'اكتشاف السكتة الدماغية'),
    summary: LocalizedText(
      en: 'Three checks that take fifteen seconds, and why the clock matters.',
      ar: 'تلات فحوصات بتاخد خمستاشر ثانية، وليه الوقت فارق.',
    ),
    cards: <LessonCard>[
      LessonCard(
        title: LocalizedText(en: 'Face', ar: 'الوش'),
        image: 'assets/steps/stroke_face_droop.svg',
        body: LocalizedText(
          en: 'Ask them to smile. Does one side fall away, or one eye or mouth droop? Compare the two halves against each other, not against how they usually look.',
          ar: 'اطلب منه يبتسم. في ناحية واقعة، أو عين أو ناحية بق نازلة؟ قارن النصين ببعض، مش بشكله المعتاد.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Arms', ar: 'الذراعين'),
        body: LocalizedText(
          en: 'Ask them to raise both arms and hold them there. Does one drift down on its own?',
          ar: 'اطلب منه يرفع دراعيه الاتنين ويثبتهم. في واحدة بتنزل لوحدها؟',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Speech', ar: 'الكلام'),
        body: LocalizedText(
          en: 'Ask a simple question. Is the speech slurred, jumbled, or missing words they are clearly reaching for?',
          ar: 'اسأله سؤال بسيط. الكلام متلعثم، أو مخربط، أو بيدوّر على كلمات وماتجيش؟',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Time', ar: 'الوقت'),
        body: LocalizedText(
          en: 'Any one of the three means call now. Note the time the symptoms started — the treatment that reverses a stroke has a window, and the hospital will ask for that time.',
          ar: 'أي واحدة من التلاتة معناها اتصل حالًا. واحفظ وقت بداية الأعراض — العلاج اللي بيعكس السكتة ليه نافذة زمنية، والمستشفى هتسألك على الوقت ده.',
        ),
      ),
    ],
    check: QuizQuestion(
      id: 'q_stroke_time',
      topicId: 'stroke',
      prompt: LocalizedText(
        en: 'Why does the hospital want to know when the symptoms started?',
        ar: 'ليه المستشفى عايزة تعرف الأعراض بدأت إمتى؟',
      ),
      options: <LocalizedText>[
        LocalizedText(en: 'For the paperwork', ar: 'عشان الأوراق'),
        LocalizedText(
          en: 'The treatment only works within a time window',
          ar: 'العلاج بينفع بس في نافذة زمنية معينة',
        ),
        LocalizedText(en: 'To work out the cause', ar: 'عشان يعرفوا السبب'),
        LocalizedText(en: 'It does not really matter', ar: 'مش فارقة فعليًا'),
      ],
      answerIndex: 1,
      explanation: LocalizedText(
        en: 'Clot-busting treatment has a hard deadline from the moment symptoms began. Knowing the time can decide whether it can be given at all.',
        ar: 'علاج إذابة الجلطة ليه وقت نهائي من لحظة بداية الأعراض. معرفة الوقت ممكن تحدد إذا كان ينفع يتعطى أصلًا.',
      ),
    ),
  ),
  Lesson(
    id: 'lesson_kit',
    icon: Icons.medical_services_outlined,
    color: AppColors.accentGreen,
    title: LocalizedText(en: 'A kit that works', ar: 'شنطة إسعاف شغالة'),
    summary: LocalizedText(
      en: 'What actually belongs in it, and why most kits fail on the day.',
      ar: 'اللي المفروض يكون فيها فعلًا، وليه أغلب الشنط بتخذل أصحابها في اليوم المهم.',
    ),
    cards: <LessonCard>[
      LessonCard(
        title: LocalizedText(en: 'Dressings before gadgets', ar: 'الضمادات قبل الأدوات'),
        body: LocalizedText(
          en: 'Sterile gauze in several sizes does more work than everything else combined. Buy more of it than you think you need.',
          ar: 'الشاش المعقّم بمقاسات مختلفة بيعمل شغل أكتر من كل حاجة تانية مجتمعة. اشتري منه أكتر من اللي فاكر إنك محتاجه.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Expiry dates kill kits', ar: 'تواريخ الصلاحية بتقتل الشنط'),
        body: LocalizedText(
          en: 'Antiseptic, burn gel and plasters all expire quietly. A kit nobody has checked in three years is a box of expired things.',
          ar: 'المطهّر وجل الحروق والبلاستر كلهم بينتهوا في صمت. الشنطة اللي محدش راجعها من تلات سنين دي علبة حاجات منتهية.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Protect yourself', ar: 'احمي نفسك'),
        body: LocalizedText(
          en: 'Gloves and a CPR face shield cost almost nothing and are the reason you can help a stranger without hesitating.',
          ar: 'القفازات وواقي الوجه للتنفس الصناعي تمنهم لا شيء تقريبًا، وهما السبب اللي يخليك تساعد غريب من غير تردد.',
        ),
      ),
      LessonCard(
        title: LocalizedText(en: 'Paper beats battery', ar: 'الورق أقوى من البطارية'),
        body: LocalizedText(
          en: 'Emergency numbers and the family\'s medical details, written on paper, in the kit. A flat phone should never be the reason nobody gets called.',
          ar: 'أرقام الطوارئ والبيانات الطبية للعيلة مكتوبة على ورق جوه الشنطة. موبايل فاصل بطارية ماينفعش يكون السبب إن محدش اتصل.',
        ),
      ),
    ],
    check: QuizQuestion(
      id: 'q_kit_fail',
      prompt: LocalizedText(
        en: 'What most often makes a home first-aid kit useless?',
        ar: 'إيه أكتر حاجة بتخلي شنطة الإسعاف في البيت مش نافعة؟',
      ),
      options: <LocalizedText>[
        LocalizedText(en: 'It is too small', ar: 'إنها صغيرة'),
        LocalizedText(en: 'Its contents have expired', ar: 'إن اللي جواها منتهي الصلاحية'),
        LocalizedText(en: 'It is the wrong colour', ar: 'إن لونها غلط'),
        LocalizedText(en: 'It has too many bandages', ar: 'إن فيها ضمادات كتير'),
      ],
      answerIndex: 1,
      explanation: LocalizedText(
        en: 'Nothing in the box announces that it has expired. Checking twice a year is the whole trick.',
        ar: 'مافيش حاجة في العلبة بتقولك إنها انتهت. المراجعة مرتين في السنة هي الحكاية كلها.',
      ),
    ),
  ),
];
