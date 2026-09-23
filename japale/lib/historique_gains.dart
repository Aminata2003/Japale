import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models/commande.dart';
import 'models/user_session.dart';

class HistoriqueGains extends StatefulWidget {
  const HistoriqueGains({super.key});

  @override
  State<HistoriqueGains> createState() => _HistoriqueGainsState();
}

class _HistoriqueGainsState extends State<HistoriqueGains> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
              const SizedBox(height: 16),
              _buildTotalGains(userId),
              const SizedBox(height: 16),
              const Text(
                'HISTORIQUE DES COURSES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1C1C),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildHistoriqueList(userId),
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
                  ),
                ),
                Text(
                  'Gains',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF574235),
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
    return Row(
      children: [
        const Text(
          'Historique',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFF6B35),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE1CF).withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month,
                color: Color(0xFFFF6B35),
                size: 16,
              ),
              const SizedBox(width: 4),
              const Text(
                'Mai 2024',
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
  }

  Widget _buildTotalGains(String? userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('commandes')
          .where('livreurId', isEqualTo: userId)
          .where('statut', isEqualTo: 'livree')
          .snapshots(),
      builder: (context, snapshot) {
        int totalGains = 0;
        int nbCourses = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            totalGains += (data['montant'] ?? 0) as int;
            nbCourses++;
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL CUMULÉ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF574235),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '$totalGains',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'FCFA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF6B35),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDCC6).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.moped,
                          color: Color(0xFFFF6B35),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$nbCourses',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF6B35),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'courses',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF574235),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoriqueList(String? userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('commandes')
          .where('livreurId', isEqualTo: userId)
          .where('statut', isEqualTo: 'livree')
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
                    Icons.history,
                    size: 64,
                    color: Color(0xFF574235),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun historique',
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
            final commande = Commande.fromFirestore(data, commandes[index].id);
            return _HistoriqueCard(commande: commande);
          },
        );
      },
    );
  }
}

class _HistoriqueCard extends StatelessWidget {
  final Commande commande;

  const _HistoriqueCard({required this.commande});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
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
            width: 4,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B35),
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEDED),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        commande.restaurant.split(' - ').first,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B1C1C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      commande.menu,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      final note = commande.note ?? 0;
                      if (index < note.floor()) {
                        return const Icon(
                          Icons.star,
                          color: Color(0xFFFF6B35),
                          size: 15,
                        );
                      } else if (index < note.ceil() && note % 1 > 0) {
                        return const Icon(
                          Icons.star_half,
                          color: Color(0xFFFF6B35),
                          size: 15,
                        );
                      } else {
                        return const Icon(
                          Icons.star_border,
                          color: Color(0xFFFF6B35),
                          size: 15,
                        );
                      }
                    }),
                    const SizedBox(width: 4),
                    Text(
                      'Client : ${commande.client} (${commande.lieu})',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${commande.montant}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF6B35),
                ),
              ),
              const Text(
                'FCFA',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF574235),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}