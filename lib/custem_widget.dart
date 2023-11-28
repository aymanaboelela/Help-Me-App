import 'package:flutter/material.dart';


import 'core/SizeBox/SizeBoxevertcal.dart';
import 'core/wedgits/back_icon.dart';

class CustemWidget extends StatelessWidget {
  const CustemWidget({
    super.key,
    @required this.headImage,
    @required this.headTitle,
    @required this.sacandTitel,
    @required this.description,
    @required this.sacandImage,
    @required this.headTitle2,
    @required this.description2,
    @required this.sacandTitle2,
    @required this.description3,
    @required this.sacandImage2,
  });

  final String? headImage;

  final String? headTitle;

  final String? sacandTitel;

  final String? description;

  final String? sacandImage;

  final String? headTitle2;

  final String? description2;

  final String? sacandTitle2;
  final String? description3;

  final String? sacandImage2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const BackIcon(icon: Icons.arrow_forward_ios),
                const SizeBoxeVirtcal(value: 5),
                Center(child: Image.asset(headImage!)),
                Center(
                  child: Text(
                    textDirection: TextDirection.rtl,
                    headTitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 29,
                      fontFamily: 'Nirmala UI',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(
                    textDirection: TextDirection.rtl,
                    sacandTitel ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF416EAB),
                      fontSize: 23,
                      fontFamily: 'Nirmala UI',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                  SizedBox(
                    width: 337,
                    child: Text(
                      textDirection: TextDirection.rtl,
                      description ?? '',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Nirmala UI',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                  )
                ]),
                Center(
                  child: Image.asset(
                    sacandImage!,
                  ),
                ),
                Center(
                  child: Text(
                    textDirection: TextDirection.rtl,
                    headTitle2 ?? '',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF416EAB),
                      fontSize: 22,
                      fontFamily: 'Nirmala UI',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
                Text(
                  textDirection: TextDirection.rtl,
                  description2 ?? '',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Nirmala UI',
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
                const SizeBoxeVirtcal(value: 2),
                Text(
                  textDirection: TextDirection.rtl,
                  sacandTitle2 ?? '',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF416EAB),
                    fontSize: 22,
                    fontFamily: 'Nirmala UI',
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
                Text(
                  textDirection: TextDirection.rtl,
                  description3 ?? '',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Nirmala UI',
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
                const SizeBoxeVirtcal(value: 2),
                Center(child: Image.asset(sacandImage2!)),
                const SizeBoxeVirtcal(value: 3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
