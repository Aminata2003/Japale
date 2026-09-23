
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