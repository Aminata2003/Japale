import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import './widgets/connexion.dart';
import 'package:japale/models/user_session.dart';

const Color kOrange = Color(0xFFF06429);
const Color kOrangeLight = Color(0xFFFDF3EE);

class InscriptionEtudiant extends StatefulWidget {
  const InscriptionEtudiant({super.key});

  @override
  State<InscriptionEtudiant> createState() => _InscriptionEtudiantState();
}

class _InscriptionEtudiantState extends State<InscriptionEtudiant> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();
  final TextEditingController _confirmerMotDePasseController =
      TextEditingController();

  bool _motDePasseVisible = false;
  bool _confirmerMotDePasseVisible = false;
  bool _accepteConditions = false;

  File? _photoProfil;
  final ImagePicker _picker = ImagePicker();

  String? _citeSelectionnee;
  final List<String> _cites = [
    for (int i = 0; i < 17; i++)
      'Village ${String.fromCharCode(65 + i)}', // Village A à Village Q
    'Hors campus',
  ];

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
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
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() => _photoProfil = File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: kOrange),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() => _photoProfil = File(image.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sInscrire() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_accepteConditions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci d\'accepter les conditions d\'utilisation'),
        ),
      );
      return;
    }

    if (_motDePasseController.text != _confirmerMotDePasseController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
        ),
      );
      return;
    }

    if (_citeSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci de sélectionner votre village'),
        ),
      );
      return;
    }

    // Sauvegarde dans UserSession
    UserSession.prenom = _prenomController.text.trim();
    UserSession.nom = _nomController.text.trim();
    UserSession.email = _emailController.text.trim();
    UserSession.telephone = _telephoneController.text.trim();
    UserSession.village = _citeSelectionnee!;
    UserSession.motDePasse = _motDePasseController.text;

    // Pour déboguer - affiche dans la console
    print('=== INSCRIPTION RÉUSSIE ===');
    print('Email: ${UserSession.email}');
    print('Mot de passe: ${UserSession.motDePasse}');
    print('============================');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compte créé avec succès !')),
    );

    // Redirige vers la page de connexion après inscription
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ConnexionPage()),
    );
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
              _buildPhotoProfil(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildChampTexte(
                              label: 'Prénom',
                              controller: _prenomController,
                              hint: 'Abdou',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Requis'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildChampTexte(
                              label: 'Nom',
                              controller: _nomController,
                              hint: 'Diop',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Requis'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildChampTexte(
                        label: 'Adresse email',
                        controller: _emailController,
                        hint: 'prenom.nom@ugb.edu.sn ou @gmail.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Requis';
                          final email = v.trim().toLowerCase();
                          final domaineValide = email.endsWith('@ugb.edu.sn') ||
                              email.endsWith('@gmail.com');
                          if (!domaineValide) {
                            return 'Utilise une adresse @ugb.edu.sn ou @gmail.com';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildChampTelephone(),
                      const SizedBox(height: 16),
                      _buildChampMotDePasse(
                        label: 'Mot de passe',
                        controller: _motDePasseController,
                        visible: _motDePasseVisible,
                        onToggle: () => setState(
                            () => _motDePasseVisible = !_motDePasseVisible),
                      ),
                      const SizedBox(height: 16),
                      _buildChampMotDePasse(
                        label: 'Confirmer le mot de passe',
                        controller: _confirmerMotDePasseController,
                        visible: _confirmerMotDePasseVisible,
                        onToggle: () => setState(() =>
                            _confirmerMotDePasseVisible =
                                !_confirmerMotDePasseVisible),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownCite(),
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
              'Créer un compte\nÉtudiant',
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

  Widget _buildPhotoProfil() {
    return Center(
      child: GestureDetector(
        onTap: _choisirPhoto,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: kOrangeLight,
              backgroundImage:
                  _photoProfil != null ? FileImage(_photoProfil!) : null,
              child: _photoProfil == null
                  ? const Icon(Icons.person, size: 40, color: kOrange)
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
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Numéro de téléphone',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: kOrangeLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kOrange.withOpacity(0.3)),
              ),
              child: const Text('+221',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
                decoration: _inputDecoration('77 123 45 67'),
              ),
            ),
          ],
        ),
      ],
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
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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

  Widget _buildDropdownCite() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Village de résidence',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _citeSelectionnee,
          decoration: _inputDecoration('Sélectionnez votre village'),
          items: _cites
              .map((cite) => DropdownMenuItem(value: cite, child: Text(cite)))
              .toList(),
          onChanged: (value) => setState(() => _citeSelectionnee = value),
        ),
      ],
    );
  }

  Widget _buildCaseConditions() {
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _accepteConditions,
            activeColor: kOrange,
            onChanged: (value) =>
                setState(() => _accepteConditions = value ?? false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 13),
              children: [
                const TextSpan(text: "J'accepte les "),
                TextSpan(
                  text: "conditions d'utilisation",
                  style: const TextStyle(
                    color: kOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoutonInscription() {
    return ElevatedButton(
      onPressed: _sInscrire,
      style: ElevatedButton.styleFrom(
        backgroundColor: kOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
      child: const Text(
        "S'inscrire",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildLienConnexion() {
    return Center(
      child: RichText(
        text: const TextSpan(
          style: TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(text: 'Déjà un compte ? '),
            TextSpan(
              text: 'Se connecter',
              style: TextStyle(color: kOrange, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: kOrangeLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kOrange, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }
}