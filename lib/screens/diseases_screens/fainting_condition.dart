import 'package:flutter/material.dart';
import '../../custem_widget.dart';
class FaintingCondition extends StatelessWidget {
  FaintingCondition({super.key});
  String firstAidSteps =
      '1. ساعد المصاب على الاستلقاء على ظهره (تجنب وضع الجلوس أو الوقوف).\n\n'
      '2. تأكد من وجود التهوية اللازمة.\n\n'
      '3. ارفع ساقي المصاب إلى أعلى 30 سم (12 بوصة) إذا كان المصاب لا يعاني من أي مشكلة في التنفس و إن لم يكن هناك ما يمنع ذلك (كما فى حالة الكسور مثلا) و رفع الساقين يكون بوضع مخدة أو صندوق مثلا تحت كعب المصاب لرفع ساقيه (لا تضع المخدة تحت الساق أو تحت الركبة).\n\n'
      '4. فك أو حل الملابس الضيقة عن المصاب.\n\n'
      '5. لا تعطي المصاب أي شيء عن طريق الفم وهو مغمى عليه.\n\n'
      '6. إذا تقيأ المصاب ضعه على جانبه و أدر رأسه جانبا و امسح القيء من فمه.\n\n'
      '7. لا تصب الماء أو أي سائل آخر على وجه المصاب بل يمكن أن تمسح وجهه بفوطة مبلولة بالماء البارد.\n\n'
      '8. إذا ما بدأ المصاب يعى ما حوله فطمئنه و ساعده على الجلوس.\n\n'
      '9. فحص المصاب و تأكد من خلوه من الجروح و الكسور الواضحة و التي قد تكون خلال سقوطه بعد فقدانه الوعي.\n\n'
      '10. راقب المصاب بعد إفاقته و انتبه إلى أن فقدان الوعي لمدة قصيرة ثم الإفاقة قد يتبعه فقدان للوعي مرة أخرى ولمدة طويلة هذه المرة ، و هنا يستحسن استدعاء الإسعاف.';
  @override
  Widget build(BuildContext context) {
    return CustemWidget(
        headImage: 'assets/images/41.jpg',
        headTitle: "حالة الإغماء",
        sacandTitel: " الإسعافات الأولية",
        description: firstAidSteps,
        sacandImage: "assets/images/4444.jpg",
        sacandImage2: "assets/images/44444.jpg");
  }
}
