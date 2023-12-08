import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/SizeBox/SizeBoxeHorsental.dart';
import '../../core/SizeBox/SizeBoxevertcal.dart';
import '../../core/wedgits/back_icon.dart';

class CoolTheHealth extends StatelessWidget {
  const CoolTheHealth({super.key});
  final String phoneNumber = '123';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizeBoxeVirtcal(value: 5),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: BackIcon(icon: Icons.arrow_back_ios),
            ),
            Center(
              child: Text(
                "أرقم الطوارئ",
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Nirmala UI',
                  fontWeight: FontWeight.w700,
                  height: 0,
                ),
              ),
            ),
            SizeBoxeVirtcal(value: 3),
            NumberOfEmergency(
              name: "النجده",
              phoneNumber: "122",
            ),
            SizeBoxeVirtcal(value: 2),
            NumberOfEmergency(
              name: "الصحه",
              phoneNumber: "127",
            ),
            SizeBoxeVirtcal(value: 2),
            NumberOfEmergency(
              name: "الكهرباء",
              phoneNumber: "121",
            ),
            SizeBoxeVirtcal(value: 2),
            NumberOfEmergency(
              name: "المياه",
              phoneNumber: "125",
            ),
            SizeBoxeVirtcal(value: 2),
            NumberOfEmergency(
              name: "المطافئ",
              phoneNumber: "180",
            ),
            SizeBoxeVirtcal(value: 2),
            NumberOfEmergency(
              name: "الامن العام",
              phoneNumber: "115",
            ),
            SizeBoxeVirtcal(value: 2),
            NumberOfEmergency(
              name: "شرطه النقل ",
              phoneNumber: "145",
            ),
            SizeBoxeVirtcal(value: 2),
            NumberOfEmergency(
              name: "السكه الحديد",
              phoneNumber: "1547",
            ),
            SizeBoxeVirtcal(value: 2),
            NumberOfEmergency(
              name: "مترو الانفاق",
              phoneNumber: "16048",
            ),
            SizeBoxeVirtcal(value: 2),
            NumberOfEmergency(
              name: "مباحث الانترنت",
              phoneNumber: "15008",
            ),
            SizeBoxeVirtcal(value: 2),
            NumberOfEmergency(
              name: "حمايه المستهلك",
              phoneNumber: "19588",
            ),
            SizeBoxeVirtcal(value: 2),
            NumberOfEmergency(
              name: "الصرف الصحي",
              phoneNumber: "175",
            ),
            SizeBoxeVirtcal(value: 2),
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
  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Can't launch $url");
    }
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
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Nirmala UI',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ),
      ],
    );
  }
}
