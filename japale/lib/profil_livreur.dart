import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_session.dart';

class ProfilLivreur extends StatefulWidget {
  const ProfilLivreur({super.key});

  @override
  State<ProfilLivreur> createState() => _ProfilLivreurState();
}

class _ProfilLivreurState extends State<ProfilLivreur> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deconnexion() async {
    await _auth.signOut();
    UserSession.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F9),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: FutureBuilder<DocumentSnapshot?>(
              future: user != null
                  ? _firestore.collection('livreurs').doc(user.uid).get()
                  : Future.value(null),
              builder: (context, snapshot) {
                final data = snapshot.data?.data() as Map<String, dynamic>?;

                return Column(
                  children: [
                    _buildProfileHeader(user, data),
                    const SizedBox(height: 16),
                    _buildStats(user),
                    const SizedBox(height: 16),
                    _buildActions(),
                  ],
                );
              },
            ),
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
                  'Profil',
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

  Widget _buildProfileHeader(User? user, Map<String, dynamic>? data) {
    final nom = data?['nom'] ?? user?.displayName ?? 'Livreur';
    final email = user?.email ?? '';
    final telephone = data?['telephone'] ?? 'Non renseigné';
    final estCertifie = data?['certifie'] ?? false;
    final note = (data?['note'] ?? 0.0).toDouble();
    final nbLivraisons = data?['nbLivraisons'] ?? 0;

    return Container(
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
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFFB786)],
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            nom,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF574235),
            ),
          ),
          const SizedBox(height: 8),
          if (estCertifie)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDCC6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.military_tech,
                    color: Color(0xFFFF6B35),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Certifié Campus',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (index) {
                if (index < note.floor()) {
                  return const Icon(
                    Icons.star,
                    color: Color(0xFFFF6B35),
                    size: 18,
                  );
                } else if (index < note.ceil() && note % 1 > 0) {
                  return const Icon(
                    Icons.star_half,
                    color: Color(0xFFFF6B35),
                    size: 18,
                  );
                } else {
                  return const Icon(
                    Icons.star_border,
                    color: Color(0xFFFF6B35),
                    size: 18,
                  );
                }
              }),
              const SizedBox(width: 4),
              Text(
                '${note.toStringAsFixed(1)} ($nbLivraisons avis)',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF574235),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.smartphone, color: Color(0xFFFF6B35), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Téléphone',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF574235),
                            ),
                          ),
                          Text(
                            telephone,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.call, color: Color(0xFF574235), size: 18),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  children: [
                    const Icon(Icons.schedule, color: Color(0xFF574235), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Disponibilité',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF574235),
                            ),
                          ),
                          Row(
                            children: [
                              _DisponibiliteBadge(label: 'Matin'),
                              const SizedBox(width: 8),
                              _DisponibiliteBadge(label: 'Soir'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(User? user) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('commandes')
          .where('livreurId', isEqualTo: user?.uid)
          .where('statut', isEqualTo: 'livree')
          .snapshots(),
      builder: (context, snapshot) {
        final livraisons = snapshot.data?.docs.length ?? 0;

        return Row(
          children: [
            Expanded(
              child: Container(
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
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEADDCC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        color: Color(0xFF655D4F),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$livraisons',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'Livraisons réussies',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF574235),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
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
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDCC6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFFFF6B35),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      UserSession.gains?.toString() ?? '0',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                    const Text(
                      'FCFA cumulés',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF574235),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/historique-gains');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payments, size: 20),
                SizedBox(width: 8),
                Text(
                  'RETIRER MES GAINS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: _deconnexion,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B35),
              side: const BorderSide(color: Color(0xFFFF6B35)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, size: 20),
                SizedBox(width: 8),
                Text(
                  'Déconnexion',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DisponibiliteBadge extends StatelessWidget {
  final String label;

  const _DisponibiliteBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEADDCC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF1B6D24),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4D4638),
            ),
          ),
        ],
      ),
    );
  }
}