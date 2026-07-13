import 'dart:io';

/// Modèle représentant un plat au menu d'un restaurant.
/// Utilisé par gestion_menu.dart, publication_menu.dart et menu_restaurant.dart.
class Plat {
  Plat({
    required this.id,
    required this.nom,
    required this.categorie,
    required this.prix,
    required this.description,
    this.imagePath,
    this.imageAsset,
    this.disponible = true,
  });

  final String id;
  String nom;
  String categorie;
  int prix; // en FCFA
  String description;
  File? imagePath; // photo prise/choisie par le restaurant
  String? imageAsset; // image de démo (assets/images/...)
  bool disponible;
}