import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localized_text.dart';
import '../model/first_aid_topic.dart';

/// The seven conditions carried over from the original app.
///
/// The Arabic text is preserved from the original content; English has been
/// added so every step is bilingual.
const List<FirstAidTopic> kOriginalTopics = <FirstAidTopic>[
  // 1) Swallowed tongue -------------------------------------------------------
  FirstAidTopic(
    id: 'swallowed_tongue',
    category: TopicCategory.breathing,
    icon: Icons.airline_seat_flat,
    color: AppColors.accentTeal,
    title: LocalizedText(en: 'Swallowed tongue', ar: 'بلع اللسان'),
    summary: LocalizedText(
      en: 'Clearing the airway when the tongue falls back and blocks breathing.',
      ar: 'تأمين مجرى الهواء عند ارتداد اللسان للخلف وإعاقة التنفس.',
    ),
    overview: LocalizedText(
      en: 'In an unconscious person the tongue can fall back and block the airway. Act quickly to reopen it.',
      ar: 'في حالة فقدان الوعي قد يرتد اللسان للخلف ويسد مجرى الهواء، لذا يجب التصرف بسرعة لإعادة فتحه.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'First aid', ar: 'الإسعافات الأولية'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Tilt the head back and lift the lower jaw forward; this brings the tongue back to its natural position.',
            ar: 'إمالة الرأس إلى الخلف والضغط على الفك السفلي مع محاولة دفع زاوية الفك الأمامي، مما يؤدي إلى عودة اللسان إلى وضعه الطبيعي.',
          ),
          LocalizedText(
            en: 'Tilt the head back and raise the chin, open the mouth and move the lower jaw down, then pull the tongue out by hooking it with the index finger and thumb behind it and pulling outward.',
            ar: 'على المسعف أن يقوم بإمالة الرأس للخلف وجعل الذقن في أعلى مستوى، ثم يتبع ذلك فتح الفم وتحريك الفك السفلي للأسفل، ثم يخرج اللسان بطريقة السحب حيث توضع الأصابع (السبابة والإبهام) خلفه على شكل خطاف ويشد للخارج.',
          ),
          LocalizedText(
            en: 'If it is hard to reposition, an endotracheal tube may be inserted to help breathing until the problem is resolved.',
            ar: 'في حال صعوبة الإرجاع يجب إدخال أنبوب للتنفس (Endotracheal Tube) للمساعدة على التنفس حتى تنفرج المشكلة.',
          ),
          LocalizedText(
            en: 'Prefer using a stick or tool to move the tongue instead of fingers — it is safer for the rescuer, as jaw spasm may make the person clamp down on the fingers.',
            ar: 'يفضل استخدام عصا أو أداة لتقليب اللسان بدلًا من استخدام الأصابع، فهي الطريقة الأكثر أمنًا للمسعف، فربما يطبق المريض فمه على أصابع المسعف نظرًا لتشنج عضلات الفك.',
          ),
          LocalizedText(
            en: 'Move the person to hospital, preferably to intensive care, as CPR — including cardiac defibrillation — may be needed if there is heart fibrillation or circulatory failure.',
            ar: 'كما يفضل نقل المصاب إلى المستشفى على أن يوضع في غرفة العناية المركزة لأنه قد يحتاج إلى إنعاش قلبي رئوي بما في ذلك صدمات كهربائية للقلب في حالة وجود رجفان في القلب أو قصور في الدورة الدموية.',
          ),
        ],
      ),
    ],
  ),

  // 2) Bleeding ---------------------------------------------------------------
  FirstAidTopic(
    id: 'bleeding',
    category: TopicCategory.bleeding,
    icon: Icons.bloodtype,
    color: AppColors.accentRed,
    title: LocalizedText(en: 'Bleeding', ar: 'النزيف'),
    summary: LocalizedText(
      en: 'Controlling external and internal bleeding.',
      ar: 'السيطرة على النزيف الخارجي والداخلي.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'Stopping external bleeding', ar: 'إيقاف النزيف الخارجي'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Apply direct pressure on the wound with a clean dressing.',
            ar: 'الضغط المباشر على الجرح النازف بغيار نظيف.',
          ),
          LocalizedText(
            en: 'Raise the injured limb if it is not fractured.',
            ar: 'رفع العضو المصاب إلى أعلى إن لم يكن به كسر.',
          ),
          LocalizedText(
            en: 'Bind the dressing firmly while the limb stays raised.',
            ar: 'يربط الضمادة جيدًا بينما يظل العضو مرفوعًا.',
          ),
          LocalizedText(
            en: 'The dressing may become soaked with blood — never change or remove it.',
            ar: 'قد يصبح الغيار مشبعًا بالدم فلا تغيره أبدًا ولا تنزعه.',
          ),
          LocalizedText(
            en: 'A second dressing can be placed over the first and bound with pressure.',
            ar: 'يمكن وضع غيار ثانٍ على الغيار الأول ويربط بضغط.',
          ),
          LocalizedText(
            en: 'Watch the person for signs of shock.',
            ar: 'مراقبة المصاب من حدوث الصدمة.',
          ),
          LocalizedText(
            en: 'Transport the person to the nearest medical centre.',
            ar: 'ينقل المصاب إلى أقرب مركز طبي.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.warning,
            text: LocalizedText(
              en: 'Do not use coffee grounds or similar substances to stop bleeding.',
              ar: 'لا تستخدم البُن أو ما شابه لإيقاف النزيف.',
            ),
          ),
        ],
      ),
      FirstAidSection(
        title: LocalizedText(en: 'First aid for internal bleeding', ar: 'الإسعاف الأولي للنزيف الداخلي'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'For a minor injury, apply ice or a cold compress to ease pain and swelling, placing a cloth between the ice and the skin to prevent skin damage.',
            ar: 'إذا كانت الإصابة بسيطة ضع عليها ثلجًا أو كمادة باردة للمساعدة في تخفيف الألم والتورم، وضع قطعة قماش بين الثلج وجلد المصاب لمنع تلف الجلد.',
          ),
          LocalizedText(
            en: 'Lay the person on their side resting on one hand with knees bent, to help any vomit drain out.',
            ar: 'اجعل المصاب يستلقي على جانبه متكئًا على إحدى يديه ويثني ركبتيه للمساعدة في خروج القيء إن وجد.',
          ),
          LocalizedText(
            en: 'Keep body temperature normal by covering the person.',
            ar: 'حافظ على درجة حرارة الجسم الطبيعية بتغطية المصاب.',
          ),
          LocalizedText(
            en: 'Reassure and calm the person.',
            ar: 'كما يجب تهدئة المصاب وبعث الطمأنينة في نفسه.',
          ),
          LocalizedText(
            en: 'Do not give the person any food or drink.',
            ar: 'لا تقدم للمصاب أي طعام أو شراب.',
          ),
          LocalizedText(
            en: 'If unconscious, check breathing and give rescue breaths if needed.',
            ar: 'إذا كان فاقدًا للوعي افحص التنفس وإذا لزم الأمر أنعش تنفسه.',
          ),
        ],
      ),
    ],
  ),

  // 3) Fainting ---------------------------------------------------------------
  FirstAidTopic(
    id: 'fainting',
    category: TopicCategory.medical,
    icon: Icons.airline_seat_individual_suite,
    color: AppColors.accentBlue,
    title: LocalizedText(en: 'Fainting', ar: 'الإغماء'),
    summary: LocalizedText(
      en: 'Helping someone who has briefly lost consciousness.',
      ar: 'إسعاف من فقد وعيه لفترة قصيرة.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'First aid', ar: 'الإسعافات الأولية'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Help the person lie on their back (avoid sitting or standing).',
            ar: 'ساعد المصاب على الاستلقاء على ظهره (تجنب وضع الجلوس أو الوقوف).',
          ),
          LocalizedText(
            en: 'Make sure there is enough ventilation.',
            ar: 'تأكد من وجود التهوية اللازمة.',
          ),
          LocalizedText(
            en: 'Raise the legs about 30 cm (12 inches) if there is no breathing problem and nothing prevents it (such as a fracture), by placing a pillow or box under the heels — not under the leg or knee.',
            ar: 'ارفع ساقي المصاب إلى أعلى 30 سم (12 بوصة) إذا كان المصاب لا يعاني من أي مشكلة في التنفس وإن لم يكن هناك ما يمنع ذلك (كما في حالة الكسور مثلًا)، ويكون رفع الساقين بوضع مخدة أو صندوق تحت كعب المصاب (لا تضع المخدة تحت الساق أو تحت الركبة).',
          ),
          LocalizedText(
            en: 'Loosen any tight clothing.',
            ar: 'فك أو حل الملابس الضيقة عن المصاب.',
          ),
          LocalizedText(
            en: 'Do not give anything by mouth while the person is unconscious.',
            ar: 'لا تعطِ المصاب أي شيء عن طريق الفم وهو مغمى عليه.',
          ),
          LocalizedText(
            en: 'If the person vomits, put them on their side, turn the head aside and clear the mouth.',
            ar: 'إذا تقيأ المصاب ضعه على جانبه وأدر رأسه جانبًا وامسح القيء من فمه.',
          ),
          LocalizedText(
            en: 'Do not pour water on the face; you may wipe the face with a cloth dampened with cold water.',
            ar: 'لا تصب الماء أو أي سائل آخر على وجه المصاب، بل يمكن أن تمسح وجهه بفوطة مبللة بالماء البارد.',
          ),
          LocalizedText(
            en: 'When the person starts to come round, reassure them and help them sit up.',
            ar: 'إذا ما بدأ المصاب يعي ما حوله فطمئنه وساعده على الجلوس.',
          ),
          LocalizedText(
            en: 'Check the person for wounds or obvious fractures that may have happened during the fall.',
            ar: 'افحص المصاب وتأكد من خلوه من الجروح والكسور الواضحة التي قد تكون حدثت خلال سقوطه بعد فقدانه الوعي.',
          ),
          LocalizedText(
            en: 'Watch the person after recovery: a brief loss of consciousness then recovery may be followed by another, longer episode — then it is best to call an ambulance.',
            ar: 'راقب المصاب بعد إفاقته وانتبه إلى أن فقدان الوعي لمدة قصيرة ثم الإفاقة قد يتبعه فقدان للوعي مرة أخرى ولمدة طويلة، وهنا يستحسن استدعاء الإسعاف.',
          ),
        ],
      ),
    ],
  ),

  // 4) Burns ------------------------------------------------------------------
  FirstAidTopic(
    id: 'burns',
    category: TopicCategory.trauma,
    icon: Icons.local_fire_department,
    color: AppColors.accentOrange,
    title: LocalizedText(en: 'Burns', ar: 'الحروق'),
    summary: LocalizedText(
      en: 'Treating minor, blistered, and large or deep burns.',
      ar: 'التعامل مع الحروق البسيطة والمترافقة بالفقاعات والكبيرة أو العميقة.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'Minor burns without blisters', ar: 'الحروق البسيطة دون فقاعات'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Rinse the burn under cool running water that is not too forceful.',
            ar: 'اغسل مكان الحرق بماء بارد جارٍ لا يكون شديد الاندفاع.',
          ),
          LocalizedText(
            en: 'Remove anything tight such as rings before swelling makes them hard to remove later.',
            ar: 'انزع أي شيء ضيق مثل الخواتم أو ما شابه ذلك قبل حدوث تورم وصعوبة نزعها فيما بعد.',
          ),
          LocalizedText(
            en: 'Cover the burn with a soft cloth dampened with cold water until the pain eases (fifteen minutes is often enough).',
            ar: 'ثم قم بتغطية الحرق بقطعة قماش طرية ومبللة بماء بارد حتى يزول الألم (غالبًا ما تكفي مدة خمس عشرة دقيقة لزوال الألم).',
          ),
          LocalizedText(
            en: 'Or wrap ice cubes in a clean cloth as a compress over the area for twenty minutes, then lift for ten minutes before reapplying, and repeat. Avoid placing ice directly on the skin or leaving the ice compress on for more than twenty minutes, as this can cause frostbite.',
            ar: 'أو قم بلف مكعبات من الثلج بقماش نظيف بصورة كمادة وتوضع فوق المنطقة المصابة لمدة عشرين دقيقة، ثم ترفع لمدة عشر دقائق قبل أن يعاد وضعها كالسابق، وهكذا تستمر الدورة، ويجب تفادي وضع الثلج مباشرة على الجلد أو إبقاء الكمادة الثلجية فوق المكان المحروق أكثر من عشرين دقيقة لأن ذلك قد يسبب ما يسمى بعضة الصقيع.',
          ),
          LocalizedText(
            en: 'Do not use home remedies or ice compresses if first- and second-degree burns cover an area larger than about five palms, as chilling such a large area can cause dangerous hypothermia — instead seek medical help as fast as possible.',
            ar: 'لا تحاول استعمال العلاجات المنزلية أو كمادات الثلج إذا كانت حروق الدرجتين الأولى والثانية تغطي مساحة أكبر من مساحة خمسة كفوف لأن وضع كمادات ثلجية على مثل هذه المساحة الكبيرة يمكن أن يسبب نقص حرارة الجسم مما قد يهدد الحياة، وبدلًا من ذلك اطلب العون الطبي بأسرع ما يمكن.',
          ),
          LocalizedText(
            en: 'When the pain eases, apply a burn ointment or cream (such as a silver-sulfadiazine cream).',
            ar: 'عندما يخف الألم ضع على الحرق مرهمًا أو كريمًا خاصًا بالحروق مثل كريم درمازين.',
          ),
        ],
      ),
      FirstAidSection(
        title: LocalizedText(en: 'Burns with blisters', ar: 'الحروق المترافقة بالفقاعات'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Rinse the burn with cold water and do not break the blisters.',
            ar: 'اغسل مكان الحرق بماء بارد ولا تخرب الفقاعات.',
          ),
          LocalizedText(en: 'Then call a doctor.', ar: 'ثم اتصل بالطبيب.'),
          LocalizedText(
            en: 'Do not try to remove clothing if it has stuck to the skin.',
            ar: 'لا تحاول نزع الملابس إذا كانت قد التصقت.',
          ),
          LocalizedText(en: 'Do not cover the burn.', ar: 'لا تغطِ الحرق.'),
          LocalizedText(
            en: 'Any burn on the face, hands, feet or genitals should be seen by a doctor as soon as possible.',
            ar: 'كل حرق في الوجه أو اليدين أو القدمين أو الأعضاء التناسلية يجب أن يتم مشاهدته من قبل الطبيب في أقرب وقت.',
          ),
        ],
      ),
      FirstAidSection(
        title: LocalizedText(en: 'Large or deep burns', ar: 'الحروق الكبيرة أو العميقة'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Move the person away from the source of the burn immediately.',
            ar: 'قم بإبعاد المصاب عن مصدر الحرق فورًا.',
          ),
          LocalizedText(
            en: 'Call an ambulance right away, or give first aid yourself; while waiting, remove all clothing from the body.',
            ar: 'اتصل بالإسعاف مباشرة أو قم بإسعاف المصاب بنفسك، وريثما يحضر الإسعاف قم بإزالة كافة الألبسة من على جسم المصاب.',
          ),
          LocalizedText(
            en: 'Do not put any medicines, ointments or household substances on the burn.',
            ar: 'لا تقم بوضع أية أدوية أو مراهم أو مواد منزلية على الحرق.',
          ),
          LocalizedText(
            en: 'You may cover the area with a clean cloth to keep air away until the ambulance arrives.',
            ar: 'يمكن تغطية المنطقة المصابة بقماش نظيف لإبعاد الهواء عنها حتى تأتي الإسعاف.',
          ),
        ],
      ),
    ],
    ageVariants: <AgeGroup, List<FirstAidSection>>{
      AgeGroup.child: <FirstAidSection>[_paediatricBurns],
      AgeGroup.infant: <FirstAidSection>[_paediatricBurns],
    },
  ),

  // 5) Diabetic coma ----------------------------------------------------------
  FirstAidTopic(
    id: 'diabetic_coma',
    category: TopicCategory.medical,
    icon: Icons.vaccines,
    color: AppColors.accentPurple,
    title: LocalizedText(en: 'Diabetic coma', ar: 'غيبوبة السكر'),
    summary: LocalizedText(
      en: 'Responding to a diabetic emergency and knowing the warning signs.',
      ar: 'التعامل مع طوارئ السكري ومعرفة العلامات التحذيرية.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'First aid for a diabetic coma', ar: 'إسعافات غيبوبة السكر'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Measure the random blood sugar to know the person condition.',
            ar: 'قياس السكر العشوائي لمعرفة الوضع الصحي للمريض.',
          ),
          LocalizedText(
            en: 'If the person is conscious, give fast-absorbing sugars at once — a sweet, chocolate, juice or sugared water — or intravenous fluids, to restore blood sugar levels.',
            ar: 'إعطاء المريض على الفور (في حالة كان واعيًا) سكريات سريعة الامتصاص مثل قطعة حلوى، شوكولاتة، عصير، ماء محلى بالسكر، أو عن طريق المحاليل التي تُعطى عن طريق الوريد، لاستعادة مستويات السكر في الدم.',
          ),
          LocalizedText(
            en: 'Go to the nearest hospital if needed.',
            ar: 'الذهاب إلى أقرب مستشفى إذا اقتضت الحاجة.',
          ),
          LocalizedText(
            en: 'If the person is unconscious, place a piece of sugar under the tongue or give a sugar solution intravenously, monitor and keep body temperature normal, and keep watching breathing and blood pressure until reaching the nearest hospital.',
            ar: 'إعطاؤه قطعة من السكر تحت اللسان، أو محلول سكري عبر الوريد حال كان المريض فاقدًا للوعي، ومراقبة درجة حرارته والمحافظة عليها ضمن الحد الطبيعي، ومراقبة التنفس والضغط باستمرار حتى التوجه إلى أقرب مستشفى.',
          ),
        ],
      ),
      FirstAidSection(
        title: LocalizedText(en: 'How is a diabetic coma treated?', ar: 'كيف يتم علاج الغيبوبة السكرية؟'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'The person may also need insulin to help cells absorb excess glucose from the blood. If sodium or potassium levels are low, supplements may be given to raise them to healthy levels. A glucagon injection also helps raise blood sugar in cases of low blood sugar.',
            ar: 'قد يحتاج المريض أيضًا الحصول على الأنسولين لمساعدة الخلايا على امتصاص الجلوكوز الزائد في الدورة الدموية، وفي حال كانت مستويات الصوديوم أو البوتاسيوم منخفضة، فقد يحصل الفرد على مكملات للمساعدة في رفعها إلى مستويات صحية. كما يساعد حقن الجلوكاجون في زيادة مستويات السكر في الدم في حال نقص السكر في الدم.',
          ),
        ],
      ),
      FirstAidSection(
        title: LocalizedText(en: 'Symptoms of high blood sugar', ar: 'أعراض ارتفاع سكر الدم'),
        steps: <LocalizedText>[
          LocalizedText(en: 'Increased urination.', ar: 'زيادة إدرار البول.'),
          LocalizedText(en: 'Feeling hungry and thirsty.', ar: 'الإصابة بالجوع والعطش.'),
          LocalizedText(
            en: 'Circulatory collapse or the onset of coma and loss of consciousness.',
            ar: 'هبوط الدورة الدموية أو بدايات الغيبوبة وفقدان الوعي.',
          ),
          LocalizedText(
            en: 'Dry mouth and a fruity smell to the breath.',
            ar: 'جفاف الفم وتغير رائحة نفس المريض لتشبه رائحة الفواكه.',
          ),
          LocalizedText(en: 'Stomach pain.', ar: 'آلام بالمعدة.'),
        ],
      ),
    ],
  ),

  // 6) Snake bite -------------------------------------------------------------
  FirstAidTopic(
    id: 'snake_bite',
    category: TopicCategory.environmental,
    icon: Icons.pest_control,
    color: AppColors.accentGreen,
    title: LocalizedText(en: 'Snake bite', ar: 'لدغة الثعبان'),
    summary: LocalizedText(
      en: 'Slowing venom spread and getting the person to hospital.',
      ar: 'إبطاء انتشار السم ونقل المصاب إلى المستشفى.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'First aid', ar: 'الإسعافات الأولية'),
        steps: <LocalizedText>[
          LocalizedText(en: 'Call an ambulance.', ar: 'اطلب الإسعاف.'),
          LocalizedText(
            en: 'Calm the person to slow the spread of venom through the body.',
            ar: 'هدئ من روع المصاب لمنع انتشار السم في الجسم.',
          ),
          LocalizedText(
            en: 'Wash the wound with running water and soap if possible.',
            ar: 'اغسل الجرح بالماء الجاري والصابون إن أمكن ذلك.',
          ),
          LocalizedText(
            en: 'Keep the bitten part still and horizontal and bandage the whole limb. The bite should be below heart level to slow venom spread.',
            ar: 'حاول تثبيت الجزء المصاب أفقيًا مع عمل ضمادة لكامل العضو المصاب، ويجب أن يكون مكان العضة أدنى من مستوى القلب لإبطاء انتشار السم.',
          ),
          LocalizedText(
            en: 'Carry the person to the emergency department, or have them walk slowly so the venom does not spread before reaching the nearest hospital.',
            ar: 'قم بحمل المصاب إلى قسم الطوارئ أو اطلب منه المشي ببطء حتى لا ينتشر السم في دمه قبل الوصول إلى أقرب مستشفى.',
          ),
          LocalizedText(
            en: 'A firm bandage can be applied above the bite to stop venom spreading to the rest of the body.',
            ar: 'يمكن عمل رباط ضاغط لربط الجزء السابق للإصابة لمنع انتشار السم إلى بقية أجزاء الجسم.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.warning,
            text: LocalizedText(
              en: 'Do not put ice on the bite — it does not help stop the venom from spreading.',
              ar: 'لا تضع الثلج على مكان الإصابة لأن ذلك لا يفيد في منع انتشار السم.',
            ),
          ),
          FirstAidCallout(
            type: CalloutType.warning,
            text: LocalizedText(
              en: 'Do not give the person any fluids, food or aspirin — it could cause loss of consciousness and choking if they vomit.',
              ar: 'لا تقدم للمصاب أي سوائل أو أطعمة أو الأسبرين، لأن ذلك قد يؤدي إلى فقدانه للوعي ويسبب اختناقًا إذا تقيأ.',
            ),
          ),
          FirstAidCallout(
            type: CalloutType.danger,
            text: LocalizedText(
              en: 'If the person loses consciousness, do not try to wake them — move them to the nearest hospital immediately.',
              ar: 'إذا فقد المصاب وعيه، لا تحاول إفاقته وانقله إلى أقرب مستشفى على الفور.',
            ),
          ),
        ],
      ),
    ],
  ),

  // 7) Seizures ---------------------------------------------------------------
  FirstAidTopic(
    id: 'seizures',
    category: TopicCategory.medical,
    icon: Icons.bolt,
    color: AppColors.accentAmber,
    title: LocalizedText(en: 'Epileptic seizures', ar: 'نوبات الصرع'),
    summary: LocalizedText(
      en: 'Keeping someone safe during and after a seizure.',
      ar: 'الحفاظ على سلامة المصاب أثناء النوبة وبعدها.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'First aid', ar: 'الإسعافات الأولية'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Do not restrain the person during convulsions; instead protect them from injury by moving harmful objects such as furniture away.',
            ar: 'لا تقيد المصاب إن كان في حالة تشنجات (لا تحاول كبح حركاته التشنجية) بل اعمل على وقايته من الإصابات وذلك بإبعاد الأشياء المؤذية من حوله أثناء النوبة مثل الأثاث.',
          ),
          LocalizedText(
            en: 'Cushion the head with a pillow or something soft to protect it from hitting the ground during the seizure.',
            ar: 'ضع وسادة أو أي شيء تحت رأسه يحميها من الارتطام بالأرض أثناء النوبة.',
          ),
          LocalizedText(
            en: 'Loosen tight clothing around the chest and neck to ease breathing.',
            ar: 'فك ملابس المصاب الضيقة من صدره وعنقه لتسهل تنفسه.',
          ),
          LocalizedText(
            en: 'After the seizure ends, place the person on their side to prevent any vomit returning to the mouth and to keep the airway clear.',
            ar: 'بعد انتهاء نوبة الصرع يوضع المصاب ممددًا على جانبه لتجنب رجوع القيء إلى فمه إن وجد وذلك للمحافظة على سلامة الممر الهوائي.',
          ),
          LocalizedText(
            en: 'If breathing stops, give mouth-to-mouth rescue breaths (mouth-to-nose if the mouth cannot be opened).',
            ar: 'إذا توقف تنفس المصاب يعمل له تنفس صناعي من الفم إلى الفم (إذا تعذر فتح الفم يعمل له تنفس من الفم إلى الأنف).',
          ),
          LocalizedText(
            en: 'The person may be prone to another seizure if they exert themselves or walk after the first one.',
            ar: 'قد يكون المصاب عرضة للإصابة بنوبة أخرى إذا بذل مجهودًا أو تمشى بعد النوبة الأولى.',
          ),
          LocalizedText(
            en: 'Provide comfort and quiet for the person.',
            ar: 'اسعَ لتوفير راحة وهدوء المصاب.',
          ),
          LocalizedText(
            en: 'Do not disturb, move or question the person.',
            ar: 'لا تزعج المصاب أو تحركه أو تسأله.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.warning,
            text: LocalizedText(
              en: 'Do not put anything in the person mouth or between the teeth.',
              ar: 'لا تضع أي شيء في فم المصاب أو بين أسنانه.',
            ),
          ),
        ],
      ),
      FirstAidSection(
        title: LocalizedText(
          en: 'Call emergency services only in these cases',
          ar: 'يتم استدعاء النجدة الطبية في الحالات التالية فقط',
        ),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'If the person is having a seizure for the first time.',
            ar: 'إذا كان المريض يصاب بهذه النوبة لأول مرة.',
          ),
          LocalizedText(
            en: 'If the seizure lasts more than five minutes or repeats several times in a row.',
            ar: 'إذا استمرت النوبة أكثر من خمس دقائق أو تكررت أكثر من مرة بشكل متوالٍ.',
          ),
          LocalizedText(
            en: 'If it happens while the person is in water (such as the sea or a swimming pool).',
            ar: 'إذا حدثت والمريض في الماء (كالبحر أو حمام السباحة).',
          ),
        ],
      ),
    ],
    ageVariants: <AgeGroup, List<FirstAidSection>>{
      AgeGroup.child: <FirstAidSection>[
        FirstAidSection(
          title: LocalizedText(
            en: 'Steps — child (1 year to puberty)',
            ar: 'الخطوات — طفل (من سنة حتى البلوغ)',
          ),
          steps: <LocalizedText>[
            LocalizedText(
              en: 'Note the time the fit started. How long it lasts is the single most useful thing you can tell a doctor.',
              ar: 'سجّل وقت بداية التشنج؛ فمدة استمراره هي أهم ما يمكنك إخبار الطبيب به.',
            ),
            LocalizedText(
              en: 'Put them on the floor on their side, clear of furniture and anything hard or sharp. Put nothing under the head that could cover the face.',
              ar: 'ضعه على الأرض على جانبه بعيدًا عن الأثاث وأي شيء صلب أو حاد، ولا تضع تحت رأسه شيئًا قد يغطي وجهه.',
            ),
            LocalizedText(
              en: 'Loosen anything tight around the neck and stay with them. Do not hold them down and do not put anything in their mouth.',
              ar: 'فُكّ أي شيء ضاغط حول الرقبة وابقَ معه. لا تُمسكه بالقوة ولا تضع أي شيء في فمه.',
            ),
            LocalizedText(
              en: 'If the child has a fever with the fit and is between 6 months and 5 years old, this is most likely a febrile convulsion — open the "Febrile convulsion" topic, which covers it in full.',
              ar: 'إذا كان التشنج مصحوبًا بارتفاع في الحرارة وكان عمر الطفل بين 6 شهور و5 سنوات فالأرجح أنه تشنج حراري — افتح حالة «تشنج الحرارة» فهي تشرحه بالكامل.',
            ),
            LocalizedText(
              en: 'When the fit stops, keep them on their side and let them sleep. Being drowsy and confused afterwards is normal.',
              ar: 'عند توقف التشنج أبقِه على جانبه ودعه ينام؛ فالنعاس والتشوش بعده أمر طبيعي.',
            ),
            LocalizedText(
              en: 'Call an ambulance (123) if the fit lasts more than 5 minutes, another starts before they wake, it is their first ever fit, they are hurt, or they do not wake up properly afterwards.',
              ar: 'اتصل بالإسعاف (123) إذا استمر التشنج أكثر من 5 دقائق، أو بدأ تشنج آخر قبل أن يفيق، أو كان أول تشنج في حياته، أو أُصيب، أو لم يستعد وعيه بشكل طبيعي بعده.',
            ),
          ],
          callouts: <FirstAidCallout>[
            FirstAidCallout(
              type: CalloutType.danger,
              text: LocalizedText(
                en: 'Never put a finger, spoon, cloth, or anything else in the mouth of a child having a fit. They cannot swallow their tongue, and you will break teeth or be bitten.',
                ar: 'لا تضع أبدًا إصبعًا أو ملعقة أو قطعة قماش أو أي شيء في فم طفل يتشنج؛ فهو لا يستطيع ابتلاع لسانه، وستكسر أسنانه أو يعضّك.',
              ),
            ),
          ],
        ),
      ],
    },
  ),
];

