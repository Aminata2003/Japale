import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/commande.dart';
import '../models/user_session.dart';
import '../widgets/japale_bottom_nav.dart';
import 'mes_commandes.dart';
import 'profil_livreur.dart';
import 'historique_gains.dart';

class AccueilLivreur extends StatefulWidget {
  const AccueilLivreur({super.key});

  @override
  State<AccueilLivreur> createState() => _AccueilLivreurState();
}

class _AccueilLivreurState extends State<AccueilLivreur> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _AccueilContent(),
    MesCommandes(),
    ProfilLivreur(),
    HistoriqueGains(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: JapaleBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        userRole: 'livreur',
      ),
    );
  }
}

class _AccueilContent extends StatefulWidget {
  const _AccueilContent();

  @override
  State<_AccueilContent> createState() => _AccueilContentState();
}

class _AccueilContentState extends State<_AccueilContent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _accepterCommande(String commandeId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection('commandes').doc(commandeId);
        final doc = await transaction.get(docRef);

        if (!doc.exists) return;

        if (doc.data()?['statut'] != 'disponible') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Cette commande a déjà été prise'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }

        transaction.update(docRef, {
          'statut': 'en_cours',
          'livreurId': _auth.currentUser?.uid,
          'livreurNom': UserSession.nomComplet,
          'accepteeA': DateTime.now().toIso8601String(),
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Commande acceptée avec succès !'),
            backgroundColor: Color(0xFF1B6D24),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F9),
      appBar: _buildAppBar('Accueil'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('commandes')
                      .where('statut', isEqualTo: 'disponible')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Erreur: ${snapshot.error}'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF6B35),
                        ),
                      );
                    }

                    final commandes = snapshot.data?.docs ?? [];

                    if (commandes.isEmpty) {
                      return const Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Color(0xFF574235),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '📭 Aucune commande disponible',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF574235),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Revenez plus tard !',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF574235),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: commandes.length,
                      itemBuilder: (context, index) {
                        final data = commandes[index].data() as Map<String, dynamic>;
                        final commande = Commande.fromFirestore(
                          data,
                          commandes[index].id,
                        );
                        return _CommandeDisponibleCard(
                          commande: commande,
                          onAccepter: () => _accepterCommande(commande.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String title) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(88),
      child: Container(
        padding: const EdgeInsets.only(top: 36, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida/AEtjO1WUS5rfJeMEH_45SGwuBz_0Pqjflbut7bbeOz8MuEFGKB2nSVQM7jg35mFXsYbPNt2IbZIhmIaHwK2eSeFa91k6BIdncBDC6FrzJkgAjrNNN8w8svT56iUojNfTgIm1Vh6-zG3Scd4icAf8sFboxbaWyMgfaiCfdsGPy_EXD4lPT_DDBT-Il-0r8I3pZbl6lqhDTd1pHGrb9nC1_8Xk4VscfUtlewCpxCjw8NXUuHMM_7v7zJg9i1bnxw',
              height: 32,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(height: 32, width: 32),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Japalé',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF6B35),
                    height: 1.0,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF574235),
                    height: 1.1,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B35),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('commandes')
          .where('statut', isEqualTo: 'disponible')
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Row(
          children: [
            const Text(
              'Commandes disponibles',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFF6B35),
              ),
            ),
            const Spacer(),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFFDCC6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                count > 0 ? Icons.notifications_active : Icons.notifications_off,
                color: count > 0 ? const Color(0xFFFF6B35) : const Color(0xFF574235),
                size: 22,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CommandeDisponibleCard extends StatelessWidget {
  final Commande commande;
  final VoidCallback onAccepter;

  const _CommandeDisponibleCard({
    required this.commande,
    required this.onAccepter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFFF6B35), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEDED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Color(0xFFFF6B35),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commande.restaurant,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Text('🍗 '),
                        Expanded(
                          child: Text(
                            commande.menu,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF574235),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${commande.montant} FCFA',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEDED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Course',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF574235),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.near_me,
                  color: Color(0xFFFF6B35),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    commande.lieu,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(
                  '~5 min',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF574235),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onAccepter,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
                shadowColor: const Color(0xFFFF6B35).withOpacity(0.35),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ACCEPTER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}