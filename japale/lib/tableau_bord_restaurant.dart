import 'package:flutter/material.dart';
import 'gestion_menu.dart';
import 'restaurant_bottom_nav.dart';

const Color kOrange = Color(0xFFFF6B35);
const Color kOrangeDark = Color(0xFFD8481F);

/// Modèle simplifié pour une commande en attente affichée sur le dashboard.
class CommandeEnAttente {
  const CommandeEnAttente({
    required this.numero,
    required this.client,
    required this.montantFcfa,
    required this.minutesEcoulees,
    required this.details,
  });

  final String numero;
  final String client;
  final int montantFcfa;
  final int minutesEcoulees;
  final String details;
}

/// Page "Tableau de Bord" restaurant. Fait partie du profil Restaurant :
/// possède la RestaurantBottomNav (onglet "Tableau de Bord" actif, index 0).
class TableauBordRestaurant extends StatelessWidget {
  const TableauBordRestaurant({super.key});

  // TODO: remplacer par les vraies données venant du backend/Firebase.
  static const String nomRestaurant = 'Maman Awa';
  static const int chiffreAffairesDuJour = 84500;
  static const int commandesEnCours = 12;
  static const int livraisonsEffectuees = 48;
  static const double noteMoyenne = 4.8;
  static const int nombreAvis = 124;

  static const List<CommandeEnAttente> _commandes = [
    CommandeEnAttente(
      numero: '#1043',
      client: 'Diagne FALL',
      montantFcfa: 1800,
      minutesEcoulees: 5,
      details: '2x Thieboudienne (Riz au poisson)',
    ),
    CommandeEnAttente(
      numero: '#1044',
      client: 'Amy SOW',
      montantFcfa: 3500,
      minutesEcoulees: 12,
      details: '1x Yassa Poulet, 2x Bissap Rouge',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildEnTete(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 12),
                  _buildCarteNote(),
                  const SizedBox(height: 20),
                  _buildEnTeteCommandes(context),
                  const SizedBox(height: 12),
                  ..._commandes.map(_buildCarteCommande),
                  const SizedBox(height: 20),
                  _buildBoutonPublierMenu(context),
                  const SizedBox(height: 20),
                  _buildBanniereEncouragement(),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const RestaurantBottomNav(currentIndex: 0),
    );
  }

  Widget _buildEnTete() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kOrange, kOrangeDark],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('restaurant',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85), fontSize: 13)),
                  const Text(
                    nomRestaurant,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Ouvert',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'CHIFFRE D\'AFFAIRES DU JOUR',
            style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$chiffreAffairesDuJour',
                style: const TextStyle(
                    color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              const Text('FCFA', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildCarteStat(
            icon: Icons.pending_actions,
            iconColor: Colors.orange,
            valeur: '$commandesEnCours',
            label: 'En cours',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCarteStat(
            icon: Icons.check_circle,
            iconColor: Colors.green,
            valeur: '$livraisonsEffectuees',
            label: 'Livraisons',
          ),
        ),
      ],
    );
  }

  Widget _buildCarteStat({
    required IconData icon,
    required Color iconColor,
    required String valeur,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(valeur,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCarteNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Note moyenne\nBasé sur $nombreAvis avis',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          ),
          Text(
            '$noteMoyenne',
            style: const TextStyle(
                color: kOrange, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEnTeteCommandes(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Commandes en attente',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () {
            // TODO: navigation vers la liste complète des commandes
          },
          child: const Text('Voir tout',
              style: TextStyle(color: kOrange, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildCarteCommande(CommandeEnAttente commande) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: kOrange, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${commande.numero} • ${commande.client}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${commande.montantFcfa} F',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: kOrange)),
            ],
          ),
          const SizedBox(height: 2),
          Text('Il y a ${commande.minutesEcoulees} min',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text(commande.details, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: passer la commande en préparation
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A1F1F),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Préparer', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onPressed: () {
                    // TODO: menu d'actions supplémentaires
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoutonPublierMenu(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GestionMenu()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF2A93B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text(
          'Publier un nouveau menu',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBanniereEncouragement() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Gardez le rythme $nomRestaurant, vos clients attendent avec impatience !',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}