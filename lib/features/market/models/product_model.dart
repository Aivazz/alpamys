class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String desc;
  final String price;
  final String rating;
  final String image;
  final bool isFavorite;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.desc,
    required this.price,
    required this.rating,
    required this.image,
    this.isFavorite = false,
  });

  factory ProductModel.fromFirestore(String id, Map<String, dynamic> data) {
    final rawPrice = data['price'];
    String formattedPrice = '0 TL';
    if (rawPrice != null) {
      if (rawPrice is num) {
        formattedPrice = '${rawPrice.toStringAsFixed(0)} TL';
      } else {
        formattedPrice = rawPrice.toString();
        if (!formattedPrice.toLowerCase().contains('tl') && formattedPrice.trim().isNotEmpty) {
          formattedPrice = '$formattedPrice TL';
        }
      }
    }

    final rawRating = data['rating'];
    String formattedRating = '5.0';
    if (rawRating != null && rawRating.toString().trim().isNotEmpty) {
      formattedRating = rawRating.toString();
    }

    return ProductModel(
      id: id,
      name: data['name']?.toString() ?? '',
      brand: data['brand']?.toString() ?? 'Alpamys Nutrition',
      category: data['category']?.toString() ?? 'Tümü',
      desc: data['desc']?.toString() ?? '',
      price: formattedPrice,
      rating: formattedRating,
      image: data['image']?.toString() ?? 'https://images.unsplash.com/photo-1579758629938-03607ccdbaba?w=300&auto=format&fit=crop&q=80',
      isFavorite: data['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'category': category,
      'desc': desc,
      'price': price,
      'rating': rating,
      'image': image,
      'isFavorite': isFavorite,
    };
  }
}
