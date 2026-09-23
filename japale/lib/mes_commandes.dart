import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/commande.dart';
import '../models/user_session.dart';

class MesCommandes extends StatefulWidget {
  const MesCommandes({super.key});

  @override
  State<MesCommandes> createState() => _MesCommandesState();
}

class _MesCommandesState extends State<MesCommandes> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _marquerLivree(String commandeId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection('commandes').doc(commandeId);
        final doc = await transaction.get(docRef);

        if (!doc.exists) return;

        final data = doc.data() as Map<String, dynamic>;
        final montant = data['montant'] ?? 0;

        transaction.update(docRef, {
          'statut': 'livree',
          'livreeA': DateTime.now().toIso8601String(),
        });

        final userId = _auth.currentUser?.uid;
        if (userId != null) {
          final livreurRef = _firestore.collection('livreurs').doc(userId);
          final livreurDoc = await transaction.get(livreurRef);
          if (livreurDoc.exists) {
            final livreurData = livreurDoc.data() as Map<String, dynamic>;
            final nbLivraisons = (livreurData['nbLivraisons'] ?? 0) + 1;
            final gains = (livreurData['gains'] ?? 0) + montant;
            transaction.update(livreurRef, {
              'nbLivraisons': nbLivraisons,
              'gains': gains,
            });

            UserSession.nbLivraisons = nbLivraisons;
            UserSession.gains = gains;
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Course terminée avec succès !'),
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
    final userId = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F9),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildMetrics(),
              const SizedBox(height: 16),
              const Text(
                'COMMANDES ACCEPTÉES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1C1C),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('commandes')
                      .where('livreurId', isEqualTo: userId)
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
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Color(0xFF574235),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucune commande acceptée',
                                style: TextStyle(
                                  fontSize: 16,
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
                        return _CommandeAccepteeCard(
                          commande: commande,
                          onLivrer: commande.statut == 'en_cours'
                              ? () => _marquerLivree(commande.id)
                              : null,
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

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(88),
      child: Container(
        padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Japalé',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF6B35),
                    height: 1.0,
                  ),
                ),
                Text(
                  'Mes Commandes',
                  style: TextStyle(
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
          .where('livreurId', isEqualTo: _auth.currentUser?.uid)
          .where('statut', isEqualTo: 'en_cours')
          .snapshots(),
      builder: (context, enCoursSnapshot) {
        final enCoursCount = enCoursSnapshot.data?.docs.length ?? 0;

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('commandes')
              .where('livreurId', isEqualTo: _auth.currentUser?.uid)
              .where('statut', isEqualTo: 'livree')
              .snapshots(),
          builder: (context, livreesSnapshot) {
            final livreeCount = livreesSnapshot.data?.docs.length ?? 0;

            return Row(
              children: [
                const Text(
                  'Mes livraisons',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF6B35),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEADDCC),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bolt,
                        color: Color(0xFFFF6B35),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'En service',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF201B10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMetrics() {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('commandes')
                .where('livreurId', isEqualTo: _auth.currentUser?.uid)
                .where('statut', isEqualTo: 'en_cours')
                .snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return _MetricCard(
                icon: Icons.two_wheeler,
                label: 'Active',
                value: '$count course${count > 1 ? 's' : ''}',
                color: const Color(0xFFFF6B35),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('commandes')
                .where('livreurId', isEqualTo: _auth.currentUser?.uid)
                .where('statut', isEqualTo: 'livree')
                .snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return _MetricCard(
                icon: Icons.check_circle,
                label: 'Complétées',
                value: '$count faite${count > 1 ? 's' : ''}',
                color: const Color(0xFF1B6D24),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF574235),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommandeAccepteeCard extends StatelessWidget {
  final Commande commande;
  final VoidCallback? onLivrer;

  const _CommandeAccepteeCard({
    required this.commande,
    this.onLivrer,
  });

  @override
  Widget build(BuildContext context) {
    final bool estEnCours = commande.statut == 'en_cours';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: estEnCours
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                ),
              ],
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
                  color: estEnCours
                      ? const Color(0xFFFF6B35).withOpacity(0.1)
                      : const Color(0xFFEFEDED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  estEnCours ? Icons.restaurant : Icons.lunch_dining,
                  color: estEnCours ? const Color(0xFFFF6B35) : const Color(0xFF574235),
                  size: 22,
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
                        const Icon(Icons.person, size: 14, color: Color(0xFF574235)),
                        const SizedBox(width: 4),
                        Text(
                          'Client : ${commande.client}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF574235),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _StatutBadge(statut: commande.statut),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFFF6B35),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Campus • ${commande.lieu}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (commande.heure != null) ...[
                  const Text(
                    'Prévu : ',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF574235),
                    ),
                  ),
                  Text(
                    commande.heure!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (estEnCours && onLivrer != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEADDCC),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Color(0xFF201B10),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onLivrer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B6D24),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Marquer livrée',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (!estEnCours) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.pin_drop,
                  size: 16,
                  color: Color(0xFF574235),
                ),
                const SizedBox(width: 4),
                Text(
                  commande.lieu,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1B1C1C),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Gain : ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF574235),
                  ),
                ),
                Text(
                  '${commande.montant} FCFA',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B6D24),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatutBadge extends StatelessWidget {
  final String statut;

  const _StatutBadge({required this.statut});

  @override
  Widget build(BuildContext context) {
    if (statut == 'en_cours') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B35),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_top, color: Colors.white, size: 13),
            SizedBox(width: 4),
            Text(
              'En cours',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF5FAF5D).withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF1B6D24), size: 14),
            SizedBox(width: 4),
            Text(
              'Livrée',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B6D24),
              ),
            ),
          ],
        ),
      );
    }
  }
}