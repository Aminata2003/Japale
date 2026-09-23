import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:japale/models/user_session.dart';
import 'confirmation_commande.dart';

const Color kOrangePanier = Color(0xFFFF6B35);

class CartItem {
  final String name;
  final int unitPrice;
  int quantity;

  CartItem({required this.name, required this.unitPrice, this.quantity = 1});

  int get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'nom': name,
      'prixUnitaire': unitPrice,
      'quantite': quantity,
      'total': totalPrice,
    };
  }
}

class PanierPage extends StatefulWidget {
  final String restaurantName;
  final int fraisLivraison;
  final List<CartItem> items;

  const PanierPage({
    super.key,

    required this.restaurantName,

    required this.fraisLivraison,

    required this.items,
  });

  @override
  State<PanierPage> createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  late List<CartItem> _items;

  String _modePaiement = 'Wave';

  bool _commandeEnCours = false;

  final String _adresseLivraison =
      'Cité universitaire Bloc B, Chambre 214, Campus Sanar';

  int _calculerFraisLivraison(String village) {
    if (village.toLowerCase().contains('hors') || village.toLowerCase().contains('hors campus')) {
      return 500;
    }
    return 200;
  }

  late int _fraisLivraisonActuels;
  late String _villageActuel;

  final List<String> _cites = [
    for (int i = 0; i < 17; i++) 'Village ${String.fromCharCode(65 + i)}',
    'Hors campus',
  ];

  void _choisirVillageLivraison() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choisir le lieu de livraison',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: _cites.length,
                    itemBuilder: (context, index) {
                      final village = _cites[index];
                      final bool estSelectionne = village == _villageActuel;
                      final int frais = _calculerFraisLivraison(village);
                      return ListTile(
                        title: Text(village),
                        subtitle: Text(
                          frais == 200 ? 'Livraison Campus • 200 FCFA' : 'Livraison Hors Campus • 500 FCFA',
                        ),
                        trailing: estSelectionne
                            ? const Icon(Icons.check_circle, color: kOrangePanier)
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _villageActuel = village;
                            _fraisLivraisonActuels = frais;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _items = List<CartItem>.from(widget.items);
    _villageActuel = UserSession.village ?? 'Village A';
    _fraisLivraisonActuels = _calculerFraisLivraison(_villageActuel);
  }

  int get _sousTotal {
    return _items.fold(0, (total, item) => total + item.totalPrice);
  }

  int get _total {
    return _sousTotal + _fraisLivraisonActuels;
  }

  Future<void> _confirmerCommande() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Votre panier est vide')));

      return;
    }

