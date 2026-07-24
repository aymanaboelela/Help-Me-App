import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localized_text.dart';
import '../model/first_aid_topic.dart';

/// Additional life-saving topics added in the 2.0 rebuild. Content follows
/// widely taught first-aid guidance and is intentionally conservative.
const List<FirstAidTopic> kExtendedTopics = <FirstAidTopic>[
  // 8) CPR --------------------------------------------------------------------
  FirstAidTopic(
    id: 'cpr',
    category: TopicCategory.cardiac,
    icon: Icons.monitor_heart,
    color: AppColors.accentCrimson,
    showMetronome: true,
    title: LocalizedText(en: 'CPR (resuscitation)', ar: 'الإنعاش القلبي الرئوي'),
    summary: LocalizedText(
      en: 'Chest compressions and rescue breaths for someone not breathing.',
      ar: 'ضغطات الصدر والتنفس الإنقاذي لمن توقف تنفسه.',
    ),
    overview: LocalizedText(
      en: 'Start CPR when an adult is unresponsive and not breathing normally. Every second counts.',
      ar: 'ابدأ الإنعاش القلبي الرئوي عندما يكون البالغ غير مستجيب ولا يتنفس بشكل طبيعي. كل ثانية لها قيمة.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'Steps', ar: 'الخطوات'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Check for a response and shout for help. Call an ambulance (123) and get an AED if one is nearby.',
            ar: 'تحقق من استجابة الشخص واطلب المساعدة، واتصل بالإسعاف (123) وأحضر جهاز صدمات (AED) إن وُجد قريبًا.',
          ),
          LocalizedText(
            en: 'Check breathing for no more than 10 seconds. If breathing is absent or not normal, start CPR.',
            ar: 'افحص التنفس لمدة لا تزيد عن 10 ثوانٍ، وإذا كان التنفس غائبًا أو غير طبيعي فابدأ الإنعاش.',
          ),
          LocalizedText(
            en: 'Kneel beside the person. Place the heel of one hand in the centre of the chest and the other hand on top, fingers interlocked.',
            ar: 'اركع بجانب الشخص، وضع كعب إحدى يديك في منتصف الصدر واليد الأخرى فوقها مع تشبيك الأصابع.',
          ),
          LocalizedText(
            en: 'Push hard and fast: compress about 5 to 6 cm deep at a rate of 100 to 120 per minute, allowing the chest to rise fully between compressions.',
            ar: 'اضغط بقوة وسرعة: بعمق حوالي 5 إلى 6 سم وبمعدل 100 إلى 120 ضغطة في الدقيقة، مع السماح للصدر بالعودة بالكامل بين كل ضغطة والأخرى.',
          ),
          LocalizedText(
            en: 'After 30 compressions give 2 rescue breaths: tilt the head, lift the chin, pinch the nose and blow until the chest rises (about 1 second each).',
            ar: 'بعد كل 30 ضغطة أعطِ نفسين إنقاذيين: أمِل الرأس وارفع الذقن واقرص الأنف وانفخ حتى يرتفع الصدر (حوالي ثانية لكل نفس).',
          ),
          LocalizedText(
            en: 'Continue cycles of 30 compressions to 2 breaths without stopping until the person recovers, help arrives, or you are exhausted.',
            ar: 'استمر في دورات من 30 ضغطة مقابل نفسين دون توقف حتى يتعافى الشخص أو يصل المسعفون أو تُنهكك القوى.',
          ),
          LocalizedText(
            en: 'If you are untrained or unwilling to give breaths, give continuous chest compressions only (hands-only CPR).',
            ar: 'إذا لم تكن مدربًا أو لا ترغب في إعطاء الأنفاس، فاكتفِ بالضغطات المتواصلة على الصدر فقط.',
          ),
          LocalizedText(
            en: 'If an AED arrives, switch it on and follow its spoken instructions.',
            ar: 'إذا توفر جهاز الصدمات (AED) فشغّله واتبع تعليماته الصوتية.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.danger,
            text: LocalizedText(
              en: 'Call an ambulance (123) before starting, or ask someone else to call while you begin CPR.',
              ar: 'اتصل بالإسعاف (123) قبل البدء، أو اطلب من شخص آخر الاتصال بينما تبدأ أنت الإنعاش.',
            ),
          ),
        ],
      ),
    ],
  ),

  // 9) Choking ----------------------------------------------------------------
  FirstAidTopic(
    id: 'choking',
    category: TopicCategory.breathing,
    icon: Icons.air,
    color: AppColors.accentTeal,
    title: LocalizedText(en: 'Choking', ar: 'الاختناق (الشرقة)'),
    summary: LocalizedText(
      en: 'Back blows and abdominal thrusts to clear a blocked airway.',
      ar: 'الضربات الخلفية والضغطات البطنية لإزالة انسداد مجرى الهواء.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'Adult or child (over 1 year)', ar: 'البالغ أو الطفل (فوق سنة)'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Ask "are you choking?" If the person can cough, encourage them to keep coughing.',
            ar: 'اسأل: "هل تختنق؟" إذا كان الشخص قادرًا على السعال فشجعه على الاستمرار في السعال.',
          ),
          LocalizedText(
            en: 'If they cannot cough, breathe or speak, give up to 5 sharp back blows between the shoulder blades with the heel of your hand.',
            ar: 'إذا لم يستطع السعال أو التنفس أو الكلام، فوجّه حتى 5 ضربات حازمة بين لوحي الكتف بكعب يدك.',
          ),
          LocalizedText(
            en: 'If that fails, give up to 5 abdominal thrusts: stand behind, make a fist just above the navel, grasp it with the other hand and pull sharply inward and upward.',
            ar: 'إذا لم تنجح، فوجّه حتى 5 ضغطات بطنية: قف خلف الشخص، واصنع قبضة فوق السرة مباشرة، وأمسكها باليد الأخرى واسحب بقوة للداخل وللأعلى.',
          ),
          LocalizedText(
            en: 'Alternate 5 back blows and 5 abdominal thrusts until the object is cleared.',
            ar: 'بادل بين 5 ضربات خلفية و5 ضغطات بطنية حتى يخرج الجسم العالق.',
          ),
          LocalizedText(
            en: 'If the person becomes unconscious, lower them to the ground, call an ambulance and start CPR.',
            ar: 'إذا فقد الشخص وعيه، فأنزله على الأرض واتصل بالإسعاف وابدأ الإنعاش القلبي الرئوي.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.tip,
            text: LocalizedText(
              en: 'For infants under 1 year, use 5 back blows and 5 chest thrusts — never abdominal thrusts.',
              ar: 'للرضّع أقل من سنة، استخدم 5 ضربات خلفية و5 ضغطات على الصدر — ولا تستخدم الضغطات البطنية أبدًا.',
            ),
          ),
        ],
      ),
    ],
  ),

  // 10) Drowning --------------------------------------------------------------
  FirstAidTopic(
    id: 'drowning',
    category: TopicCategory.environmental,
    icon: Icons.pool,
    color: AppColors.accentBlue,
    title: LocalizedText(en: 'Drowning', ar: 'الغرق'),
    summary: LocalizedText(
      en: 'Rescuing safely and resuscitating a drowning casualty.',
      ar: 'الإنقاذ الآمن وإنعاش الغريق.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'First aid', ar: 'الإسعافات الأولية'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Protect yourself first. Do not enter dangerous water — reach out with an object or throw a float instead.',
            ar: 'احمِ نفسك أولًا. لا تدخل المياه الخطرة، بل مُد للشخص شيئًا يمسكه أو ارمِ له عوّامة.',
          ),
          LocalizedText(
            en: 'Get the person out of the water and call an ambulance.',
            ar: 'أخرج الشخص من الماء واتصل بالإسعاف.',
          ),
          LocalizedText(
            en: 'If not breathing, give 5 initial rescue breaths, then start CPR with cycles of 30 compressions to 2 breaths.',
            ar: 'إذا لم يكن يتنفس، فأعطِ 5 أنفاس إنقاذية أولية ثم ابدأ الإنعاش بدورات من 30 ضغطة مقابل نفسين.',
          ),
          LocalizedText(
            en: 'Keep the person warm: remove wet clothes and cover them.',
            ar: 'حافظ على دفء الشخص: انزع الملابس المبللة وغطّه.',
          ),
          LocalizedText(
            en: 'Even if the person seems fine, they must be checked by a doctor — problems can appear hours later.',
            ar: 'حتى لو بدا الشخص بخير، يجب أن يفحصه طبيب لأن المضاعفات قد تظهر بعد ساعات.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.warning,
            text: LocalizedText(
              en: 'Do not waste time trying to drain water from the lungs — start rescue breaths and CPR.',
              ar: 'لا تضيّع الوقت في محاولة إخراج الماء من الرئتين — ابدأ التنفس الإنقاذي والإنعاش.',
            ),
          ),
        ],
      ),
    ],
  ),

  // 11) Poisoning -------------------------------------------------------------
  FirstAidTopic(
    id: 'poisoning',
    category: TopicCategory.medical,
    icon: Icons.science,
    color: AppColors.accentPurple,
    title: LocalizedText(en: 'Poisoning', ar: 'التسمم'),
    summary: LocalizedText(
      en: 'Swallowed, inhaled, or skin-contact poisons.',
      ar: 'السموم المبتلعة أو المستنشقة أو الملامسة للجلد.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'First aid', ar: 'الإسعافات الأولية'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Call an ambulance or poison control. Try to identify the substance and keep its container to show the medical team.',
            ar: 'اتصل بالإسعاف أو بمركز السموم، وحاول التعرف على المادة واحتفظ بعبوتها لعرضها على الفريق الطبي.',
          ),
          LocalizedText(
            en: 'Swallowed poison: wipe the mouth. Do not give anything to eat or drink unless a professional tells you to.',
            ar: 'السم المبتلع: امسح الفم، ولا تعطِ أي طعام أو شراب إلا بتوجيه من مختص.',
          ),
          LocalizedText(
            en: 'Inhaled poison (such as gas): move the person to fresh air, making sure it is safe for you first.',
            ar: 'السم المستنشق (كالغاز): انقل الشخص إلى هواء نقي، مع التأكد من أن المكان آمن لك أولًا.',
          ),
          LocalizedText(
            en: 'Skin or eye contact: rinse with running water for 15 to 20 minutes and remove contaminated clothing.',
            ar: 'ملامسة الجلد أو العين: اشطف بالماء الجاري لمدة 15 إلى 20 دقيقة وانزع الملابس الملوثة.',
          ),
          LocalizedText(
            en: 'If unconscious but breathing, place in the recovery position. If not breathing, start CPR.',
            ar: 'إذا كان فاقدًا للوعي ويتنفس فضعه في وضع الإفاقة، وإذا توقف تنفسه فابدأ الإنعاش.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.warning,
            text: LocalizedText(
              en: 'Do not try to make the person vomit unless a medical professional instructs you to.',
              ar: 'لا تحاول جعل الشخص يتقيأ إلا إذا وجهك مختص طبي بذلك.',
            ),
          ),
        ],
      ),
    ],
  ),

  // 12) Electric shock --------------------------------------------------------
  FirstAidTopic(
    id: 'electric_shock',
    category: TopicCategory.trauma,
    icon: Icons.electric_bolt,
    color: AppColors.accentAmber,
    title: LocalizedText(en: 'Electric shock', ar: 'الصعق الكهربائي'),
    summary: LocalizedText(
      en: 'Breaking contact safely and treating the casualty.',
      ar: 'قطع التلامس بأمان وإسعاف المصاب.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'First aid', ar: 'الإسعافات الأولية'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Do not touch the person while they are still in contact with the current. Switch off the power source first.',
            ar: 'لا تلمس الشخص وهو ما زال ملامسًا للتيار. افصل مصدر الكهرباء أولًا.',
          ),
          LocalizedText(
            en: 'If you cannot switch it off, stand on something dry and use a dry non-conductive object (such as wood) to separate them from the source.',
            ar: 'إذا تعذّر فصل التيار، قف على شيء جاف واستخدم أداة جافة غير موصلة (مثل الخشب) لإبعاده عن المصدر.',
          ),
          LocalizedText(
            en: 'Once it is safe, call an ambulance.',
            ar: 'بمجرد أن يصبح المكان آمنًا، اتصل بالإسعاف.',
          ),
          LocalizedText(
            en: 'Check breathing. If it is absent, start CPR.',
            ar: 'افحص التنفس، وإذا كان غائبًا فابدأ الإنعاش القلبي الرئوي.',
          ),
          LocalizedText(
            en: 'Cool any burns at the entry and exit points with cool water and cover them with a clean dressing.',
            ar: 'برّد أي حروق عند نقطتي دخول وخروج التيار بالماء البارد وغطّها بضماد نظيف.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.danger,
            text: LocalizedText(
              en: 'High voltage or overhead power lines: stay at least 6 metres away and wait for the professionals.',
              ar: 'الجهد العالي أو أسلاك الكهرباء المعلقة: ابقَ على بُعد 6 أمتار على الأقل وانتظر المختصين.',
            ),
          ),
        ],
      ),
    ],
  ),

  // 13) Heat stroke -----------------------------------------------------------
  FirstAidTopic(
    id: 'heat_stroke',
    category: TopicCategory.environmental,
    icon: Icons.wb_sunny,
    color: AppColors.accentOrange,
    title: LocalizedText(en: 'Heat stroke', ar: 'ضربة الشمس'),
    summary: LocalizedText(
      en: 'Cooling someone with dangerously high body temperature.',
      ar: 'تبريد شخص ارتفعت حرارة جسمه بشكل خطير.',
    ),
    overview: LocalizedText(
      en: 'Signs include hot skin, a very high temperature, confusion, headache and a rapid pulse.',
      ar: 'من علاماتها سخونة الجلد وارتفاع الحرارة الشديد والتشوش والصداع وتسارع النبض.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'First aid', ar: 'الإسعافات الأولية'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Move the person to a cool, shaded place and call an ambulance.',
            ar: 'انقل الشخص إلى مكان بارد ومظلل واتصل بالإسعاف.',
          ),
          LocalizedText(
            en: 'Remove outer clothing.',
            ar: 'انزع الملابس الخارجية.',
          ),
          LocalizedText(
            en: 'Cool them quickly: wet the skin with cool water, fan them, and place cold packs on the neck, armpits and groin.',
            ar: 'برّده بسرعة: بلّل الجلد بماء بارد، وروّح عليه، وضع كمادات باردة على الرقبة وتحت الإبطين وبين الفخذين.',
          ),
          LocalizedText(
            en: 'If conscious and able to drink, give cool water.',
            ar: 'إذا كان واعيًا وقادرًا على الشرب فأعطِه ماءً باردًا.',
          ),
          LocalizedText(
            en: 'Keep cooling and monitoring until the temperature drops. If unconscious, place in the recovery position and start CPR if breathing stops.',
            ar: 'استمر في التبريد والمراقبة حتى تنخفض الحرارة. وإذا فقد الوعي فضعه في وضع الإفاقة وابدأ الإنعاش إذا توقف التنفس.',
          ),
        ],
      ),
    ],
  ),

  // 14) Fracture --------------------------------------------------------------
  FirstAidTopic(
    id: 'fracture',
    category: TopicCategory.trauma,
    icon: Icons.personal_injury,
    color: AppColors.accentIndigo,
    title: LocalizedText(en: 'Fractures', ar: 'الكسور'),
    summary: LocalizedText(
      en: 'Supporting and immobilizing a broken bone.',
      ar: 'تثبيت العظم المكسور ودعمه.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'First aid', ar: 'الإسعافات الأولية'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Keep the injured part still. Do not try to straighten it or move it.',
            ar: 'أبقِ الجزء المصاب ثابتًا، ولا تحاول تقويمه أو تحريكه.',
          ),
          LocalizedText(
            en: 'Support the limb in the position you found it, using padding such as clothing or blankets.',
            ar: 'ادعم الطرف في الوضع الذي وجدته عليه باستخدام حشوات مثل الملابس أو البطانيات.',
          ),
          LocalizedText(
            en: 'Steady and support the injury above and below the break; use a splint or sling only if you are trained.',
            ar: 'ثبّت وادعم الإصابة من أعلى ومن أسفل مكان الكسر، ولا تستخدم الجبيرة أو الحمّالة إلا إذا كنت مدربًا.',
          ),
          LocalizedText(
            en: 'Apply a cold pack wrapped in cloth to reduce swelling and pain.',
            ar: 'ضع كمادة باردة ملفوفة بقماش لتقليل التورم والألم.',
          ),
          LocalizedText(
            en: 'Do not give food or drink, as surgery may be needed.',
            ar: 'لا تعطِ طعامًا أو شرابًا لأن الأمر قد يستدعي جراحة.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.danger,
            text: LocalizedText(
              en: 'If the bone breaks the skin, or you suspect a neck or spine injury, do not move the person — call an ambulance.',
              ar: 'إذا اخترق العظم الجلد أو اشتبهت بإصابة في الرقبة أو العمود الفقري، فلا تحرك الشخص واتصل بالإسعاف.',
            ),
          ),
        ],
      ),
    ],
  ),

  // 15) Heart attack ----------------------------------------------------------
  FirstAidTopic(
    id: 'heart_attack',
    category: TopicCategory.cardiac,
    icon: Icons.favorite,
    color: AppColors.accentRed,
    title: LocalizedText(en: 'Heart attack', ar: 'الأزمة القلبية'),
    summary: LocalizedText(
      en: 'Recognizing chest pain and helping until help arrives.',
      ar: 'التعرف على ألم الصدر وإسعاف المصاب حتى وصول المساعدة.',
    ),
    overview: LocalizedText(
      en: 'Signs include central chest pain or pressure spreading to the arm, jaw or back, sweating, shortness of breath and nausea.',
      ar: 'من علاماتها ألم أو ضغط في وسط الصدر يمتد إلى الذراع أو الفك أو الظهر، مع التعرق وضيق النفس والغثيان.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'First aid', ar: 'الإسعافات الأولية'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Call an ambulance immediately.',
            ar: 'اتصل بالإسعاف فورًا.',
          ),
          LocalizedText(
            en: 'Help the person sit down and rest — a half-sitting position with knees bent is comfortable.',
            ar: 'ساعد الشخص على الجلوس والراحة، ووضعية نصف الجلوس مع ثني الركبتين مريحة له.',
          ),
          LocalizedText(
            en: 'Loosen tight clothing and keep the person calm.',
            ar: 'فك الملابس الضيقة وحافظ على هدوء الشخص.',
          ),
          LocalizedText(
            en: 'If the person is conscious and not allergic to aspirin, let them slowly chew one adult aspirin (about 300 mg).',
            ar: 'إذا كان الشخص واعيًا وغير مصاب بحساسية من الأسبرين، فدعه يمضغ ببطء قرص أسبرين للبالغين (حوالي 300 ملجم).',
          ),
          LocalizedText(
            en: 'If they have prescribed angina medication (such as a GTN spray), help them take it.',
            ar: 'إذا كان يملك دواءً موصوفًا للذبحة الصدرية (مثل بخاخ النيتروجليسرين)، فساعده على أخذه.',
          ),
          LocalizedText(
            en: 'If the person becomes unconscious and stops breathing, start CPR.',
            ar: 'إذا فقد الشخص وعيه وتوقف تنفسه، فابدأ الإنعاش القلبي الرئوي.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.danger,
            text: LocalizedText(
              en: 'Chest pain that lasts more than a few minutes is an emergency — call 123 without delay.',
              ar: 'ألم الصدر الذي يستمر أكثر من بضع دقائق حالة طارئة — اتصل بـ 123 دون تأخير.',
            ),
          ),
        ],
      ),
    ],
  ),

  // 16) Stroke ----------------------------------------------------------------
  FirstAidTopic(
    id: 'stroke',
    category: TopicCategory.medical,
    icon: Icons.psychology,
    color: AppColors.accentPink,
    title: LocalizedText(en: 'Stroke', ar: 'الجلطة الدماغية'),
    summary: LocalizedText(
      en: 'Use the FAST test and call for help fast.',
      ar: 'استخدم اختبار "فاست" واطلب المساعدة بسرعة.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'The FAST test', ar: 'اختبار فاست (FAST)'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Face: ask the person to smile — has one side of the face drooped?',
            ar: 'الوجه (Face): اطلب من الشخص أن يبتسم — هل تدلّى أحد جانبي الوجه؟',
          ),
          LocalizedText(
            en: 'Arms: can the person raise both arms and keep them up?',
            ar: 'الذراعان (Arms): هل يستطيع رفع كلتا ذراعيه وإبقاءهما مرفوعتين؟',
          ),
          LocalizedText(
            en: 'Speech: is their speech slurred or hard to understand?',
            ar: 'الكلام (Speech): هل كلامه متداخل أو يصعب فهمه؟',
          ),
          LocalizedText(
            en: 'Time: if you see any of these signs, it is time to call an ambulance at once.',
            ar: 'الوقت (Time): إذا رأيت أيًّا من هذه العلامات فقد حان وقت الاتصال بالإسعاف فورًا.',
          ),
        ],
      ),
      FirstAidSection(
        title: LocalizedText(en: 'While you wait', ar: 'أثناء الانتظار'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Call an ambulance and note the time the symptoms started.',
            ar: 'اتصل بالإسعاف وسجّل وقت بدء الأعراض.',
          ),
          LocalizedText(
            en: 'Keep the person comfortable, lying with the head and shoulders slightly raised.',
            ar: 'أبقِ الشخص مرتاحًا مستلقيًا مع رفع الرأس والكتفين قليلًا.',
          ),
          LocalizedText(
            en: 'Reassure the person and monitor their breathing. If unconscious, place in the recovery position.',
            ar: 'طمئن الشخص وراقب تنفسه، وإذا فقد الوعي فضعه في وضع الإفاقة.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.warning,
            text: LocalizedText(
              en: 'Do not give food or drink — swallowing may be affected.',
              ar: 'لا تعطِ طعامًا أو شرابًا لأن القدرة على البلع قد تكون متأثرة.',
            ),
          ),
        ],
      ),
    ],
  ),

  // 17) Severe allergic reaction ---------------------------------------------
  FirstAidTopic(
    id: 'anaphylaxis',
    category: TopicCategory.medical,
    icon: Icons.sick,
    color: AppColors.accentGreen,
    title: LocalizedText(en: 'Severe allergic reaction', ar: 'الحساسية الشديدة'),
    summary: LocalizedText(
      en: 'Anaphylaxis: swelling, breathing trouble, and using an auto-injector.',
      ar: 'صدمة الحساسية: التورم وصعوبة التنفس واستخدام حاقن الأدرينالين.',
    ),
    overview: LocalizedText(
      en: 'Signs include swelling of the face, lips or throat, difficulty breathing, a widespread rash, and feeling faint.',
      ar: 'من علاماتها تورم الوجه أو الشفتين أو الحلق، وصعوبة التنفس، وطفح جلدي منتشر، والإحساس بالإغماء.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'First aid', ar: 'الإسعافات الأولية'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Call an ambulance immediately and say it is anaphylaxis.',
            ar: 'اتصل بالإسعاف فورًا وأخبرهم أنها حالة حساسية شديدة (أنافيلاكسي).',
          ),
          LocalizedText(
            en: 'If the person has an adrenaline auto-injector (such as an EpiPen), help them use it into the outer thigh right away.',
            ar: 'إذا كان لدى الشخص حاقن أدرينالين ذاتي (مثل EpiPen) فساعده على استخدامه في الفخذ الخارجي على الفور.',
          ),
          LocalizedText(
            en: 'Help the person sit up if breathing is hard; lay them down with legs raised if they feel faint.',
            ar: 'ساعد الشخص على الجلوس إذا كان التنفس صعبًا، أو مدّده مع رفع ساقيه إذا شعر بالإغماء.',
          ),
          LocalizedText(
            en: 'Remove the trigger if you can (for example a bee sting), but do not delay treatment.',
            ar: 'أزل المسبب إن أمكن (مثل لسعة النحل) دون أن تؤخر العلاج.',
          ),
          LocalizedText(
            en: 'A second dose of the auto-injector can be given after 5 minutes if there is no improvement.',
            ar: 'يمكن إعطاء جرعة ثانية من الحاقن بعد 5 دقائق إذا لم يتحسن الشخص.',
          ),
          LocalizedText(
            en: 'If the person becomes unconscious and stops breathing, start CPR.',
            ar: 'إذا فقد الشخص وعيه وتوقف تنفسه، فابدأ الإنعاش القلبي الرئوي.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.danger,
            text: LocalizedText(
              en: 'Anaphylaxis is life-threatening — call 123 even if the auto-injector seems to help.',
              ar: 'صدمة الحساسية تهدد الحياة — اتصل بـ 123 حتى لو بدا أن الحاقن قد ساعد.',
            ),
          ),
        ],
      ),
    ],
  ),
];
