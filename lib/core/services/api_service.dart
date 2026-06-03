import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String _resolvedBaseUrl = '';

  static String get baseUrl {
    if (_resolvedBaseUrl.isNotEmpty) {
      return _resolvedBaseUrl;
    }
    // Synchronous fallback
    return 'http://127.0.0.1:8080/api';
  }

  // Auto-discover the working backend URL in parallel
  static Future<void> resolveBaseUrl() async {
    if (kIsWeb) {
      _resolvedBaseUrl = 'http://localhost:8080/api';
      return;
    }

    final candidates = <String>[];
    try {
      if (Platform.isAndroid) {
        candidates.add('http://10.0.2.2:8080/api');  // Android emulator default
        candidates.add('http://127.0.0.1:8080/api'); // Physical device via adb reverse
      } else if (Platform.isIOS) {
        candidates.add('http://localhost:8080/api'); // iOS simulator default
      }
    } catch (_) {}

    candidates.add('http://localhost:8080/api');
    candidates.add('http://127.0.0.1:8080/api');

    final uniqueCandidates = candidates.toSet().toList();
    debugPrint('Resolving backend from candidates in parallel: $uniqueCandidates');

    try {
      final List<String?> results = await Future.wait(
        uniqueCandidates.map((candidate) async {
          try {
            final response = await http
                .get(Uri.parse('$candidate/health'))
                .timeout(const Duration(milliseconds: 1500));
            if (response.statusCode == 200) {
              return candidate;
            }
          } catch (_) {}
          return null;
        }),
      );

      for (var result in results) {
        if (result != null) {
          _resolvedBaseUrl = result;
          debugPrint('Successfully resolved backend in parallel at: $_resolvedBaseUrl');
          return;
        }
      }
    } catch (e) {
      debugPrint('Error in parallel resolveBaseUrl: $e');
    }

    _resolvedBaseUrl = uniqueCandidates.first;
    debugPrint('Could not ping healthcheck, using default fallback: $_resolvedBaseUrl');
  }

  // Get current Firebase User's ID Token
  static Future<String?> _getIdToken() async {
    try {
      if (Firebase.apps.isEmpty) {
        return "mock-firebase-token";
      }
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
    } catch (e) {
      debugPrint("Error getting Firebase ID Token, using mock fallback: $e");
    }
    return "mock-firebase-token";
  }

  // Save onboarding details to local storage
  static Future<void> _saveLocalOnboarding(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (var entry in data.entries) {
        if (entry.value is String) {
          await prefs.setString(entry.key, entry.value as String);
        } else if (entry.value is int) {
          await prefs.setInt(entry.key, entry.value as int);
        } else if (entry.value is double) {
          await prefs.setDouble(entry.key, entry.value as double);
        } else if (entry.value is num) {
          await prefs.setDouble(entry.key, (entry.value as num).toDouble());
        } else if (entry.value is bool) {
          await prefs.setBool(entry.key, entry.value as bool);
        }
      }
    } catch (e) {
      debugPrint('Error saving local onboarding: $e');
    }
  }

  // Load profile from local storage as fallback
  static Future<Map<String, dynamic>> _getLocalOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      String? defaultName;
      if (Firebase.apps.isNotEmpty) {
        defaultName = FirebaseAuth.instance.currentUser?.displayName;
      }
      
      String? defaultEmail;
      if (Firebase.apps.isNotEmpty) {
        defaultEmail = FirebaseAuth.instance.currentUser?.email;
      }

      return {
        'full_name': prefs.getString('full_name') ?? (defaultName ?? 'Test User (Offline)'),
        'email': prefs.getString('email') ?? (defaultEmail ?? 'offline@example.com'),
        'phone': prefs.getString('phone') ?? '',
        'avatar': prefs.getString('avatar') ?? '',
        'weight': prefs.getDouble('weight') ?? prefs.getInt('weight')?.toDouble() ?? 75.0,
        'weight_unit': prefs.getString('weight_unit') ?? 'KG',
        'height': prefs.getDouble('height') ?? prefs.getInt('height')?.toDouble() ?? 175.0,
        'height_unit': prefs.getString('height_unit') ?? 'CM',
        'gender': prefs.getString('gender') ?? 'Erkek',
        'age': prefs.getInt('age') ?? 25,
        'favorite_activity': prefs.getString('favorite_activity') ?? 'Running',
        'fitness_level': prefs.getString('fitness_level') ?? 'Beginner',
        'goal': prefs.getString('goal') ?? 'Improve fitness',
      };
    } catch (_) {
      return {
        'full_name': 'Test User (Offline)',
        'email': 'offline@example.com',
        'weight': 75.0,
        'weight_unit': 'KG',
        'height': 175.0,
        'height_unit': 'CM',
        'gender': 'Erkek',
        'age': 25,
        'favorite_activity': 'Running',
        'fitness_level': 'Beginner',
        'goal': 'Improve fitness',
      };
    }
  }

  // Sync user profile to backend (creates a local profile on first login/signup)
  static Future<bool> syncUser() async {
    try {
      // Save name/email locally
      final prefs = await SharedPreferences.getInstance();
      if (Firebase.apps.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          if (user.displayName != null && user.displayName!.isNotEmpty) {
            await prefs.setString('full_name', user.displayName!);
          }
          if (user.email != null && user.email!.isNotEmpty) {
            await prefs.setString('email', user.email!);
          }
        }
      }

      final token = await _getIdToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/user/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        debugPrint('User synced with Go backend successfully.');
        final data = jsonDecode(response.body);
        final userMap = data['user'] as Map<String, dynamic>?;
        if (userMap != null) {
          final age = userMap['age'] as int? ?? 0;
          final gender = userMap['gender'] as String? ?? '';
          if (age > 0 && gender.isNotEmpty) {
            await prefs.setBool('onboarding_completed', true);
            // Cache user fields as well
            await _saveLocalOnboarding(userMap);
          } else {
            await prefs.setBool('onboarding_completed', false);
          }
        }
        return true;
      } else {
        debugPrint('Sync user failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Backend unreachable, using offline fallback: $e');
      // Return true to prevent blocking login/signup UI flow on physical devices
      return true;
    }
  }

  // Save onboarding details to backend
  static Future<bool> saveOnboarding({
    String? fullName,
    required String gender,
    required String favoriteActivity,
    required int age,
    required double weight,
    required String weightUnit,
    required double height,
    required String heightUnit,
    required String fitnessLevel,
    required String goal,
  }) async {
    final Map<String, dynamic> data = {
      'gender': gender,
      'favorite_activity': favoriteActivity,
      'age': age,
      'weight': weight,
      'weight_unit': weightUnit,
      'height': height,
      'height_unit': heightUnit,
      'fitness_level': fitnessLevel,
      'goal': goal,
    };
    if (fullName != null) {
      data['full_name'] = fullName;
    }

    // Save to local cache first
    await _saveLocalOnboarding(data);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    try {
      final token = await _getIdToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/user/onboarding'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        debugPrint('Onboarding saved to Go backend successfully.');
        return true;
      } else {
        debugPrint('Saving onboarding failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Backend unreachable, saved locally only: $e');
      return true; // Keep flow moving on offline tests
    }
  }

  // Check if onboarding is completed
  static Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('onboarding_completed') ?? false;
    } catch (_) {
      return false;
    }
  }

  // Get user profile details from Go backend
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = await _getIdToken();
      if (token == null) {
        return await _getLocalOnboarding();
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // Cache this profile data locally
        await _saveLocalOnboarding(data);
        return data;
      } else {
        debugPrint('Get profile failed: ${response.body}');
        return await _getLocalOnboarding();
      }
    } catch (e) {
      debugPrint('Backend unreachable, returning cached local profile: $e');
      return await _getLocalOnboarding();
    }
  }

  // Check if email already exists in Go database or local preferences
  static Future<bool> checkUserExists(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/check?email=${Uri.encodeComponent(email)}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Backend unreachable for user check, falling back to local SharedPreferences: $e');
      final prefs = await SharedPreferences.getInstance();
      final cachedEmail = prefs.getString('email') ?? '';
      return cachedEmail.trim().toLowerCase() == email.trim().toLowerCase();
    }
  }

  // Fetch products from Go backend (SQLite database), fallback to mock data if unreachable
  static Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('Backend unreachable, using built-in mock products: $e');
    }
    return _mockProducts();
  }

  static List<Map<String, dynamic>> _mockProducts() {
    const String pImg  = 'https://images.unsplash.com/photo-1693996045899-7cf0ac0229c7?q=80&w=600&auto=format&fit=crop';
    const String gImg  = 'https://iconfit.eu/cdn/shop/products/mass-gainer-15-700px.jpg?v=1643728464';
    const String cImg  = 'https://images.unsplash.com/photo-1693996046514-0406d0773a7d?q=80&w=600&auto=format&fit=crop';
    const String vaImg = 'https://plus.unsplash.com/premium_photo-1732689834566-a7c313f00478?q=80&w=600&auto=format&fit=crop';
    return [
      // ── PROTEIN (1 карточка, 5 вкусов) ───────────────────────
      {
        'id': 1, 'name': 'Whey Gold Protein', 'brand': 'Alpamys Nutrition',
        'category': 'Protein', 'desc': '5 Aroma Seçeneği · 2.27 kg · 30 Servis',
        'price': 1490, 'rating': 4.9, 'image': pImg, 'isFavorite': false,
        'flavors': ['Çift Çikolata', 'Vanilyalı Dondurma', 'Çilek Krema', 'Muz', 'Bisküvi Krema (Oreo)'],
      },
      // ── GAINER (1 карточка, 5 вкусов) ────────────────────────
      {
        'id': 2, 'name': 'Mass Gainer Pro', 'brand': 'Alpamys Nutrition',
        'category': 'Gainer', 'desc': '5 Aroma Seçeneği · 3 kg · 10 Servis',
        'price': 1290, 'rating': 4.6, 'image': gImg, 'isFavorite': false,
        'flavors': ['Çikolatalı Kek', 'Vanilyalı Shake', 'Çilek Reçel', 'Muz Split', 'Karamel Toffee'],
      },
      // ── KREATİN (1 карточка, 5 вкусов) ──────────────────────
      {
        'id': 3, 'name': 'Creatine Monohydrate', 'brand': 'Alpamys Nutrition',
        'category': 'Kreatin', 'desc': '5 Aroma Seçeneği · 300 g · 60 Servis',
        'price': 690, 'rating': 4.9, 'image': cImg, 'isFavorite': true,
        'flavors': ['Aromasız', 'Yeşil Elma', 'Limon-Lime', 'Orman Meyveleri', 'Fruit Punch'],
      },
      // ── VİTAMİNLER ───────────────────────────────────────────
      {'id': 4,  'name': 'Vitamin A',        'brand': 'Alpamys Nutrition', 'category': 'Vitaminler', 'desc': '5000 IU · 90 Kapsül · Retinol',               'price': 290, 'rating': 4.7, 'image': vaImg, 'isFavorite': false},
      {'id': 5,  'name': 'Vitamin B Kompleks','brand': 'Alpamys Nutrition', 'category': 'Vitaminler', 'desc': 'B1·B2·B3·B5·B6·B7·B9·B12 · 60 Tablet',      'price': 350, 'rating': 4.8, 'image': vaImg, 'isFavorite': false},
      {'id': 6,  'name': 'Vitamin C',        'brand': 'Alpamys Nutrition', 'category': 'Vitaminler', 'desc': '1000 mg · 90 Tablet · Bağışıklık Desteği',    'price': 320, 'rating': 4.9, 'image': vaImg, 'isFavorite': true},
      {'id': 7,  'name': 'Vitamin D3',       'brand': 'Alpamys Nutrition', 'category': 'Vitaminler', 'desc': '2000 IU · 120 Kapsül · Kemik Sağlığı',        'price': 380, 'rating': 4.8, 'image': vaImg, 'isFavorite': false},
      {'id': 8,  'name': 'Vitamin E',        'brand': 'Alpamys Nutrition', 'category': 'Vitaminler', 'desc': '400 IU · 90 Kapsül · Antioksidan',            'price': 310, 'rating': 4.6, 'image': vaImg, 'isFavorite': false},
      {'id': 9,  'name': 'Vitamin K2',       'brand': 'Alpamys Nutrition', 'category': 'Vitaminler', 'desc': '200 mcg · 60 Kapsül · MK-7 Formu',           'price': 420, 'rating': 4.7, 'image': vaImg, 'isFavorite': false},
      // ── AMİNO ASİTLER — Zorunlu EAA ──────────────────────────
      {'id': 10, 'name': 'L-Valine',        'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': 'Saf Toz · 250 g · BCAA Bileşeni',           'price': 580, 'rating': 4.5, 'image': vaImg, 'isFavorite': false},
      {'id': 11, 'name': 'L-Isoleucine',    'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': 'Saf Toz · 250 g · BCAA Bileşeni',           'price': 580, 'rating': 4.5, 'image': vaImg, 'isFavorite': false},
      {'id': 12, 'name': 'L-Leucine',       'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': 'Saf Toz · 250 g · BCAA Bileşeni',           'price': 620, 'rating': 4.7, 'image': vaImg, 'isFavorite': false},
      {'id': 13, 'name': 'L-Lysine',        'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': '500 mg · 100 Kapsül · Bağışıklık & Büyüme', 'price': 490, 'rating': 4.6, 'image': vaImg, 'isFavorite': false},
      {'id': 14, 'name': 'L-Methionine',    'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': '500 mg · 90 Kapsül · Karaciğer Desteği',    'price': 510, 'rating': 4.4, 'image': vaImg, 'isFavorite': false},
      {'id': 15, 'name': 'L-Threonine',     'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': 'Saf Toz · 250 g · Kolajen Sentezi',          'price': 540, 'rating': 4.3, 'image': vaImg, 'isFavorite': false},
      {'id': 16, 'name': 'L-Tryptophan',    'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': '500 mg · 60 Kapsül · Serotonin Öncüsü',     'price': 560, 'rating': 4.5, 'image': vaImg, 'isFavorite': false},
      {'id': 17, 'name': 'L-Phenylalanine', 'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': 'Saf Toz · 250 g · Tirozin Öncüsü',          'price': 590, 'rating': 4.3, 'image': vaImg, 'isFavorite': false},
      // ── AMİNO ASİTLER — Koşullu Zorunlu ─────────────────────
      {'id': 18, 'name': 'L-Arginine',      'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': 'Saf Toz · 300 g · NO & Kan Akışı',          'price': 640, 'rating': 4.6, 'image': vaImg, 'isFavorite': false},
      {'id': 19, 'name': 'L-Glutamine',     'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': 'Saf Toz · 500 g · Toparlanma & Bağırsak',   'price': 690, 'rating': 4.8, 'image': vaImg, 'isFavorite': true},
      {'id': 20, 'name': 'L-Tyrosine',      'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': '500 mg · 90 Kapsül · Odaklanma & Enerji',   'price': 600, 'rating': 4.5, 'image': vaImg, 'isFavorite': false},
      {'id': 21, 'name': 'L-Cysteine',      'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': '500 mg · 60 Kapsül · Antioksidan & Saç',    'price': 650, 'rating': 4.4, 'image': vaImg, 'isFavorite': false},
      {'id': 22, 'name': 'L-Histidine',     'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': 'Saf Toz · 250 g · Karnosin Öncüsü',         'price': 570, 'rating': 4.2, 'image': vaImg, 'isFavorite': false},
      {'id': 23, 'name': 'L-Proline',       'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': 'Saf Toz · 250 g · Kolajen & Eklem',         'price': 555, 'rating': 4.3, 'image': vaImg, 'isFavorite': false},
      // ── AMİNO ASİTLER — Zorunsuz ─────────────────────────────
      {'id': 24, 'name': 'L-Alanine',       'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': 'Saf Toz · 250 g · Enerji Metabolizması',    'price': 480, 'rating': 4.4, 'image': vaImg, 'isFavorite': false},
      {'id': 25, 'name': 'L-Asparagine',    'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': '500 mg · 60 Kapsül · Sinir Sistemi',        'price': 520, 'rating': 4.2, 'image': vaImg, 'isFavorite': false},
      {'id': 26, 'name': 'L-Aspartic Acid', 'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': 'Saf Toz · 250 g · Krebs Döngüsü',           'price': 495, 'rating': 4.3, 'image': vaImg, 'isFavorite': false},
      {'id': 27, 'name': 'L-Glutamic Acid', 'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': 'Saf Toz · 250 g · Beyin Nörotransmitter',   'price': 505, 'rating': 4.4, 'image': vaImg, 'isFavorite': false},
      {'id': 28, 'name': 'L-Glycine',       'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': 'Saf Toz · 500 g · Uyku & Kolajen',          'price': 450, 'rating': 4.6, 'image': vaImg, 'isFavorite': false},
      {'id': 29, 'name': 'L-Serine',        'brand': 'Alpamys Nutrition', 'category': 'Amino Asitler', 'desc': 'Saf Toz · 250 g · Hücre Zarı Sağlığı',      'price': 510, 'rating': 4.3, 'image': vaImg, 'isFavorite': false},
    ];
  }
}
