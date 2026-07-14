import 'package:flutter/material.dart';
import 'gestion_menu.dart';
import 'package:japale/welcomPage.dart';
import 'tableau_bord_restaurant.dart';
import 'inscription_etudiant.dart';
import 'inscription_restaurant.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Japale',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B35)),
        useMaterial3: true,
      ),

      // Change cette ligne pour tester une page
      home: const InscriptionRestaurant(),
    );
  }
}
