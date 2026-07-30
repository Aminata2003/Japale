import 'package:flutter/material.dart';

import 'package:japale/choix_profil.dart'; // adapte le nom du fichier si besoin
import 'package:japale/widgets/connexion.dart';
import 'package:japale/inscription_etudiant.dart';
import 'package:japale/inscription_livreur.dart';
import 'package:japale/welcomPage.dart';
// à décommenter une fois créé
import 'package:japale/acceuil_client.dart';
//import 'package:japale/dashboard.dart';
// import 'package:japale/table_de_bord_restaurant.dart';
// import 'package:japale/menu_restaurant.dart';
//import 'package:japale/panier_page.dart';
// import 'package:japale/suivi_commande.dart';
import 'package:japale/profil_etudiant.dart';
// import 'package:japale/profil_livreur.dart';
import 'package:japale/profil_restaurant.dart';
// import 'package:japale/gestion_de_menu.dart';
import 'package:japale/publication_menu.dart';
// import 'package:japale/alerte.dart';

// Toutes les routes de l'application sont déclarées ici.
// Pour ajouter une nouvelle page : ajoute une constante + une entrée dans
// `routes`. Tu n'as plus jamais besoin de toucher à main.dart.
class AppRoutes {
  static const String choixProfil = '/choix-profil';
  static const String connexion = '/connexion';
  static const String inscriptionEtudiant = '/inscription-etudiant';
  static const String inscriptionLivreur = '/inscription-livreur';
  static const String inscriptionRestaurant = '/inscription-restaurant';
  static const String accueilClient = '/accueil-client';
  static const String dashboardLivreur = '/dashboard-livreur';
  static const String tableDeBordRestaurant = '/table-de-bord-restaurant';
  static const String menuRestaurant = '/menu-restaurant';
  //static const String PanierPage= '/panier_page';
  static const String suiviCommande = '/suivi-commande';
  static const String profilEtudiant = '/profil-etudiant';
  static const String profilLivreur = '/profil-livreur';
  static const String gestionDeMenu = '/gestion-de-menu';
  static const String publicationMenu = '/publication-menu';
  static const String profilRestaurant = '/profil-restaurant';
  static const String welcome = '/';

  static Map<String, WidgetBuilder> get routes {
    return {
      welcome: (context) => const WelcomePage(),

      choixProfil: (context) => const ChoixProfilPage(),

      connexion: (context) => const ConnexionPage(profil: ''),

      inscriptionEtudiant: (context) => const InscriptionEtudiant(),

      inscriptionLivreur: (context) => const InscriptionLivreur(),

      accueilClient: (context) => const AccueilClient(),

      profilEtudiant: (context) => const ProfilEtudiant(),

      profilRestaurant: (context) => const ProfilRestaurant(),

      publicationMenu: (context) => const PublicationMenu(),

      // à activer quand les pages seront créées
      // tableDeBordRestaurant: (context) => const TableauBordRestaurant(),
      // gestionDeMenu: (context) => const GestionMenu(),
    };
  }
}
