import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:japale/inscription_livreur.dart';
import 'package:japale/inscription_etudiant.dart';
import 'package:japale/inscription_restaurant.dart';
import 'package:japale/acceuil_client.dart';
import 'package:japale/tableau_bord_restaurant.dart';
import 'package:japale/widgets/japale_logo.dart';
import 'package:japale/models/user_session.dart';

import 'package:japale/accueil_livreur.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key, required this.profil});

  final String profil;

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  bool _obscurePassword = true;
  bool _chargement = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ===============================
  // CONNEXION FIREBASE
  // ===============================

  Future<void> _seConnecter() async {
    String emailSaisi = _emailController.text.trim();
    String motDePasseSaisi = _passwordController.text.trim();

    if (emailSaisi.isEmpty || motDePasseSaisi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      _chargement = true;
    });

    try {
      // Connexion Firebase Auth
      UserCredential resultat = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailSaisi,
            password: motDePasseSaisi,
          );

      User? utilisateur = resultat.user;

      if (utilisateur == null) {
        throw Exception("Utilisateur introuvable");
      }

      // Chargement des informations Firestore
      // Chargement des informations Firestore
      await UserSession.chargerDepuisFirestore(
        utilisateur.uid,
        profil: widget.profil,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connexion réussie !"),
          backgroundColor: Colors.green,
        ),
      );

      // Redirection selon le profil (étudiant / restaurant / livreur)
      Widget pageDestination;

      switch (UserSession.role) {
        case 'restaurant':
          pageDestination = const TableauBordRestaurant();
          break;
        case 'livreur':
          pageDestination = const AccueilLivreur();
          break;
        case 'etudiant':
        default:
          pageDestination = const AccueilClient();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => pageDestination),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Erreur de connexion";

      if (e.code == 'user-not-found') {
        message = "Aucun compte trouvé avec cet email";
      } else if (e.code == 'wrong-password') {
        message = "Mot de passe incorrect";
      } else if (e.code == 'invalid-email') {
        message = "Adresse email invalide";
      } else if (e.code == 'invalid-credential') {
        message = "Email ou mot de passe incorrect";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _chargement = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B35),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          'Connexion',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),

          child: Column(
            children: [
              _buildLogo(),

              const SizedBox(height: 32),

              _buildEmailField(),

              const SizedBox(height: 20),

              _buildPasswordField(),

              const SizedBox(height: 8),

              _buildForgotPassword(),

              const SizedBox(height: 24),

              _buildLoginButton(context),

              const SizedBox(height: 20),

              _buildDivider(),

              const SizedBox(height: 20),

              _buildGoogleButton(),

              const SizedBox(height: 60),

              _buildSignupPrompt(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'Adresse email',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: _emailController,

          keyboardType: TextInputType.emailAddress,

          decoration: InputDecoration(
            hintText: 'etudiant@ugb.sn',

            hintStyle: TextStyle(color: Colors.grey.shade400),

            prefixIcon: const Icon(Icons.mail_outline),

            filled: true,

            fillColor: Colors.grey.shade100,

            contentPadding: const EdgeInsets.symmetric(vertical: 14),

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'Mot de passe',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: _passwordController,

          obscureText: _obscurePassword,

          decoration: InputDecoration(
            hintText: '••••••••',

            prefixIcon: const Icon(Icons.lock_outline),

            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),

              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),

            filled: true,

            fillColor: Colors.grey.shade100,

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,

      child: GestureDetector(
        onTap: () {},

        child: const Text(
          'Mot de passe oublié ?',

          style: TextStyle(
            color: Color(0xFFB5401A),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      height: 54,

      child: ElevatedButton(
        onPressed: _chargement ? null : _seConnecter,

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),

        child: _chargement
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Se connecter',

                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),

          child: Text('ou', style: TextStyle(color: Colors.grey.shade600)),
        ),

        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,

      height: 54,

      child: OutlinedButton.icon(
        onPressed: () {},

        icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),

        label: const Text(
          'Continuer avec Google',
          style: TextStyle(color: Colors.black87, fontSize: 15),
        ),

        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupPrompt(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),

          children: [
            const TextSpan(text: 'Pas encore de compte ? '),

            TextSpan(
              text: "S'inscrire",

              style: const TextStyle(
                color: Color(0xFFB5401A),

                fontWeight: FontWeight.bold,
              ),

              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Widget pageInscription;

                  switch (widget.profil) {
                    case 'restaurant':
                      pageInscription = const InscriptionRestaurant();
                      break;
                    case 'livreur':
                      pageInscription = const InscriptionLivreur();
                      break;
                    case 'etudiant':
                      pageInscription = const InscriptionEtudiant();
                      break;
                    default:
                      pageInscription = const InscriptionEtudiant();
                  }

                  Navigator.pushReplacement(
                    context,

                    MaterialPageRoute(builder: (context) => pageInscription),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        const JapaleLogo(
          size: 100,

          iconSize: 44,

          backgroundColor: Color(0xFFFFE4D6),

          iconColor: Color(0xFFFF6B35),

          isCircle: false,
        ),

        const SizedBox(height: 16),

        const Text(
          'Japale',

          style: TextStyle(
            color: Color(0xFFFF6B35),

            fontSize: 24,

            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "L'entraide étudiante, un repas à la fois.",

          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }
}
