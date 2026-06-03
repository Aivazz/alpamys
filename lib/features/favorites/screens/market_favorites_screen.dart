import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';
import '../../market/screens/product_detail_screen.dart';
import '../../cart/services/cart_service.dart';
import '../services/favorites_service.dart';

class MarketFavoritesScreen extends StatelessWidget {
  const MarketFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          // 1. Dark Top Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF131313),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 24),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'FAVORİ ÜRÜNLERİM',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hızlı erişim için beğendiğiniz premium spor gıdaları',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Favorites Grid
          Expanded(
            child: ListenableBuilder(
              listenable: FavoritesService(),
              builder: (context, child) {
                final products = FavoritesService().favoriteProducts;
                if (products.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopping_bag_rounded,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz favori ürün eklemediniz.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.5,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Alışverişe Başla',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    final rawPrice = product['price'];
                    String formattedPrice = '0 TL';
                    if (rawPrice != null) {
                      if (rawPrice is num) {
                        formattedPrice = '${rawPrice.toStringAsFixed(0)} TL';
                      } else {
                        formattedPrice = rawPrice.toString();
                        if (!formattedPrice.toLowerCase().contains('tl')) {
                          formattedPrice = '$formattedPrice TL';
                        }
                      }
                    }

                    final uiProduct = Map<String, dynamic>.from(product);
                    uiProduct['price'] = formattedPrice;

                    final rawRating = product['rating'];
                    if (rawRating != null) {
                      uiProduct['rating'] = rawRating.toString();
                    } else {
                      uiProduct['rating'] = '5.0';
                    }

                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          barrierColor: Colors.black.withOpacity(0.5),
                          builder: (context) => FractionallySizedBox(
                            heightFactor: 0.9,
                            child: ProductDetailScreen(product: uiProduct),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image and Badges
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: const Color(0xFFF9FAFB),
                                        child: Image.network(
                                          uiProduct['image']?.toString() ?? '',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: const Color(0xFFF1F3F5),
                                              child: Center(
                                                child: Icon(
                                                  UIcons.regularRounded.picture,
                                                  color: Colors.grey,
                                                  size: 24,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    // Star Rating Badge
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              UIcons.regularRounded.star,
                                              color: const Color(0xFFF59E0B),
                                              size: 11,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${uiProduct['rating']}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Heart Badge
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          FavoritesService().toggleFavorite(product);
                                          CustomFeedback.show(
                                            context,
                                            '${product['name']} favorilerden kaldırıldı',
                                            type: FeedbackType.info,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.favorite,
                                            color: Color(0xFFED5151),
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Name
                              Text(
                                uiProduct['name']?.toString() ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF2F2D30),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // Description
                              const SizedBox(height: 2),
                              Text(
                                uiProduct['desc']?.toString() ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF9B9B9B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 12),

                              // Price and Add to Cart
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formattedPrice,
                                    style: const TextStyle(
                                      color: Color(0xFF2F2D30),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      final name = uiProduct['name']?.toString() ?? '';
                                      String defaultSize = '300g';
                                      if (name.contains('Protein')) defaultSize = '1 kg';
                                      if (name.contains('BCAA')) defaultSize = '400g';
                                      if (name.contains('Gainer')) defaultSize = '3 kg';
                                      if (name.contains('Omega')) defaultSize = '120 Kapsül';

                                      CartService().addItem(uiProduct, defaultSize);
                                      CustomFeedback.show(
                                        context,
                                        '$name ($defaultSize) sepete eklendi!',
                                        type: FeedbackType.success,
                                      );
                                    },
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFA3CB24),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          UIcons.regularRounded.plus,
                                          color: Colors.black,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
