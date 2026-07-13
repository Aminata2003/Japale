import 'package:flutter/material.dart';

class CartItem {
  final String name;
  final int unitPrice;
  int quantity;

  CartItem({
    required this.name,
    required this.unitPrice,
    this.quantity = 1,
  });

  int get totalPrice => unitPrice * quantity;
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

  @override
  void initState() {
    super.initState();
    _items = widget.items;
  }

  int get _sousTotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  int get _total => _sousTotal + widget.fraisLivraison;

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
      color: const Color(0xFFFF6B35),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Mon Panier',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
              const Icon(Icons.storefront_outlined, color: Color(0xFFFF6B35), size: 20),
              const SizedBox(width: 8),
              Text(widget.restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          Row(
            children: [
              Icon(Icons.pedal_bike, color: Colors.grey.shade600, size: 18),
              const SizedBox(width: 4),
              Text('${widget.fraisLivraison} FCFA livraison', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
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

  Widget _buildStepperButton({required IconData icon, required VoidCallback onTap}) {
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
        _buildPriceLine('Frais de livraison', widget.fraisLivraison),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFFF6B35))),
            Text(
              '$_total FCFA',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFFF6B35)),
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
        Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
        Text('$amount FCFA', style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Adresse de livraison', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                child: const Icon(Icons.location_on_outlined, color: Color(0xFFFF6B35), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cité universitaire Bloc B', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Chambre 214, Campus Sanar', style: TextStyle(color: Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: modifier l'adresse
                },
                child: const Text('Modifier', style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold)),
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
        const Text('Mode de paiement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildPaymentOption('Wave', Icons.account_balance_wallet_outlined, const Color(0xFF4FA8E0))),
            const SizedBox(width: 10),
            Expanded(child: _buildPaymentOption('Orange Money', Icons.wallet_outlined, const Color(0xFFFFA726))),
            const SizedBox(width: 10),
            Expanded(child: _buildPaymentOption('Cash', Icons.payments_outlined, Colors.grey.shade600)),
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
                color: isSelected ? const Color(0xFFFF6B35) : Colors.black87,
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            // TODO: logique de confirmation de commande
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
          child: const Text(
            'Confirmer la commande',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}