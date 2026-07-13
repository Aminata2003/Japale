# Guide de navigation — Japale

Ce document décrit la logique de navigation de l'application, écran par écran, pour les trois profils : **Étudiant/Client**, **Livreur**, **Restaurant**.

---

## 1. Point d'entrée commun

Tous les utilisateurs, quel que soit leur profil, passent par le même point de départ :

```
choix_du_profil
   ├── Étudiant / Client
   ├── Livreur étudiant
   └── Restaurant
```

L'utilisateur choisit son profil, puis est dirigé vers l'inscription correspondante (ou directement vers la connexion s'il a déjà un compte).

Toutes les branches convergent ensuite vers un écran unique : **connexion**.

---

## 2. Parcours Étudiant / Client

```
inscription_etudiant
        ↓
    connexion
        ↓
  acceuil_client   ← écran central (hub)
        ↓
   ┌────┴────┬─────────────┬──────────────┐
menu_restaurant  mon_panier  suivi_commande  profil_etudiant
```

**Détail des écrans :**

| Écran (fichier) | Rôle |
|---|---|
| `inscription_etudiant.dart` | Créer un compte étudiant (nom, prénom, email UGB/gmail, téléphone, mot de passe, village de résidence) |
| `connexion.dart` | Se connecter avec un compte existant |
| `acceuil_client.dart` | Écran principal après connexion — accès aux 4 fonctions ci-dessous |
| `menu_restaurant.dart` | Consulter les menus disponibles et choisir des plats |
| `mon_panier.dart` | Valider et envoyer la commande |
| `suivi_commande.dart` | Suivre le statut de la livraison en temps réel |
| `profil_etudiant.dart` | Voir/modifier les informations du compte |

---

## 3. Parcours Livreur

```
inscription_livreur
        ↓
    connexion
        ↓
    dashbord   ← tableau de bord livreur (hub)
        ↓
   ┌────┴────┐
suivi_commande  profil_livreur
```

**Détail des écrans :**

| Écran (fichier) | Rôle |
|---|---|
| `inscription_livreur.dart` | Créer un compte livreur |
| `connexion.dart` | Se connecter (écran partagé avec les autres profils) |
| `dashbord.dart` | Écran principal livreur — commandes à livrer, statut |
| `suivi_commande.dart` | Suivre une livraison en cours (vue livreur) |
| `profil_livreur.dart` | Voir/modifier les informations du compte livreur |

---

## 4. Parcours Restaurant

```
inscription_restaurant   ⚠️ à créer
        ↓
    connexion
        ↓
table de bord restaurant   ← hub restaurant
        ↓
   ┌────┴────┐
gestion de menu  publication menu restaurant
```

**Détail des écrans :**

| Écran (fichier) | Rôle |
|---|---|
| `inscription_restaurant.dart` | ⚠️ **Pas encore créé** — à faire : créer un compte restaurant |
| `connexion.dart` | Se connecter (écran partagé) |
| `table de bord restaurant.dart` | Écran principal restaurant — vue d'ensemble des commandes |
| `gestion de menu.dart` | Ajouter/modifier/supprimer des plats du menu |
| `publication menu restaurant.dart` | Publier ou mettre à jour le menu visible par les clients |

---

## 5. Écrans transverses (accessibles depuis plusieurs endroits)

| Écran (fichier) | Rôle | Accessible depuis |
|---|---|---|
| `alerte.dart` | Notifications | Probablement une icône présente sur tous les écrans principaux (accueil, dashboard, tableau de bord) — à confirmer entre vous |

---

## 6. Points à décider ensemble avec ton binôme

- [ ] Créer l'écran `inscription_restaurant` (pas encore fait)
- [ ] Confirmer si `alerte` est une icône globale ou un écran séparé accessible depuis un menu
- [ ] Décider si `connexion.dart` doit détecter automatiquement le profil (étudiant/livreur/restaurant) selon l'email, ou si le profil est mémorisé depuis `choix_du_profil`
- [ ] Vérifier le nom exact des classes Dart pour chaque fichier (ex: `AcceuilClient`, `InscriptionLivreur`) afin que les imports/navigations soient cohérents entre vos deux parties du code

---

## 7. Rappel technique — comment naviguer entre les pages en Flutter

Pour aller d'une page à une autre :
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const NomDeLaPage()),
);
```

Pour aller à une page **sans pouvoir revenir en arrière** (ex: après inscription ou connexion réussie) :
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const NomDeLaPage()),
);
```
