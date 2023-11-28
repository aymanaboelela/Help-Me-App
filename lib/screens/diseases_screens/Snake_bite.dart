import 'package:flutter/material.dart';


import '../../custem_widget.dart';

class SnakeBite extends StatelessWidget {
  SnakeBite({super.key});
  String snakeBiteInstructions = '''
1- أطلب الإسعاف.
2- هدئ من روع المصاب لمنع انتشار السم في الجسم.
3- اغسل الجرح بالماء الجاري والصابون إن أمكن ذلك.
4- حاول تثبيت الجزء المصاب أفقيا مع عمل ضمادة لكامل العضو المصاب. يجب أن يكون مكان العضة أدنى من مستوى القلب لإبطاء انتشار السم.
5- قم بحمل المصاب إلى قسم الطوارئ أو اطلب منه المشي ببطء حتى لا ينتشر السم في دمه قبل الوصول إلى أقرب مستشفى.
6- يمكن عمل رباط ضاغط لربط الجزء السابق للإصابة لمنع انتشار السم إلى بقية أجزاء الجسم.
7- لا تضع الثلج على مكان الإصابة لأن ذلك لا يفيد في منع انتشار السم.
8- لا تقدم للمصاب أي سوائل أو أطعمة أو الأسبرين، لأن ذلك قد يؤدي إلى فقدانه للوعي ويسبب اختناقًا إذا تقيأ.
9- إذا فقد المصاب وعيه، لا تحاول إفاقته ونقله إلى أقرب مستشفى على الفور.
''';

  @override
  Widget build(BuildContext context) {
    return CustemWidget(
        headImage: "assets/images/6.jpg",
        headTitle: " عضة الثعبان",
        sacandTitel: "الإسعافات الأولية",
        description: snakeBiteInstructions,
        sacandImage: "assets/images/66.jpg",
        sacandImage2: "assets/images/66666.jpg");
  }
}
