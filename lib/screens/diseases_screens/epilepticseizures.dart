import 'package:flutter/material.dart';


import '../../custem_widget.dart';

class EpilepticSeizures extends StatelessWidget {
  EpilepticSeizures({super.key});
  String seizureInstructions = '''
1- لا تقيد المصاب إن كان في حالة تشنجات (لا تحاول كبح حركاته التشنجية) بل إعمل على وقايته من الإصابات وذلك بإبعاد الأشياء المؤذية من حوله أثناء النوبة مثل الأثاث.
2- لا تضع أي شيء في فم المصاب أو بين أسنانه.
3- ضع وسادة أو أي شيء تحت رأسه يحميها من الارتطام بالأرض أثناء النوبة.
4- فك ملابس المصاب الضيقة من صدره وعنقه لتسهل تنفسه.
5- بعد انتهاء نوبة الصرع يوضع المصاب ممددًا على جانبه لتجنب رجوع القيء إلى فمه إن وجد وذلك للمحافظة على سلامة الممر الهوائي.
6- إذا توقف تنفس المصاب يعمل له تنفس صناعي من الفم إلى الفم (إذا تعذر فتح الفم يعمل له تنفس من الفم إلى الأنف).
7- قد يكون المصاب عرضة للإصابة بنوبة أخرى إذا بذل مجهودًا أو تمشى بعد النوبة الأولى.
8- اسع لتوفير راحة وهدوء المصاب.
9- لا تزعج المصاب أو تحركه أو تسأله.
''';
  String additionalSeizureInstructions = '''
- إذا كان المريض يصاب بهذه النوبة لأول مرة.
- إذا استمرت النوبة أكثر من خمس دقائق أو تكررت أكثر من مرة بشكل متوالي.
- إذا حدثت و المريض فى الماء (كالبحر أو حمام السباحة).
''';
  @override
  Widget build(BuildContext context) {
    return CustemWidget(
        headImage: "assets/images/7.jpg",
        headTitle: "نوبات الصرع",
        sacandTitel: "الإسعافات الأولية",
        description: seizureInstructions,
        sacandImage: "assets/images/77.jpg",
        headTitle2: "يتم استدعاء النجدة الطبية فى الحالات التالية فقط :",
        description2: additionalSeizureInstructions,
        sacandImage2: "assets/images/77777777777.jpg");
  }
}
