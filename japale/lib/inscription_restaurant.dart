import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:japale/services/cloudinary_service.dart';
import './widgets/connexion.dart';

const Color kOrange = Color(0xFFFF6B35);
const Color kOrangeLight = Color(0xFFFDF3EE);

class InscriptionRestaurant extends StatefulWidget {
  const InscriptionRestaurant({super.key});

  @override
  State<InscriptionRestaurant> createState() => _InscriptionRestaurantState();
}

class _InscriptionRestaurantState extends State<InscriptionRestaurant> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomRestaurantController =
      TextEditingController();
  final TextEditingController _nomProprietaireController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();
  final TextEditingController _confirmerMotDePasseController =
      TextEditingController();

  bool _motDePasseVisible = false;
  bool _confirmerMotDePasseVisible = false;
  bool _accepteConditions = false;
  bool _inscriptionEnCours = false;

  File? _photoRestaurant;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nomRestaurantController.dispose();
    _nomProprietaireController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _motDePasseController.dispose();
    _confirmerMotDePasseController.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: kOrange),
                title: const Text('Choisir depuis la galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() => _photoRestaurant = File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: kOrange),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    setState(() => _photoRestaurant = File(image.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Upload la photo du restaurant sur Cloudinary (remplace l'ancien
  /// Firebase Storage, qui exige désormais un compte Blaze avec carte
  /// bancaire).
  Future<String?> _envoyerPhoto() async {
    if (_photoRestaurant == null) return null;
    try {
      return await CloudinaryService.uploadImage(
        _photoRestaurant!,
        folder: 'profils_restaurants',
      );
    } catch (e) {
      debugPrint("Erreur upload photo restaurant : $e");
      return null;
    }
  }

  Future<void> _sInscrire() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_accepteConditions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Merci d'accepter les conditions")),
      );
      return;
    }

    if (_motDePasseController.text != _confirmerMotDePasseController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    setState(() => _inscriptionEnCours = true);

    try {
      final UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _motDePasseController.text.trim(),
          );

      final User user = credential.user!;
      final String? photoUrl = await _envoyerPhoto();

      // Le document restaurants/{uid} inclut dès la création les champs
      // par défaut attendus par tableau_bord_restaurant.dart, gestion_menu.dart
      // ET par le modèle Restaurant (accueil_client.dart, côté étudiant).
      await FirebaseFirestore.instance.collection('restaurants').doc(user.uid).set({
        'uid': user.uid,

        // Champs "internes" (gestion, contact, dashboard restaurant)
        'nomRestaurant': _nomRestaurantController.text.trim(),
        'nomResponsable': _nomProprietaireController.text.trim(),
        'email': _emailController.text.trim(),
        'telephone': '+221${_telephoneController.text.trim()}',
        'adresse': _adresseController.text.trim(),
        'photoUrl': photoUrl ?? '',
        'role': 'restaurant',
        'statut': 'en_attente',
        'ouvert': true,
        'chiffreAffairesDuJour': 0,
        'commandesEnCours': 0,
        'livraisonsEffectuees': 0,
        'nombreAvis': 0,
        'createdAt': FieldValue.serverTimestamp(),

        // Champs attendus par le modèle Restaurant côté étudiant
        // (accueil_client.dart) — dupliqués pour ne pas casser ce fichier.
        'name': _nomRestaurantController.text.trim(),
        'imagePath': photoUrl ?? '',
        'rating': 0.0,
        'noteMoyenne': 0.0, // même valeur, nom utilisé côté dashboard
        // TODO: 'price' représente les frais de livraison (voir
        // PanierPage(fraisLivraison: restaurant.price) dans accueil_client.dart).
        // Pas encore de champ dans ce formulaire pour le configurer — valeur
        // par défaut à ajuster plus tard depuis un écran "Modifier mon profil".
        'price': 500,
        'deliveryMinutes': 30,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte restaurant créé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ConnexionPage(profil: "restaurant"),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Erreur d'inscription";
      if (e.code == 'email-already-in-use') {
        message = "Cet email est déjà utilisé";
      } else if (e.code == 'weak-password') {
        message = "Mot de passe trop faible";
      } else if (e.code == 'invalid-email') {
        message = "Email invalide";
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _inscriptionEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEnTete(context),
              const SizedBox(height: 12),
              _buildPhotoRestaurant(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChampTexte(
                        label: 'Nom du restaurant',
                        controller: _nomRestaurantController,
                        hint: 'Ex: Chez Maman Awa',
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildChampTexte(
                        label: 'Nom du responsable',
                        controller: _nomProprietaireController,
                        hint: 'Prénom et nom',
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildChampTexte(
                        label: 'Adresse email',
                        controller: _emailController,
                        hint: 'contact@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Requis';
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildChampTelephone(),
                      const SizedBox(height: 16),
                      _buildChampTexte(
                        label: 'Adresse du restaurant',
                        controller: _adresseController,
                        hint: 'Quartier, ville',
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildChampMotDePasse(
                        label: 'Mot de passe',
                        controller: _motDePasseController,
                        visible: _motDePasseVisible,
                        onToggle: () => setState(
                          () => _motDePasseVisible = !_motDePasseVisible,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildChampMotDePasse(
                        label: 'Confirmer le mot de passe',
                        controller: _confirmerMotDePasseController,
                        visible: _confirmerMotDePasseVisible,
                        onToggle: () => setState(
                          () => _confirmerMotDePasseVisible =
                              !_confirmerMotDePasseVisible,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCaseConditions(),
                      const SizedBox(height: 24),
                      _buildBoutonInscription(),
                      const SizedBox(height: 16),
                      _buildLienConnexion(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnTete(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: kOrange,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Créer un compte\nRestaurant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoRestaurant() {
    return Center(
      child: GestureDetector(
        onTap: _choisirPhoto,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: kOrangeLight,
              backgroundImage: _photoRestaurant != null
                  ? FileImage(_photoRestaurant!)
                  : null,
              child: _photoRestaurant == null
                  ? const Icon(Icons.storefront, size: 40, color: kOrange)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: kOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChampTexte({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _buildChampTelephone() {
    return _buildChampTexte(
      label: 'Téléphone',
      controller: _telephoneController,
      hint: '77 123 45 67',
      keyboardType: TextInputType.phone,
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Téléphone requis' : null,
    );
  }

  Widget _buildChampMotDePasse({
    required String label,
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: !visible,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Requis';
            if (v.length < 6) return '6 caractères minimum';
            return null;
          },
          decoration: _inputDecoration('••••••••').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                visible ? Icons.visibility_off : Icons.visibility,
                color: kOrange,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaseConditions() {
    return Row(
      children: [
        Checkbox(
          value: _accepteConditions,
          activeColor: kOrange,
          onChanged: (v) => setState(() => _accepteConditions = v ?? false),
        ),
        const Expanded(
          child: Text(
            "J'accepte les conditions d'utilisation",
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildBoutonInscription() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _inscriptionEnCours ? null : _sInscrire,
        style: ElevatedButton.styleFrom(
          backgroundColor: kOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _inscriptionEnCours
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "S'inscrire",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildLienConnexion() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: "Déjà un compte ? "),
            TextSpan(
              text: "Se connecter",
              style: const TextStyle(
                color: kOrange,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConnexionPage(profil: "restaurant"),
                    ),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: kOrangeLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
