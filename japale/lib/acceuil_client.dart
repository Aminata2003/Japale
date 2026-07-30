import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/restaurant.dart';
import 'panier_page.dart';
import 'package:japale/widgets/japale_bottom_nav.dart';
import 'package:japale/profil_etudiant.dart';
import 'package:japale/models/user_session.dart';

class AccueilClient extends StatefulWidget {
  const AccueilClient({super.key});

  @override
  State<AccueilClient> createState() => _AccueilClientState();
}

class _AccueilClientState extends State<AccueilClient> {
  int _currentNavIndex = 0;

  String _categorieSelectionnee = 'Tout';

  // Restaurants récupérés depuis Firebase
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

      final restaurantsFirebase = snapshot.docs.map((doc) {
        final data = doc.data();

        return Restaurant(
          name: data['name'] ?? '',

          imagePath: data['imagePath'] ?? '',

          rating: (data['rating'] ?? 0).toDouble(),

          reviewCount: data['reviewCount'] ?? 0,

          price: data['price'] ?? 0,

          deliveryMinutes: data['deliveryMinutes'] ?? 0,
        );
      }).toList();

      setState(() {
        _restaurants = restaurantsFirebase;

        _chargement = false;
      });
    } catch (e) {
      print("Erreur chargement restaurants Firebase : $e");

      setState(() {
        _chargement = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),

      appBar: _buildAppBar(),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 20),

            _buildGreeting(),

            const SizedBox(height: 16),

            _buildSearchBar(),

            const SizedBox(height: 16),

            _buildCategoryChips(),

            const SizedBox(height: 24),

            _buildSectionHeader(),

            const SizedBox(height: 12),

            _chargement
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),

                      child: CircularProgressIndicator(),
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

          setState(() {
            _currentNavIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,

                MaterialPageRoute(builder: (context) => const AccueilClient()),
              );

              break;

            case 1:

              // TODO page Restaurants

              break;

            case 2:

              // TODO page Commandes

              break;

            case 3:

              // TODO page Alertes

              break;

            case 4:
              Navigator.pushReplacement(
                context,

                MaterialPageRoute(builder: (context) => const ProfilEtudiant()),
              );

              break;
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFDF6F0),

      elevation: 0,

      titleSpacing: 20,

      title: const Text(
        'Japale',

        style: TextStyle(
          color: Color(0xFFB5401A),

          fontSize: 22,

          fontWeight: FontWeight.bold,
        ),
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),

          child: Stack(
            clipBehavior: Clip.none,

            children: [
              const Icon(
                Icons.notifications_none,

                color: Colors.black87,

                size: 26,
              ),

              Positioned(
                right: -2,

                top: -2,

                child: Container(
                  padding: const EdgeInsets.all(4),

                  decoration: const BoxDecoration(
                    color: Colors.red,

                    shape: BoxShape.circle,
                  ),

                  child: const Text(
                    '2',

                    style: TextStyle(
                      color: Colors.white,

                      fontSize: 10,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(30),

        child: Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 8),

          child: Align(
            alignment: Alignment.centerLeft,

            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,

                  size: 16,

                  color: Colors.grey.shade600,
                ),

                const SizedBox(width: 4),

                Text(
                  'Campus UGB, Saint-Louis',

                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),

                Icon(
                  Icons.keyboard_arrow_down,

                  size: 16,

                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantImage(String imagePath) {
    final bool estUneUrl = imagePath.startsWith('http');

    return SizedBox.expand(
      child: estUneUrl
          ? Image.network(
              imagePath,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.restaurant,
                    size: 40,
                    color: Colors.grey,
                  ),
                );
              },
            )
          : Image.asset(
              imagePath,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.restaurant,
                    size: 40,
                    color: Colors.grey,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            'Bonjour ${UserSession.prenom ?? "Fatou"} 👋',

            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              padding: const EdgeInsets.symmetric(horizontal: 18),

              alignment: Alignment.center,

              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFB5401A)
                    : Colors.grey.shade200,

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

            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          GestureDetector(
            onTap: () {},

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

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.grey.shade200),
      ),

      clipBehavior: Clip.antiAlias,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Expanded(flex: 2, child: _buildRestaurantImage(restaurant.imagePath)),

          Expanded(
            flex: 3,

            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),

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
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          '${restaurant.rating} (${restaurant.reviewCount}+)',

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 12,

                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '${restaurant.price} FCFA • ~${restaurant.deliveryMinutes} min',

                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,

                    height: 32,

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (context) => PanierPage(
                              restaurantName: restaurant.name,

                              fraisLivraison: restaurant.price,

                              items: [
                                CartItem(
                                  name: 'Thiébou Dieune',

                                  unitPrice: 1500,
                                ),

                                CartItem(
                                  name: 'Jus de Bissap (50cl)',

                                  unitPrice: 300,
                                ),
                              ],
                            ),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),

                        padding: EdgeInsets.zero,
                      ),

                      child: const Text(
                        'Commander',

                        style: TextStyle(
                          color: Colors.white,

                          fontWeight: FontWeight.bold,

                          fontSize: 13,
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

          mainAxisSpacing: 14,

          childAspectRatio: 0.68,
        ),

        itemBuilder: (context, index) {
          return _buildRestaurantCard(_restaurants[index]);
        },
      ),
    );
  }
}
