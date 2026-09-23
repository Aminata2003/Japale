import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './widgets/connexion.dart';
import 'package:japale/models/user_session.dart';

class InscriptionLivreur extends StatefulWidget {
  const InscriptionLivreur({super.key});

  @override
  State<InscriptionLivreur> createState() => _InscriptionLivreurState();
}

class _InscriptionLivreurState extends State<InscriptionLivreur> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();
  final TextEditingController _confirmerMotDePasseController = TextEditingController();
  final TextEditingController _cniController = TextEditingController();
  final TextEditingController _paiementController = TextEditingController();

  bool _motDePasseVisible = false;
  bool _confirmerMotDePasseVisible = false;

  String _transportChoisi = 'Vélo';
  final Set<String> _disponibilites = {'Soir'};

  bool _isLoading = false;

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _motDePasseController.dispose();
    _confirmerMotDePasseController.dispose();
    _cniController.dispose();
    _paiementController.dispose();
    super.dispose();
  }

  Future<void> _inscrireLivreur() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_motDePasseController.text != _confirmerMotDePasseController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Création du compte Firebase Auth avec le vrai mot de passe choisi
      // par le livreur (fini le mot de passe codé en dur).
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _motDePasseController.text,
      );

      final uid = credential.user!.uid;

      // ⚠️ Collection "users" (et non "livreurs") pour rester cohérent avec
      // UserSession.chargerDepuisFirestore() et le reste de l'app.
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'prenom': _prenomController.text.trim(),
        'nom': _nomController.text.trim(),
        'email': _emailController.text.trim(),
        'telephone': _telephoneController.text.trim(),
        'transport': _transportChoisi,
        'disponibilites': _disponibilites.toList(),
        'cni': _cniController.text.trim(),
        'paiement': _paiementController.text.trim(),
        'role': 'livreur',
        'statut': 'en_attente_verification',
        'dateCreation': FieldValue.serverTimestamp(),
      });

      UserSession.uid = uid;
      UserSession.role = 'livreur';
      UserSession.prenom = _prenomController.text.trim();
      UserSession.nom = _nomController.text.trim();
      UserSession.email = _emailController.text.trim();
      UserSession.telephone = _telephoneController.text.trim();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande envoyée avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      // Redirige vers la connexion (le compte reste "en attente de
      // vérification" côté statut, mais l'utilisateur peut déjà se
      // reconnecter avec son email/mot de passe).
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ConnexionPage(profil: "livreur")),
      );
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Erreur Firebase';
      if (e.code == 'email-already-in-use') {
        message = 'Cette adresse email possède déjà un compte';
      } else if (e.code == 'weak-password') {
        message = 'Le mot de passe est trop faible';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildForm(),
                    const SizedBox(height: 28),
                    _buildMotDePasseSection(),
                    const SizedBox(height: 28),
                    _buildMoyenDeTransportSection(),
                    const SizedBox(height: 28),
                    _buildDisponibilitesSection(),
                    const SizedBox(height: 28),
                    _buildVerificationSection(),
                    const SizedBox(height: 28),
                    _buildPaiementsSection(),
                    const SizedBox(height: 28),
                    _buildImageEtBouton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B35),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Devenir Livreur Japale',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Votre profil sera vérifié avant activation ✓',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 1.5)),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("INFORMATIONS PERSONNELLES",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _prenomController,
                decoration: _fieldDecoration('Prénom'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Prénom requis' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _nomController,
                decoration: _fieldDecoration('Nom'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Nom requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _fieldDecoration('abdou.diop@ugb.edu.sn'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Email requis';
            if (!value.contains('@')) return 'Email invalide';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _telephoneController,
          keyboardType: TextInputType.phone,
          decoration: _fieldDecoration('77 000 00 00'),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'Téléphone requis' : null,
        ),
      ],
    );
  }

  Widget _buildMotDePasseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SÉCURITÉ DU COMPTE",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
        const SizedBox(height: 16),
        TextFormField(
          controller: _motDePasseController,
          obscureText: !_motDePasseVisible,
          decoration: _fieldDecoration('Mot de passe').copyWith(
            suffixIcon: IconButton(
              icon: Icon(_motDePasseVisible ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFFF6B35)),
              onPressed: () => setState(() => _motDePasseVisible = !_motDePasseVisible),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Requis';
            if (v.length < 6) return '6 caractères minimum';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmerMotDePasseController,
          obscureText: !_confirmerMotDePasseVisible,
          decoration: _fieldDecoration('Confirmer le mot de passe').copyWith(
            suffixIcon: IconButton(
              icon: Icon(_confirmerMotDePasseVisible ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFFF6B35)),
              onPressed: () => setState(() => _confirmerMotDePasseVisible = !_confirmerMotDePasseVisible),
            ),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
        ),
      ],
    );
  }

  Widget _buildMoyenDeTransportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("MOYEN DE TRANSPORT",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTransportOption(Icons.directions_bike, 'Vélo'),
            _buildTransportOption(Icons.moped, 'Moto'),
            _buildTransportOption(Icons.directions_walk, 'À pied'),
          ],
        ),
      ],
    );
  }

  Widget _buildTransportOption(IconData icon, String label) {
    final bool selected = _transportChoisi == label;
    return GestureDetector(
      onTap: () => setState(() => _transportChoisi = label),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFF1EB) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? const Color(0xFFFF6B35) : Colors.transparent, width: 2),
            ),
            child: Icon(icon, size: 30, color: const Color(0xFFFF6B35)),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildDisponibilitesSection() {
    final List<String> options = ['Matin', 'Midi', 'Soir', 'Week-end'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("DISPONIBILITÉS",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final bool selected = _disponibilites.contains(option);
            return GestureDetector(
              onTap: () => setState(() {
                if (selected) {
                  _disponibilites.remove(option);
                } else {
                  _disponibilites.add(option);
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFFF6B35) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(option, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                    if (selected) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check, size: 16, color: Colors.white),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVerificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("VÉRIFICATION D'IDENTITÉ",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cniController,
          decoration: _fieldDecoration('Numéro CNI ou carte étudiant'),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'Numéro requis' : null,
        ),
        const SizedBox(height: 8),
        Text('Téléchargez un scan recto-verso lisible.',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildPaiementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("PAIEMENTS",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Numéro Wave ou Orange Money', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _paiementController,
                keyboardType: TextInputType.phone,
                decoration: _fieldDecoration('7x xxx xx xx'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Numéro de paiement requis' : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageEtBouton() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset('assets/images/livreur.jpg', height: 160, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _inscrireLivreur,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Soumettre ma demande', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.send, color: Colors.white, size: 18),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}