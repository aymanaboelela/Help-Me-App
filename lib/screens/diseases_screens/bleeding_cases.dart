import 'package:flutter/material.dart';


import '../../custem_widget.dart';

class BleedingCases extends StatelessWidget {
  BleedingCases({super.key});
  String firstAidSteps = '1. الضغط المباشر على الجرح النازف بغيار نظيف\n\n'
      '2. رفع العضو المصاب إلى أعلى إن لم يكن به كسر\n\n'
      '3. يربط الضمادة جيدا بينما يظل العضو مرفوعا\n\n'
      '4. قد يصبح الغيار مشبعا بالدم فلا تغيره أبدا و لا تنزعه\n\n'
      '5. يمكن وضع غيار ثاني على الغيار الأول و يربط بضغط\n\n'
      '6. مراقبة المصاب من حدوث الصدمة\n\n'
      '7. ينقل المصاب إلى أقرب مركز طبي\n\n'
      '8. لا تستخدم البن أو ما شابه لإيقاف النزيف';
  String firstAidSteps2 =
      '1. إذا كانت الإصابة بسيطة ضع عليها ثلجا أو كمادة باردة للمساعدة في تخفيف الألم و التورم ، و ضع قطعة قماش بين الثلج و جلد المصاب لمنع تلف الجلد\n\n'
      '2. اجعل المصاب يستلقي على جانبه متكئا على إحدى يديه و يثني ركبتيه للمساعدة في خروج القيء إن وجد\n\n'
      '3. حافظ على درجة حرارة الجسم الطبيعية بتغطية المصاب\n\n'
      '4. كما يجب تهدئة المصاب و بعث الطمأنينة في نفسه\n\n'
      '5. لا تقدم للمصاب أي طعام أو شراب\n\n'
      '6. إذا كان فاقدا للوعي أفحص التنفس و إذا لزم الأمر أنعش تنفسه';

  @override
  Widget build(BuildContext context) {
    return CustemWidget(
        headImage: "assets/images/33333.jpg",
        headTitle: " إيقاف النزيف الخارجي",
        sacandTitel: " الإسعافات الأولية",
        description: firstAidSteps,
        sacandImage: "assets/images/333333333.jpg",
        headTitle2: " الإسعاف الأولي للنزيف الداخلي",
        description2: firstAidSteps2,
        sacandImage2: "assets/images/33333333333333.jpg");
  }
}
