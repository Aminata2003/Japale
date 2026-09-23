import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'acceuil_client.dart';
import 'liste_restaurants.dart';
import 'alerte_page.dart';
import 'profil_etudiant.dart';
import 'widgets/japale_bottom_nav.dart';
import 'models/user_session.dart';

const Color kOrange = Color(0xFFFF6B35);
const Color kOrangeLight = Color(0xFFFDF3EE);

class SuiviCommandePage extends StatefulWidget {
  const SuiviCommandePage({super.key});

  @override
  State<SuiviCommandePage> createState() => _SuiviCommandePageState();
}

class _SuiviCommandePageState extends State<SuiviCommandePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentNavIndex = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formaterDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Récemment';
    final dt = timestamp.toDate();
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year à $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String currentUid = user?.uid ?? UserSession.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6F0),
        elevation: 0,
        title: const Text(
          'Mes Commandes',
          style: TextStyle(
            color: Color(0xFFB5401A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kOrange,
          labelColor: kOrange,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'En cours'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: currentUid.isEmpty
          ? _buildNonConnecte()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStreamCommandes(currentUid, estEnCours: true),
                _buildStreamCommandes(currentUid, estEnCours: false),
              ],
            ),
      bottomNavigationBar: JapaleBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == _currentNavIndex) return;
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AccueilClient()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ListeRestaurantsPage()),
              );
              break;
            case 2:
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AlertePage()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfilEtudiant()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildNonConnecte() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Veuillez vous connecter pour voir vos commandes',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: kOrange),
            child: const Text('Retour à l\'accueil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamCommandes(String uid, {required bool estEnCours}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('commandes')
          .where('clientId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur de chargement: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kOrange),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        // Filtrer les commandes selon le statut
        final commandesFiltrees = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final statut = (data['statut'] ?? '').toString().toLowerCase();
          final estLivre = statut.contains('livré') || statut.contains('livre') || statut.contains('terminé') || statut.contains('annulé');
          return estEnCours ? !estLivre : estLivre;
        }).toList();

        // Tri local par date décroissante
        commandesFiltrees.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          final dateA = (dataA['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          final dateB = (dataB['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          return dateB.compareTo(dateA);
        });

        if (commandesFiltrees.isEmpty) {
          return _buildVideScreen(estEnCours);
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: commandesFiltrees.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final doc = commandesFiltrees[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildCommandeCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildVideScreen(bool estEnCours) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              estEnCours ? Icons.delivery_dining : Icons.history,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              estEnCours
                  ? 'Aucune commande en cours'
                  : 'Aucune commande dans l\'historique',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              estEnCours
                  ? 'Vos commandes actives apparaîtront ici avec leur suivi en temps réel.'
                  : 'Retrouvez l\'historique de toutes vos commandes livrées.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ListeRestaurantsPage()),
                );
              },
              icon: const Icon(Icons.restaurant_menu, color: Colors.white),
              label: const Text(
                'Commander à manger',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandeCard(String id, Map<String, dynamic> data) {
    final String restaurantName = data['restaurantName'] ?? data['restaurantId'] ?? 'Restaurant Japale';
    final int total = (data['total'] ?? 0) as int;
    final int fraisLivraison = (data['fraisLivraison'] ?? 200) as int;
    final String statut = (data['statut'] ?? 'En attente').toString();
    final String adresse = (data['adresseLivraison'] ?? 'Campus UGB').toString();
    final String paiement = (data['paiement'] ?? 'Wave').toString();
    final List plats = (data['plats'] as List?) ?? [];

    final Timestamp? timestamp = data['createdAt'] as Timestamp?;
    final String formattedDate = _formaterDate(timestamp);

    return Container(
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la carte
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: kOrangeLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront, color: kOrange, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatutBadge(statut),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 14),

          // Liste des plats
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: plats.map((item) {
              final String nomPlat = item['nom'] ?? item['name'] ?? 'Plat';
              final int qte = item['quantite'] ?? item['quantity'] ?? 1;
              final int prix = item['prix'] ?? item['unitPrice'] ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${qte}x $nomPlat',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${prix * qte} FCFA',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),
          // Indicateur de statut / Suivi Stepper si en cours
          _buildStepperProgression(statut),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),

          // Récapitulatif tarif & détails
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            adresse,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.payment, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Payé via $paiement (Livraison $fraisLivraison FCFA)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$total FCFA',
                style: const TextStyle(
                  color: kOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatutBadge(String statut) {
    Color bg;
    Color fg;
    String label = statut;

    final s = statut.toLowerCase();
    if (s.contains('livré') || s.contains('livre')) {
      bg = Colors.green.shade100;
      fg = Colors.green.shade800;
      label = 'LIVRÉ ✓';
    } else if (s.contains('préparation') || s.contains('preparation')) {
      bg = Colors.orange.shade100;
      fg = Colors.orange.shade900;
      label = 'En préparation 🍳';
    } else if (s.contains('livraison') || s.contains('cours')) {
      bg = Colors.blue.shade100;
      fg = Colors.blue.shade900;
      label = 'En livraison 🚲';
    } else {
      bg = Colors.amber.shade100;
      fg = Colors.amber.shade900;
      label = 'En attente ⏳';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildStepperProgression(String statut) {
    final s = statut.toLowerCase();
    int etapeActuelle = 1;
    if (s.contains('livraison') || s.contains('cours') || s.contains('préparation') || s.contains('preparation')) {
      etapeActuelle = 2;
    } else if (s.contains('livré') || s.contains('livre') || s.contains('terminé')) {
      etapeActuelle = 3;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildEtapeItem(1, 'Reçue', Icons.receipt_long, etapeActuelle >= 1),
          _buildLigneProgress(etapeActuelle >= 2),
          _buildEtapeItem(2, 'En livraison', Icons.directions_bike, etapeActuelle >= 2),
          _buildLigneProgress(etapeActuelle >= 3),
          _buildEtapeItem(3, 'Livrée', Icons.check_circle, etapeActuelle >= 3),
        ],
      ),
    );
  }

  Widget _buildEtapeItem(int etape, String label, IconData icon, bool active) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: active ? kOrange : Colors.grey.shade400,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? kOrange : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildLigneProgress(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? kOrange : Colors.grey.shade300,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}
