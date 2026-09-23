import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'restaurant_bottom_nav.dart';

const Color kRestaurantOrange = Color(0xFFFF6B35);

class CommandesRestaurant extends StatefulWidget {
  const CommandesRestaurant({super.key});

  @override
  State<CommandesRestaurant> createState() => _CommandesRestaurantState();
}

class _CommandesRestaurantState extends State<CommandesRestaurant> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Identifiant du restaurant connecté (récupéré depuis Firebase Auth,
  /// plus jamais codé en dur).
  String get restaurantId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<QuerySnapshot> _getCommandes() {
    return _firestore
        .collection('commandes')
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _changerStatut(String commandeId, String nouveauStatut) async {
    await _firestore.collection('commandes').doc(commandeId).update({
      'statut': nouveauStatut,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (restaurantId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Vous devez être connecté')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),

      appBar: AppBar(
        backgroundColor: kRestaurantOrange,
        automaticallyImplyLeading: false,
        title: const Text(
          "Commandes",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _getCommandes(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Aucune commande reçue",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final commandes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: commandes.length,
            itemBuilder: (context, index) {
              final commande = commandes[index];
              return _buildCommandeCard(commande);
            },
          );
        },
      ),

      bottomNavigationBar: const RestaurantBottomNav(currentIndex: 2),
    );
  }

  Widget _buildCommandeCard(DocumentSnapshot commande) {
    final data = commande.data() as Map<String, dynamic>;

    final String clientNom = data['clientNom'] ?? 'Client inconnu';
    final String statut = data['statut'] ?? 'En attente';
    final int total = data['total'] ?? 0;
    final String paiement = data['paiement'] ?? 'Non défini';
    final String adresse = data['adresseLivraison'] ?? 'Adresse inconnue';
    final List<dynamic> plats = data['plats'] ?? [];

    Color statutColor;
    switch (statut) {
      case 'Acceptée':
        statutColor = Colors.green;
        break;
      case 'Refusée':
        statutColor = Colors.red;
        break;
      case 'En préparation':
        statutColor = Colors.orange;
        break;
      case 'Livrée':
        statutColor = Colors.blue;
        break;
      default:
        statutColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  clientNom,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statutColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statut,
                  style: TextStyle(
                    color: statutColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Commande",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          ...plats.map((plat) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${plat['nom']} x${plat['quantite']}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    "${plat['prix']} FCFA",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: kRestaurantOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  adresse,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(paiement, style: TextStyle(color: Colors.grey.shade700)),
              Text(
                "$total FCFA",
                style: const TextStyle(
                  color: kRestaurantOrange,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionsCommande(commande.id, statut),
        ],
      ),
    );
  }

  Widget _buildActionsCommande(String commandeId, String statut) {
    if (statut == "Refusée" || statut == "Livrée") {
      return const SizedBox();
    }

    return Row(
      children: [
        if (statut == "En attente")
          Expanded(
            child: ElevatedButton(
              onPressed: () => _changerStatut(commandeId, "Acceptée"),
              style: ElevatedButton.styleFrom(
                backgroundColor: kRestaurantOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Accepter",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        if (statut == "En attente") const SizedBox(width: 10),
        if (statut == "En attente")
          Expanded(
            child: OutlinedButton(
              onPressed: () => _changerStatut(commandeId, "Refusée"),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Refuser",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        if (statut == "Acceptée")
          Expanded(
            child: ElevatedButton(
              onPressed: () => _changerStatut(commandeId, "En préparation"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Préparer",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        if (statut == "En préparation")
          Expanded(
            child: ElevatedButton(
              onPressed: () => _changerStatut(commandeId, "Livrée"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Marquer livrée",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}