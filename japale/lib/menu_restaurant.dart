import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/restaurant.dart';
import 'panier_page.dart';

const Color kOrange = Color(0xFFFF6B35);
const Color kOrangeLight = Color(0xFFFDF3EE);

class MenuRestaurantPage extends StatefulWidget {
  final Restaurant restaurant;

  const MenuRestaurantPage({
    super.key,
    required this.restaurant,
  });

  @override
  State<MenuRestaurantPage> createState() => _MenuRestaurantPageState();
}

class _MenuRestaurantPageState extends State<MenuRestaurantPage> {
  String _categorieActive = 'Tous';
  final List<String> _categories = ['Tous', 'Riz', 'Grillades', 'Boissons', 'Desserts'];

  // Map local des quantités sélectionnées : {nomPlat: CartItem}
  final Map<String, CartItem> _panierLocal = {};

  List<Map<String, dynamic>> _plats = [];
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _chargerPlatsDuRestaurant();
  }

  Future<void> _chargerPlatsDuRestaurant() async {
    try {
      // 1. On cherche d'abord les plats associés dans Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('plats')
          .where('disponible', isEqualTo: true)
          .get();

      final listPlats = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nom': data['nom'] ?? data['name'] ?? 'Plat du jour',
          'description': data['description'] ?? 'Délicieux plat prepared avec soin.',
          'prixFcfa': (data['prixFcfa'] ?? data['prix'] ?? 1500) as int,
          'categorie': data['categorie'] ?? 'Riz',
          'imageUrl': data['imageUrl'] ?? data['image'] ?? '',
        };
      }).toList();

      if (listPlats.isEmpty) {
        _plats = _getPlatsDemonstration();
      } else {
        _plats = listPlats;
      }
    } catch (e) {
      debugPrint("Erreur chargement plats : $e");
      _plats = _getPlatsDemonstration();
    } finally {
      if (mounted) {
        setState(() {
          _chargement = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getPlatsDemonstration() {
    return [
      {
        'id': '1',
        'nom': 'Thiébou Dieune Penda Mbaye',
        'description': 'Riz au poisson blanc avec légumes frais, tamarins et diaga.',
        'prixFcfa': 1500,
        'categorie': 'Riz',
        'imageUrl': 'assets/images/petite_cote.jpg',
      },
      {
        'id': '2',
        'nom': 'Yassa Poulet Braisé',
        'description': 'Poulet mariné au citron et oignons caramélisés avec riz blanc.',
        'prixFcfa': 1800,
        'categorie': 'Grillades',
        'imageUrl': 'assets/images/maman_awa.jpg',
      },
      {
        'id': '3',
        'nom': 'Dibi Agneau Sanar',
        'description': 'Viande d\'agneau grillée au feu de bois avec oignons et piment.',
        'prixFcfa': 2500,
        'categorie': 'Grillades',
        'imageUrl': 'assets/images/qg.jpg',
      },
      {
        'id': '4',
        'nom': 'Jus de Bissap Maison (50cl)',
        'description': 'Boisson rafraîchissante à l\'hibiscus et feuilles de menthe.',
        'prixFcfa': 300,
        'categorie': 'Boissons',
        'imageUrl': 'assets/images/jardin.jpg',
      },
      {
        'id': '5',
        'nom': 'Jus de Bouye (50cl)',
        'description': 'Jus de pain de singe onctueux à la vanille.',
        'prixFcfa': 400,
        'categorie': 'Boissons',
        'imageUrl': 'assets/images/mame_goor.jpg',
      },
      {
        'id': '6',
        'nom': 'Soupe Kandia (Gombo)',
        'description': 'Sauce gombo à l\'huile de palme avec viande et poisson séché.',
        'prixFcfa': 1700,
        'categorie': 'Riz',
        'imageUrl': 'assets/images/mme_faye.jpg',
      },
    ];
  }

  List<Map<String, dynamic>> get _platsFiltres {
    if (_categorieActive == 'Tous') return _plats;
    return _plats.where((p) => p['categorie'] == _categorieActive).toList();
  }

  void _ajouterAuPanier(Map<String, dynamic> plat) {
    final String nom = plat['nom'];
    final int prix = plat['prixFcfa'];

    setState(() {
      if (_panierLocal.containsKey(nom)) {
        _panierLocal[nom]!.quantity++;
      } else {
        _panierLocal[nom] = CartItem(
          name: nom,
          unitPrice: prix,
          quantity: 1,
        );
      }
    });
  }

  void _retirerDuPanier(Map<String, dynamic> plat) {
    final String nom = plat['nom'];
    if (!_panierLocal.containsKey(nom)) return;

    setState(() {
      if (_panierLocal[nom]!.quantity > 1) {
        _panierLocal[nom]!.quantity--;
      } else {
        _panierLocal.remove(nom);
      }
    });
  }

  int get _totalArticles {
    return _panierLocal.values.fold(0, (sum, item) => sum + item.quantity);
  }

  int get _totalPrix {
    return _panierLocal.values.fold(0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRestaurantInfo(),
                  const SizedBox(height: 20),
                  _buildCategoryFilter(),
                  const SizedBox(height: 20),
                  const Text(
                    'Plats disponibles aujourd\'hui',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _chargement
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child: CircularProgressIndicator(color: kOrange),
                          ),
                        )
                      : _buildPlatsList(),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _totalArticles > 0 ? _buildPanierBottomBar() : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: kOrange,
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildHeaderImage(widget.restaurant.imagePath),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: Text(
                widget.restaurant.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover);
    }
    String assetPath = path.startsWith('assets/') ? path : 'assets/images/$path';
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: kOrangeLight),
    );
  }

  Widget _buildRestaurantInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${widget.restaurant.rating} (${widget.restaurant.reviewCount}+)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(width: 1, height: 24, color: Colors.grey.shade300),
          Row(
            children: [
              const Icon(Icons.access_time, color: kOrange, size: 20),
              const SizedBox(width: 4),
              Text('~${widget.restaurant.deliveryMinutes} min'),
            ],
          ),
          Container(width: 1, height: 24, color: Colors.grey.shade300),
          Row(
            children: [
              const Icon(Icons.delivery_dining, color: kOrange, size: 20),
              const SizedBox(width: 4),
              Text('${widget.restaurant.price} FCFA'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final bool active = cat == _categorieActive;
          return GestureDetector(
            onTap: () => setState(() => _categorieActive = cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? kOrange : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: active ? Colors.white : Colors.black87,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlatsList() {
    final list = _platsFiltres;
    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("Aucun plat dans cette catégorie"),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final plat = list[index];
        final String nom = plat['nom'];
        final int quantite = _panierLocal[nom]?.quantity ?? 0;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 85,
                  height: 85,
                  child: _buildPlatImage(plat['imageUrl']),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plat['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${plat['prixFcfa']} FCFA',
                          style: const TextStyle(
                            color: kOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        quantite > 0
                            ? Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: kOrange, size: 22),
                                    onPressed: () => _retirerDuPanier(plat),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      '$quantite',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle, color: kOrange, size: 22),
                                    onPressed: () => _ajouterAuPanier(plat),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              )
                            : ElevatedButton(
                                onPressed: () => _ajouterAuPanier(plat),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kOrange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Ajouter',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlatImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: kOrangeLight, child: const Icon(Icons.fastfood, color: kOrange)),
      );
    }
    String path = url.isEmpty ? 'assets/images/petite_cote.jpg' : (url.startsWith('assets/') ? url : 'assets/images/$url');
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: kOrangeLight, child: const Icon(Icons.fastfood, color: kOrange)),
    );
  }

  Widget _buildPanierBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_totalArticles article${_totalArticles > 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                '$_totalPrix FCFA',
                style: const TextStyle(
                  color: kOrange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PanierPage(
                    restaurantName: widget.restaurant.name,
                    fraisLivraison: widget.restaurant.price,
                    items: _panierLocal.values.toList(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kOrange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Row(
              children: [
                Text(
                  'Voir mon panier',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
