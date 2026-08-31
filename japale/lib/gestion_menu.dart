import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/plat.dart';
import 'publication_menu.dart';
import 'restaurant_bottom_nav.dart';
import 'package:japale/models/user_session.dart';

const Color kOrange = Color(0xFFFF6B35);
const Color kOrangeLight = Color(0xFFFDF3EE);

/// Page "Gestion du Menu". Fait partie du profil Restaurant :
/// possède la RestaurantBottomNav (onglet "Menus" actif, index 1).
class GestionMenu extends StatefulWidget {
  const GestionMenu({super.key});

  @override
  State<GestionMenu> createState() => _GestionMenuState();
}

class _GestionMenuState extends State<GestionMenu> {
  final TextEditingController _rechercheController = TextEditingController();

  String _categorieActive = 'Tous';

  final List<String> _categories = [
    'Tous',
    'Riz',
    'Viande',
    'Poisson',
    'Boisson',
  ];

  List<Plat> _plats = [];
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _chargerMenus();
  }

  Future<void> _chargerMenus() async {
    try {
      final uidRestaurant = UserSession.uid;

      if (uidRestaurant == null) {
        throw Exception("Aucun restaurant connecté");
      }

      // ⚠️ Corrigé : la collection s'appelle "plats" (comme dans
      // publication_menu.dart), pas "menus".
      final snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(uidRestaurant)
          .collection('plats')
          .get();

      final platsFirebase = snapshot.docs
          .map((doc) => Plat.fromFirestore(doc.id, doc.data()))
          .toList();

      setState(() {
        _plats = platsFirebase;
        _chargement = false;
      });
    } catch (e) {
      debugPrint("Erreur chargement menus Firebase : $e");
      setState(() {
        _chargement = false;
      });
    }
  }

  List<Plat> get _platsFiltres {
    return _plats.where((plat) {
      final matchCategorie =
          _categorieActive == 'Tous' || plat.categorie == _categorieActive;

      final matchRecherche = plat.nom.toLowerCase().contains(
            _rechercheController.text.trim().toLowerCase(),
          );

      return matchCategorie && matchRecherche;
    }).toList();
  }

  Future<void> _ouvrirAjoutPlat({Plat? platExistant}) async {
    final resultat = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PublicationMenu(platExistant: platExistant),
      ),
    );

    // publication_menu.dart écrit déjà dans Firestore ; on recharge
    // simplement la liste depuis la base pour rester synchronisé.
    if (resultat == true) {
      setState(() => _chargement = true);
      await _chargerMenus();
    }
  }

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6F0),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Gestion du Menu',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Ouvert',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  controller: _rechercheController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un plat...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search, color: kOrange),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final categorie = _categories[index];
                    final active = categorie == _categorieActive;

                    return ChoiceChip(
                      label: Text(categorie),
                      selected: active,
                      onSelected: (_) =>
                          setState(() => _categorieActive = categorie),
                      selectedColor: kOrange,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: active ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: active ? kOrange : Colors.grey.shade300,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _chargement
                    ? const Center(
                        child: CircularProgressIndicator(color: kOrange),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                        itemCount: _platsFiltres.length,
                        itemBuilder: (context, index) {
                          final plat = _platsFiltres[index];
                          return _buildCartePlat(plat);
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              backgroundColor: kOrange,
              onPressed: () => _ouvrirAjoutPlat(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const RestaurantBottomNav(currentIndex: 1),
    );
  }

  Widget _buildCartePlat(Plat plat) {
    return GestureDetector(
      onTap: () => _ouvrirAjoutPlat(platExistant: plat),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: plat.imageUrl != null
                      ? Image.network(
                          plat.imageUrl!,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
                if (!plat.disponible)
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ÉPUISÉ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          plat.nom,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${plat.prixFcfa} FCFA',
                        style: const TextStyle(
                          color: kOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plat.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'DISPONIBILITÉ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      if (plat.disponible)
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'En stock',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Text(
                              'Rupture',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Transform.scale(
                              scale: 0.75,
                              child: Switch(
                                value: false,
                                onChanged: (v) async {
                                  setState(() => plat.disponible = v);
                                  final uidRestaurant = UserSession.uid;
                                  if (uidRestaurant != null) {
                                    await FirebaseFirestore.instance
                                        .collection('restaurants')
                                        .doc(uidRestaurant)
                                        .collection('plats')
                                        .doc(plat.id)
                                        .update({'disponible': v});
                                  }
                                },
                                activeThumbColor: kOrange,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: 150,
      color: kOrangeLight,
      child: const Icon(Icons.restaurant, color: kOrange, size: 40),
    );
  }
}