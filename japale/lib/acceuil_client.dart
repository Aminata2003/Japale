import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/restaurant.dart';
import 'panier_page.dart';
import 'menu_restaurant.dart';
import 'liste_restaurants.dart';
import 'suivi_commande.dart';
import 'alerte_page.dart';
import 'profil_etudiant.dart';
import 'widgets/japale_bottom_nav.dart';
import 'models/user_session.dart';

const Color kOrangePrimary = Color(0xFFFF6432);
const Color kBgColor = Color(0xFFFDF9F6);

class AccueilClient extends StatefulWidget {
  const AccueilClient({super.key});

  @override
  State<AccueilClient> createState() => _AccueilClientState();
}

class _AccueilClientState extends State<AccueilClient> {
  int _currentNavIndex = 0;
  String _categorieSelectionnee = 'Tout';
  List<Restaurant> _restaurants = [];
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _verifierEtChargerUser();
    _chargerRestaurants();
  }

  Future<void> _verifierEtChargerUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && UserSession.prenom == null) {
      try {
        await UserSession.chargerDepuisFirestore(user.uid);
        if (mounted) setState(() {});
      } catch (e) {
        debugPrint("Erreur chargement session user dans AccueilClient: $e");
      }
    }
  }

  Future<void> _chargerRestaurants() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .get();

      final restaurantsFirebase = snapshot.docs.map((doc) {
        final data = doc.data();
        String img = (data['photoUrl'] ??
                data['imagePath'] ??
                data['imageUrl'] ??
                data['image'] ??
                '')
            .toString();

        return Restaurant(
          name: (data['nomRestaurant'] ?? data['name'] ?? 'Restaurant').toString(),
          imagePath: img,
          rating: ((data['noteMoyenne'] ?? data['rating'] ?? 4.7) as num).toDouble(),
          reviewCount: ((data['nombreAvis'] ?? data['reviewCount'] ?? 120) as num).toInt(),
          price: ((data['price'] ?? 200) as num).toInt(),
          deliveryMinutes: ((data['deliveryMinutes'] ?? 15) as num).toInt(),
        );
      }).toList();

      if (mounted) {
        setState(() {
          if (restaurantsFirebase.isEmpty) {
            _restaurants = _demoRestaurants;
          } else {
            _restaurants = restaurantsFirebase;
          }
          _chargement = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement restaurants Firebase : $e");
      if (mounted) {
        setState(() {
          _restaurants = _demoRestaurants;
          _chargement = false;
        });
      }
    }
  }

  static const List<Restaurant> _demoRestaurants = [
    Restaurant(
      name: 'QG',
      imagePath: 'assets/images/qg.jpg',
      rating: 4.5,
      reviewCount: 120,
      price: 200,
      deliveryMinutes: 15,
    ),
    Restaurant(
      name: 'Maman Awa',
      imagePath: 'assets/images/maman_awa.jpg',
      rating: 4.8,
      reviewCount: 340,
      price: 200,
      deliveryMinutes: 20,
    ),
    Restaurant(
      name: 'Mme Faye',
      imagePath: 'assets/images/mme_faye.jpg',
      rating: 4.3,
      reviewCount: 80,
      price: 200,
      deliveryMinutes: 10,
    ),
    Restaurant(
      name: 'La Petite Côte',
      imagePath: 'assets/images/petite_cote.jpg',
      rating: 4.6,
      reviewCount: 210,
      price: 200,
      deliveryMinutes: 25,
    ),
    Restaurant(
      name: 'Mame Goor',
      imagePath: 'assets/images/mame_goor.jpg',
      rating: 4.7,
      reviewCount: 290,
      price: 200,
      deliveryMinutes: 18,
    ),
    Restaurant(
      name: 'Jardin Sanar',
      imagePath: 'assets/images/jardin.jpg',
      rating: 4.9,
      reviewCount: 450,
      price: 200,
      deliveryMinutes: 15,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildGreeting(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildCategoryChips(),
            const SizedBox(height: 24),
            _buildSectionHeader(),
            const SizedBox(height: 14),
            _chargement
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(color: kOrangePrimary),
                    ),
                  )
                : _buildRestaurantGrid(),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kBgColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Text(
            'Japale',
            style: TextStyle(
              color: Color(0xFFB5401A),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            UserSession.village ?? 'Campus UGB, Saint-Louis',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black87, size: 26),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlertePage()),
                );
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: kOrangePrimary,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '2',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildGreeting() {
    final String prenom = UserSession.prenom ?? "Fatou";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour $prenom 👋',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          const Text(
            'Que voulez-vous commander ?',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un plat ou restaurant...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
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
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['Tout', 'Riz', 'Sandwich', 'Jus', 'Pizza', 'Grillades'];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected = _categorieSelectionnee == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                _categorieSelectionnee = category;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFB5401A) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Restaurants disponibles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListeRestaurantsPage()),
              );
            },
            child: const Text(
              'Voir tout',
              style: TextStyle(
                color: Color(0xFFB5401A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _restaurants.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          return _buildRestaurantCard(_restaurants[index]);
        },
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuRestaurantPage(restaurant: restaurant),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo du restaurant (Partie haute de la carte)
            Expanded(
              flex: 5,
              child: SizedBox(
                width: double.infinity,
                child: _buildRestaurantImage(
                  restaurant.imagePath,
                  restaurantName: restaurant.name,
                ),
              ),
            ),

            // Détails du restaurant (Partie basse avec bouton Commander centré)
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${restaurant.rating}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          ' (${restaurant.reviewCount}+)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.delivery_dining, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${restaurant.price} FCFA • ~${restaurant.deliveryMinutes} min',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Bouton "Commander" centré en pilule orange (Conforme à la maquette)
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuRestaurantPage(restaurant: restaurant),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kOrangePrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Commander',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFallbackAssetForName(String? name) {
    if (name == null) return 'assets/images/maman_awa.jpg';
    final n = name.toLowerCase();
    if (n.contains('awa')) return 'assets/images/maman_awa.jpg';
    if (n.contains('cote') || n.contains('côte')) return 'assets/images/petite_cote.jpg';
    if (n.contains('qg')) return 'assets/images/qg.jpg';
    if (n.contains('goor')) return 'assets/images/mame_goor.jpg';
    if (n.contains('jardin')) return 'assets/images/jardin.jpg';
    if (n.contains('faye')) return 'assets/images/mme_faye.jpg';
    return 'assets/images/maman_awa.jpg';
  }

  Widget _buildRestaurantImage(String imagePath, {String? restaurantName}) {
    String cleanPath = imagePath.trim();

    if (cleanPath.isEmpty || cleanPath == 'null') {
      String fallbackAsset = _getFallbackAssetForName(restaurantName);
      return SizedBox.expand(
        child: Image.asset(
          fallbackAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFFFE4D6),
              child: const Center(
                child: Icon(Icons.restaurant, size: 40, color: kOrangePrimary),
              ),
            );
          },
        ),
      );
    }

    if (cleanPath.startsWith('http')) {
      return SizedBox.expand(
        child: Image.network(
          cleanPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            String fallbackAsset = _getFallbackAssetForName(restaurantName);
            return Image.asset(
              fallbackAsset,
              fit: BoxFit.cover,
            );
          },
        ),
      );
    }

    String assetPath = cleanPath;
    if (!assetPath.startsWith('assets/')) {
      assetPath = 'assets/images/$cleanPath';
    }

    return SizedBox.expand(
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          String fallbackAsset = _getFallbackAssetForName(restaurantName);
          return Image.asset(
            fallbackAsset,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
