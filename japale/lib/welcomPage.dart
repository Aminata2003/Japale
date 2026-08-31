import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'choix_profil.dart';
import 'widgets/japale_logo.dart';

import 'package:japale/widgets/connexion.dart';
import 'package:japale/acceuil_client.dart';
import 'package:japale/profil_restaurant.dart';
import 'package:japale/models/user_session.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _verificationEnCours = true;

  @override
  void initState() {
    super.initState();
    _verifierConnexion();
  }

  Future<void> _verifierConnexion() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await UserSession.chargerDepuisFirestore(user.uid);
        String role = UserSession.role ?? 'etudiant';

        if (!mounted) return;

        switch (role) {
          case 'restaurant':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfilRestaurant()),
            );
            break;

          case 'etudiant':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AccueilClient()),
            );
            break;

          default:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ChoixProfilPage()),
            );
        }

        return;
      } catch (e) {
        debugPrint("Erreur récupération profil Firebase : $e");
      }
    }

    if (mounted) {
      setState(() {
        _verificationEnCours = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_verificationEnCours) {
      return const Scaffold(
        backgroundColor: Color(0xFFFF7A3D),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,

        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,

            colors: [Color(0xFFFF7A3D), Color(0xFFFF9500)],
          ),
        ),

        child: Stack(
          children: [
            Positioned(
              top: 20,

              right: -20,

              child: Icon(
                Icons.restaurant,

                size: 160,

                color: Colors.white.withOpacity(0.08),
              ),
            ),

            Positioned(
              bottom: -40,

              left: -40,

              child: Icon(
                Icons.pedal_bike,

                size: 200,

                color: Colors.white.withOpacity(0.06),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),

                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    const JapaleLogo(),

                    const SizedBox(height: 28),

                    const Text(
                      'JAPALE',

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 36,

                        fontWeight: FontWeight.w900,

                        letterSpacing: 4,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'La livraison étudiante au campus UGB',

                      textAlign: TextAlign.center,

                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),

                    const Spacer(flex: 4),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,

                        vertical: 14,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Text(
                        '🚲 Livraison rapide • 200 FCFA campus • 500 FCFA hors campus',

                        textAlign: TextAlign.center,

                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 54,

                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ConnexionPage(profil: ''),
                                  ),
                                );
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),

                              child: const Text(
                                'Se connecter',

                                style: TextStyle(
                                  color: Color(0xFFB5401A),

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: SizedBox(
                            height: 54,

                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (_) => const ChoixProfilPage(),
                                  ),
                                );
                              },

                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.white,

                                  width: 1.5,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),

                              child: const Text(
                                "S'inscrire",

                                style: TextStyle(
                                  color: Colors.white,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Aide & Assistance • v2.0.1',

                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),

                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
