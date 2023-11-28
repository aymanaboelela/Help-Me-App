import 'package:flutter/material.dart';


import '../../core/wedgits/back_icon.dart';

class SwallowingScreen extends StatelessWidget {
  const SwallowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BackIcon(icon: Icons.arrow_forward_ios_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
