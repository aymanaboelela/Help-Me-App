import 'package:flutter/material.dart';

import '../utils/size_config.dart';



class SizeBoxeVirtcal extends StatelessWidget {
  const SizeBoxeVirtcal({super.key, required this.value});
  final double value;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.defaultSize! * value,
    );
  }
}
