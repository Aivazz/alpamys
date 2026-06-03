import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uicons/uicons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';
import '../../profile/providers/profile_provider.dart';
import '../../payment/widgets/payment_sheet.dart';
import '../services/subscription_service.dart';
import 'qr_scanner_screen.dart';

class SubscribersScreen extends StatefulWidget {
  final bool? showBackButton;
  const SubscribersScreen({super.key, this.showBackButton = false});

  @override
  State<SubscribersScreen> createState() => _SubscribersScreenState();
}

class _SubscribersScreenState extends State<SubscribersScreen> {
  bool _hasActiveSubscription = false;
  int _selectedPlanIndex = 1; // Default to 3-month (Most Popular)
  String _selectedCategory = 'Hepsi';
  String _searchQuery = '';

  double _lastFetchedLat = 0.0;
  double _lastFetchedLon = 0.0;
  List<Map<String, dynamic>>? _realGymsFetched;
  bool _isFetchingRealGyms = false;
  static const String yandexApiKey = '3ddc9317-27bd-47cb-8d36-7e0f10b98c6c';
  Timer? _debounceTimer;

  int _currentPassSliderIndex = 0;
  final PageController _passSliderController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    SubscriptionService().loadSubscriptions().then((_) {
      if (mounted) {
        setState(() {
          _hasActiveSubscription = SubscriptionService().hasActivePass;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _passSliderController.dispose();
    super.dispose();
  }

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

  // Returns gyms: real data from Overpass/Yandex API if available, else a generic generated list.
  List<Map<String, dynamic>> get _gyms {
    if (_realGymsFetched != null) {
      return _realGymsFetched!;
    }
    final location = ProfileProvider().profileData['location']?.toString() ?? '';
    final String cityName = location.replaceAll(' (GPS)', '').trim();
    final double lat = (ProfileProvider().profileData['latitude'] as num?)?.toDouble() ?? 43.2389;
    final double lon = (ProfileProvider().profileData['longitude'] as num?)?.toDouble() ?? 76.8897;
    return _generateRealisticGyms(cityName.isNotEmpty ? cityName : 'City', lat, lon);
  }

  Future<void> _onRefresh() async {
    final profile = ProfileProvider().profileData;
    final double lat = (profile['latitude'] as num?)?.toDouble() ?? 43.2389;
    final double lon = (profile['longitude'] as num?)?.toDouble() ?? 76.8897;
    if (yandexApiKey.isNotEmpty) {
      await _fetchGymsFromYandex(lat, lon, query: _searchQuery);
    } else {
      final String locationName = profile['location']?.toString() ?? 'Almatı';
      final String cityName = locationName.replaceAll(' (GPS)', '').trim();
      if (mounted) {
        setState(() {
          _realGymsFetched = _generateRealisticGyms(cityName, lat, lon);
        });
      }
    }
  }

  Future<void> _fetchGymsFromYandex(double lat, double lon, {String? query}) async {
    if (_isFetchingRealGyms) return;
    setState(() {
      _isFetchingRealGyms = true;
    });

    final String locationName = ProfileProvider().profileData['location']?.toString() ?? 'Almatı';
    final String cityName = locationName.replaceAll(' (GPS)', '').trim();
    final String searchTerm = (query != null && query.trim().isNotEmpty)
        ? "$query $cityName"
        : "spor salonu fitness спортзал $cityName";
    final textQuery = Uri.encodeComponent(searchTerm);

    final url = Uri.parse(
      'https://search-maps.yandex.ru/v1/'
      '?apikey=$yandexApiKey'
      '&text=$textQuery'
      '&lang=tr_TR'
      '&ll=$lon,$lat'
      '&spn=0.65,0.65'
      '&results=50'
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List features = data['features'] ?? [];
        
        List<Map<String, dynamic>> parsedList = [];
        int index = 0;
        final List<String> unsplashGymImages = [
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=500&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=500&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1593079831268-3381b0db4a77?w=500&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=500&auto=format&fit=crop&q=80',
        ];

        for (var feature in features) {
          final properties = feature['properties'] ?? {};
          final companyMeta = properties['CompanyMetaData'] ?? {};
          final name = companyMeta['name'] ?? properties['name'] ?? 'Spor Salonu';
          
          final List coords = feature['geometry']?['coordinates'] ?? [lon, lat];
          final double gymLon = (coords[0] as num).toDouble();
          final double gymLat = (coords[1] as num).toDouble();
          
          final double dist = _calculateDistance(lat, lon, gymLat, gymLon);
          final String address = companyMeta['address'] ?? properties['description'] ?? 'Yakınlarda';

          final image = unsplashGymImages[index % unsplashGymImages.length];
          final List<String> images = [
            image,
            unsplashGymImages[(index + 1) % unsplashGymImages.length],
            unsplashGymImages[(index + 2) % unsplashGymImages.length],
          ];

          final int idVal = int.tryParse(companyMeta['id']?.toString() ?? '') ?? index;
          final ratingData = companyMeta['Rating'];
          final double rating = (ratingData?['score'] as num?)?.toDouble() ?? 
              (4.0 + (idVal % 10) / 10).clamp(4.0, 5.0);
          final int reviews = (ratingData?['reviews'] as num?)?.toInt() ?? 
              ((idVal % 200) + 12);

          final List phonesList = companyMeta['Phones'] ?? [];
          final String phone = phonesList.isNotEmpty ? (phonesList[0]['formatted'] ?? '') : '';
          final String website = companyMeta['url'] ?? '';
          final String openingHours = companyMeta['Hours']?['text'] ?? '';

          String gymDescription = '';
          if (properties['description'] != null && properties['description'].toString().isNotEmpty) {
            gymDescription = '$name, Yandex verilerine göre $address adresinde hizmet vermektedir.';
          } else {
            gymDescription = '$name, modern altyapısı ve geniş antrenman alanlarıyla kaliteli bir spor deneyimi sunar.';
          }
          
          if (openingHours.isNotEmpty) {
            gymDescription += ' Çalışma saatleri: $openingHours.';
          }
          if (phone.isNotEmpty) {
            gymDescription += ' İletişim: $phone.';
          }
          if (website.isNotEmpty) {
            gymDescription += ' Web sitesi: $website.';
          }

          const priceTiersY = [890, 990, 1090, 1190, 1290, 1390, 1490, 1590, 1690, 1790, 1890, 1990];
          final String approxPriceY = '~${priceTiersY[idVal.abs() % priceTiersY.length]} TL';

          parsedList.add({
            'id': companyMeta['id']?.toString() ?? 'yandex_$index',
            'name': name,
            'image': image,
            'images': images,
            'rating': double.parse(rating.toStringAsFixed(1)),
            'reviews': reviews,
            'distance': '${dist.toStringAsFixed(1)} km',
            'address': address,
            'price': approxPriceY,
            'tags': ['Gym', if (name.toString().toLowerCase().contains('havuz') || name.toString().toLowerCase().contains('pool')) 'Pool'],
            'latitude': gymLat,
            'longitude': gymLon,
            'description': gymDescription,
          });
          index++;
        }

        if (parsedList.length < 5) {
          final List<Map<String, dynamic>> generatedGyms = _generateRealisticGyms(cityName, lat, lon);
          for (var gen in generatedGyms) {
            if (!parsedList.any((g) => g['name'].toString().toLowerCase() == gen['name'].toString().toLowerCase())) {
              parsedList.add(gen);
            }
          }
        }

        parsedList.sort((a, b) {
          final double da = double.tryParse(a['distance'].toString().replaceAll(' km', '')) ?? 999.0;
          final double db = double.tryParse(b['distance'].toString().replaceAll(' km', '')) ?? 999.0;
          return da.compareTo(db);
        });

        if (mounted) {
          setState(() {
            _realGymsFetched = parsedList;
            _isFetchingRealGyms = false;
          });
        }
      } else {
        throw Exception("Yandex API returned status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching from Yandex Places API: $e. Falling back to Nominatim API.");
      _fetchGymsFromNominatim(cityName, lat, lon, query: query);
    }
  }

  Future<void> _fetchGymsFromNominatim(String cityName, double lat, double lon, {String? query}) async {
    final double radiusMeters = 25000;

    final String overpassQuery = '''
[out:json][timeout:25];
(
  nwr["leisure"="fitness_centre"](around:$radiusMeters,$lat,$lon);
  nwr["amenity"="gym"](around:$radiusMeters,$lat,$lon);
  nwr["sport"="fitness"](around:$radiusMeters,$lat,$lon);
  nwr["leisure"="sports_centre"]["sport"~"fitness|gym"](around:$radiusMeters,$lat,$lon);
);
out center tags;
''';

    final List<Map<String, dynamic>> overpassEndpoints = [
      {'url': 'https://overpass.osm.ch/api/interpreter', 'method': 'get'},
      {'url': 'https://overpass-api.de/api/interpreter',  'method': 'post'},
      {'url': 'https://lz4.overpass-api.de/api/interpreter', 'method': 'post'},
      {'url': 'https://overpass.kumi.systems/api/interpreter', 'method': 'get'},
    ];

    List<Map<String, dynamic>> parsedList = [];
    final List<String> unsplashGymImages = [
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1593079831268-3381b0db4a77?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=500&auto=format&fit=crop&q=80',
    ];

    bool success = false;
    for (final endpoint in overpassEndpoints) {
      final String epUrl = endpoint['url'] as String;
      final String epMethod = endpoint['method'] as String;
      try {
        http.Response response;
        if (epMethod == 'post') {
          response = await http.post(
            Uri.parse(epUrl),
            body: {'data': overpassQuery},
            headers: {'User-Agent': 'AlpamysApp/1.0 (fitness finder)'},
          ).timeout(const Duration(seconds: 15));
        } else {
          final urlStr = '$epUrl?data=${Uri.encodeQueryComponent(overpassQuery)}';
          response = await http.get(
            Uri.parse(urlStr),
            headers: {'User-Agent': 'AlpamysApp/1.0 (fitness finder)'},
          ).timeout(const Duration(seconds: 15));
        }

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
          final List elements = data['elements'] ?? [];

          if (elements.isNotEmpty) {
            final String queryLower = (query ?? '').trim().toLowerCase();

            int index = 0;
            for (var element in elements) {
              final tags = element['tags'] ?? {};
              final String name = tags['name'] ?? tags['name:en'] ?? tags['name:tr'] ?? '';
              if (name.isEmpty) continue;

              if (queryLower.isNotEmpty && !name.toLowerCase().contains(queryLower)) continue;

              final double gymLat = (element['lat'] ?? element['center']?['lat'] as num? ?? lat).toDouble();
              final double gymLon = (element['lon'] ?? element['center']?['lon'] as num? ?? lon).toDouble();
              final double dist = _calculateDistance(lat, lon, gymLat, gymLon);

              final List<String> addrParts = [
                if (tags['addr:street'] != null) '${tags['addr:street']}${tags['addr:housenumber'] != null ? ' ${tags['addr:housenumber']}' : ''}',
                if (tags['addr:city'] != null) tags['addr:city'],
              ];
              final String address = addrParts.isNotEmpty ? addrParts.join(', ') : cityName;

              final String phone = tags['phone'] ?? tags['contact:phone'] ?? '';
              final String website = tags['website'] ?? tags['contact:website'] ?? '';
              final String openingHours = tags['opening_hours'] ?? '';

              String gymDescription = '$name, $address adresinde hizmet vermektedir. Modern altyapısı ve geniş antrenman alanlarıyla kaliteli bir spor deneyimi sunar.';
              if (openingHours.isNotEmpty) gymDescription += ' Çalışma saatleri: $openingHours.';
              if (phone.isNotEmpty) gymDescription += ' İletişim: $phone.';
              if (website.isNotEmpty) gymDescription += ' Web sitesi: $website.';

              final image = unsplashGymImages[index % unsplashGymImages.length];
              final int idVal = element['id'] as int? ?? index;
              final double rating = double.parse((4.0 + (idVal % 10) / 10).clamp(4.0, 5.0).toStringAsFixed(1));
              final int reviews = (idVal % 200) + 12;

              final bool hasPool = (tags['leisure'] == 'sports_centre' && (tags['sport'] ?? '').contains('swimming')) ||
                  name.toLowerCase().contains('havuz') || name.toLowerCase().contains('pool') || name.toLowerCase().contains('yüzme');

              parsedList.add({
                'id': 'osm_${element['id']}',
                'name': name,
                'image': image,
                'images': [
                  image,
                  unsplashGymImages[(index + 1) % unsplashGymImages.length],
                  unsplashGymImages[(index + 2) % unsplashGymImages.length],
                ],
                'rating': rating,
                'reviews': reviews,
                'distance': '${dist.toStringAsFixed(1)} km',
                'address': address,
                'price': '~${_approxPrice(idVal)} TL',
                'tags': ['Gym', if (hasPool) 'Pool'],
                'latitude': gymLat,
                'longitude': gymLon,
                'description': gymDescription,
              });
              index++;
            }
            success = true;
            break;
          }
        }
      } catch (e) {
        debugPrint('Overpass endpoint $epUrl failed: $e');
      }
    }

    if (!success || parsedList.isEmpty) {
      debugPrint('All Overpass endpoints failed or returned no results. Using generated gyms.');
    }

    if (parsedList.length < 3) {
      final List<Map<String, dynamic>> staticGyms = _gyms;
      for (var g in staticGyms) {
        if (!parsedList.any((p) => p['name'].toString().toLowerCase() == g['name'].toString().toLowerCase())) {
          parsedList.add(g);
        }
      }
    }

    parsedList.sort((a, b) {
      final double da = double.tryParse(a['distance'].toString().replaceAll(' km', '')) ?? 999.0;
      final double db = double.tryParse(b['distance'].toString().replaceAll(' km', '')) ?? 999.0;
      return da.compareTo(db);
    });

    if (mounted) {
      setState(() {
        _realGymsFetched = parsedList.isNotEmpty ? parsedList : _gyms;
        _isFetchingRealGyms = false;
      });
    }
  }

  String _approxPrice(int seed) {
    const tiers = [890, 990, 1090, 1190, 1290, 1390, 1490, 1590, 1690, 1790, 1890, 1990];
    return tiers[seed.abs() % tiers.length].toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
  }

  void _updateSubscriptionState(bool val) {
    if (val) {
      SubscriptionService().activatePass();
    } else {
      SubscriptionService().deactivatePass();
    }
    setState(() {
      _hasActiveSubscription = val;
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + 
          c(lat1 * p) * c(lat2 * p) * 
          (1 - c((lon2 - lon1) * p))/2;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: ProfileProvider(),
      builder: (context, child) {
        final profile = ProfileProvider().profileData;
        final double lat = (profile['latitude'] as num?)?.toDouble() ?? 43.2389;
        final double lon = (profile['longitude'] as num?)?.toDouble() ?? 76.8897;

        if (_lastFetchedLat != lat || _lastFetchedLon != lon) {
          _lastFetchedLat = lat;
          _lastFetchedLon = lon;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (yandexApiKey.isNotEmpty) {
              _fetchGymsFromYandex(lat, lon, query: _searchQuery);
            } else {
              final String locationName = profile['location']?.toString() ?? 'Almatı';
              final String cityName = locationName.replaceAll(' (GPS)', '').trim();
              if (mounted) {
                setState(() {
                  _realGymsFetched = _generateRealisticGyms(cityName, lat, lon);
                });
              }
            }
          });
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF6F8FA),
          extendBody: true,
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  _buildMainBodyContent(),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: topPadding + 68,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: topPadding + 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if ((widget.showBackButton ?? false) && Navigator.canPop(context))
                      Positioned(
                        left: 0,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                UIcons.regularRounded.angle_left,
                                size: 16,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withOpacity(0.35)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'SPOR SALONLARI',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  letterSpacing: 1.0,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildPassSlider(BuildContext context) {
    if (_hasActiveSubscription) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1E24), Color(0xFF111215)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 6),
              )
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ALPAMYS PASS',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sınırsız Paket Aktif',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'AKTİF',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Tüm anlaşmalı spor salonlarında geçerli üyeliğiniz bulunmaktadır. Giriş yapmak için QR kod okutucuyu açın.',
                style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.45),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () => _openRealQrScanner(context, 'Alpamys Pass Giriş'),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_scanner_rounded, color: Colors.black, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Giriş Yap (QR Kod)',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ALPAMYS PASS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tek Üyelikle Sınırsız Spor Keyfi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 195,
          child: PageView.builder(
            controller: _passSliderController,
            onPageChanged: (index) {
              setState(() {
                _currentPassSliderIndex = index;
              });
            },
            itemCount: _plans.length,
            itemBuilder: (context, index) {
              final plan = _plans[index];
              final discount = plan['discount'] as String;
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1E24), Color(0xFF111215)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(
                    color: index == 1 ? AppColors.primary.withOpacity(0.5) : Colors.white.withOpacity(0.08),
                    width: index == 1 ? 1.5 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'PASS CARD',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              if (discount.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    discount,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            plan['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan['subtitle'] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 12),
                              SizedBox(width: 6),
                              Text(
                                'Tüm salonlarda geçerli',
                                style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          plan['price'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '/ Ay',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPlanIndex = index;
                            });
                            _showPaymentBottomSheet(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: const Text(
                              'Satın Al',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_plans.length, (i) {
            final isActive = _currentPassSliderIndex == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.grey.shade600,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _openRealQrScanner(BuildContext context, String title, {Map<String, dynamic>? gym}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScannerScreen(
          title: title,
          gymId: gym?['id'] as String?,
          gymName: gym?['name'] as String?,
          gymImage: gym?['image'] as String?,
        ),
      ),
    );
  }

  Widget _buildMainBodyContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredGyms = _gyms.where((g) {
      final tags = List<String>.from(g['tags'] as List);
      final matchesCategory = _selectedCategory == 'Hepsi' || tags.contains(_selectedCategory);
      final matchesSearch = g['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            g['address'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPassSlider(context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.1 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                          if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
                          _debounceTimer = Timer(const Duration(milliseconds: 600), () {
                            final profile = ProfileProvider().profileData;
                            final double lat = (profile['latitude'] as num?)?.toDouble() ?? 43.2389;
                            final double lon = (profile['longitude'] as num?)?.toDouble() ?? 76.8897;
                            _fetchGymsFromYandex(lat, lon, query: val);
                          });
                        },
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Salon veya bölge ara...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey : Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Categories Row list
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildCategoryChip('Hepsi'),
                    _buildCategoryChip('Gym'),
                    _buildCategoryChip('Pool'),
                    _buildCategoryChip('Yoga'),
                    _buildCategoryChip('Spa'),
                    _buildCategoryChip('CrossFit'),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Gym Cards Grid / List / Spinner
              if (_isFetchingRealGyms)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                )
              else if (filteredGyms.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, color: Colors.grey.shade600, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Aradığınız kriterlere uygun salon bulunamadı.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredGyms.length,
                  itemBuilder: (context, idx) {
                    final gym = filteredGyms[idx];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GymDetailScreen(
                              gym: gym,
                              hasActiveSubscription: _hasActiveSubscription,
                              onSubscriptionSuccess: () => _updateSubscriptionState(true),
                              showQRScanner: () => _showQRScannerSimulation(context),
                              showPackages: _showSubscriptionPackagesSheet,
                            ),
                          ),
                        );
                      },
                      child: _buildGymCard(gym),
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary 
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : (isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0)),
            width: 1.5,
          ),
          boxShadow: isSelected 
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : (isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]),
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              color: isSelected 
                  ? Colors.black 
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGymCard(Map<String, dynamic> gym) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
                Image.network(
                  gym['image'] as String,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    );
                  },
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
                                    Row(
                                      children: [
                                        Text(
                                          plan['title'] as String,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900, 
                                            fontSize: 15,
                                            color: isDark ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        if (plan['discount'].toString().isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              plan['discount'] as String,
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      plan['subtitle'] as String,
                                      style: TextStyle(
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
}

class GymDetailScreen extends StatefulWidget {
  final Map<String, dynamic> gym;
  final bool hasActiveSubscription;
  final VoidCallback onSubscriptionSuccess;
  final VoidCallback showQRScanner;
  final VoidCallback showPackages;

  const GymDetailScreen({
    super.key,
    required this.gym,
    required this.hasActiveSubscription,
    required this.onSubscriptionSuccess,
    required this.showQRScanner,
    required this.showPackages,
  });

  @override
  State<GymDetailScreen> createState() => _GymDetailScreenState();
}

class _GymDetailScreenState extends State<GymDetailScreen> {
  late bool _isSubscribed;
  int _userRating = 0;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    final gymId = widget.gym['id']?.toString() ?? '';
    _isSubscribed = widget.hasActiveSubscription || SubscriptionService().isSubscribedToGym(gymId);
    _loadUserRating();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRating() async {
    final name = widget.gym['name'] as String? ?? '';
    try {
      final prefs = await SharedPreferences.getInstance();
      final rating = prefs.getInt('gym_rating_$name') ?? 0;
      if (mounted) {
        setState(() {
          _userRating = rating;
        });
      }
    } catch (e) {
      debugPrint('Error loading gym rating: $e');
    }
  }

  Future<void> _saveUserRating(int rating) async {
    final name = widget.gym['name'] as String? ?? '';
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('gym_rating_$name', rating);
      if (mounted) {
        setState(() {
          _userRating = rating;
        });
      }
      if (mounted) {
        CustomFeedback.show(
          context,
          'Değerlendirmeniz kaydedildi: $rating/5',
          type: FeedbackType.success,
        );
      }
    } catch (e) {
      debugPrint('Error saving gym rating: $e');
    }
  }

  void _buyMembership() {
    final gymName = widget.gym['name'] as String? ?? 'Spor Salonu';
    final gymPrice = widget.gym['price'] as String? ?? '1.290 TL';
    showPaymentSheet(
      context: context,
      title: '$gymName Üyeliği',
      subtitle: 'Aylık $gymPrice — Bu salon için üyelik satın alıyorsunuz.',
      confirmLabel: 'Üyeliği Satın Al  ($gymPrice / Ay)',
      primaryColor: AppColors.primary,
      onConfirm: () {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
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
                      '$gymName üyeliğiniz aktif edildi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: () async {
                        final gymId = widget.gym['id']?.toString() ?? '';
                        final navigator = Navigator.of(ctx);
                        await SubscriptionService().subscribeToGym(gymId);
                        if (mounted) {
                          navigator.pop();
                          setState(() => _isSubscribed = true);
                          widget.onSubscriptionSuccess();
                        }
                      },
                      child: Container(
                        width: double.infinity, height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text('Harika 🎉',
                              style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = (widget.gym['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [
      widget.gym['image'] as String? ?? 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1593079831268-3381b0db4a77?w=500&auto=format&fit=crop&q=80',
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF6F8FA),
      extendBody: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 60,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.fitness_center_rounded,
                                color: AppColors.primary,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 32,
                    right: 20,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1} / ${images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -12),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131313) : const Color(0xFFF6F8FA),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.gym['name'] as String,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : Colors.black,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                          ),
                          child: Text(
                            widget.gym['price'] as String,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD60A).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFFFD60A), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                  '${widget.gym['rating']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFFD60A),
                                  ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Spor Salonu  •  ${widget.gym['reviews']} Değerlendirme',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'AÇIKLAMA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.grey : Colors.grey.shade600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.gym['description'] as String? ?? 
                          '${widget.gym['name']}, modern altyapısı ve hijyen standartlarıyla antrenmanlarınız için kusursuz bir ortam sunar.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        CustomFeedback.show(context, 'Tüm açıklama gösteriliyor...', type: FeedbackType.info);
                      },
                      child: const Text(
                        'Hepsini Göster',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    Text(
                      'SALON DEĞERLENDİRMELERİ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.grey : Colors.grey.shade600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final double mainRating = double.tryParse(widget.gym['rating']?.toString() ?? '') ?? 4.8;
                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${widget.gym['rating']}',
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Mükemmel',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${widget.gym['reviews']} Değerlendirme',
                                      style: TextStyle(
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 90,
                                width: 1,
                                color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildRatingProgressRow('Personel İlgisi', mainRating),
                                    const SizedBox(height: 6),
                                    _buildRatingProgressRow('Eğitmen Uzmanlığı', double.parse(mainRating.toStringAsFixed(1))),
                                    const SizedBox(height: 6),
                                    _buildRatingProgressRow('Temizlik ve Hijyen', double.parse((mainRating + 0.1).clamp(4.0, 5.0).toStringAsFixed(1))),
                                    const SizedBox(height: 6),
                                    _buildRatingProgressRow('Ekipman Kalitesi', double.parse((mainRating - 0.1).clamp(4.0, 5.0).toStringAsFixed(1))),
                                    const SizedBox(height: 6),
                                    _buildRatingProgressRow('Soyunma Odası', double.parse((mainRating - 0.2).clamp(4.0, 5.0).toStringAsFixed(1))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 20),
                    _buildUserRatingCard(),
                    const SizedBox(height: 28),

                    Text(
                      'KONUM',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.grey : Colors.grey.shade600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: latlong.LatLng(
                              (widget.gym['latitude'] as num?)?.toDouble() ?? 43.2389,
                              (widget.gym['longitude'] as num?)?.toDouble() ?? 76.8897,
                            ),
                            initialZoom: 15.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.alpamys.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: latlong.LatLng(
                                    (widget.gym['latitude'] as num?)?.toDouble() ?? 43.2389,
                                    (widget.gym['longitude'] as num?)?.toDouble() ?? 76.8897,
                                  ),
                                  width: 40,
                                  height: 40,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.4),
                                          blurRadius: 6,
                                          spreadRadius: 2,
                                        )
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.fitness_center_rounded,
                                        color: Colors.black,
                                        size: 16,
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
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.gym['address'] as String,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Zemin kat (Giriş Katı)',
                                style: TextStyle(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        final double gymLat = (widget.gym['latitude'] as num?)?.toDouble() ?? 43.2389;
                        final double gymLon = (widget.gym['longitude'] as num?)?.toDouble() ?? 76.8897;
                        final String gymName = widget.gym['name']?.toString() ?? 'Gym';
                        _launchYandexMaps(gymLat, gymLon, gymName);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_rounded, color: AppColors.primary, size: 18),
                          const SizedBox(width: 6),
                          const Text(
                            'Yol Tarifi Al',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    Text(
                      'OLANAKLAR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.grey : Colors.grey.shade600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: [
                        _buildAmenityChip('Soyunma Odası', Icons.meeting_room_outlined, true),
                        _buildAmenityChip('Duş', Icons.shower_outlined, true),
                        _buildAmenityChip('Havalandırma', Icons.wind_power_outlined, true),
                        _buildAmenityChip('Otopark', Icons.local_parking_rounded, true),
                        _buildAmenityChip('Cafe', Icons.coffee_rounded, true),
                        _buildAmenityChip('Havuz', Icons.pool_rounded, false),
                        _buildAmenityChip('Sauna', Icons.hot_tub_rounded, false),
                        _buildAmenityChip('Fön Makinesi', Icons.air_rounded, false),
                        _buildAmenityChip('Wi-Fi', Icons.wifi_rounded, false),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  )
                ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AYLIK ÜYELİK',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.grey : Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.gym['price'] as String? ?? '1.290 TL',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_isSubscribed) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QrScannerScreen(
                          title: 'Salon Girişi',
                          gymId: widget.gym['id'] as String?,
                          gymName: widget.gym['name'] as String?,
                          gymImage: widget.gym['image'] as String?,
                        ),
                      ),
                    );
                  } else {
                    _buyMembership();
                  }
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: _isSubscribed 
                        ? (isDark ? const Color(0xFF2E2E2E) : Colors.grey.shade200) 
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (_isSubscribed ? Colors.black : AppColors.primary).withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isSubscribed ? Icons.qr_code_scanner_rounded : Icons.shopping_bag_rounded,
                          color: _isSubscribed ? AppColors.primary : Colors.black,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isSubscribed ? 'Giriş Yap (QR Kod)' : 'Üyelik Satın Al',
                          style: TextStyle(
                            color: _isSubscribed ? AppColors.primary : Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingProgressRow(String label, double score) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$score',
          style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildAmenityChip(String label, IconData icon, bool isActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive 
              ? (isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0)) 
              : (isDark ? const Color(0xFF131313) : const Color(0xFFF1F5F9)), 
          width: 1.2,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            color: isActive ? AppColors.primary : Colors.grey.shade600, 
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? (isDark ? Colors.white : Colors.black) : Colors.grey.shade600,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              decoration: isActive ? TextDecoration.none : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRatingCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        children: [
          Text(
            'Bu Salonu Değerlendir',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userRating > 0
                ? 'Puanınız: $_userRating / 5'
                : 'Salonu oylamak için yıldızlara dokunun',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isSelected = starValue <= _userRating;
              return GestureDetector(
                onTap: () => _saveUserRating(starValue),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  curve: Curves.easeOut,
                  transform: isSelected
                      ? (Matrix4.identity()..scale(1.15))
                      : Matrix4.identity(),
                  child: Icon(
                    isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isSelected ? const Color(0xFFFFD60A) : Colors.grey.shade600,
                    size: 36,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _launchYandexMaps(double lat, double lon, String gymName) async {
    final String query = Uri.encodeComponent(gymName);
    final String appUrl = 'yandexmaps://maps.yandex.ru/?pt=$lon,$lat&z=16&l=map';
    final String webUrl = 'https://yandex.ru/maps/?ll=$lon,$lat&z=16&text=$query';

    try {
      final Uri appUri = Uri.parse(appUrl);
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri);
      } else {
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch Yandex Maps: $e");
      try {
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      } catch (err) {
        debugPrint("Web fallback also failed: $err");
      }
    }
  }
}
