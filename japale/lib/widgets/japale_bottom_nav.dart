import 'package:flutter/material.dart';

class JapaleBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const JapaleBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFFF6B35),
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