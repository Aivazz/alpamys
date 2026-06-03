import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';
import '../../../common_widgets/media/cached_image.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/responsive.dart';
import 'product_detail_screen.dart';
import '../../cart/services/cart_service.dart';
import '../../cart/screens/cart_screen.dart';
import '../../favorites/services/favorites_service.dart';
import '../../favorites/screens/market_favorites_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _selectedCategory = 'Tümü';
  String _selectedSort = 'default';
  double _minPrice = 0.0;
  double _maxPrice = 2500.0;
  int _cartCount = 0;
  String _searchQuery = '';

  final List<String> _categories = [
    'Tümü',
    'Protein',
    'Kreatin',
    'Amino Asitler',
    'Gainer',
    'Vitaminler',
  ];

  late Future<List<Map<String, dynamic>>> _productsFuture;

  @override
  void initState() {
    super.initState();
    CartService().addListener(_updateCartCount);
    _cartCount = CartService().totalItemsCount;
    _loadProducts();
  }

  void _loadProducts() {
    _productsFuture = ApiService.getProducts().then((products) {
      FavoritesService().initializeFromProducts(products);
      return products;
    });
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _loadProducts();
    });
  }

  @override
  void dispose() {
    CartService().removeListener(_updateCartCount);
    super.dispose();
  }

  void _updateCartCount() {
    if (mounted) {
      setState(() {
        _cartCount = CartService().totalItemsCount;
      });
    }
  }

  Widget _buildBannerStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFA3CB24),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final topPadding = MediaQuery.paddingOf(context).top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF9F9F9),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        color: const Color(0xFFA3CB24),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Dark Header + overlapping Promo Banner in one Stack so it scrolls together
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Dark Top Background Block
                  Container(
                    width: double.infinity,
                    height: topPadding + 190,
                    decoration: const BoxDecoration(
                      color: Color(0xFF131313),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                  ),

                  // Header Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Title row
                      Padding(
                        padding: EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          top: topPadding + 12.0,
                        ),
                        child: SizedBox(
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
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        UIcons.regularRounded.angle_left,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Center(
                                child: Text(
                                  'MARKET',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const MarketFavoritesScreen(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            UIcons.regularRounded.heart,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CartScreen(),
                                          ),
                                        );
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.1,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                UIcons
                                                    .regularRounded
                                                    .shopping_cart,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                          if (_cartCount > 0)
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFA3CB24),
                                                  shape: BoxShape.circle,
                                                ),
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 16,
                                                      minHeight: 16,
                                                    ),
                                                child: Text(
                                                  '$_cartCount',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Search and Filter Settings Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF313131),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: TextField(
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val;
                                    });
                                  },
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Spor gıdası ara...',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF989898),
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Icon(
                                        UIcons.regularRounded.search,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => _showFilterBottomSheet(context),
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFA3CB24),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Icon(
                                    UIcons.regularRounded.settings_sliders,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Brand Banner ─────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A2E00), Color(0xFF0D1A00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFA3CB24,
                                ).withOpacity(0.18),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Decorative circle
                              Positioned(
                                right: -30,
                                top: -30,
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(
                                      0xFFA3CB24,
                                    ).withOpacity(0.07),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 10,
                                bottom: -20,
                                child: Opacity(
                                  opacity: 0.08,
                                  child: Icon(
                                    UIcons.regularRounded.gym,
                                    size: 120,
                                    color: const Color(0xFFA3CB24),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(22.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Brand label
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFA3CB24),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'ALPAMYS NUTRITION',
                                          style: TextStyle(
                                            color: Color(0xFFA3CB24),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Performansın Yeni Standartı',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Stats row
                                    Row(
                                      children: [
                                        _buildBannerStat('29+', 'Ürün'),
                                        Container(
                                          width: 1,
                                          height: 32,
                                          color: Colors.white.withOpacity(0.15),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                        ),
                                        _buildBannerStat('100%', 'Saf İçerik'),
                                        Container(
                                          width: 1,
                                          height: 32,
                                          color: Colors.white.withOpacity(0.15),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                        ),
                                        _buildBannerStat(
                                          'Ücretsiz',
                                          'Kargo 500₺+',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Product Cards Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFA3CB24),
                            ),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Text(
                            'Yüklenirken hata oluştu: ${snapshot.error}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    final products = snapshot.data ?? [];
                    final filteredProducts = products.where((product) {
                      final matchesCategory =
                          _selectedCategory == 'Tümü' ||
                          (product['category']?.toString() ?? '') ==
                              _selectedCategory;

                      final rawPrice = product['price'];
                      double priceVal = 0.0;
                      if (rawPrice is num) {
                        priceVal = rawPrice.toDouble();
                      } else if (rawPrice != null) {
                        priceVal = double.tryParse(rawPrice.toString()) ?? 0.0;
                      }
                      final matchesPrice =
                          priceVal >= _minPrice && priceVal <= _maxPrice;

                      final name = product['name']?.toString() ?? '';
                      final desc = product['desc']?.toString() ?? '';
                      final matchesSearch =
                          name.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ||
                          desc.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          );
                      return matchesCategory && matchesPrice && matchesSearch;
                    }).toList();

                    if (_selectedSort == 'price_asc') {
                      filteredProducts.sort(
                        (a, b) =>
                            (a['price'] as num).compareTo(b['price'] as num),
                      );
                    } else if (_selectedSort == 'price_desc') {
                      filteredProducts.sort(
                        (a, b) =>
                            (b['price'] as num).compareTo(a['price'] as num),
                      );
                    } else if (_selectedSort == 'rating_desc') {
                      filteredProducts.sort(
                        (a, b) =>
                            (b['rating'] as num).compareTo(a['rating'] as num),
                      );
                    }

                    if (filteredProducts.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Text(
                            'Aradığınız kriterlerde ürün bulunamadı.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];

                        final rawPrice = product['price'];
                        String formattedPrice = '0 TL';
                        if (rawPrice != null) {
                          if (rawPrice is num) {
                            formattedPrice =
                                '${rawPrice.toStringAsFixed(0)} TL';
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
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
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
                                  // Rounded Image container
                                  Expanded(
                                    child: Stack(
                                      children: [
                                         ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: CachedImage(
                                            url: uiProduct['image']?.toString() ?? '',
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        // Star Rating Badge
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  UIcons.regularRounded.star,
                                                  color: const Color(
                                                    0xFFF59E0B,
                                                  ),
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
                                        // Heart/Favorite Badge
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: ListenableBuilder(
                                            listenable: FavoritesService(),
                                            builder: (context, child) {
                                              final isFav = FavoritesService()
                                                  .isFavorite(product);
                                              return GestureDetector(
                                                onTap: () {
                                                  FavoritesService()
                                                      .toggleFavorite(product);
                                                  CustomFeedback.show(
                                                    context,
                                                    isFav
                                                        ? '${product['name']} favorilerden kaldırıldı'
                                                        : '${product['name']} favorilere eklendi!',
                                                    type: FeedbackType.success,
                                                  );
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        blurRadius: 4,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    isFav
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: isFav
                                                        ? const Color(
                                                            0xFFED5151,
                                                          )
                                                        : const Color(
                                                            0xFF2F2D30,
                                                          ),
                                                    size: 16,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Product Title
                                  Text(
                                    uiProduct['name']?.toString() ?? '',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : const Color(0xFF2F2D30),
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

                                  // Price and Add Button
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        uiProduct['price'] as String,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : const Color(0xFF2F2D30),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          final name =
                                              uiProduct['name']?.toString() ??
                                              '';
                                          String defaultSize = '300g';
                                          if (name.contains('Protein')) {
                                            defaultSize = '1 kg';
                                          }
                                          if (name.contains('BCAA')) {
                                            defaultSize = '400g';
                                          }
                                          if (name.contains('Gainer')) {
                                            defaultSize = '3 kg';
                                          }
                                          if (name.contains('Omega')) {
                                            defaultSize = '120 Kapsül';
                                          }

                                          CartService().addItem(
                                            uiProduct,
                                            defaultSize,
                                          );
                                          CustomFeedback.show(
                                            context,
                                            '${uiProduct['name']} ($defaultSize) sepete eklendi!',
                                            type: FeedbackType.success,
                                          );
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFA3CB24),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    // Keep local copies of parameters to only commit on "Uygula"
    String tempCategory = _selectedCategory;
    String tempSort = _selectedSort;
    double tempMinPrice = _minPrice;
    double tempMaxPrice = _maxPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131313), // Premium Obsidian Black
      barrierColor: Colors.black.withOpacity(0.7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Helper for Custom Styled Chips
            Widget buildCustomChip({
              required String label,
              required bool isSelected,
              required VoidCallback onTap,
            }) {
              return GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFA3CB24)
                        : const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFA3CB24)
                          : const Color(0xFF2E2E2E),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFA3CB24).withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.black
                          : const Color(0xFF9E9E9E),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'FİLTRELE VE SIRALA',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 1. Kategori Section
                    const Text(
                      'Kategori Seçimi',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        return buildCustomChip(
                          label: category,
                          isSelected: tempCategory == category,
                          onTap: () {
                            setModalState(() {
                              tempCategory = category;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // 2. Fiyat Aralığı Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Fiyat Aralığı',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${tempMinPrice.toStringAsFixed(0)} TL - ${tempMaxPrice.toStringAsFixed(0)} TL',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFA3CB24),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFFA3CB24),
                        inactiveTrackColor: const Color(0xFF222222),
                        trackHeight: 3.5,
                        thumbColor: const Color(0xFFA3CB24),
                        overlayColor: const Color(0xFFA3CB24).withOpacity(0.12),
                        rangeThumbShape: const RoundRangeSliderThumbShape(
                          enabledThumbRadius: 8.0,
                          elevation: 4.0,
                        ),
                        valueIndicatorColor: const Color(0xFF222222),
                        valueIndicatorTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: RangeSlider(
                        values: RangeValues(tempMinPrice, tempMaxPrice),
                        min: 0.0,
                        max: 2500.0,
                        divisions: 50,
                        labels: RangeLabels(
                          '${tempMinPrice.toStringAsFixed(0)} TL',
                          '${tempMaxPrice.toStringAsFixed(0)} TL',
                        ),
                        onChanged: (RangeValues values) {
                          setModalState(() {
                            tempMinPrice = values.start;
                            tempMaxPrice = values.end;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3. Sıralama Seçeneği Section
                    const Text(
                      'Sıralama Seçeneği',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        buildCustomChip(
                          label: 'Varsayılan',
                          isSelected: tempSort == 'default',
                          onTap: () =>
                              setModalState(() => tempSort = 'default'),
                        ),
                        buildCustomChip(
                          label: 'Fiyat: Artan',
                          isSelected: tempSort == 'price_asc',
                          onTap: () =>
                              setModalState(() => tempSort = 'price_asc'),
                        ),
                        buildCustomChip(
                          label: 'Fiyat: Azalan',
                          isSelected: tempSort == 'price_desc',
                          onTap: () =>
                              setModalState(() => tempSort = 'price_desc'),
                        ),
                        buildCustomChip(
                          label: 'En Yüksek Puan',
                          isSelected: tempSort == 'rating_desc',
                          onTap: () =>
                              setModalState(() => tempSort = 'rating_desc'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Apply Button
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA3CB24).withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA3CB24),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedCategory = tempCategory;
                            _selectedSort = tempSort;
                            _minPrice = tempMinPrice;
                            _maxPrice = tempMaxPrice;
                          });
                          Navigator.pop(context);
                          CustomFeedback.show(
                            context,
                            'Filtreler uygulandı!',
                            type: FeedbackType.success,
                          );
                        },
                        child: const Text(
                          'FİLTRELERİ UYGULA',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
