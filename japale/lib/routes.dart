import 'package:flutter/material.dart';


import 'package:japale/choix_profil.dart'; // adapte le nom du fichier si besoin
import 'package:japale/widgets/connexion.dart';
import 'package:japale/inscription_etudiant.dart';
import 'package:japale/inscription_livreur.dart';
import 'package:japale/welcomPage.dart';
// à décommenter une fois créé
import 'package:japale/acceuil_client.dart';
import 'package:japale/liste_restaurants.dart';
import 'package:japale/suivi_commande.dart';
import 'package:japale/alerte_page.dart';
import 'package:japale/profil_etudiant.dart';
import 'package:japale/profil_restaurant.dart';
import 'package:japale/publication_menu.dart';
import 'package:japale/accueil_livreur.dart';
import 'package:japale/mes_commandes.dart';
import 'package:japale/profil_livreur.dart';
import 'package:japale/historique_gains.dart';

class AppRoutes {
  static const String choixProfil = '/choix-profil';
  static const String connexion = '/connexion';
  static const String inscriptionEtudiant = '/inscription-etudiant';
  static const String inscriptionLivreur = '/inscription-livreur';
  static const String inscriptionRestaurant = '/inscription-restaurant';
  static const String accueilClient = '/accueil-client';
  static const String listeRestaurants = '/liste-restaurants';
  static const String dashboardLivreur = '/dashboard-livreur';
  static const String tableDeBordRestaurant = '/table-de-bord-restaurant';
  static const String menuRestaurant = '/menu-restaurant';
  static const String suiviCommande = '/suivi-commande';
  static const String alerte = '/alerte';
  static const String profilEtudiant = '/profil-etudiant';
  static const String profilLivreur = '/profil-livreur';
  static const String gestionDeMenu = '/gestion-de-menu';
  static const String publicationMenu = '/publication-menu';
  static const String profilRestaurant = '/profil-restaurant';
  static const String welcome = '/';
   // ===== ROUTES LIVREUR =====
  static const String mesCommandes = '/mes-commandes';
  static const String historiqueGains = '/historique-gains';
  // ==========================

  static Map<String, WidgetBuilder> get routes {
    return {
      welcome: (context) => const WelcomePage(),
      choixProfil: (context) => const ChoixProfilPage(),
      connexion: (context) => const ConnexionPage(profil: ''),
      inscriptionEtudiant: (context) => const InscriptionEtudiant(),
      inscriptionLivreur: (context) => const InscriptionLivreur(),
      accueilClient: (context) => const AccueilClient(),
      listeRestaurants: (context) => const ListeRestaurantsPage(),
      suiviCommande: (context) => const SuiviCommandePage(),
      alerte: (context) => const AlertePage(),
      profilEtudiant: (context) => const ProfilEtudiant(),
      profilRestaurant: (context) => const ProfilRestaurant(),
      publicationMenu: (context) => const PublicationMenu(),
      // ===== ROUTES LIVREUR =====
      dashboardLivreur: (context) => const AccueilLivreur(),
      mesCommandes: (context) => const MesCommandes(),
      profilLivreur: (context) => const ProfilLivreur(),
      historiqueGains: (context) => const HistoriqueGains(),
      // ==========================

    };
  }
}
