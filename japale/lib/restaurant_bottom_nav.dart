import 'package:flutter/material.dart';

import 'package:japale/tableau_bord_restaurant.dart';
import 'package:japale/gestion_menu.dart';
import 'package:japale/panier_page.dart';
import 'package:japale/profil_restaurant.dart';

const Color kRestaurantOrange = Color(0xFFFF6B35);

class RestaurantBottomNav extends StatelessWidget {
  const RestaurantBottomNav({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;

    switch (index) {
      case 0:
        page = const TableauBordRestaurant();
        break;

      case 1:
        page = const GestionMenu();
        break;

      case 2:
        page = const PanierPage(restaurantName: '', fraisLivraison: 0, items: [],);
        break;

      case 3:
        page = const ProfilRestaurant();
        break;

      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kRestaurantOrange,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: "Tableau de bord",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: "Menus",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: "Commandes",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profil",
        ),
      ],
    );
  }
}