import 'package:flutter/material.dart';

import '../utils/size_config.dart';



class SizeBoxeHorsental extends StatelessWidget {
  const SizeBoxeHorsental({super.key, required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConfig.defaultSize! * value,
    );
  }
}
