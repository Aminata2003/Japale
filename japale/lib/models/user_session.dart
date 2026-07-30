import 'package:cloud_firestore/cloud_firestore.dart';

/// Session utilisateur en mémoire, valable pour toute l'app.
class UserSession {
  static String? uid;
  static String? role; // 'etudiant' | 'livreur' | 'restaurant'

  // Champs communs / étudiant
  static String? prenom;
  static String? nom;
  static String? email;
  static String? telephone;
  static String? village;
  static String? photoProfil;

  // Champs spécifiques restaurant
  static String? nomRestaurant;
  static String? nomResponsable;
  static String? adresse;

  @Deprecated(
    'Le mot de passe est géré par Firebase Auth, ne pas le stocker ici',
  )
  static String? motDePasse;

  static bool get estConnecte => uid != null;

  static const Map<String, String> _collectionParProfil = {
    'etudiant': 'etudiants',
    'restaurant': 'restaurants',
    'livreur': 'livreurs',
  };

  /// À appeler juste après une connexion réussie (Firebase Auth).
  /// [profil] doit être 'etudiant', 'restaurant' ou 'livreur'. S'il est
  /// fourni, on cherche directement dans la bonne collection ; sinon on
  /// essaie les trois dans l'ordre.
  static Future<void> chargerDepuisFirestore(
    String uidUtilisateur, {
    String? profil,
  }) async {
    final collectionsAEssayer =
        profil != null && _collectionParProfil.containsKey(profil)
        ? [_collectionParProfil[profil]!]
        : _collectionParProfil.values.toList();

    for (final nomCollection in collectionsAEssayer) {
      final doc = await FirebaseFirestore.instance
          .collection(nomCollection)
          .doc(uidUtilisateur)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        uid = uidUtilisateur;
        role =
            data['role'] as String? ??
            profil ??
            _roleDepuisCollection(nomCollection);
        email = data['email'] as String?;
        telephone = data['telephone'] as String?;

        if (nomCollection == 'restaurants') {
          nomRestaurant = data['nomRestaurant'] as String?;
          nomResponsable = data['nomResponsable'] as String?;
          adresse = data['adresse'] as String?;
          photoProfil = data['photoUrl'] as String?;

          // Compat avec le code existant qui lit UserSession.prenom
          prenom = nomRestaurant;
          nom = '';
        } else {
          prenom = data['prenom'] as String?;
          nom = data['nom'] as String?;
          village = data['village'] as String?;
          photoProfil = data['photoProfil'] as String?;
        }

        return;
      }
    }

    throw Exception('Aucun profil trouvé pour cet utilisateur dans Firestore');
  }

  static String _roleDepuisCollection(String collection) {
    return _collectionParProfil.entries
        .firstWhere((e) => e.value == collection)
        .key;
  }

  static void clear() {
    uid = null;
    role = null;
    prenom = null;
    nom = null;
    email = null;
    telephone = null;
    village = null;
    photoProfil = null;
    nomRestaurant = null;
    nomResponsable = null;
    adresse = null;
  }
}
