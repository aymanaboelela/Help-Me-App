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
    ageVariants: <AgeGroup, List<FirstAidSection>>{
      AgeGroup.child: <FirstAidSection>[
        FirstAidSection(
          title: LocalizedText(
            en: 'Steps — child (1 year to puberty)',
            ar: 'الخطوات — طفل (من سنة حتى البلوغ)',
          ),
          steps: <LocalizedText>[
            LocalizedText(
              en: "Check for a response: call the child's name and tap their shoulder. Shout for help and put your phone on speaker while you call an ambulance (123).",
              ar: 'تحقق من الاستجابة: نادِ الطفل باسمه واربت على كتفه. اطلب المساعدة، وضع هاتفك على مكبر الصوت أثناء اتصالك بالإسعاف (123).',
            ),
            LocalizedText(
              en: 'Open the airway: tilt the head back gently and lift the chin. Check breathing for no more than 10 seconds.',
              ar: 'افتح مجرى الهواء: أمِل الرأس للخلف برفق وارفع الذقن. افحص التنفس لمدة لا تزيد عن 10 ثوانٍ.',
            ),
            LocalizedText(
              en: 'Give five rescue breaths first, before any compressions: pinch the nose, seal your mouth over theirs, and blow steadily for about 1 second until the chest rises.',
              ar: 'أعطِ خمسة أنفاس إنقاذية أولًا قبل أي ضغطات: اقرص الأنف، وأطبق فمك على فمه، وانفخ بثبات لمدة ثانية تقريبًا حتى يرتفع الصدر.',
            ),
            LocalizedText(
              en: 'Then start compressions: the heel of one hand in the centre of the chest — use two hands if the child is large or you cannot press deep enough with one.',
              ar: 'ثم ابدأ الضغطات: كعب يد واحدة في منتصف الصدر — استخدم يدين إذا كان الطفل كبيرًا أو لم تستطع الضغط بعمق كافٍ بيد واحدة.',
            ),
            LocalizedText(
              en: 'Press about 5 cm deep — roughly one third of the depth of the chest — at 100 to 120 compressions a minute, letting the chest come all the way back up each time.',
              ar: 'اضغط بعمق 5 سم تقريبًا — نحو ثلث عمق الصدر — بمعدل 100 إلى 120 ضغطة في الدقيقة، مع السماح للصدر بالعودة بالكامل بعد كل ضغطة.',
            ),
            LocalizedText(
              en: 'Continue cycles of 30 compressions to 2 breaths without stopping until the child responds or help arrives.',
              ar: 'استمر في دورات من 30 ضغطة مقابل نفسين دون توقف حتى يستجيب الطفل أو يصل المسعفون.',
            ),
            LocalizedText(
              en: 'If an AED arrives, use paediatric pads if it has them. If it only has adult pads, use those rather than nothing.',
              ar: 'إذا وصل جهاز الصدمات (AED) فاستخدم لصقات الأطفال إن وُجدت، وإذا لم تتوفر سوى لصقات البالغين فاستخدمها بدلًا من عدم استخدام الجهاز.',
            ),
          ],
          callouts: <FirstAidCallout>[
            FirstAidCallout(
              type: CalloutType.danger,
              text: LocalizedText(
                en: "A child's heart usually stops because breathing stopped first. That is why the five rescue breaths come before compressions — do not skip them.",
                ar: 'قلب الطفل يتوقف عادةً لأن التنفس توقف أولًا، ولهذا تأتي الأنفاس الخمسة قبل الضغطات — لا تتجاوزها.',
              ),
            ),
            FirstAidCallout(
              type: CalloutType.tip,
              text: LocalizedText(
                en: 'If you are alone with no phone, do CPR for one minute before leaving to get help.',
                ar: 'إذا كنت وحدك بلا هاتف، فقم بالإنعاش لمدة دقيقة واحدة قبل أن تترك الطفل لطلب المساعدة.',
              ),
            ),
          ],
        ),
      ],
      AgeGroup.infant: <FirstAidSection>[
        FirstAidSection(
          title: LocalizedText(
            en: 'Steps — infant (under 1 year)',
            ar: 'الخطوات — رضيع (أقل من سنة)',
          ),
          steps: <LocalizedText>[
            LocalizedText(
              en: 'Check for a response: tap the sole of the foot and call out. Never shake a baby.',
              ar: 'تحقق من الاستجابة: اربت على باطن القدم ونادِ عليه. لا تهزّ الرضيع أبدًا.',
            ),
            LocalizedText(
              en: 'Shout for help and call an ambulance (123) on speaker. Open the airway by keeping the head in a neutral position — level, not tilted back — and lifting the chin.',
              ar: 'اطلب المساعدة واتصل بالإسعاف (123) على مكبر الصوت. افتح مجرى الهواء بإبقاء الرأس في وضع محايد — مستوٍ وغير مائل للخلف — مع رفع الذقن.',
            ),
            LocalizedText(
              en: 'Check breathing for no more than 10 seconds.',
              ar: 'افحص التنفس لمدة لا تزيد عن 10 ثوانٍ.',
            ),
            LocalizedText(
              en: "Give five rescue breaths first: cover the baby's mouth and nose with your mouth and give gentle puffs of about 1 second each — just enough to see the chest rise.",
              ar: 'أعطِ خمسة أنفاس إنقاذية أولًا: غطِّ فم الرضيع وأنفه معًا بفمك وانفخ نفخات لطيفة مدة كل منها ثانية تقريبًا — بقدر ما ترى الصدر يرتفع فقط.',
            ),
            LocalizedText(
              en: 'Then start compressions with two fingers in the centre of the chest, just below an imaginary line between the nipples.',
              ar: 'ثم ابدأ الضغطات بإصبعين في منتصف الصدر، أسفل خط وهمي يصل بين الحلمتين مباشرةً.',
            ),
            LocalizedText(
              en: 'Press about 4 cm deep — roughly one third of the depth of the chest — at 100 to 120 compressions a minute.',
              ar: 'اضغط بعمق 4 سم تقريبًا — نحو ثلث عمق الصدر — بمعدل 100 إلى 120 ضغطة في الدقيقة.',
            ),
            LocalizedText(
              en: 'Continue cycles of 30 compressions to 2 breaths without stopping until the baby responds or help arrives.',
              ar: 'استمر في دورات من 30 ضغطة مقابل نفسين دون توقف حتى يستجيب الرضيع أو يصل المسعفون.',
            ),
          ],
          callouts: <FirstAidCallout>[
            FirstAidCallout(
              type: CalloutType.warning,
              text: LocalizedText(
                en: "Do not tilt a baby's head far back. Their airway is soft and tilting it too far closes the airway instead of opening it.",
                ar: 'لا تُمِل رأس الرضيع كثيرًا للخلف؛ فمجرى الهواء لديه ليّن، والإمالة الزائدة تغلقه بدلًا من أن تفتحه.',
              ),
            ),
            FirstAidCallout(
              type: CalloutType.warning,
              text: LocalizedText(
                en: "Blow gently. A baby's lungs hold a fraction of what yours do — you are looking for the chest to rise, nothing more.",
                ar: 'انفخ برفق؛ فرئتا الرضيع تسعان جزءًا يسيرًا مما تسعه رئتاك — المطلوب أن يرتفع الصدر فقط لا أكثر.',
              ),
            ),
          ],
        ),
      ],
    },
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
            type: CalloutType.danger,
            text: LocalizedText(
              en: 'These are the adult steps. For a child or a baby under 1 year the technique is different — switch to Child or Infant above.',
              ar: 'هذه خطوات البالغين. أما الطفل أو الرضيع أقل من سنة فالأسلوب مختلف — بدّل إلى «طفل» أو «رضيع» بالأعلى.',
            ),
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
              en: 'If the child can cough loudly, cry, or speak, the blockage is partial. Encourage them to keep coughing and stay with them — do not hit them on the back.',
              ar: 'إذا كان الطفل يستطيع السعال بصوت عالٍ أو البكاء أو الكلام فالانسداد جزئي. شجّعه على مواصلة السعال وابقَ معه — ولا تضربه على ظهره.',
            ),
            LocalizedText(
              en: 'If the cough goes silent, they cannot breathe, or they turn blue, act now and have someone call an ambulance (123).',
              ar: 'إذا صار السعال صامتًا أو عجز عن التنفس أو ازرقّ لونه فتصرّف فورًا، واطلب من أحد الاتصال بالإسعاف (123).',
            ),
            LocalizedText(
              en: 'Lean the child forward and give five sharp back blows between the shoulder blades with the heel of your hand.',
              ar: 'أمِل الطفل للأمام وأعطِه خمس ضربات حازمة على الظهر بين لوحي الكتف بكعب يدك.',
            ),
            LocalizedText(
              en: 'If that fails, give five abdominal thrusts: stand or kneel behind them, make a fist just above the navel and below the ribs, grasp it with your other hand and pull sharply inwards and upwards.',
              ar: 'إذا لم تنجح، أعطِ خمس ضغطات على البطن: قف أو اركع خلفه، واجعل قبضتك فوق السرة وأسفل الأضلاع، وأمسكها بيدك الأخرى واسحب بقوة للداخل وللأعلى.',
            ),
            LocalizedText(
              en: 'Keep alternating five back blows and five abdominal thrusts until the object comes out or the child stops responding.',
              ar: 'واصل التبديل بين خمس ضربات على الظهر وخمس ضغطات على البطن حتى يخرج الجسم أو يفقد الطفل استجابته.',
            ),
            LocalizedText(
              en: 'Look in the mouth between rounds and remove an object only if you can see it clearly and grasp it. Never sweep a finger around blindly.',
              ar: 'انظر داخل الفم بين الجولات، ولا تُخرج الجسم إلا إذا رأيته بوضوح وأمكنك الإمساك به. لا تُدخل إصبعك للبحث عشوائيًا أبدًا.',
            ),
            LocalizedText(
              en: 'If the child stops responding, start CPR for a child: five rescue breaths, then cycles of 30 compressions to 2 breaths.',
              ar: 'إذا فقد الطفل استجابته فابدأ الإنعاش الخاص بالأطفال: خمسة أنفاس إنقاذية، ثم دورات من 30 ضغطة مقابل نفسين.',
            ),
          ],
          callouts: <FirstAidCallout>[
            FirstAidCallout(
              type: CalloutType.warning,
              text: LocalizedText(
                en: 'Any child who has received abdominal thrusts must be seen by a doctor afterwards, even if they seem completely fine — the thrusts can injure organs inside.',
                ar: 'أي طفل تلقّى ضغطات على البطن يجب أن يفحصه طبيب بعدها حتى لو بدا بخير تمامًا؛ فهذه الضغطات قد تُصيب أعضاء الداخل.',
              ),
            ),
          ],
        ),
      ],
      AgeGroup.infant: <FirstAidSection>[
        FirstAidSection(
          title: LocalizedText(
            en: 'Steps — infant (under 1 year)',
            ar: 'الخطوات — رضيع (أقل من سنة)',
          ),
          steps: <LocalizedText>[
            LocalizedText(
              en: 'If the baby is coughing forcefully or crying loudly, let them keep coughing and watch closely. A crying baby is moving air.',
              ar: 'إذا كان الرضيع يسعل بقوة أو يبكي بصوت عالٍ فدعه يواصل السعال وراقبه عن قرب؛ فالرضيع الذي يبكي يدخل الهواء إلى صدره.',
            ),
            LocalizedText(
              en: 'If the cough is silent, the cry is weak, or the baby is going blue, act now and have someone call an ambulance (123).',
              ar: 'إذا كان السعال صامتًا أو البكاء ضعيفًا أو بدأ لون الرضيع يزرقّ فتصرّف فورًا، واطلب من أحد الاتصال بالإسعاف (123).',
            ),
            LocalizedText(
              en: 'Lay the baby face down along your forearm with the head lower than the chest, supporting the jaw with your fingers — do not press on the soft throat.',
              ar: 'ضع الرضيع على بطنه فوق ساعدك ورأسه أخفض من صدره، وادعم فكه بأصابعك — ولا تضغط على مقدمة الرقبة الليّنة.',
            ),
            LocalizedText(
              en: 'Give five back blows between the shoulder blades with the heel of your hand.',
              ar: 'أعطِ خمس ضربات على الظهر بين لوحي الكتف بكعب يدك.',
            ),
            LocalizedText(
              en: 'If that fails, turn the baby face up along your other forearm and give five chest thrusts: two fingers on the breastbone just below the nipple line, pressed sharper and slower than CPR compressions — about one a second.',
              ar: 'إذا لم تنجح، اقلب الرضيع على ظهره فوق ساعدك الآخر وأعطِ خمس ضغطات على الصدر: بإصبعين على عظمة الصدر أسفل خط الحلمتين مباشرةً، أحدّ وأبطأ من ضغطات الإنعاش — نحو ضغطة كل ثانية.',
            ),
            LocalizedText(
              en: 'Keep alternating five back blows and five chest thrusts until the object comes out or the baby stops responding.',
              ar: 'واصل التبديل بين خمس ضربات على الظهر وخمس ضغطات على الصدر حتى يخرج الجسم أو يفقد الرضيع استجابته.',
            ),
            LocalizedText(
              en: 'Look in the mouth between rounds and remove an object only if you can see it and grasp it. Never sweep a finger around blindly — it pushes the object deeper.',
              ar: 'انظر داخل الفم بين الجولات، ولا تُخرج الجسم إلا إذا رأيته وأمكنك الإمساك به. لا تُدخل إصبعك للبحث عشوائيًا أبدًا؛ فذلك يدفع الجسم إلى الداخل.',
            ),
            LocalizedText(
              en: 'If the baby stops responding, start CPR for an infant: five rescue breaths, then cycles of 30 compressions to 2 breaths with two fingers.',
              ar: 'إذا فقد الرضيع استجابته فابدأ الإنعاش الخاص بالرضّع: خمسة أنفاس إنقاذية، ثم دورات من 30 ضغطة مقابل نفسين بإصبعين.',
            ),
          ],
          callouts: <FirstAidCallout>[
            FirstAidCallout(
              type: CalloutType.danger,
              text: LocalizedText(
                en: 'Never give abdominal thrusts to a baby under one year. They can tear the liver or spleen. Chest thrusts, not abdominal thrusts.',
                ar: 'لا تُعطِ أبدًا ضغطات على البطن لرضيع أقل من سنة؛ فقد تُمزّق الكبد أو الطحال. ضغطات على الصدر، لا على البطن.',
              ),
            ),
            FirstAidCallout(
              type: CalloutType.warning,
              text: LocalizedText(
                en: 'Even if the object comes out and the baby seems fine, have a doctor check them the same day.',
                ar: 'حتى لو خرج الجسم وبدا الرضيع بخير، اعرضه على طبيب في اليوم نفسه.',
              ),
            ),
          ],
        ),
      ],
    },
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
    ageVariants: <AgeGroup, List<FirstAidSection>>{
      AgeGroup.child: <FirstAidSection>[_paediatricDrowning],
      AgeGroup.infant: <FirstAidSection>[_paediatricDrowning],
    },
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
    ageVariants: <AgeGroup, List<FirstAidSection>>{
      AgeGroup.child: <FirstAidSection>[
        FirstAidSection(
          title: LocalizedText(
            en: 'Steps — child or infant',
            ar: 'الخطوات — طفل أو رضيع',
          ),
          steps: <LocalizedText>[
            LocalizedText(
              en: 'Call an ambulance (123) straight away and say the word "anaphylaxis".',
              ar: 'اتصل بالإسعاف (123) فورًا وقل إنها حالة حساسية شديدة (أنافيلاكسي).',
            ),
            LocalizedText(
              en: 'Use their adrenaline auto-injector without waiting: the junior 0.15 mg device for a child under 30 kg, the 0.3 mg device for a child over 30 kg.',
              ar: 'استخدم حاقن الأدرينالين الخاص به دون انتظار: جهاز الأطفال 0.15 مجم لمن يقل وزنه عن 30 كجم، وجهاز 0.3 مجم لمن يزيد وزنه عن 30 كجم.',
            ),
            LocalizedText(
              en: 'Inject into the outer thigh, through clothing if necessary, and hold it in place for the time printed on the device. Hold the leg still — a struggling child can tear the skin on the needle.',
              ar: 'احقن في الجانب الخارجي للفخذ، من فوق الملابس إن لزم، وثبّته للمدة المكتوبة على الجهاز. ثبّت الساق جيدًا؛ فحركة الطفل قد تُمزّق الجلد بالإبرة.',
            ),
            LocalizedText(
              en: 'Lay them flat with their legs raised. If they are struggling to breathe, let them sit up. If they are vomiting or drowsy, place them on their side.',
              ar: 'أضجعه على ظهره وارفع ساقيه. وإذا كان يجد صعوبة في التنفس فدعه يجلس، وإذا كان يتقيأ أو يميل للنعاس فضعه على جانبه.',
            ),
            LocalizedText(
              en: 'If there is no improvement after 5 minutes, give a second dose in the other thigh.',
              ar: 'إذا لم يتحسّن خلال 5 دقائق فأعطِ جرعة ثانية في الفخذ الآخر.',
            ),
            LocalizedText(
              en: 'Stay with them until the ambulance arrives, even if they look much better.',
              ar: 'ابقَ معه حتى وصول الإسعاف، حتى لو بدا أنه تحسّن كثيرًا.',
            ),
          ],
          callouts: <FirstAidCallout>[
            FirstAidCallout(
              type: CalloutType.danger,
              text: LocalizedText(
                en: 'Never stand a child up or sit them upright suddenly during anaphylaxis, and never let them walk. It can stop the heart.',
                ar: 'لا تُوقِف الطفل أبدًا ولا تُجلسه فجأة أثناء نوبة الحساسية الشديدة، ولا تدعه يمشي؛ فقد يؤدي ذلك إلى توقف القلب.',
              ),
            ),
            FirstAidCallout(
              type: CalloutType.warning,
              text: LocalizedText(
                en: 'Antihistamine syrup does not treat anaphylaxis. Adrenaline first, always.',
                ar: 'شراب مضاد الهيستامين لا يعالج الحساسية الشديدة. الأدرينالين أولًا دائمًا.',
              ),
            ),
            FirstAidCallout(
              type: CalloutType.tip,
              text: LocalizedText(
                en: 'These steps also apply to a baby over about 7.5 kg. Below that weight the dose is a doctor\'s decision, so call the ambulance and follow what they tell you.',
                ar: 'هذه الخطوات تنطبق أيضًا على رضيع يزيد وزنه عن 7.5 كجم تقريبًا. وأقل من ذلك تكون الجرعة قرار الطبيب، فاتصل بالإسعاف واتبع ما يقولونه لك.',
              ),
            ),
          ],
        ),
      ],
    },
  ),
];

