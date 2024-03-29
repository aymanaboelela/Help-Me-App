import 'package:flutter/material.dart';

import '../../../core/SizeBox/SizeBoxeHorsental.dart';
import 'package:google_fonts/google_fonts.dart';

class CustemItem extends StatelessWidget {
  const CustemItem({
    super.key,
    required this.name,
    required this.image,
    required this.onTap,
  });
  final String name;
  final String image;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(name,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                )),
            const SizeBoxeHorsental(
              value: 2,
            ),
            Container(
              width: 53,
              height: 55,
              decoration: const ShapeDecoration(
                shape: OvalBorder(
                  side: BorderSide(width: 2, color: Color(0xFFDD0404)),
                ),
              ),
              child: Image.asset(image),
            ),
          ],
        ),
      ),
    );
  }
}
