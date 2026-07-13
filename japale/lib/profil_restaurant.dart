import 'package:flutter/material.dart';
import 'restaurant_bottom_nav.dart';
import './widgets/connexion.dart'; // adapte le nom du fichier si besoin

const Color kOrange = Color(0xFFFF6B35);
const Color kOrangeLight = Color(0xFFFDF3EE);

/// Page profil du restaurant. Fait partie du profil Restaurant :
/// possède donc la RestaurantBottomNav (onglet "Profil" actif, index 3).
class ProfilRestaurant extends StatelessWidget {
  const ProfilRestaurant({super.key});

  // TODO: remplacer ces valeurs statiques par les vraies données du
  // restaurant connecté (backend / Firebase).
  static const String nomRestaurant = 'Maman Awa';
  static const String adresse = 'Cité Kennedy, Saint-Louis';
  static const String telephone = '+221 77 123 45 67';
  static const String email = 'contact@mamanawa.sn';
  static const double noteMoyenne = 4.8;
  static const int nombreAvis = 124;

  @override
  Widget build(BuildContext context) {
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
            const CircleAvatar(
              radius: 48,
              backgroundColor: kOrangeLight,
              child: Icon(Icons.storefront, size: 44, color: kOrange),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: kOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          nomRestaurant,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(
              '$noteMoyenne  ($nombreAvis avis)',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionInfos() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLigneInfo(Icons.location_on_outlined, 'Adresse', adresse),
          const Divider(height: 24),
          _buildLigneInfo(Icons.phone_outlined, 'Téléphone', telephone),
          const Divider(height: 24),
          _buildLigneInfo(Icons.mail_outline, 'Email', email),
        ],
      ),
    );
  }

  Widget _buildLigneInfo(IconData icon, String label, String valeur) {
    return Row(
      children: [
        Icon(icon, color: kOrange, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(valeur,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              // TODO: navigation vers un écran de modification
            },
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.access_time,
            label: "Horaires d'ouverture",
            onTap: () {
              // TODO: navigation vers un écran horaires
            },
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.logout,
            label: 'Se déconnecter',
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ConnexionPage()),
                (route) => false,
              );
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
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}