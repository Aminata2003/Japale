import 'package:flutter/material.dart';

class JapaleLogo extends StatelessWidget {
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final bool isCircle; // true = cercle, false = carré arrondi

  const JapaleLogo({
    super.key,
    this.size = 130,
    this.iconSize = 60,
    this.backgroundColor = Colors.white24, // valeur par défaut = ton usage actuel (WelcomePage)
    this.iconColor = Colors.white,
    this.isCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(24),
        color: backgroundColor,
      ),
      child: Icon(
        Icons.moped, // j'ai harmonisé sur "moped" (vu sur la page connexion), à toi de garder pedal_bike si tu préfères
        size: iconSize,
        color: iconColor,
      ),
    );
  }
}