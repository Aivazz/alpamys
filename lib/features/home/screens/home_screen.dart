import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/home_header.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../training/screens/workout_detail_screen.dart';
import '../../training/screens/training_screen.dart';
import '../../recipes/screens/recipes_screen.dart';
import '../../../core/services/api_service.dart';
import '../../market/screens/market_screen.dart';
import '../../market/screens/product_detail_screen.dart';
import '../../subscribers/screens/subscribers_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  const HomeScreen({super.key, this.onMenuPressed});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _popularWorkouts = [
    {
      'title': 'Full Body (Tüm Vücut)',
      'level': 'Orta Seviye',
      'duration': '60 dk',
      'days': 'Haftada 2-3 Gün',
      'desc': 'Her antrenmanda tüm ana kas gruplarını (bacak, sırt, göğüs, omuz, kol) temel çok eklemli egzersizler kullanarak çalıştırırsınız.',
      'whoFits': 'Yeni başlayanlar, zamanı kısıtlı olanlar (haftada 2-3 gün yeterlidir) ve spora ara verip geri dönenler.',
      'image': 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500&auto=format&fit=crop&q=80',
      'color': Color(0xFF6C63FF),
      'exercises': [
        {'name': 'Barbell Squat', 'sets': '4x10', 'desc': 'Bacak ve kalça gücü.', 'duration': '6 dk'},
        {'name': 'Bench Press', 'sets': '4x10', 'desc': 'Göğüs ve omuz gücü.', 'duration': '6 dk'},
        {'name': 'Barbell Row', 'sets': '4x8', 'desc': 'Sırt çekiş gücü.', 'duration': '5 dk'},
        {'name': 'Overhead Press', 'sets': '3x10', 'desc': 'Omuz itiş.', 'duration': '5 dk'},
        {'name': 'Romanian Deadlift', 'sets': '3x12', 'desc': 'Hamstring ve bel.', 'duration': '5 dk'},
      ],
    },
    {
      'title': 'Split Antrenmanları (Bölgesel)',
      'level': 'İleri Seviye',
      'duration': '50 dk',
      'days': 'Haftada 3-4 Gün',
      'desc': 'Kaslar gruplara ayrılır ve her gün sadece belirli kas grupları çalıştırılır. Bu, kası daha fazla zorlamayı ve dinlenmesi için daha fazla süre tanımayı sağlar.',
      'image': 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=500&auto=format&fit=crop&q=80',
      'color': Color(0xFFFF6584),
      'exercises': [
        {'name': 'Incline Dumbbell Press', 'sets': '4x12', 'desc': 'Üst göğüs.', 'duration': '6 dk'},
        {'name': 'Cable Fly', 'sets': '3x15', 'desc': 'Göğüs izolasyon.', 'duration': '4 dk'},
        {'name': 'Lat Pulldown', 'sets': '4x12', 'desc': 'Sırt genişliği.', 'duration': '5 dk'},
        {'name': 'Face Pull', 'sets': '3x20', 'desc': 'Arka omuz.', 'duration': '4 dk'},
        {'name': 'Leg Press', 'sets': '5x15', 'desc': 'Quads ve kalça.', 'duration': '7 dk'},
      ],
      'schemes': [
        {
          'name': 'Push-Pull-Legs (İtiş / Çekiş / Bacak)',
          'desc': '1. Gün — itiş kasları (göğüs, omuz, arkakol); 2. Gün — çekiş (sırt, pazı); 3. Gün — bacak ve karın.',
        },
        {
          'name': 'Üst / Alt Vücut (Upper / Lower)',
          'desc': 'Vücudun ikiye bölünmesi. Haftada 4 antrenman (iki kez üst, iki kez alt vücut).',
        },
        {
          'name': 'Klasik Vücut Geliştirme Spliti (Bodybuilding)',
          'desc': 'Örneğin: Pazartesi — göğüs/pazı, Çarşamba — sırt/arkakol, Cuma — bacak/omuz.',
        },
      ],
    },
  ];

  List<Map<String, dynamic>> _marketProducts = [];
  bool _isLoadingProducts = true;

  Color get _textColor => Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    ApiService.getProducts().then((products) {
      if (mounted) {
        setState(() {
          _marketProducts = products.take(4).toList();
          _isLoadingProducts = false;
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        top: false, // Let header primary color span behind status bar
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                onMenuTap: widget.onMenuPressed ?? () {
                  Scaffold.of(context).openDrawer();
                },
                onNotificationsTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
                onSearchChanged: (query) {
                  // Handle search filter logic
                },
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPopularExercises(),
                    const SizedBox(height: 28),
                    _buildRecipesSection(),
                    const SizedBox(height: 28),
                    _buildMarketSection(),
                    const SizedBox(height: 28),
                    _buildSubscriptionBannerSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularExercises() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ANTRENMANLAR',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: _textColor,
                letterSpacing: 0.5,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrainingScreen()),
                );
              },
              child: const Text(
                'Hepsini Gör',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Exercise 1 Card
        _buildExerciseCard(
          workout: _popularWorkouts[0],
        ),
        const SizedBox(height: 24),
        // Exercise 2 Card
        _buildExerciseCard(
          workout: _popularWorkouts[1],
        ),
      ],
    );
  }

  Widget _buildExerciseCard({
    required Map<String, dynamic> workout,
  }) {
    final matchingWorkout = kTrainingTypes.firstWhere(
      (t) {
        final tTitle = t['title'] as String;
        final wTitle = workout['title'] as String;
        if (wTitle.toLowerCase().contains('split') && tTitle.toLowerCase().contains('split')) {
          return true;
        }
        return wTitle.toLowerCase().contains(tTitle.toLowerCase()) ||
               tTitle.toLowerCase().contains(wTitle.toLowerCase());
      },
      orElse: () => workout,
    );

    final title = workout['title'] as String;
    final level = matchingWorkout['level'] as String;

    final exercises = matchingWorkout['exercises'] as List<dynamic>? ?? [];
    int totalMinutes = 0;
    for (final ex in exercises) {
      final durStr = ex['duration'] as String? ?? '';
      final match = RegExp(r'(\d+)').firstMatch(durStr);
      if (match != null) {
        totalMinutes += int.tryParse(match.group(1) ?? '0') ?? 0;
      }
    }
    final durationText = totalMinutes > 0 ? '$totalMinutes dk' : (workout['duration'] as String? ?? '30 dk');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailScreen(workoutData: matchingWorkout),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.network(
                  workout['image'] as String,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported_rounded, size: 40, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                level,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '  |  ',
                style: TextStyle(color: Colors.grey.shade300),
              ),
              Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                durationText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TARİFLER',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: _textColor,
                letterSpacing: 0.5,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecipesScreen()),
                );
              },
              child: const Text(
                'Hepsini Gör',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (RecipesScreen.recipes.isNotEmpty) ...[
          _buildRecipeHomeCard(RecipesScreen.recipes[0]),
          const SizedBox(height: 24),
        ],
        if (RecipesScreen.recipes.length > 1) ...[
          _buildRecipeHomeCard(RecipesScreen.recipes[1]),
        ],
      ],
    );
  }

  Widget _buildRecipeHomeCard(RecipeModel recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(
              recipe: recipe,
              isFavorite: false,
              onFavoriteToggled: () {},
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              recipe.image,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey.shade200,
                child: const Icon(Icons.restaurant_rounded, size: 40, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            recipe.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                recipe.category,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '  |  ',
                style: TextStyle(color: Colors.grey.shade300),
              ),
              Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                recipe.calories,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ÖNE ÇIKAN ÜRÜNLER',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: _textColor,
                letterSpacing: 0.5,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MarketScreen()),
                );
              },
              child: const Text(
                'Hepsini Gör',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingProducts)
          SizedBox(
            height: 190,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_textColor),
              ),
            ),
          )
        else if (_marketProducts.isEmpty)
          const SizedBox(
            height: 190,
            child: Center(
              child: Text(
                'Ürün bulunamadı',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          )
        else
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _marketProducts.length,
              itemBuilder: (context, index) {
                final product = _marketProducts[index];
                
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

                final rawRating = product['rating'];
                String formattedRating = '5.0';
                if (rawRating != null) {
                  formattedRating = rawRating.toString();
                }

                final image = product['image']?.toString() ?? '';
                final name = product['name']?.toString() ?? '';
                final brand = product['brand']?.toString() ?? 'Alpamys Nutrition';

                return GestureDetector(
                  onTap: () {
                    final uiProduct = Map<String, dynamic>.from(product);
                    uiProduct['price'] = formattedPrice;
                    uiProduct['rating'] = formattedRating;

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
                    width: 150,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Image.network(
                                image,
                                height: 140,
                                width: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 140,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image, size: 30, color: Colors.grey),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 10),
                                      const SizedBox(width: 2),
                                      Text(
                                        formattedRating,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          brand,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedPrice,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: _textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSubscriptionBannerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SPOR SALONLARI',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: _textColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SubscribersScreen(showBackButton: true)),
            );
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF131313), Color(0xFF252525)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -50,
                  top: -50,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  right: -20,
                  bottom: -60,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.02),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'PREMIUM SALONLAR',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white70,
                            size: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Şehrinizdeki En İyi Salonlar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Modern altyapı ve geniş olanaklara sahip premium spor salonlarını, havuzları ve stüdyoları keşfedin.',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12.5,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            'Salonları Keşfet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
