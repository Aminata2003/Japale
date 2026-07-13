class Restaurant {
  final String name;
  final String imagePath;
  final double rating;
  final int reviewCount;
  final int price;
  final int deliveryMinutes;

  const Restaurant({
    required this.name,
    required this.imagePath,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.deliveryMinutes,
  });
}