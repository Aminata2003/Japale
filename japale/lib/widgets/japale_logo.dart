import 'package:flutter/material.dart';

class JapaleLogo extends StatelessWidget {
  final double size;
  final double iconSize;

  const JapaleLogo({
    super.key,
    this.size = 130,
    this.iconSize = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
      ),
      child: Icon(
        Icons.pedal_bike,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }
}