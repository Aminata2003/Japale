import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'restaurant_bottom_nav.dart';
import './widgets/connexion.dart';

const Color kOrange = Color(0xFFFF6B35);
const Color kOrangeLight = Color(0xFFFDF3EE);

class ProfilRestaurant extends StatefulWidget {
  const ProfilRestaurant({super.key});

  @override
  State<ProfilRestaurant> createState() => _ProfilRestaurantState();
}

class _ProfilRestaurantState extends State<ProfilRestaurant> {
  bool _loading = true;

  String nomRestaurant = '';
  String adresse = '';
  String telephone = '';
  String email = '';
  String photo = '';
  double noteMoyenne = 0.0;
  int nombreAvis = 0;

  @override
  void initState() {
    super.initState();
    _chargerRestaurant();
  }

  Future<void> _chargerRestaurant() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        setState(() {
          nomRestaurant = data['nomRestaurant'] ?? '';
          adresse = data['adresse'] ?? '';
          telephone = data['telephone'] ?? '';
          email = data['email'] ?? user.email ?? '';
          photo = data['photoProfil'] ?? '';
          noteMoyenne = (data['noteMoyenne'] ?? 0).toDouble();
          nombreAvis = (data['nombreAvis'] ?? 0);

          _loading = false;
        });
      } else {
        setState(() {
          email = user.email ?? '';
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _deconnexion(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ConnexionPage(profil: '')),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F2EE),
        body: Center(child: CircularProgressIndicator(color: kOrange)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EE),
      appBar: AppBar(
        backgroundColor: kOrange,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildEnTeteProfil(),
          const SizedBox(height: 24),
          _buildSectionInfos(),
          const SizedBox(height: 20),
          _buildOptions(context),
        ],
      ),
      bottomNavigationBar: const RestaurantBottomNav(currentIndex: 3),
    );
  }

  Widget _buildEnTeteProfil() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: kOrangeLight,
              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
              child: photo.isEmpty
                  ? const Icon(Icons.storefront, size: 45, color: kOrange)
                  : null,
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: kOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          nomRestaurant.isEmpty ? 'Restaurant' : nomRestaurant,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(
              '$noteMoyenne ($nombreAvis avis)',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionInfos() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLigneInfo(
            Icons.location_on_outlined,
            'Adresse',
            adresse.isEmpty ? 'Non renseignée' : adresse,
          ),
          const Divider(height: 28),
          _buildLigneInfo(
            Icons.phone_outlined,
            'Téléphone',
            telephone.isEmpty ? 'Non renseigné' : telephone,
          ),
          const Divider(height: 28),
          _buildLigneInfo(
            Icons.email_outlined,
            'Adresse e-mail',
            email.isEmpty ? 'Non renseignée' : email,
          ),
        ],
      ),
    );
  }

  Widget _buildLigneInfo(IconData icon, String titre, String valeur) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: kOrangeLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: kOrange),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                valeur,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            icon: Icons.edit_outlined,
            label: 'Modifier les informations',
            onTap: () {
              // TODO:
              // Ajouter ici la page de modification du restaurant
            },
          ),

          const Divider(height: 1),

          _buildOptionTile(
            icon: Icons.access_time,
            label: "Horaires d'ouverture",
            onTap: () {
              // TODO:
              // Ajouter ici la gestion des horaires
            },
          ),

          const Divider(height: 1),

          _buildOptionTile(
            icon: Icons.logout,
            label: 'Se déconnecter',
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
            onTap: () {
              _deconnexion(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = kOrange,
    Color textColor = Colors.black87,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
}
