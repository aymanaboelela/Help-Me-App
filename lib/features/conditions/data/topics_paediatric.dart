import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localized_text.dart';
import '../model/first_aid_topic.dart';

/// Emergencies that only happen to children, so they carry no age switch — they
/// are already written for a child throughout.
const List<FirstAidTopic> kPaediatricTopics = <FirstAidTopic>[
  // 18) Febrile convulsion ----------------------------------------------------
  FirstAidTopic(
    id: 'febrile_seizure',
    category: TopicCategory.medical,
    icon: Icons.thermostat,
    color: AppColors.accentOrange,
    isPaediatric: true,
    title: LocalizedText(en: 'Febrile convulsion', ar: 'تشنج الحرارة'),
    summary: LocalizedText(
      en: 'A fit brought on by fever in a young child.',
      ar: 'تشنج يحدث بسبب ارتفاع الحرارة عند الأطفال الصغار.',
    ),
    overview: LocalizedText(
      en: 'A febrile convulsion happens to otherwise healthy children between 6 months and 5 years when their temperature rises quickly. It is terrifying to watch and almost always harmless. Your job is to keep them safe and time it.',
      ar: 'يحدث تشنج الحرارة للأطفال الأصحاء بين 6 شهور و5 سنوات عندما ترتفع حرارتهم بسرعة. منظره مُفزع لكنه في الغالب غير مؤذٍ. مهمتك أن تحافظ على سلامته وأن تحسب مدته.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'During the fit', ar: 'أثناء التشنج'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Look at the clock and note the time it started.',
            ar: 'انظر إلى الساعة وسجّل وقت البداية.',
          ),
          LocalizedText(
            en: 'Lay the child on the floor on their side, away from furniture, stairs, and anything hard or hot.',
            ar: 'ضع الطفل على الأرض على جانبه بعيدًا عن الأثاث والسلالم وأي شيء صلب أو ساخن.',
          ),
          LocalizedText(
            en: 'Loosen tight clothing around the neck and remove extra layers — the room should be comfortable, not cold.',
            ar: 'فُكّ الملابس الضيقة حول الرقبة وانزع الطبقات الزائدة؛ فالغرفة يجب أن تكون مريحة لا باردة.',
          ),
          LocalizedText(
            en: 'Do not hold the child down or try to stop the shaking. Put nothing in their mouth — not a finger, a spoon, a cloth, or water.',
            ar: 'لا تُمسك الطفل بالقوة ولا تحاول إيقاف الرجفة. ولا تضع أي شيء في فمه — لا إصبعًا ولا ملعقة ولا قماشًا ولا ماءً.',
          ),
          LocalizedText(
            en: 'Do not put them in a cold or iced bath and do not pour cold water over them.',
            ar: 'لا تضعه في حمام بارد أو مثلج ولا تصبّ عليه ماءً باردًا.',
          ),
          LocalizedText(
            en: 'Stay beside them and keep watching the clock. Most fits stop on their own within 2 to 3 minutes.',
            ar: 'ابقَ بجانبه وواصل مراقبة الساعة؛ فمعظم التشنجات تتوقف وحدها خلال دقيقتين إلى ثلاث.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.danger,
            text: LocalizedText(
              en: 'Call an ambulance (123) if the fit lasts more than 5 minutes, a second fit starts before the child wakes, they go blue or stop breathing, or they are under 6 months or over 5 years old.',
              ar: 'اتصل بالإسعاف (123) إذا استمر التشنج أكثر من 5 دقائق، أو بدأ تشنج ثانٍ قبل أن يفيق الطفل، أو ازرقّ لونه أو توقف تنفسه، أو كان عمره أقل من 6 شهور أو أكثر من 5 سنوات.',
            ),
          ),
        ],
      ),
      FirstAidSection(
        title: LocalizedText(en: 'After the fit', ar: 'بعد التشنج'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Keep them on their side and let them sleep. Being deeply drowsy and confused for up to an hour afterwards is normal.',
            ar: 'أبقِه على جانبه ودعه ينام؛ فالنعاس الشديد والتشوش لمدة تصل إلى ساعة بعده أمر طبيعي.',
          ),
          LocalizedText(
            en: 'Once they are fully awake, give paracetamol at the dose for their weight to bring the fever down and make them comfortable.',
            ar: 'بعد أن يستيقظ تمامًا، أعطِه الباراسيتامول بالجرعة المناسبة لوزنه لخفض الحرارة وراحته.',
          ),
          LocalizedText(
            en: 'Offer small sips of fluid once they are awake enough to swallow safely.',
            ar: 'قدّم له رشفات صغيرة من السوائل بعد أن يستيقظ بما يكفي للبلع بأمان.',
          ),
          LocalizedText(
            en: 'Have a doctor see them the same day, even if they seem completely back to normal — the fever still needs a cause.',
            ar: 'اعرضه على طبيب في اليوم نفسه حتى لو عاد إلى طبيعته تمامًا؛ فسبب الحرارة ما زال يحتاج إلى تشخيص.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.danger,
            text: LocalizedText(
              en: 'Go to hospital now if the child has a stiff neck, a rash that does not fade when pressed, repeated vomiting, or does not wake properly. These are signs of meningitis, not a simple febrile convulsion.',
              ar: 'اذهب إلى المستشفى فورًا إذا كان لدى الطفل تيبّس في الرقبة، أو طفح جلدي لا يختفي بالضغط عليه، أو قيء متكرر، أو لم يستعد وعيه بشكل صحيح. هذه علامات التهاب سحائي وليست تشنج حرارة بسيطًا.',
            ),
          ),
          FirstAidCallout(
            type: CalloutType.tip,
            text: LocalizedText(
              en: 'Fever medicine does not prevent febrile convulsions. Give it to make a feverish child comfortable, not out of fear of another fit.',
              ar: 'خافض الحرارة لا يمنع تشنج الحرارة. أعطِه لراحة الطفل المحموم، لا خوفًا من تشنج آخر.',
            ),
          ),
        ],
      ),
    ],
  ),

  // 19) Dehydration in children -----------------------------------------------
  FirstAidTopic(
    id: 'child_dehydration',
    category: TopicCategory.medical,
    icon: Icons.water_drop,
    color: AppColors.accentBlue,
    isPaediatric: true,
    title: LocalizedText(
      en: 'Dehydration in children',
      ar: 'الجفاف عند الأطفال',
    ),
    summary: LocalizedText(
      en: 'Fluid loss from diarrhoea or vomiting — dangerous fast in small children.',
      ar: 'فقدان السوائل بسبب الإسهال أو القيء — يصبح خطيرًا بسرعة عند الأطفال الصغار.',
    ),
    overview: LocalizedText(
      en: 'A small child loses fluid far faster than an adult and has far less in reserve. Most deaths from gastroenteritis come from dehydration, not from the infection — and oral rehydration salts prevent almost all of them.',
      ar: 'الطفل الصغير يفقد السوائل أسرع بكثير من البالغ ومخزونه أقل بكثير. معظم الوفيات الناتجة عن النزلة المعوية سببها الجفاف لا العدوى نفسها — ومحلول معالجة الجفاف يمنع معظمها.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(
          en: 'Signs to look for',
          ar: 'العلامات التي تبحث عنها',
        ),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'A dry mouth and tongue, and crying without tears.',
            ar: 'جفاف الفم واللسان، والبكاء بلا دموع.',
          ),
          LocalizedText(
            en: 'Fewer wet nappies than usual — fewer than four in a day, or none at all for 6 to 8 hours.',
            ar: 'عدد حفاضات مبللة أقل من المعتاد — أقل من أربع في اليوم، أو لا شيء لمدة 6 إلى 8 ساعات.',
          ),
          LocalizedText(
            en: 'Sunken eyes, and in a baby a sunken soft spot on the top of the head.',
            ar: 'غؤور العينين، وعند الرضيع غؤور اليافوخ في أعلى الرأس.',
          ),
          LocalizedText(
            en: 'Unusual sleepiness, floppiness, or irritability.',
            ar: 'نعاس غير معتاد أو ارتخاء أو تهيّج شديد.',
          ),
        ],
      ),
      FirstAidSection(
        title: LocalizedText(en: 'What to do', ar: 'ماذا تفعل'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Start oral rehydration salts straight away. Buy the sachets from any pharmacy and mix one sachet into exactly 1 litre of clean drinking water.',
            ar: 'ابدأ بمحلول معالجة الجفاف فورًا. اشترِ الأكياس من أي صيدلية وأذب كيسًا واحدًا في لتر واحد بالضبط من مياه الشرب النظيفة.',
          ),
          LocalizedText(
            en: 'Use the whole sachet and the full litre. A stronger or weaker mix does harm, not good.',
            ar: 'استخدم الكيس كاملًا واللتر كاملًا؛ فالخلطة الأقوى أو الأضعف تضر ولا تنفع.',
          ),
          LocalizedText(
            en: 'Give it in small amounts, often: a teaspoon or two every one to two minutes. Big gulps come straight back up.',
            ar: 'أعطِه بكميات صغيرة ومتكررة: ملعقة صغيرة أو اثنتين كل دقيقة إلى دقيقتين؛ فالكميات الكبيرة تعود بالقيء فورًا.',
          ),
          LocalizedText(
            en: 'If they vomit, wait 10 minutes and start again more slowly. Do not give up — slow and steady still gets fluid in.',
            ar: 'إذا تقيأ فانتظر 10 دقائق ثم ابدأ من جديد ببطء أكثر. لا تستسلم؛ فالبطء والثبات يُدخلان السوائل فعلًا.',
          ),
          LocalizedText(
            en: "Keep breastfeeding or giving milk, more often and for shorter times. Never stop a baby's milk because of diarrhoea.",
            ar: 'واصل الرضاعة الطبيعية أو إعطاء الحليب، بمرات أكثر ولمدة أقصر. ولا توقف حليب الرضيع أبدًا بسبب الإسهال.',
          ),
          LocalizedText(
            en: 'Give another drink of the solution after every loose stool, and go on offering normal food as soon as they will take it.',
            ar: 'أعطِه شربة أخرى من المحلول بعد كل إخراج لين، وواصل تقديم الطعام المعتاد بمجرد أن يقبله.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.danger,
            text: LocalizedText(
              en: 'Go to hospital now if there is blood in the stool, green vomit, no urine for 8 hours, the child cannot keep any fluid down, they are very drowsy or floppy, or the child is under 6 months old.',
              ar: 'اذهب إلى المستشفى فورًا إذا كان هناك دم في البراز، أو قيء أخضر، أو انقطاع البول 8 ساعات، أو عجز الطفل عن الاحتفاظ بأي سائل، أو كان شديد النعاس أو مرتخيًا، أو كان عمره أقل من 6 شهور.',
            ),
          ),
          FirstAidCallout(
            type: CalloutType.warning,
            text: LocalizedText(
              en: 'Do not give anti-diarrhoea medicines to a child. They trap the infection instead of clearing it.',
              ar: 'لا تعطِ الطفل أدوية إيقاف الإسهال؛ فهي تحبس العدوى بدلًا من التخلص منها.',
            ),
          ),
          FirstAidCallout(
            type: CalloutType.warning,
            text: LocalizedText(
              en: 'Plain water, fizzy drinks, and fruit juice are not substitutes. Juice and soft drinks make diarrhoea worse.',
              ar: 'الماء وحده والمشروبات الغازية والعصائر ليست بديلًا؛ بل العصير والمشروبات الغازية تزيد الإسهال سوءًا.',
            ),
          ),
        ],
      ),
    ],
  ),

  // 20) Swallowed object ------------------------------------------------------
  FirstAidTopic(
    id: 'swallowed_object',
    category: TopicCategory.medical,
    icon: Icons.battery_alert,
    color: AppColors.accentPurple,
    isPaediatric: true,
    title: LocalizedText(en: 'Swallowed object', ar: 'ابتلاع جسم غريب'),
    summary: LocalizedText(
      en: 'A battery, magnet, coin, or sharp object swallowed by a child.',
      ar: 'ابتلاع الطفل لبطارية أو مغناطيس أو عملة أو جسم حاد.',
    ),
    overview: LocalizedText(
      en: 'Most swallowed objects pass on their own. A few do not, and one of them — the flat button battery — burns through the food pipe in hours. Knowing which is which is the whole of this topic.',
      ar: 'معظم الأجسام المبتلعة تخرج وحدها. وقليل منها لا يخرج، وأحدها — بطارية القرص المسطحة — تحرق المريء خلال ساعات. معرفة الفرق بينها هي كل ما في هذه الحالة.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'What to do first', ar: 'ماذا تفعل أولًا'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'If the child cannot breathe, is coughing silently, or is turning blue, the object is in the airway — go to the "Choking" topic and act now.',
            ar: 'إذا كان الطفل لا يستطيع التنفس أو يسعل بصمت أو يزرقّ لونه فالجسم في مجرى الهواء — افتح حالة «الاختناق بجسم غريب» وتصرّف فورًا.',
          ),
          LocalizedText(
            en: 'Do not make the child vomit, and do not give food or drink until a doctor has said it is safe.',
            ar: 'لا تجعل الطفل يتقيأ، ولا تعطه طعامًا أو شرابًا حتى يؤكد الطبيب أن ذلك آمن.',
          ),
          LocalizedText(
            en: 'If you have the packet or an identical object, take it with you to the hospital — it tells the doctor exactly what they are dealing with.',
            ar: 'إذا كانت العبوة أو جسم مطابق متاحًا فخذه معك إلى المستشفى؛ فهو يخبر الطبيب بما يتعامل معه بالضبط.',
          ),
        ],
      ),
      FirstAidSection(
        title: LocalizedText(
          en: 'Go to hospital immediately for these',
          ar: 'اذهب للمستشفى فورًا في هذه الحالات',
        ),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'A button battery — the flat, round kind from a watch, remote, toy, or hearing aid. This is an emergency measured in hours, not days, and it must be removed even if the child seems perfectly well.',
            ar: 'بطارية قرص — النوع المسطح الدائري من الساعة أو الريموت أو اللعبة أو سماعة الأذن. هذه حالة طارئة تُقاس بالساعات لا بالأيام، ويجب إخراجها حتى لو بدا الطفل بخير تمامًا.',
          ),
          LocalizedText(
            en: 'Two or more magnets, or one magnet with any metal object. They pull towards each other through the walls of the bowel and cut through them.',
            ar: 'مغناطيسان أو أكثر، أو مغناطيس مع أي جسم معدني. فهي تنجذب لبعضها عبر جدران الأمعاء وتقطعها.',
          ),
          LocalizedText(
            en: 'Anything sharp — a needle, pin, bone, or piece of broken glass.',
            ar: 'أي شيء حاد — إبرة أو دبوس أو عظمة أو قطعة زجاج مكسور.',
          ),
          LocalizedText(
            en: 'A coin, which needs an x-ray: one that has stopped in the food pipe has to be taken out.',
            ar: 'عملة معدنية، فهي تحتاج أشعة؛ لأن العملة التي توقفت في المريء يجب إخراجها.',
          ),
          LocalizedText(
            en: 'A nut or seed that was inhaled while eating, if the child has been coughing or wheezing since — it may be in the lung.',
            ar: 'مكسرات أو بذرة استُنشقت أثناء الأكل إذا ظل الطفل يسعل أو يصفر صدره بعدها — فقد تكون في الرئة.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.danger,
            text: LocalizedText(
              en: 'Drooling, refusing to eat, pain on swallowing, chest or tummy pain, vomiting, or noisy breathing after swallowing something all mean hospital now.',
              ar: 'سيلان اللعاب أو رفض الأكل أو ألم عند البلع أو ألم في الصدر أو البطن أو القيء أو تنفس مصحوب بصوت بعد ابتلاع شيء — كلها تعني المستشفى فورًا.',
            ),
          ),
          FirstAidCallout(
            type: CalloutType.tip,
            text: LocalizedText(
              en: 'A small, smooth, blunt object in a well child often just passes. Let a doctor make that call rather than deciding at home.',
              ar: 'الجسم الصغير الأملس غير الحاد كثيرًا ما يخرج وحده عند طفل بحالة جيدة. اترك هذا القرار للطبيب بدلًا من تقريره في البيت.',
            ),
          ),
        ],
      ),
    ],
  ),
];
