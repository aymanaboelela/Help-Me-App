import 'package:flutter/material.dart';

class BackIcon extends StatelessWidget {
  const BackIcon({
    super.key, required this.icon,
  });
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(
        icon,
        color: Colors.red,
      ),
    );
  }
}
