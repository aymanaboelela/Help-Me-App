import 'package:flutter/material.dart';

import '../core/SizeBox/SizeBoxevertcal.dart';
import '../core/utils/size_config.dart';
import '../screens/Home_Screen/Home_Screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  Animation? animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    animation = Tween<double>(begin: 0.2, end: 1).animate(animationController!)
      ..addListener(() {
        setState(() {});
      });
    animationController?.repeat(reverse: true);
    GetToNewScreen();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Image.asset(
          //   "assets/images/Ellipse 11.png",
          // ),
          AnimatedBuilder(
            animation: animation!,
            builder: (context, _) => Opacity(
              opacity: animation!.value,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      width: SizeConfig.screenWidth! * 0.60,
                    ),
                    const SizeBoxeVirtcal(value: 1),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("  Help",
                            style: TextStyle(
                                fontSize: 30,
                                color: Colors.red,
                                fontWeight: FontWeight.w600)),
                        Text(" My",
                            style: TextStyle(
                                fontSize: 30,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void GetToNewScreen() {
    Future.delayed(
      const Duration(seconds: 5),
      () {
        // Get.offAll(() => const HomeScreen(), transition: Transition.fade);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ));
      },
    );
  }
}
