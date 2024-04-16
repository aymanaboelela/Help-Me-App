import 'package:flutter/material.dart';
import 'package:help_my/core/SizeBox/SizeBoxevertcal.dart';

import '../diseases_screens/Burn_cases.dart';
import '../diseases_screens/He_swallowed_his_tongue_2.dart';
import '../diseases_screens/Snake_bite.dart';
import '../diseases_screens/bleeding_cases.dart';
import '../diseases_screens/diabetic_coma_screen_1.dart';
import '../diseases_screens/epilepticseizures.dart';
import '../diseases_screens/fainting_condition.dart';
import '../drawer_screen/drwaer_screen.dart';
import 'widgets/custem_item.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final List items = [
      const SizeBoxeVirtcal(value: 1),
      CustemItem(
        name: 'بلع اللسان',
        image: "assets/images/mouth 1.png",
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return HeswallowedHistongue();
            },
          ));
        },
      ),
      const SizeBoxeVirtcal(value: 1),
      CustemItem(
        name: 'نزيف الانف',
        image: "assets/images/nostril 1.png",
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return BleedingCases();
            },
          ));
        },
      ),
      const SizeBoxeVirtcal(value: 1),
      CustemItem(
        name: 'حالة إغماء',
        image: "assets/images/woman 1.png",
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return FaintingCondition();
            },
          ));
        },
      ),
      const SizeBoxeVirtcal(value: 1),
      CustemItem(
        name: 'حالة حروق',
        image: "assets/images/fire 1.png",
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return BurnCases();
            },
          ));
        },
      ),
      const SizeBoxeVirtcal(value: 1),
      CustemItem(
        name: 'غيبوبه سكر',
        image: "assets/images/Syringe.png",
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return const DiabeticComaScreen();
            },
          ));
        },
      ),
      const SizeBoxeVirtcal(value: 1),
      CustemItem(
        name: 'لدغة الثعبان',
        image: "assets/images/animal 1.png",
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return SnakeBite();
            },
          ));
        },
      ),
      const SizeBoxeVirtcal(value: 1),
      CustemItem(
        name: 'نوبات الصرع',
        image: "assets/images/tonic 1.png",
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return EpilepticSeizures();
            },
          ));
        },
      ),
    ];
    return Scaffold(
        drawer: const DrwaerScreen(),
        appBar: AppBar(
          centerTitle: true,
          title: Text('الرئيسية',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              )),
          backgroundColor: Colors.red,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView.builder(
            itemBuilder: (context, index) {
              return items[index];
            },
            itemCount: items.length,
          ),
        ));
  }
}
