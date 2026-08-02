import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'acceuil_client.dart';
import 'liste_restaurants.dart';
import 'suivi_commande.dart';
import 'profil_etudiant.dart';
import 'widgets/japale_bottom_nav.dart';
import 'models/user_session.dart';

const Color kOrange = Color(0xFFFF6B35);
const Color kOrangeLight = Color(0xFFFDF3EE);

class AlertePage extends StatefulWidget {
  const AlertePage({super.key});

  @override
  State<AlertePage> createState() => _AlertePageState();
}

class _AlertePageState extends State<AlertePage> {
  int _currentNavIndex = 3;
  String _filtreActif = 'Toutes';

  final List<Map<String, dynamic>> _demoAlertes = [
    {
      'id': '1',
      'titre': 'Livreur en chemin ! 🚲',
      'message': 'Votre livreur Samba est en route vers le Village A avec votre repas.',
      'type': 'commande',
      'temps': 'Il y a 5 min',
      'estLu': false,
      'icon': Icons.directions_bike,
      'color': kOrange,
    },
    {
      'titre': 'Nouveau plat du jour disponible 🍲',
      'message': 'Le restaurant Maman Awa vient de publier son Thiébou Dieune Penda Mbaye !',
      'type': 'offre',
      'temps': 'Il y a 25 min',
      'estLu': false,
      'icon': Icons.restaurant_menu,
      'color': Colors.green,
    },
    {
      'titre': 'Commande #1042 confirmée ✅',
      'message': 'Le restaurant Le QG a validé votre commande et prépare le paquet.',
      'type': 'commande',
      'temps': 'Il y a 1 heure',
      'estLu': true,
      'icon': Icons.check_circle_outline,
      'color': Colors.blue,
    },
    {
      'titre': 'Promo Spéciale Campus 🎁',
      'message': 'Livraison gratuite sur tout le campus Sanar jusqu’à 15h aujourd’hui !',
      'type': 'offre',
      'temps': 'Hier à 18:30',
      'estLu': true,
      'icon': Icons.card_giftcard,
      'color': Colors.purple,
    },
    {
      'titre': 'Information Japale ℹ️',
      'message': 'De nouveaux restaurants du Village F ont rejoint la plateforme Japale.',
      'type': 'info',
      'temps': 'Hier à 10:15',
      'estLu': true,
      'icon': Icons.info_outline,
      'color': Colors.teal,
    },
  ];

  void _toutMarquerCommeLu() {
    setState(() {
      for (var a in _demoAlertes) {
        a['estLu'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Toutes les notifications sont marquées comme lues'),
        backgroundColor: kOrange,
      ),
    );
  }

  List<Map<String, dynamic>> get _alertesFiltrees {
    if (_filtreActif == 'Toutes') return _demoAlertes;
    if (_filtreActif == 'Commandes') {
      return _demoAlertes.where((a) => a['type'] == 'commande').toList();
    }
    if (_filtreActif == 'Promos') {
      return _demoAlertes.where((a) => a['type'] == 'offre').toList();
    }
    return _demoAlertes.where((a) => a['type'] == 'info').toList();
  }

  int get _nonLuesCount {
    return _demoAlertes.where((a) => a['estLu'] == false).length;
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
        automaticallyImplyLeading: false,
        title: const Text(
          'Alertes & Notifications',
          style: TextStyle(
            color: Color(0xFFB5401A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_nonLuesCount > 0)
            TextButton.icon(
              onPressed: _toutMarquerCommeLu,
              icon: const Icon(Icons.done_all, size: 18, color: kOrange),
              label: const Text(
                'Tout lire',
                style: TextStyle(color: kOrange, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildFiltresChips(),
            const SizedBox(height: 20),
            currentUid.isNotEmpty
                ? _buildStreamOuDemoAlertes(currentUid)
                : _buildListAlertesView(_alertesFiltrees),
            const SizedBox(height: 90),
          ],
        ),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SuiviCommandePage()),
              );
              break;
            case 3:
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

  Widget _buildFiltresChips() {
    final filtres = ['Toutes', 'Commandes', 'Promos', 'Infos'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filtres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = filtres[index];
          final bool active = f == _filtreActif;
          return GestureDetector(
            onTap: () => setState(() => _filtreActif = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? kOrange : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                f,
                style: TextStyle(
                  color: active ? Colors.white : Colors.black87,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreamOuDemoAlertes(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final docs = snapshot.data!.docs;
          final listFirestore = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String type = (data['type'] ?? 'info').toString();
            final Timestamp? ts = data['createdAt'] as Timestamp?;
            return {
              'id': doc.id,
              'titre': data['titre'] ?? 'Notification Japale',
              'message': data['message'] ?? '',
              'type': type,
              'temps': _formaterDateTemps(ts),
              'estLu': data['estLu'] ?? false,
              'icon': _getIconPourType(type),
              'color': _getColorPourType(type),
            };
          }).toList();

          // Tri local si nécessaire
          listFirestore.sort((a, b) => (b['estLu'] == false ? 1 : 0).compareTo(a['estLu'] == false ? 1 : 0));

          return _buildListAlertesView(listFirestore);
        }
        return _buildListAlertesView(_alertesFiltrees);
      },
    );
  }

  String _formaterDateTemps(Timestamp? timestamp) {
    if (timestamp == null) return 'Récemment';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getIconPourType(String type) {
    switch (type.toLowerCase()) {
      case 'commande':
        return Icons.directions_bike;
      case 'offre':
      case 'menu':
        return Icons.restaurant_menu;
      case 'info':
      default:
        return Icons.info_outline;
    }
  }

  Color _getColorPourType(String type) {
    switch (type.toLowerCase()) {
      case 'commande':
        return kOrange;
      case 'offre':
      case 'menu':
        return Colors.green;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  Future<void> _marquerNotificationLu(Map<String, dynamic> item) async {
    final String id = item['id'] ?? '';
    setState(() {
      item['estLu'] = true;
    });

    if (id.isNotEmpty && FirebaseAuth.instance.currentUser != null) {
      try {
        await FirebaseFirestore.instance.collection('notifications').doc(id).update({
          'estLu': true,
        });
      } catch (e) {
        debugPrint("Erreur mise à jour notification: $e");
      }
    }

    final String type = (item['type'] ?? '').toString().toLowerCase();
    if (!mounted) return;
    if (type == 'commande') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SuiviCommandePage()),
      );
    } else if (type == 'offre' || type == 'menu') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ListeRestaurantsPage()),
      );
    }
  }

  Widget _buildListAlertesView(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 14),
              const Text(
                'Aucune alerte dans cette catégorie',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = list[index];
        final bool estLu = item['estLu'] ?? true;

        return GestureDetector(
          onTap: () => _marquerNotificationLu(item),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: estLu ? Colors.white : const Color(0xFFFFF7F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: estLu ? Colors.grey.shade200 : kOrange.withOpacity(0.3),
                width: estLu ? 1 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['titre'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: estLu ? FontWeight.bold : FontWeight.w800,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (!estLu)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: const BoxDecoration(
                                color: kOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['message'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withOpacity(0.7),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['temps'],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
