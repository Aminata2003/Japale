class UserSession {
  static String? prenom;
  static String? nom;
  static String? email;
  static String? telephone;
  static String? village;
  static String? motDePasse;
  static String? photoProfil;

  // Méthode pour réinitialiser la session
  static void clear() {
    prenom = null;
    nom = null;
    email = null;
    telephone = null;
    village = null;
    motDePasse = null;
    photoProfil = null;
  }
}