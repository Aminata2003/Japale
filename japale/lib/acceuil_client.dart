import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import 'panier_page.dart';

class AccueilClient extends StatefulWidget {
  const AccueilClient({super.key});

  @override
  State<AccueilClient> createState() => _AccueilClientState();
}

class _AccueilClientState extends State<AccueilClient> {
  int _currentNavIndex = 0;
  String _categorieSelectionnee = 'Tout';

  final List<Restaurant> _restaurants = const [
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
      name: 'Le Jardin',
      imagePath: 'assets/images/jardin.jpg',
      rating: 4.6,
      reviewCount: 210,
      price: 200,
      deliveryMinutes: 25,
    ),
    Restaurant(
      name: 'Petite Côte',
      imagePath: 'assets/images/petite_cote.jpg',
      rating: 4.2,
      reviewCount: 150,
      price: 200,
      deliveryMinutes: 15,
    ),
    Restaurant(
      name: 'Mame Goor',
      imagePath: 'assets/images/mame_goor.jpg',
      rating: 4.7,
      reviewCount: 290,
      price: 200,
      deliveryMinutes: 18,
    ),
  ];

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
          _buildRestaurantGrid(),
          const SizedBox(height: 90), // espace pour ne pas cacher le contenu sous la bottom nav
        ],
      ),
      
    ),
    // on l'ajoute juste après
    bottomNavigationBar: _buildBottomNav(),
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
              const Icon(Icons.notifications_none, color: Colors.black87, size: 26),
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
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Campus UGB, Saint-Louis',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fonction utilitaire : affiche l'image si elle existe, sinon un placeholder gris
  Widget _buildRestaurantImage(String imagePath) {
    return SizedBox.expand(
      child: Image.asset(
        imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox.expand(
            child: Container(
              color: Colors.grey.shade300,
              child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
  Widget _buildGreeting() {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour Fatou 👋',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
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
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () {
            // TODO: navigation vers la liste complète
          },
          child: const Text(
            'Voir tout',
            style: TextStyle(color: Color(0xFFB5401A), fontWeight: FontWeight.bold, fontSize: 14),
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
        Expanded(
          flex: 2,
          child: _buildRestaurantImage(restaurant.imagePath),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  restaurant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${restaurant.price} FCFA • ~${restaurant.deliveryMinutes} min',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                                CartItem(name: 'Thiébou Dieune', unitPrice: 1500),
                                CartItem(name: 'Jus de Bissap (50cl)', unitPrice: 300),
                              ],
                            ),
                          ),
                        );
                      },
  
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Commander',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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

Widget _buildBottomNav() {
  return BottomNavigationBar(
    currentIndex: _currentNavIndex,
    onTap: (index) {
      setState(() {
        _currentNavIndex = index;
      });
      // TODO: naviguer vers la vraie page correspondante
    },
    type: BottomNavigationBarType.fixed, // important si plus de 3 items
    selectedItemColor: const Color(0xFFB5401A),
    unselectedItemColor: Colors.grey,
    showUnselectedLabels: true,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
      BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Restaurants'),
      BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Commandes'),
      BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Alertes'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
    ],
  );
}
}