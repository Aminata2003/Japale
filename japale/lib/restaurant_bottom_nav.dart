import 'package:flutter/material.dart';


/// Barre de navigation en bas d'écran, spécifique au profil Restaurant.
/// À ajouter sur : Tableau de bord, Gestion de menu, Commandes, Profil restaurant.
/// À NE PAS ajouter sur : Inscription restaurant, Connexion, Ajouter un plat
/// (ce sont des sous-pages ou des pages hors profil, avec un simple bouton retour).
///
/// Utilisation dans une page :
/// ```dart
/// Scaffold(
///   body: ...,
///   bottomNavigationBar: const RestaurantBottomNav(currentIndex: 0),
/// )
/// ```
/// currentIndex : 0 = Tableau de Bord, 1 = Menus, 2 = Commandes, 3 = Profil

const Color kRestaurantOrange = Color(0xFFFF6B35);

class RestaurantBottomNav extends StatelessWidget {
  const RestaurantBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  static const List<_RestaurantNavItem> _items = [
    _RestaurantNavItem(
      label: 'Tableau de Bord',
      icon: Icons.grid_view_rounded,
      routeName: '/table-de-bord-restaurant',
    ),
    _RestaurantNavItem(
      label: 'Menus',
      icon: Icons.restaurant_menu,
      routeName: '/gestion-de-menu',
    ),
    _RestaurantNavItem(
      label: 'Commandes',
      icon: Icons.receipt_long,
      routeName: '/commandes-restaurant',
    ),
    _RestaurantNavItem(
      label: 'Profil',
      icon: Icons.person,
      routeName: '/profil-restaurant',
    ),
  ];

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return; // déjà sur cette page

    // pushReplacementNamed évite d'empiler les pages à l'infini quand on
    // navigue d'un onglet à l'autre.
    Navigator.of(context).pushReplacementNamed(_items[index].routeName);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kRestaurantOrange,
      unselectedItemColor: Colors.grey.shade400,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: _items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ))
          .toList(),
    );
  }
}

class _RestaurantNavItem {
  const _RestaurantNavItem({
    required this.label,
    required this.icon,
    required this.routeName,
  });

  final String label;
  final IconData icon;
  final String routeName;
}