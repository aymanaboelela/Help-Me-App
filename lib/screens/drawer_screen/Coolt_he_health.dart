import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/SizeBox/SizeBoxeHorsental.dart';
import '../../core/SizeBox/SizeBoxevertcal.dart';
import '../../core/wedgits/back_icon.dart';

class CoolTheHealth extends StatelessWidget {
  const CoolTheHealth({super.key});
  final String phoneNumber = '123';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizeBoxeVirtcal(value: 5),
            Center(
              child: Text(
                "أرقم الطوارئ",
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizeBoxeVirtcal(value: 3),
            const NumberOfEmergency(
              name: "النجده",
              phoneNumber: "122",
            ),
            const SizeBoxeVirtcal(value: 2),
            const NumberOfEmergency(
              name: "الصحه",
              phoneNumber: "127",
            ),
            const SizeBoxeVirtcal(value: 2),
            const NumberOfEmergency(
              name: "الكهرباء",
              phoneNumber: "121",
            ),
            const SizeBoxeVirtcal(value: 2),
            const NumberOfEmergency(
              name: "المياه",
              phoneNumber: "125",
            ),
            const SizeBoxeVirtcal(value: 2),
            const NumberOfEmergency(
              name: "المطافئ",
              phoneNumber: "180",
            ),
            const SizeBoxeVirtcal(value: 2),
            const NumberOfEmergency(
              name: "الامن العام",
              phoneNumber: "115",
            ),
            const SizeBoxeVirtcal(value: 2),
            const NumberOfEmergency(
              name: "شرطه النقل ",
              phoneNumber: "145",
            ),
            const SizeBoxeVirtcal(value: 2),
            const NumberOfEmergency(
              name: "السكه الحديد",
              phoneNumber: "1547",
            ),
            const SizeBoxeVirtcal(value: 2),
            const NumberOfEmergency(
              name: "مترو الانفاق",
              phoneNumber: "16048",
            ),
            const SizeBoxeVirtcal(value: 2),
            const NumberOfEmergency(
              name: "مباحث الانترنت",
              phoneNumber: "15008",
            ),
            const SizeBoxeVirtcal(value: 2),
            const NumberOfEmergency(
              name: "حمايه المستهلك",
              phoneNumber: "19588",
            ),
            const SizeBoxeVirtcal(value: 2),
            const NumberOfEmergency(
              name: "الصرف الصحي",
              phoneNumber: "175",
            ),
            const SizeBoxeVirtcal(value: 2),
          ],
        ),
      ),
    );
  }
}

class NumberOfEmergency extends StatelessWidget {
  const NumberOfEmergency({
    super.key,
    required this.name,
    required this.phoneNumber,
  });
  final String name;
  final String phoneNumber;
  Future<void> _makePhoneCall ( String phoneNumper) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () {
            final telUrl = 'tel:$phoneNumber';
            _makePhoneCall(telUrl);
          },
          icon: const Icon(
            Icons.phone,
            size: 30,
          ),
          color: Colors.red,
        ),
        const SizeBoxeHorsental(value: 10),
        Text(
          name,
          // textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
