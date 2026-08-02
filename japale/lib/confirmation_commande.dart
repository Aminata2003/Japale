import 'package:flutter/material.dart';
import 'acceuil_client.dart';
import 'suivi_commande.dart';
import 'panier_page.dart';

const Color kOrangePrimary = Color(0xFFFF6432);
const Color kOrangeAccent = Color(0xFFFFA500);
const Color kBgColor = Color(0xFFFDF9F6);

class ConfirmationCommandePage extends StatelessWidget {
  final String commandeId;
  final String restaurantName;
  final int total;
  final List<CartItem> items;
  final String adresse;
  final int fraisLivraison;

  const ConfirmationCommandePage({
    super.key,
    required this.commandeId,
    required this.restaurantName,
    required this.total,
    required this.items,
    required this.adresse,
    required this.fraisLivraison,
  });

  @override
  Widget build(BuildContext context) {
    // ID court type #1042
    final String numeroCommande = commandeId.length > 5
        ? '#${commandeId.substring(commandeId.length - 4).toUpperCase()}'
        : '#1042';

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // 1. Cercle d'animation Succès (Jaune & Orange)
              _buildSuccessBadge(),

              const SizedBox(height: 24),

              // 2. Titre & Sous-titre
              const Text(
                'Commande envoyée ! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nous recherchons un livreur disponible\npour vous...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.6),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // 3. Carte Résumé de la Commande
              _buildCardSummary(numeroCommande),

              const SizedBox(height: 28),

              // 4. Stepper 3 Étapes (Conforme à la maquette)
              _buildStepperMaquette(),

              const SizedBox(height: 28),

              // 5. Aperçu visuel des plats commandés
              _buildPlatsThumbnails(),

              const Spacer(flex: 2),

              // 6. Bouton d'action principal
              _buildRetourAccueilButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBadge() {
    return Container(
      width: 130,
      height: 130,
      decoration: const BoxDecoration(
        color: kOrangeAccent,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: const BoxDecoration(
          color: kOrangePrimary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildCardSummary(String numeroCommande) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF3EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOrangePrimary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commande $numeroCommande',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBDC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'En cours',
                  style: TextStyle(
                    color: kOrangePrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.black.withOpacity(0.08), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Restaurant',
                style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 14),
              ),
              Text(
                restaurantName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 14),
              ),
              Text(
                '$total FCFA',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: kOrangePrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperMaquette() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Étape 1 : Commande reçue (Active)
            _buildStepperCircle(
              icon: Icons.restaurant,
              isActive: true,
            ),
            _buildStepperLine(isActive: true),

            // Étape 2 : Livreur en route
            _buildStepperCircle(
              icon: Icons.two_wheeler,
              isActive: false,
            ),
            _buildStepperLine(isActive: false),

            // Étape 3 : Livraison
            _buildStepperCircle(
              icon: Icons.location_on,
              isActive: false,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Commande reçue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: kOrangePrimary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Livreur en route',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Livraison',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepperCircle({required IconData icon, required bool isActive}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isActive ? kOrangePrimary : const Color(0xFFEBE6E1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 22,
        color: isActive ? Colors.white : Colors.black45,
      ),
    );
  }

  Widget _buildStepperLine({required bool isActive}) {
    return Container(
      width: 50,
      height: 3,
      color: isActive ? kOrangePrimary : const Color(0xFFEBE6E1),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildPlatsThumbnails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF9EFE6).withOpacity(0.7),
            const Color(0xFFF6E8DC).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items.take(3).map((item) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                _getPlatImageSample(item.name),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: kOrangePrimary.withOpacity(0.1),
                  child: const Icon(Icons.fastfood, color: kOrangePrimary),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getPlatImageSample(String nom) {
    final n = nom.toLowerCase();
    if (n.contains('thiebou') || n.contains('riz') || n.contains('poisson')) {
      return 'assets/images/petite_cote.jpg';
    }
    if (n.contains('poulet') || n.contains('yassa') || n.contains('burger')) {
      return 'assets/images/maman_awa.jpg';
    }
    if (n.contains('dibi') || n.contains('viande') || n.contains('agneau')) {
      return 'assets/images/qg.jpg';
    }
    return 'assets/images/jardin.jpg';
  }

  Widget _buildRetourAccueilButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          // Aller vers la page de suivi ou l'accueil
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SuiviCommandePage()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        label: const Text(
          'Retour à l\'accueil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kOrangePrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