    setState(() {
      _commandeEnCours = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final docRef = await FirebaseFirestore.instance.collection('commandes').add({
        'clientId': user.uid,
        'clientNom': '${UserSession.prenom ?? "Étudiant"} ${UserSession.nom ?? ""}'.trim(),
        'restaurantId': widget.restaurantName,
        'restaurantName': widget.restaurantName,
        'plats': _items.map((item) {
          return {
            'nom': item.name,
            'prix': item.unitPrice,
            'quantite': item.quantity,
          };
        }).toList(),
        'sousTotal': _sousTotal,
        'fraisLivraison': _fraisLivraisonActuels,
        'total': _total,
        'paiement': _modePaiement,
        'adresseLivraison': _villageActuel,
        'statut': 'En attente',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmationCommandePage(
            commandeId: docRef.id,
            restaurantName: widget.restaurantName,
            total: _total,
            items: _items,
            adresse: _villageActuel,
            fraisLivraison: _fraisLivraisonActuels,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _commandeEnCours = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),

      body: Column(
        children: [
          _buildHeader(context),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  _buildRestaurantBanner(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const SizedBox(height: 20),

                        ..._items.map((item) => _buildCartItemRow(item)),

                        const SizedBox(height: 12),

                        Divider(color: Colors.grey.shade300, thickness: 1),

                        const SizedBox(height: 12),

                        _buildPriceSummary(),

                        const SizedBox(height: 24),

                        _buildAddressSection(),

                        const SizedBox(height: 24),

                        _buildPaymentSection(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),

      color: kOrangePanier,

      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),

            onPressed: () {
              Navigator.pop(context);
            },
          ),

          const SizedBox(width: 8),

          const Text(
            'Mon Panier',

            style: TextStyle(
              color: Colors.white,

              fontSize: 22,

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantBanner() {
    return Container(
      width: double.infinity,

      color: Colors.grey.shade100,

      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Row(
            children: [
              const Icon(
                Icons.storefront_outlined,

                color: kOrangePanier,

                size: 20,
              ),

              const SizedBox(width: 8),

              Text(
                widget.restaurantName,

                style: const TextStyle(
                  fontWeight: FontWeight.bold,

                  fontSize: 15,
                ),
              ),
            ],
          ),

          Row(
            children: [
              Icon(Icons.pedal_bike, color: Colors.grey.shade600, size: 18),

              const SizedBox(width: 4),

              Text(
                '${widget.fraisLivraison} FCFA livraison',

                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(item.name, style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 10),

              _buildQuantityStepper(item),
            ],
          ),

          Text(
            '${item.totalPrice} FCFA',

            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityStepper(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          _buildStepperButton(
            icon: Icons.remove,

            onTap: () {
              setState(() {
                if (item.quantity > 1) {
                  item.quantity--;
                } else {
                  _items.remove(item);
                }
              });
            },
          ),

          SizedBox(
            width: 32,

            child: Text(
              '${item.quantity}',

              textAlign: TextAlign.center,

              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          _buildStepperButton(
            icon: Icons.add,

            onTap: () {
              setState(() {
                item.quantity++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,

    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 36,

        height: 36,

        alignment: Alignment.center,

        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [
        _buildPriceLine('Sous-total', _sousTotal),

        const SizedBox(height: 8),

        _buildPriceLine(
          'Frais de livraison (${_fraisLivraisonActuels == 200 ? "Campus UGB" : "Hors campus"})',
          _fraisLivraisonActuels,
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            const Text(
              'Total',

              style: TextStyle(
                fontWeight: FontWeight.bold,

                fontSize: 18,

                color: kOrangePanier,
              ),
            ),

            Text(
              '$_total FCFA',

              style: const TextStyle(
                fontWeight: FontWeight.bold,

                fontSize: 18,

                color: kOrangePanier,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceLine(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          label,

          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),

        Text('$amount FCFA', style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'Adresse de livraison',

          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: Colors.grey.shade50,

            borderRadius: BorderRadius.circular(14),

            border: Border.all(color: Colors.grey.shade300),
          ),

          child: Row(
            children: [
              Container(
                width: 40,

                height: 40,

                decoration: const BoxDecoration(
                  color: Color(0xFFFFE4D6),

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.location_on_outlined,

                  color: kOrangePanier,

                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _villageActuel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _fraisLivraisonActuels == 200
                          ? 'Livraison Campus UGB • 200 FCFA'
                          : 'Livraison Hors Campus • 500 FCFA',
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: _choisirVillageLivraison,
                child: const Text(
                  'Modifier',
                  style: TextStyle(
                    color: kOrangePanier,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'Mode de paiement',

          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildPaymentOption(
                'Wave',

                Icons.account_balance_wallet_outlined,

                const Color(0xFF4FA8E0),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildPaymentOption(
                'Orange Money',

                Icons.wallet_outlined,

                const Color(0xFFFFA726),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildPaymentOption(
                'Cash',

                Icons.payments_outlined,

                Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String label, IconData icon, Color iconColor) {
    final bool isSelected = _modePaiement == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _modePaiement = label;
        });
      },

      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),

        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF1EB) : Colors.white,

          borderRadius: BorderRadius.circular(14),

          border: Border.all(
            color: isSelected ? const Color(0xFFB5401A) : Colors.grey.shade300,

            width: isSelected ? 2 : 1,
          ),
        ),

        child: Column(
          children: [
            Icon(icon, size: 28, color: iconColor),

            const SizedBox(height: 8),

            Text(
              label,

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 12,

                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,

                color: isSelected ? kOrangePanier : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),

            blurRadius: 8,

            offset: const Offset(0, -2),
          ),
        ],
      ),

      child: SizedBox(
        height: 56,

        child: ElevatedButton(
          onPressed: _commandeEnCours ? null : _confirmerCommande,

          style: ElevatedButton.styleFrom(
            backgroundColor: kOrangePanier,

            disabledBackgroundColor: Colors.grey,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),

          child: _commandeEnCours
              ? const SizedBox(
                  width: 24,

                  height: 24,

                  child: CircularProgressIndicator(
                    color: Colors.white,

                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Confirmer la commande',

                  style: TextStyle(
                    color: Colors.white,

                    fontWeight: FontWeight.bold,

                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
