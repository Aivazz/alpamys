import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/responsive.dart';
import '../../../common_widgets/media/cached_image.dart';
import '../../profile/providers/profile_provider.dart';
import '../../subscribers/services/subscription_service.dart';
import '../../subscribers/screens/qr_scanner_screen.dart';
import '../../subscribers/screens/subscribers_screen.dart';
import '../../training/screens/workout_detail_screen.dart';
import '../../training/screens/training_screen.dart';
import '../../recipes/screens/recipes_screen.dart';
import '../../market/screens/market_screen.dart';
import '../../market/screens/product_detail_screen.dart';
import '../widgets/home_header.dart';
import '../../payment/widgets/payment_sheet.dart';

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
    SubscriptionService().loadSubscriptions().then((_) {
      if (mounted) {
        setState(() {
          _hasActiveSubscription = SubscriptionService().hasActivePass;
        });
      }
    });
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
    R.init(context);
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
                CachedImage(
                  url: workout['image'] as String,
                  height: R.gymCardImageH * 0.85,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(20),
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
          CachedImage(
            url: recipe.image,
            height: R.gymCardImageH * 0.85,
            width: double.infinity,
            borderRadius: BorderRadius.circular(20),
            errorChild: Icon(Icons.restaurant_rounded, size: R.iconLg, color: Colors.grey),
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
                              CachedImage(
                                url: image,
                                height: 140,
                                width: 150,
                                borderRadius: BorderRadius.circular(16),
                                errorChild: Icon(Icons.image, size: R.iconLg, color: Colors.grey),
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

  bool _hasActiveSubscription = false;
  int _selectedPlanIndex = 1;

  final List<Map<String, dynamic>> _plans = [
    {
      'title': '1 Aylık Paket',
      'subtitle': 'Aylık yenilenir',
      'price': '1.290 TL',
      'total': '1.290 TL',
      'discount': '',
      'months': 1,
    },
    {
      'title': '3 Aylık Paket',
      'subtitle': 'En popüler seçenek',
      'price': '1.090 TL',
      'total': '3.270 TL',
      'discount': '%20 Tasarruf',
      'months': 3,
    },
    {
      'title': '12 Aylık Paket',
      'subtitle': 'En iyi fiyat garantisi',
      'price': '790 TL',
      'total': '9.480 TL',
      'discount': '%40 Tasarruf',
      'months': 12,
    },
  ];



  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  List<Map<String, dynamic>> _generateRealisticGyms(String cityName, double lat, double lon) {
    final List<String> unsplashGymImages = [
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1593079831268-3381b0db4a77?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1593079831268-3381b0db4a77?w=500&auto=format&fit=crop&q=80',
    ];

    final int seed = cityName.codeUnits.fold(0, (prev, element) => prev + element);
    final Random rand = Random(seed);

    final List<String> gymNameTemplates = [
      'Fitness Center',
      'Sport Club',
      'Life & Sport Club',
      'Premium Fitness',
      'Gold Gym',
      'Champion Club',
      'Elite Fitness Center',
      'Dynamic Sport Club',
    ];

    final List<String> streets = [
      'Atatürk Caddesi',
      'Cumhuriyet Caddesi',
      'İstiklal Caddesi',
      'Fatih Sultan Mehmet Caddesi',
      'Bülent Ecevit Bulvarı',
      'Menderes Caddesi',
      'İnönü Caddesi',
      'Hürriyet Caddesi',
    ];

    List<Map<String, dynamic>> list = [];
    for (int i = 0; i < gymNameTemplates.length; i++) {
      final name = gymNameTemplates[i];
      
      final double latOffset = (rand.nextDouble() - 0.5) * 0.007;
      final double lonOffset = (rand.nextDouble() - 0.5) * 0.01;
      final double gymLat = lat + latOffset;
      final double gymLon = lon + lonOffset;

      final double dist = _calculateDistance(lat, lon, gymLat, gymLon);
      final String street = streets[i % streets.length];
      final String address = '$street No: ${rand.nextInt(120) + 1}, $cityName';

      final image = unsplashGymImages[i % unsplashGymImages.length];
      final List<String> images = [
        image,
        unsplashGymImages[(i + 1) % unsplashGymImages.length],
        unsplashGymImages[(i + 2) % unsplashGymImages.length],
      ];

      final double rating = double.parse((4.2 + rand.nextDouble() * 0.7).toStringAsFixed(1));
      final int reviews = rand.nextInt(250) + 20;

      final String phone = '+90 378 ${rand.nextInt(900) + 100} ${rand.nextInt(9000) + 1000}';
      final String website = 'www.${gymNameTemplates[i].toLowerCase().replaceAll('&', '').replaceAll(' ', '')}$cityName.com'.toLowerCase();
      const priceTiers = [890, 990, 1090, 1190, 1290, 1390, 1490, 1590, 1690, 1790];
      final String approxPrice = '~${priceTiers[(seed + i) % priceTiers.length]} TL';
      
      final String gymDescription = '$name, $cityName şehrinin en popüler spor salonlarından biridir. Modern ekipmanları, güler yüzlü eğitmenleri ve geniş çalışma alanları ile hedeflerinize ulaşmanız için ideal bir ortam sunar. Adres: $address. Çalışma saatleri: 08:00 - 22:00. İletişim: $phone. Web sitesi: $website.';

      list.add({
        'id': 'gen_${cityName.toLowerCase()}_$i',
        'name': name,
        'image': image,
        'images': images,
        'rating': rating,
        'reviews': reviews,
        'distance': '${dist.toStringAsFixed(1)} km',
        'address': address,
        'price': approxPrice,
        'tags': ['Gym', if (i % 3 == 0) 'Pool', if (i % 4 == 0) 'Spa'],
        'latitude': gymLat,
        'longitude': gymLon,
        'description': gymDescription,
      });
    }

    return list;
  }

  List<Map<String, dynamic>> get _gyms {
    final location = ProfileProvider().profileData['location']?.toString() ?? '';
    final String cityName = location.replaceAll(' (GPS)', '').trim();
    final double lat = (ProfileProvider().profileData['latitude'] as num?)?.toDouble() ?? 43.2389;
    final double lon = (ProfileProvider().profileData['longitude'] as num?)?.toDouble() ?? 76.8897;
    return _generateRealisticGyms(cityName.isNotEmpty ? cityName : 'City', lat, lon);
  }

  void _showSubscriptionPackagesSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Paket Seçimi Yapın',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tek üyelikle spor salonuna sınırsız erişim sağlayın.',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Column(
                    children: _plans.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final plan = entry.value;
                      final isSelected = _selectedPlanIndex == idx;

                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _selectedPlanIndex = idx;
                          });
                          setState(() {});
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? (isDark ? const Color(0xFF2E2E2E) : const Color(0xFFF1F5F9)) 
                                : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0)),
                              width: isSelected ? 2 : 1.2,
                            ),
                            boxShadow: isSelected 
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                                    width: isSelected ? 6.5 : 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plan['title'] as String,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      plan['subtitle'] as String,
                                      style: TextStyle(
                                        color: isDark ? Colors.grey : Colors.grey.shade600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    plan['price'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '/ Ay',
                                    style: TextStyle(
                                      color: isDark ? Colors.grey : Colors.grey.shade600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showPaymentBottomSheet(context);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                           BoxShadow(
                             color: AppColors.primary.withOpacity(0.2),
                             blurRadius: 10,
                             offset: const Offset(0, 4),
                           )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Devam Et (${_plans[_selectedPlanIndex]['price']} / Ay)',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPaymentBottomSheet(BuildContext targetContext) {
    final selectedPlan = _plans[_selectedPlanIndex];
    showPaymentSheet(
      context: targetContext,
      title: 'Alpamys Pass Satın Al',
      subtitle: '${selectedPlan['title']} — ${selectedPlan['total']} ödeme alınacak.',
      confirmLabel: 'Güvenli Ödeme Yap',
      primaryColor: AppColors.primary,
      onConfirm: () => _showLoadingAndSuccessNotification(targetContext),
    );
  }

  void _showLoadingAndSuccessNotification(BuildContext targetContext) {
    showDialog(
      context: targetContext,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || !targetContext.mounted) return;
      Navigator.pop(targetContext);
      
      showDialog(
        context: targetContext,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Dialog(
            backgroundColor: isDark ? const Color(0xFF131313) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ödeme Başarılı!',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Alpamys Pass üyeliğiniz aktif edildi. Keyifli antrenmanlar dileriz!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _hasActiveSubscription = true;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'Harika',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showQRScannerSimulation(BuildContext targetContext) {
    Navigator.push(
      targetContext,
      MaterialPageRoute(
        builder: (context) => const QrScannerScreen(title: 'Salon Girişi'),
      ),
    );
  }

  Widget _buildGymCard(Map<String, dynamic> gym) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: Stack(
              children: [
                CachedImage(
                  url: gym['image'] as String,
                  height: 180,
                  width: double.infinity,
                  errorChild: Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.primary,
                    size: R.iconLg,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.25),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFD60A), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${gym['rating']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 14,
                  left: 14,
                  child: Row(
                    children: List<String>.from(gym['tags'] as List).map((t) {
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          t,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        gym['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        gym['price'] as String,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        gym['address'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          gym['distance'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildSubscriptionBannerSection() {
    final gymsList = _gyms;
    final topGyms = gymsList.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscribersScreen(showBackButton: true)),
                );
              },
              child: const Text(
                'Tümünü Gör',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (topGyms.isEmpty)
          const Center(
            child: Text(
              'Yakınınızda spor salonu bulunamadı.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          )
        else
          Column(
            children: topGyms.map((gym) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GymDetailScreen(
                        gym: gym,
                        hasActiveSubscription: _hasActiveSubscription,
                        onSubscriptionSuccess: () {
                          if (mounted) {
                            setState(() {
                              _hasActiveSubscription = true;
                            });
                          }
                        },
                        showQRScanner: () => _showQRScannerSimulation(context),
                        showPackages: _showSubscriptionPackagesSheet,
                      ),
                    ),
                  );
                },
                child: _buildGymCard(gym),
              );
            }).toList(),
          ),
      ],
    );
  }
}
