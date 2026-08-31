import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/restaurant.dart';
import 'menu_restaurant.dart';
import 'acceuil_client.dart';
import 'suivi_commande.dart';
import 'alerte_page.dart';
import 'profil_etudiant.dart';
import 'widgets/japale_bottom_nav.dart';

const Color kOrange = Color(0xFFFF6B35);

class ListeRestaurantsPage extends StatefulWidget {
  const ListeRestaurantsPage({super.key});

  @override
  State<ListeRestaurantsPage> createState() => _ListeRestaurantsPageState();
}

class _ListeRestaurantsPageState extends State<ListeRestaurantsPage> {
  int _currentNavIndex = 1;
  String _rechercheText = '';
  List<Restaurant> _restaurants = [];
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _chargerRestaurants();
  }

  Future<void> _chargerRestaurants() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        String img = (data['photoUrl'] ?? data['imagePath'] ?? data['imageUrl'] ?? '').toString();
        return Restaurant(
          name: (data['nomRestaurant'] ?? data['name'] ?? 'Restaurant').toString(),
          imagePath: img,
          rating: ((data['noteMoyenne'] ?? data['rating'] ?? 4.7) as num).toDouble(),
          reviewCount: ((data['nombreAvis'] ?? data['reviewCount'] ?? 80) as num).toInt(),
          price: ((data['price'] ?? 400) as num).toInt(),
          deliveryMinutes: ((data['deliveryMinutes'] ?? 20) as num).toInt(),
        );
      }).toList();

      if (list.isEmpty) {
        _restaurants = _demoRestaurants;
      } else {
        _restaurants = list;
      }
    } catch (e) {
      debugPrint("Erreur chargement restaurants : $e");
      _restaurants = _demoRestaurants;
    } finally {
      if (mounted) {
        setState(() => _chargement = false);
      }
    }
  }

  static const List<Restaurant> _demoRestaurants = [
    Restaurant(
      name: 'Maman Awa (Village A)',
      imagePath: 'assets/images/maman_awa.jpg',
      rating: 4.8,
      reviewCount: 124,
      price: 200,
      deliveryMinutes: 20,
    ),
    Restaurant(
      name: 'La Petite Côte',
      imagePath: 'assets/images/petite_cote.jpg',
      rating: 4.6,
      reviewCount: 98,
      price: 200,
      deliveryMinutes: 25,
    ),
    Restaurant(
      name: 'Le QG Sanar',
      imagePath: 'assets/images/qg.jpg',
      rating: 4.7,
      reviewCount: 85,
      price: 200,
      deliveryMinutes: 15,
    ),
    Restaurant(
      name: 'Mame Goor',
      imagePath: 'assets/images/mame_goor.jpg',
      rating: 4.5,
      reviewCount: 60,
      price: 200,
      deliveryMinutes: 30,
    ),
    Restaurant(
      name: 'Jardin Sanar',
      imagePath: 'assets/images/jardin.jpg',
      rating: 4.9,
      reviewCount: 210,
      price: 200,
      deliveryMinutes: 20,
    ),
    Restaurant(
      name: 'Chez Mme Faye',
      imagePath: 'assets/images/mme_faye.jpg',
      rating: 4.4,
      reviewCount: 45,
      price: 200,
      deliveryMinutes: 25,
    ),
  ];

  List<Restaurant> get _restaurantsFiltres {
    if (_rechercheText.trim().isEmpty) return _restaurants;
    return _restaurants
        .where((r) => r.name.toLowerCase().contains(_rechercheText.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6F0),
        elevation: 0,
        title: const Text(
          'Tous les Restaurants',
          style: TextStyle(
            color: Color(0xFFB5401A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextField(
              onChanged: (val) => setState(() => _rechercheText = val),
              decoration: InputDecoration(
                hintText: 'Rechercher un restaurant par nom...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _chargement
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(color: kOrange),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _restaurantsFiltres.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final resto = _restaurantsFiltres[index];
                      return _buildRestaurantTile(resto);
                    },
                  ),
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
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SuiviCommandePage()),
              );
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

  Widget _buildRestaurantTile(Restaurant resto) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MenuRestaurantPage(restaurant: resto),
          ),
        );
      },
      child: Container(
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: _buildImage(resto.imagePath, resto.name),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resto.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${resto.rating} (${resto.reviewCount}+ avis)',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              '~${resto.deliveryMinutes} min',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF3EE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Voir Menu',
                      style: const TextStyle(
                        color: kOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String path, String name) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(_getFallback(name), fit: BoxFit.cover),
      );
    }
    String asset = path.isEmpty
        ? _getFallback(name)
        : (path.startsWith('assets/') ? path : 'assets/images/$path');
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(_getFallback(name), fit: BoxFit.cover),
    );
  }

  String _getFallback(String name) {
    final n = name.toLowerCase();
    if (n.contains('awa')) return 'assets/images/maman_awa.jpg';
    if (n.contains('cote') || n.contains('côte')) return 'assets/images/petite_cote.jpg';
    if (n.contains('qg')) return 'assets/images/qg.jpg';
    if (n.contains('goor')) return 'assets/images/mame_goor.jpg';
    if (n.contains('jardin')) return 'assets/images/jardin.jpg';
    if (n.contains('faye')) return 'assets/images/mme_faye.jpg';
    return 'assets/images/maman_awa.jpg';
  }
}
