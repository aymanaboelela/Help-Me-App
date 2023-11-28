import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../core/SizeBox/SizeBoxeHorsental.dart';
import '../../core/SizeBox/SizeBoxevertcal.dart';
import '../../core/wedgits/back_icon.dart';

class CoolTheHealth extends StatelessWidget {
  const CoolTheHealth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizeBoxeVirtcal(value: 5),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: BackIcon(icon: Icons.arrow_back_ios),
          ),
          const SizeBoxeVirtcal(value: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage("assets/images/mouth 1.png"),
              ),
              const SizeBoxeHorsental(value: 1),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.phone,
                    size: 30,
                  ))
            ],
          )
        ],
      ),
    );
  }
}

void _launchCaller(String phoneNumber) async {
  if (await canLaunch(phoneNumber)) {
    await launch(phoneNumber);
  } else {
    throw 'Could not launch $phoneNumber';
  }
}
