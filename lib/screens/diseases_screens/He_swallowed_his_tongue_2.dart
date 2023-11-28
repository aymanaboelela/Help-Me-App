import 'package:flutter/material.dart';


import '../../custem_widget.dart';

class HeswallowedHistongue extends StatelessWidget {
  HeswallowedHistongue({super.key});
  String combinedText =
      '1. إمالة الرأس إلى الخلف و الضغط على الفك السفلي مع محاولة دفع زاوية الفك الأمامي ، مما يؤدى إلى عودة اللسان إلى وضعه الطبيعي.\n\n'
      '2. على المسعف أن يقوم بإمالة الرأس للخلف و جعل الذقن في أعلى مستوى ، ثم يتبع ذلك فتح الفم و تحريك تحريك الفك السفلي للأسفل ، ثم يخرج اللسان بطريقة السحب حيث توضع الأصابع (السبابة و الإبهام) خلفه على شكل خطاف و يشد للخارج.\n\n'
      '3. في حال صعوبة الإرجاع يجب إدخال أنبوب للتنفس Tube Endotracheal للمساعدة على التنفس حتى تنفرج المشكلة.\n\n'
      '4. يفضل استخدام عصا أو أداة لتقليب اللسان بدل من استخدام الأصابع ، فهي الطريقة الأكثر أمنا للمسعف ، فربما المريض قد يطبق فمه على المسعف و يقطع أصابعه نظرا لتشنج عضلات الفك.\n\n'
      '5. كما يفضل نقل المصاب إلى المستشفى على أن يوضع في غرفة العناية المركزة لأنه قد يحتاج إلى إنعاش قلبي رئوي بما في ذلك صدمات كهربائية للقلب في حالة وجود رجفان في القلب أو قصور في الدورة الدموية.';

  @override
  Widget build(BuildContext context) {
    return CustemWidget(
        headImage: 'assets/images/2.jpg',
        headTitle: ' حالة بلع اللسان',
        sacandTitel: ' الإسعافات الأولية',
        description: combinedText,
        sacandImage: "assets/images/22.jpg",
        // headTitle2: headTitle2,
        // description2: description2,
        // sacandTitle2: sacandTitle2,
        // description3: description3,
        sacandImage2: "assets/images/222222222222.jpg");
  }
}