/// Shared by the child and infant drowning variants: what changes from the
/// adult procedure is identical for both, and duplicating it would mean two
/// places to keep correct.
const FirstAidSection _paediatricDrowning = FirstAidSection(
  title: LocalizedText(
    en: 'Steps — child or infant',
    ar: 'الخطوات — طفل أو رضيع',
  ),
  steps: <LocalizedText>[
    LocalizedText(
      en: 'Get them out of the water safely without putting yourself in danger, and call an ambulance (123).',
      ar: 'أخرجه من الماء بأمان دون أن تعرّض نفسك للخطر، واتصل بالإسعاف (123).',
    ),
    LocalizedText(
      en: 'Lay them on their back on a firm surface and check whether they are breathing, for no more than 10 seconds.',
      ar: 'ضعه على ظهره على سطح صلب، وافحص تنفسه لمدة لا تزيد عن 10 ثوانٍ.',
    ),
    LocalizedText(
      en: 'If they are not breathing normally, give five rescue breaths before any chest compressions — drowning stops the breathing first, so the breaths matter most.',
      ar: 'إذا لم يكن تنفسه طبيعيًا فأعطِ خمسة أنفاس إنقاذية قبل أي ضغطات على الصدر؛ فالغرق يوقف التنفس أولًا، ولذلك تكون الأنفاس هي الأهم.',
    ),
    LocalizedText(
      en: 'Then continue with cycles of 30 compressions to 2 breaths, using the technique for their age.',
      ar: 'ثم واصل بدورات من 30 ضغطة مقابل نفسين، بالأسلوب المناسب لعمره.',
    ),
    LocalizedText(
      en: 'Do not try to press water out of the lungs or turn them upside down. It wastes time and causes vomiting.',
      ar: 'لا تحاول إخراج الماء من الرئتين أو قلبه رأسًا على عقب؛ فذلك يضيّع الوقت ويسبب القيء.',
    ),
    LocalizedText(
      en: 'Once they are breathing, place them on their side, keep them warm with dry clothing or a blanket, and stay with them.',
      ar: 'بمجرد أن يتنفس، ضعه على جانبه، ودفّئه بملابس جافة أو بطانية، وابقَ معه.',
    ),
  ],
  callouts: <FirstAidCallout>[
    FirstAidCallout(
      type: CalloutType.danger,
      text: LocalizedText(
        en: 'Every child who has been rescued from water must be seen at hospital, even if they seem completely recovered. Water in the lungs can cause trouble hours later.',
        ar: 'كل طفل أُنقذ من الماء يجب عرضه على المستشفى حتى لو بدا أنه تعافى تمامًا؛ فالماء في الرئتين قد يسبب مشكلة بعد ساعات.',
      ),
    ),
    FirstAidCallout(
      type: CalloutType.warning,
      text: LocalizedText(
        en: 'A small child gets cold very quickly. Dry them and cover them as soon as they are breathing.',
        ar: 'الطفل الصغير يبرد بسرعة كبيرة؛ جفّفه وغطّه فور أن يتنفس.',
      ),
    ),
  ],
);
