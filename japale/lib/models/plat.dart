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
    this.imageUrl,
    this.disponible = true,
  });

  final String id;
  String nom;
  int prixFcfa;
  String description;
  String categorie; // Riz, Viande, Poisson, Boisson...
  bool disponible;

  /// Photo choisie localement (avant upload), utilisée pour la prévisualisation.
  File? image;

  /// URL de la photo une fois hébergée sur Firebase Storage.
  /// C'est cette URL qui doit être utilisée pour l'affichage une fois le
  /// plat chargé depuis Firestore (le champ `image` sera alors null).
  String? imageUrl;

  factory Plat.fromFirestore(String id, Map<String, dynamic> data) {
    return Plat(
      id: id,
      nom: data['nom'] as String? ?? '',
      prixFcfa: (data['prixFcfa'] as num?)?.toInt() ?? 0,
      description: data['description'] as String? ?? '',
      categorie: data['categorie'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      disponible: data['disponible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'prixFcfa': prixFcfa,
      'description': description,
      'categorie': categorie,
      'imageUrl': imageUrl,
      'disponible': disponible,
    };
  }
}