/// Shared by the child and infant burn variants. What changes is the same for
/// both: a small body loses heat fast, and the same burn is proportionally far
/// larger than it would be on an adult.
const FirstAidSection _paediatricBurns = FirstAidSection(
  title: LocalizedText(
    en: 'Steps — child or infant',
    ar: 'الخطوات — طفل أو رضيع',
  ),
  steps: <LocalizedText>[
    LocalizedText(
      en: 'Stop the burning: move them away from the heat and take off any clothing or nappy soaked in hot liquid, unless it is stuck to the skin.',
      ar: 'أوقف الحرق: أبعده عن مصدر الحرارة وانزع أي ملابس أو حفاض مبلل بسائل ساخن، إلا إذا كان ملتصقًا بالجلد.',
    ),
    LocalizedText(
      en: 'Cool the burn under cool — not cold — running water for 20 minutes. Cool the burn only, and keep the rest of the body covered and warm.',
      ar: 'برّد الحرق تحت ماء جارٍ فاتر — لا بارد — لمدة 20 دقيقة. برّد موضع الحرق فقط، وأبقِ باقي الجسم مغطى ودافئًا.',
    ),
    LocalizedText(
      en: 'While cooling, watch for shivering or a cold body. If they start to shiver, stop cooling and wrap them up.',
      ar: 'أثناء التبريد راقب الارتعاش أو برودة الجسم. إذا بدأ يرتعش فأوقف التبريد ولفّه بغطاء.',
    ),
    LocalizedText(
      en: 'Cover the burn loosely with cling film laid on lengthways, or a clean non-fluffy cloth. Never wrap it tightly around a limb.',
      ar: 'غطِّ الحرق برفق بشريحة بلاستيك مطبخي موضوعة بالطول أو بقطعة قماش نظيفة غير وبرية، ولا تلفّه بإحكام حول طرف أبدًا.',
    ),
    LocalizedText(
      en: 'Take any child with a burn larger than the palm of their own hand to hospital, and any burn at all on the face, hands, feet, or genitals.',
      ar: 'اذهب بالطفل إلى المستشفى إذا كان الحرق أكبر من كف يده هو، وكذلك أي حرق مهما كان صغيرًا في الوجه أو اليدين أو القدمين أو المنطقة التناسلية.',
    ),
    LocalizedText(
      en: 'Take any burn on a baby under one year to hospital, whatever its size.',
      ar: 'اذهب بأي حرق يصيب رضيعًا أقل من سنة إلى المستشفى مهما كان حجمه.',
    ),
  ],
  callouts: <FirstAidCallout>[
    FirstAidCallout(
      type: CalloutType.danger,
      text: LocalizedText(
        en: "A small body goes cold during cooling far faster than an adult's. Cool the burn, but keep the child warm — a burn that has been cooled into hypothermia is a second emergency.",
        ar: 'الجسم الصغير يبرد أثناء التبريد أسرع بكثير من جسم البالغ. برّد الحرق وأبقِ الطفل دافئًا؛ فالتبريد الذي يؤدي إلى انخفاض حرارة الجسم يصنع حالة طارئة ثانية.',
      ),
    ),
    FirstAidCallout(
      type: CalloutType.warning,
      text: LocalizedText(
        en: 'Never use ice, iced water, butter, toothpaste, or flour. On a child\'s thin skin they cause further damage.',
        ar: 'لا تستخدم أبدًا ثلجًا أو ماءً مثلجًا أو زبدة أو معجون أسنان أو دقيقًا؛ فهي تسبب ضررًا إضافيًا على جلد الطفل الرقيق.',
      ),
    ),
  ],
);
