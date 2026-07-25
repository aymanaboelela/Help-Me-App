import '../../../core/localized_text.dart';
import '../model/learn_content.dart';

/// One short first-aid fact for each day.
///
/// Chosen by day-of-year rather than at random, so every device shows the same
/// tip on the same day without a server deciding it — and so the same tip never
/// appears twice in a week.
///
/// Each one is a single actionable sentence. Tips that only say "be careful"
/// were left out; a tip you cannot act on is not a tip.
const List<DailyTip> kDailyTips = <DailyTip>[
  DailyTip(
    id: 'tip_cpr_rate',
    topicId: 'cpr',
    text: LocalizedText(
      en: 'Chest compressions go at 100–120 a minute — the beat of "Stayin\' Alive". Push hard, and let the chest come all the way back up between each one.',
      ar: 'ضغطات الصدر بتبقى ١٠٠–١٢٠ في الدقيقة — على إيقاع أغنية «Stayin\' Alive». اضغط بقوة، وسيب الصدر يرجع بالكامل بين كل ضغطة والتانية.',
    ),
  ),
  DailyTip(
    id: 'tip_cpr_hands_only',
    topicId: 'cpr',
    text: LocalizedText(
      en: 'If you are untrained or unwilling to give rescue breaths, do compressions only. Hands-only CPR is far better than doing nothing.',
      ar: 'لو مش متدرب أو مش مرتاح تعمل تنفس صناعي، اعمل ضغطات بس. الإنعاش باليدين لوحدهم أحسن بكتير من إنك ماتعملش حاجة.',
    ),
  ),
  DailyTip(
    id: 'tip_burn_water',
    topicId: 'burns',
    text: LocalizedText(
      en: 'Cool a burn under running water for at least 20 minutes. Not ice, not butter, not toothpaste — those make it worse.',
      ar: 'برّد الحرق تحت ميّه جارية ٢٠ دقيقة على الأقل. مش تلج ولا زبدة ولا معجون أسنان — دي بتزوّده.',
    ),
  ),
  DailyTip(
    id: 'tip_burn_jewellery',
    topicId: 'burns',
    text: LocalizedText(
      en: 'Take rings and watches off a burned limb straight away, before it swells. Leave anything stuck to the skin exactly where it is.',
      ar: 'شيل الخواتم والساعة من على الطرف المحروق فورًا قبل ما يتورّم. وأي حاجة لازقة في الجلد سيبها مكانها بالظبط.',
    ),
  ),
  DailyTip(
    id: 'tip_bleeding_pressure',
    topicId: 'bleeding',
    text: LocalizedText(
      en: 'For serious bleeding, press hard directly on the wound and keep pressing. Lifting your hand to check restarts the bleeding.',
      ar: 'في النزيف الشديد، اضغط بقوة على الجرح نفسه وفضل ضاغط. رفع إيدك عشان تتطمن بيرجّع النزيف من الأول.',
    ),
  ),
  DailyTip(
    id: 'tip_bleeding_layer',
    topicId: 'bleeding',
    text: LocalizedText(
      en: 'If blood soaks through the dressing, add another on top. Never take the first one off — you would pull the clot away with it.',
      ar: 'لو الدم نفذ من الشاش، حط شاش تاني فوقه. ماتشيلش الأولاني أبدًا — هتشيل معاه الجلطة اللي وقّفت الدم.',
    ),
  ),
  DailyTip(
    id: 'tip_choking_back_blows',
    topicId: 'choking',
    text: LocalizedText(
      en: 'Someone choking and unable to speak needs five sharp back blows between the shoulder blades first, then five abdominal thrusts.',
      ar: 'اللي بيختنق ومش قادر يتكلم محتاج خمس ضربات قوية بين لوحي الكتف الأول، وبعدين خمس ضغطات على البطن.',
    ),
  ),
  DailyTip(
    id: 'tip_choking_cough',
    topicId: 'choking',
    text: LocalizedText(
      en: 'If a choking person can still cough forcefully, let them cough. Their own cough is stronger than anything you can do.',
      ar: 'لو اللي بيختنق لسه بيقدر يكحّ بقوة، سيبه يكحّ. الكحة بتاعته أقوى من أي حاجة تقدر تعملها.',
    ),
  ),
  DailyTip(
    id: 'tip_recovery_position',
    topicId: 'swallowed_tongue',
    text: LocalizedText(
      en: 'Anyone unconscious but breathing goes on their side. It keeps the tongue off the airway and lets vomit drain out instead of in.',
      ar: 'أي حد فاقد الوعي بس بيتنفس يتحط على جنبه. كده اللسان مايسدّش مجرى الهوا، والقيء يخرج بدل ما يدخل.',
    ),
  ),
  DailyTip(
    id: 'tip_stroke_fast',
    topicId: 'stroke',
    text: LocalizedText(
      en: 'Stroke is FAST: Face drooping, Arm weakness, Speech trouble — Time to call. Note the time symptoms started; the hospital will ask.',
      ar: 'علامات السكتة: الوش مايل، وضعف في الذراع، وصعوبة في الكلام — واتصل فورًا. واحفظ وقت بداية الأعراض؛ المستشفى هتسألك عليه.',
    ),
  ),
  DailyTip(
    id: 'tip_heart_attack_position',
    topicId: 'heart_attack',
    text: LocalizedText(
      en: 'Sit a person with chest pain on the floor, leaning against something, knees bent. Do not let them walk to the car.',
      ar: 'قعّد اللي عنده ألم في صدره على الأرض مسنود ورُكبه مثنية. وماتخليهوش يمشي لحد العربية.',
    ),
  ),
  DailyTip(
    id: 'tip_seizure_dont_hold',
    topicId: 'seizures',
    text: LocalizedText(
      en: 'During a seizure, never hold the person down and never put anything in their mouth. Cushion the head and time it instead.',
      ar: 'أثناء التشنج، ماتمسكش الشخص بالقوة وماتحطش أي حاجة في بقّه. حط حاجة طرية تحت راسه واحسب الوقت.',
    ),
  ),
  DailyTip(
    id: 'tip_seizure_five_minutes',
    topicId: 'seizures',
    text: LocalizedText(
      en: 'A seizure lasting more than five minutes, or a second one straight after, is an emergency. Call an ambulance.',
      ar: 'التشنج اللي بيعدّي خمس دقايق، أو تشنج تاني وراه على طول، ده طارئ. اتصل بالإسعاف.',
    ),
  ),
  DailyTip(
    id: 'tip_anaphylaxis_thigh',
    topicId: 'anaphylaxis',
    text: LocalizedText(
      en: 'An adrenaline auto-injector goes into the outer thigh — through clothing if you have to. Then call an ambulance, even if they improve.',
      ar: 'قلم الأدرينالين بيتحط في الفخذ من برّه — ومن فوق الهدوم لو اضطريت. وبعدين اتصل بالإسعاف حتى لو اتحسّن.',
    ),
  ),
  DailyTip(
    id: 'tip_anaphylaxis_second_dose',
    topicId: 'anaphylaxis',
    text: LocalizedText(
      en: 'Anaphylaxis can come back after the first injection wears off. That is why the ambulance is not optional.',
      ar: 'الحساسية المفرطة ممكن ترجع لما مفعول الحقنة الأولى يخلص. عشان كده الإسعاف مش اختياري.',
    ),
  ),
  DailyTip(
    id: 'tip_poison_no_vomit',
    topicId: 'poisoning',
    text: LocalizedText(
      en: 'Never make a poisoned person vomit. Many substances burn twice as much on the way back up.',
      ar: 'ماتخليش المتسمم يترجّع أبدًا. في مواد كتير بتحرق مرتين وهي طالعة.',
    ),
  ),
  DailyTip(
    id: 'tip_poison_container',
    topicId: 'poisoning',
    text: LocalizedText(
      en: 'Take the container, packet, or plant with you to hospital. Knowing exactly what was swallowed changes the treatment.',
      ar: 'خد معاك العبوة أو الشريط أو النبات للمستشفى. معرفة اللي اتبلع بالظبط بتغيّر العلاج.',
    ),
  ),
  DailyTip(
    id: 'tip_electric_power_first',
    topicId: 'electric_shock',
    text: LocalizedText(
      en: 'With an electric shock, switch the power off before you touch anyone. A second casualty helps no one.',
      ar: 'في الصعق الكهربائي، اقطع الكهربا قبل ما تلمس أي حد. مصاب تاني مش هيفيد حد.',
    ),
  ),
  DailyTip(
    id: 'tip_heat_stroke_cool',
    topicId: 'heat_stroke',
    text: LocalizedText(
      en: 'Heat stroke is cooled fastest with wet cloths at the neck, armpits and groin — where the big vessels run close to the skin.',
      ar: 'ضربة الشمس بتبرد أسرع بفوط مبلولة على الرقبة وتحت الإبط وبين الفخذين — مكان الأوعية الكبيرة القريبة من الجلد.',
    ),
  ),
  DailyTip(
    id: 'tip_heat_confusion',
    topicId: 'heat_stroke',
    text: LocalizedText(
      en: 'Confusion in someone who has been in the heat is the danger sign. Sweating stopping is another. Both mean call for help.',
      ar: 'التشوّش عند حد قعد في الحر ده علامة خطر. ووقف العرق علامة تانية. الاتنين معناهم اطلب النجدة.',
    ),
  ),
  DailyTip(
    id: 'tip_fainting_legs',
    topicId: 'fainting',
    text: LocalizedText(
      en: 'Someone who has fainted should stay lying flat with their legs raised for a minute or two. Standing up too fast drops them again.',
      ar: 'اللي أُغمي عليه يفضل نايم على ضهره ورجليه مرفوعة دقيقة أو اتنين. القيام بسرعة بيوقّعه تاني.',
    ),
  ),
  DailyTip(
    id: 'tip_diabetic_sugar',
    topicId: 'diabetic_coma',
    text: LocalizedText(
      en: 'If a diabetic person is shaky or confused but awake, give something sweet. If in doubt about high or low sugar, sugar is the safer guess.',
      ar: 'لو مريض السكر بيرتعش أو مشوّش بس واعي، إديه حاجة سكر. ولو متردد سكره عالي ولا واطي، السكر هو التخمين الأأمن.',
    ),
  ),
  DailyTip(
    id: 'tip_diabetic_unconscious',
    topicId: 'diabetic_coma',
    text: LocalizedText(
      en: 'Never put food or drink in the mouth of someone drowsy or unconscious — it goes into the lungs, not the stomach.',
      ar: 'ماتحطش أكل ولا شرب في بق حد نعسان أو فاقد الوعي — هيروح للرئة مش للمعدة.',
    ),
  ),
  DailyTip(
    id: 'tip_fracture_dont_straighten',
    topicId: 'fracture',
    text: LocalizedText(
      en: 'Never try to straighten a broken limb. Support it exactly as you found it and let the hospital do the rest.',
      ar: 'ماتحاولش تعدّل طرف مكسور. ثبّته زي ما لقيته بالظبط وسيب الباقي للمستشفى.',
    ),
  ),
  DailyTip(
    id: 'tip_snake_no_cut',
    topicId: 'snake_bite',
    text: LocalizedText(
      en: 'For a snake bite: no cutting, no sucking, no ice, no tourniquet. Keep the limb still and below the heart, and get to hospital.',
      ar: 'في لدغة التعبان: ماتقطعش، ماتمصّش، ماتحطش تلج، ماتربطش رباط ضاغط. ثبّت الطرف تحت مستوى القلب واروح المستشفى.',
    ),
  ),
  DailyTip(
    id: 'tip_drowning_breathing',
    topicId: 'drowning',
    text: LocalizedText(
      en: 'Someone pulled from water may look fine and get worse hours later. Any near-drowning needs to be seen by a doctor.',
      ar: 'اللي بيتشال من الميّه ممكن يبان كويس ويتعب بعد ساعات. أي حالة قرب غرق لازم دكتور يشوفها.',
    ),
  ),
  DailyTip(
    id: 'tip_check_danger',
    text: LocalizedText(
      en: 'Before you reach anyone, look around. Traffic, fire, live wires, gas — the first rule is not becoming the second casualty.',
      ar: 'قبل ما توصل لحد، بصّ حواليك. عربيات، حريقة، أسلاك مكشوفة، غاز — أول قاعدة إنك ماتبقاش المصاب التاني.',
    ),
  ),
  DailyTip(
    id: 'tip_call_early',
    text: LocalizedText(
      en: 'Calling for help early is never wrong. An ambulance that turns out not to be needed costs far less than one called too late.',
      ar: 'إنك تتصل بدري مش غلط أبدًا. إسعاف طلع مش محتاجينه أرخص بكتير من إسعاف اتطلب متأخر.',
    ),
  ),
  DailyTip(
    id: 'tip_speaker_phone',
    text: LocalizedText(
      en: 'On an emergency call, put the phone on speaker. It frees both your hands and lets the dispatcher guide you while you work.',
      ar: 'وانت بتتصل بالطوارئ، حط الموبايل على السماعة الخارجية. كده إيديك الاتنين فاضيين والموظف يقدر يوجّهك وانت بتشتغل.',
    ),
  ),
  DailyTip(
    id: 'tip_address_first',
    text: LocalizedText(
      en: 'Give your exact location first on an emergency call. If the line drops after that, help is already on its way.',
      ar: 'قول عنوانك بالظبط الأول في مكالمة الطوارئ. لو الخط قطع بعدها، النجدة تكون في طريقها بالفعل.',
    ),
  ),
  DailyTip(
    id: 'tip_kit_check',
    text: LocalizedText(
      en: 'Check your first-aid kit twice a year. The two things that fail are the antiseptic and the plasters, and both fail quietly.',
      ar: 'راجع شنطة الإسعاف مرتين في السنة. أكتر حاجتين بيبوظوا هما المطهّر والبلاستر، والاتنين بيبوظوا في صمت.',
    ),
  ),
  DailyTip(
    id: 'tip_kit_car',
    text: LocalizedText(
      en: 'Keep a second, smaller kit in the car. Most of the injuries you will actually meet happen away from home.',
      ar: 'خلّي شنطة تانية صغيرة في العربية. أغلب الإصابات اللي هتقابلها فعلًا بتحصل بره البيت.',
    ),
  ),
  DailyTip(
    id: 'tip_ice_contacts',
    text: LocalizedText(
      en: 'Save an emergency contact that someone else could find on your phone. A locked phone helps nobody.',
      ar: 'سجّل رقم طوارئ حد تاني يقدر يلاقيه في موبايلك. موبايل مقفول مابيفيدش حد.',
    ),
  ),
  DailyTip(
    id: 'tip_allergies_written',
    text: LocalizedText(
      en: 'Write your allergies down somewhere a stranger could find them. In an emergency you may not be able to say them out loud.',
      ar: 'اكتب حساسيتك في مكان أي حد غريب يقدر يلاقيه. وقت الطوارئ ممكن ماتكونش قادر تقولها بصوتك.',
    ),
  ),
  DailyTip(
    id: 'tip_gloves',
    text: LocalizedText(
      en: 'Put gloves on if you have them. If you do not, a clean plastic bag over your hand does the job.',
      ar: 'البس قفازات لو معاك. ولو مش معاك، كيس بلاستيك نضيف على إيدك بيعمل المطلوب.',
    ),
  ),
  DailyTip(
    id: 'tip_talk_to_them',
    text: LocalizedText(
      en: 'Keep talking to an injured person even if they cannot answer. Hearing is often the last sense to go and the first to return.',
      ar: 'فضل بتكلّم المصاب حتى لو مش بيرد. السمع غالبًا آخر حاسة بتروح وأول واحدة بترجع.',
    ),
  ),
  DailyTip(
    id: 'tip_shock_signs',
    text: LocalizedText(
      en: 'Pale, cold, clammy skin with fast shallow breathing is shock. Lay them down, raise the legs, keep them warm, and call for help.',
      ar: 'جلد شاحب وبارد ومبلول مع نَفَس سريع وسطحي معناه صدمة. نيّمه وارفع رجليه ودفّيه واطلب النجدة.',
    ),
  ),
  DailyTip(
    id: 'tip_nosebleed',
    text: LocalizedText(
      en: 'For a nosebleed, lean forward and pinch the soft part of the nose for ten minutes without letting go. Leaning back sends blood down the throat.',
      ar: 'في نزيف الأنف، ميل لقدام واقرص الجزء الطري من مناخيرك عشر دقايق من غير ما تسيب. الميلان لورا بيوصّل الدم للزور.',
    ),
  ),
  DailyTip(
    id: 'tip_wound_wash',
    text: LocalizedText(
      en: 'A dirty scrape is cleaned with running water, not with disinfectant poured into it. Water carries the dirt out.',
      ar: 'الخدش المتوسّخ بيتنضّف بميّه جارية، مش بمطهّر مصبوب جواه. الميّه هي اللي بتطلّع التراب.',
    ),
  ),
  DailyTip(
    id: 'tip_sprain_rice',
    text: LocalizedText(
      en: 'A sprain wants rest, ice through a cloth, gentle compression and elevation — and ice for no more than 20 minutes at a time.',
      ar: 'الالتواء عايز راحة، وتلج من فوق قماشة، ورباط ضاغط خفيف، ورفع الطرف — والتلج مش أكتر من ٢٠ دقيقة في المرة.',
    ),
  ),
  DailyTip(
    id: 'tip_head_injury_watch',
    text: LocalizedText(
      en: 'After a bang to the head, watch for vomiting, worsening headache, confusion or drowsiness over the next 24 hours. Any of them means hospital.',
      ar: 'بعد خبطة في الراس، راقب القيء والصداع اللي بيزيد والتشوّش والنعاس على مدى ٢٤ ساعة. أي واحدة فيهم معناها مستشفى.',
    ),
  ),
  DailyTip(
    id: 'tip_child_dose',
    text: LocalizedText(
      en: 'Children are not small adults. Never split an adult dose by eye — ask a pharmacist for the right one.',
      ar: 'الأطفال مش كبار مصغّرين. ماتقسّمش جرعة الكبار بالنظر — اسأل الصيدلي على الجرعة الصح.',
    ),
  ),
  DailyTip(
    id: 'tip_expiry_matters',
    text: LocalizedText(
      en: 'An expired medicine is not just weaker; some become harmful. Check the dates in your cabinet today.',
      ar: 'الدوا المنتهي مش بس بيبقى أضعف؛ في منه اللي بيبقى ضار. راجع التواريخ في خزنتك النهارده.',
    ),
  ),
  DailyTip(
    id: 'tip_teach_children',
    text: LocalizedText(
      en: 'Teach a child your emergency number and your address as a rhyme. A five-year-old who can call for help has saved lives.',
      ar: 'علّم طفلك رقم الطوارئ وعنوانكم على شكل أغنية. طفل عنده خمس سنين وعارف يتصل أنقذ أرواح فعلًا.',
    ),
  ),
  DailyTip(
    id: 'tip_hot_liquids',
    text: LocalizedText(
      en: 'Most childhood burns are from hot drinks, not fire. Keep tea and coffee away from table edges.',
      ar: 'أغلب حروق الأطفال من المشروبات السخنة، مش من النار. بعّد الشاي والقهوة عن حرف الترابيزة.',
    ),
  ),
  DailyTip(
    id: 'tip_button_battery',
    text: LocalizedText(
      en: 'A swallowed button battery is an emergency within hours, even if the child seems fine. Go straight to hospital.',
      ar: 'بطارية الساعة لو اتبلعت بتبقى حالة طارئة خلال ساعات، حتى لو الطفل باين كويس. روح المستشفى على طول.',
    ),
  ),
  DailyTip(
    id: 'tip_practice',
    text: LocalizedText(
      en: 'Read one topic in this app today while nothing is wrong. Knowledge you have to look up under panic is knowledge you do not have.',
      ar: 'اقرا موضوع واحد في التطبيق النهارده وانت مرتاح. المعلومة اللي بتدوّر عليها وانت مرعوب مش معلومة عندك.',
    ),
  ),
];
