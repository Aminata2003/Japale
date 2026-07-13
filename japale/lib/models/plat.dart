import 'dart:io';

/// Modèle représentant un plat du menu restaurant.
class Plat {
  Plat({
    required this.id,
    required this.nom,
    required this.prixFcfa,
    required this.description,
    required this.categorie,
    this.image,
    this.disponible = true,
  });

  final String id;
  String nom;
  int prixFcfa;
  String description;
  String categorie; // Riz, Viande, Poisson, Boisson...
  File? image;
  bool disponible;
}