import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gestion_menu.dart';
import 'restaurant_bottom_nav.dart';

const Color kOrange = Color(0xFFFF6B35);
const Color kOrangeDark = Color(0xFFD8481F);

/// Commande en attente, construite à partir du même schéma Firestore que
/// commandes_restaurant.dart : clientNom, statut ("En attente", "Acceptée",
/// "En préparation", "Livrée", "Refusée"), total, plats (liste), createdAt.
class CommandeEnAttente {
  const CommandeEnAttente({
    required this.id,
    required this.clientNom,
    required this.total,
    required this.detailsPlats,
    required this.dateCreation,
  });

  final String id;
  final String clientNom;
  final int total;
  final String detailsPlats;
  final DateTime dateCreation;

  factory CommandeEnAttente.fromFirestore(String id, Map<String, dynamic> data) {
    final timestamp = data['createdAt'] as Timestamp?;
    final List<dynamic> plats = data['plats'] ?? [];

    final details = plats
        .map((p) => "${p['quantite']}x ${p['nom']}")
        .join(', ');

    return CommandeEnAttente(
      id: id,
      clientNom: data['clientNom'] as String? ?? 'Client',
      total: (data['total'] as num?)?.toInt() ?? 0,
      detailsPlats: details.isEmpty ? 'Commande' : details,
      dateCreation: timestamp?.toDate() ?? DateTime.now(),
    );
  }

  int get minutesEcoulees => DateTime.now().difference(dateCreation).inMinutes;
}

/// Page "Tableau de Bord" restaurant, connectée en temps réel à Firestore.
class TableauBordRestaurant extends StatelessWidget {
  const TableauBordRestaurant({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurantId = FirebaseAuth.instance.currentUser?.uid;

    if (restaurantId == null) {
      return const Scaffold(body: Center(child: Text('Vous devez être connecté')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('restaurants').doc(restaurantId).snapshots(),
          builder: (context, snapshotRestaurant) {
            if (snapshotRestaurant.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: kOrange));
            }

            if (!snapshotRestaurant.hasData || !snapshotRestaurant.data!.exists) {
              return const Center(child: Text('Aucune donnée de restaurant trouvée'));
            }

            final data = snapshotRestaurant.data!.data()!;
            final nomRestaurant = data['nomRestaurant'] as String? ?? 'Restaurant';
            final ouvert = data['ouvert'] as bool? ?? true;
            final chiffreAffairesDuJour = (data['chiffreAffairesDuJour'] as num?)?.toInt() ?? 0;
            final commandesEnCours = (data['commandesEnCours'] as num?)?.toInt() ?? 0;
            final livraisonsEffectuees = (data['livraisonsEffectuees'] as num?)?.toInt() ?? 0;
            final noteMoyenne = (data['noteMoyenne'] as num?)?.toDouble() ?? 0.0;
            final nombreAvis = (data['nombreAvis'] as num?)?.toInt() ?? 0;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildEnTete(nomRestaurant: nomRestaurant, ouvert: ouvert, chiffreAffairesDuJour: chiffreAffairesDuJour),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsRow(commandesEnCours, livraisonsEffectuees),
                      const SizedBox(height: 12),
                      _buildCarteNote(noteMoyenne, nombreAvis),
                      const SizedBox(height: 20),
                      _buildEnTeteCommandes(context),
                      const SizedBox(height: 12),
                      _buildListeCommandes(restaurantId),
                      const SizedBox(height: 20),
                      _buildBoutonPublierMenu(context),
                      const SizedBox(height: 20),
                      _buildBanniereEncouragement(nomRestaurant),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const RestaurantBottomNav(currentIndex: 0),
    );
  }

  Widget _buildEnTete({required String nomRestaurant, required bool ouvert, required int chiffreAffairesDuJour}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kOrange, kOrangeDark]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
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
                  Text('restaurant', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                  Text(nomRestaurant, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(ouvert ? 'Ouvert' : 'Fermé', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('CHIFFRE D\'AFFAIRES DU JOUR',
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$chiffreAffairesDuJour', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              const Text('FCFA', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int commandesEnCours, int livraisonsEffectuees) {
    return Row(
      children: [
        Expanded(child: _buildCarteStat(icon: Icons.pending_actions, iconColor: Colors.orange, valeur: '$commandesEnCours', label: 'En cours')),
        const SizedBox(width: 12),
        Expanded(child: _buildCarteStat(icon: Icons.check_circle, iconColor: Colors.green, valeur: '$livraisonsEffectuees', label: 'Livraisons')),
      ],
    );
  }

  Widget _buildCarteStat({required IconData icon, required Color iconColor, required String valeur, required String label}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(valeur, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCarteNote(double noteMoyenne, int nombreAvis) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
      ]),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text('Note moyenne\nBasé sur $nombreAvis avis', style: TextStyle(color: Colors.grey.shade700, fontSize: 12))),
          Text(noteMoyenne.toStringAsFixed(1), style: const TextStyle(color: kOrange, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEnTeteCommandes(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Commandes en attente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () {
            // TODO: navigation vers commandes_restaurant.dart (liste complète)
          },
          child: const Text('Voir tout', style: TextStyle(color: kOrange, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildListeCommandes(String restaurantId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      // ⚠️ statut "En attente" (avec majuscule et accent) pour matcher
      // exactement les valeurs utilisées dans commandes_restaurant.dart.
      stream: FirebaseFirestore.instance
          .collection('commandes')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('statut', isEqualTo: 'En attente')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(color: kOrange)),
          );
        }

        if (snapshot.hasError) {
          return Text('Erreur : ${snapshot.error}');
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Text('Aucune commande en attente pour le moment.', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
          );
        }

        final commandes = docs.map((doc) => CommandeEnAttente.fromFirestore(doc.id, doc.data())).toList();

        return Column(children: commandes.map(_buildCarteCommande).toList());
      },
    );
  }

  Widget _buildCarteCommande(CommandeEnAttente commande) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: kOrange, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(commande.clientNom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${commande.total} F', style: const TextStyle(fontWeight: FontWeight.bold, color: kOrange)),
            ],
          ),
          const SizedBox(height: 2),
          Text('Il y a ${commande.minutesEcoulees} min', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text(commande.detailsPlats, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  // Cohérent avec commandes_restaurant.dart : "En attente" ->
                  // "Acceptée" est la première étape du flux.
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('commandes').doc(commande.id).update({'statut': 'Acceptée'});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A1F1F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Accepter', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => const GestionMenu()));
        },
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF2A93B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text('Publier un nouveau menu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBanniereEncouragement(String nomRestaurant) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12))),
          const SizedBox(height: 12),
          Text('Gardez le rythme $nomRestaurant, vos clients attendent avec impatience !', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ),
    );
  }
}