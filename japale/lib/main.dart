import 'package:flutter/material.dart';
import 'package:japale/welcomPage.dart';
import 'package:japale/inscription_livreur.dart';
import 'package:japale/widgets/connexion.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomePage(), // Page d'accueil de l'application
    );
  }
}
