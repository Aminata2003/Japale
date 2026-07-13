import 'package:flutter/material.dart';

import 'package:japale/welcomPage.dart';
import 'package:japale/inscription_livreur.dart';
import 'package:japale/inscription_restaurant.dart';
import 'package:japale/widgets/connexion.dart';
import 'package:japale/profil_restaurant.dart';
import 'package:japale/acceuil_client.dart';
import 'package:japale/models/plat.dart';
import 'package:japale/publication_menu.dart';
import 'package:japale/panier_page.dart';

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
      home: const WelcomePage(),
    );
  }
}
