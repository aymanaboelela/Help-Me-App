import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_my/screens/drawer_screen/Coolt_he_health.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/size_config.dart';
import 'star.dart';

class DrwaerScreen extends StatelessWidget {
  const DrwaerScreen({
    super.key,
  });
  final String phoneNumber = '123';

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Can't launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(),
            child: SizedBox(
              width: SizeConfig.defaultSize! * 5,
              child: Image.asset('assets/images/emergency.png'),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.phone,
              color: Colors.red,
              size: SizeConfig.defaultSize! * 3.5,
            ),
            title: SizedBox(
              width: 157,
              height: 31,
              child: Text(
                'أرقام الطوارئ',
                style: GoogleFonts.cairo(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const CoolTheHealth();
                },
              ));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.healing_outlined,
              color: Colors.red,
              size: SizeConfig.defaultSize! * 3.5,
            ),
            title: SizedBox(
              width: 157,
              height: 31,
              child: Text('طلب الاسعاف',
                  style: GoogleFonts.cairo(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            onTap: () {
              final telUrl = 'tel:$phoneNumber';
              _makePhoneCall(telUrl);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.star_outline_rounded,
              color: Colors.red,
              size: SizeConfig.defaultSize! * 3.5,
            ),
            title: SizedBox(
              width: 157,
              height: 31,
              child: Text(' تقييم الخدمة',
                  style: GoogleFonts.cairo(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const Star();
                },
              ));
            },
          ),
        ],
      ),
    );
  }
}
