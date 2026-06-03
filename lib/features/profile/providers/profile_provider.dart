import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/app_assets.dart';
import '../data/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final _repository = ProfileRepository();
  late Map<String, dynamic> _profileData;
  bool _isLoading = false;

  static final ProfileProvider _instance = ProfileProvider._internal();
  factory ProfileProvider() => _instance;

  ProfileProvider._internal() {
    _profileData = _repository.getUserProfile();
    _profileData['avatar'] = AppAssets.avatar;
    _profileData['location'] = 'Almatı';
    _profileData['latitude'] = 43.2389;
    _profileData['longitude'] = 76.8897;
    fetchProfile();
  }

  Map<String, dynamic> get profileData => _profileData;
  bool get isLoading => _isLoading;

  ImageProvider getAvatarImage() {
    final avatarUrl = _profileData['avatar']?.toString() ?? AppAssets.avatar;
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return NetworkImage(avatarUrl);
    }
    if (kIsWeb) {
      return NetworkImage(avatarUrl);
    }
    return FileImage(File(avatarUrl));
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final localName    = prefs.getString('full_name') ?? '';
      final localEmail   = prefs.getString('email') ?? '';
      final localPhone   = prefs.getString('phone') ?? '';
      final localAvatar  = prefs.getString('avatar') ?? '';
      final localLocation = prefs.getString('location') ?? 'Almatı';
      final localLat     = prefs.getDouble('location_latitude') ?? 43.2389;
      final localLon     = prefs.getDouble('location_longitude') ?? 76.8897;

      // Prefer locally cached name/email so manual edits survive restarts
      final firebaseName  = Firebase.apps.isNotEmpty
          ? (FirebaseAuth.instance.currentUser?.displayName ?? '')
          : '';
      final firebaseEmail = Firebase.apps.isNotEmpty
          ? (FirebaseAuth.instance.currentUser?.email ?? '')
          : '';

      final cachedName  = localName.isNotEmpty  ? localName  : (firebaseName.isNotEmpty  ? firebaseName  : 'Kullanıcı');
      final cachedEmail = localEmail.isNotEmpty ? localEmail : firebaseEmail;

      final data = await ApiService.getUserProfile();

      if (data != null) {
        final String displayName = (data['full_name']?.toString().isNotEmpty == true)
            ? data['full_name'].toString()
            : cachedName;

        final rawAvatar = data['avatar']?.toString() ?? '';
        final avatarVal = (rawAvatar.isNotEmpty && rawAvatar != 'null')
            ? rawAvatar
            : (localAvatar.isNotEmpty ? localAvatar : AppAssets.avatar);

        final rawPhone = data['phone']?.toString() ?? '';
        final phoneVal = (rawPhone.isNotEmpty && rawPhone != 'null') ? rawPhone : localPhone;

        final String emailVal = (data['email']?.toString().isNotEmpty == true)
            ? data['email'].toString()
            : cachedEmail;

        _profileData = {
          'name': displayName,
          'membership': 'Basic member',
          'phone': phoneVal,
          'avatar': avatarVal,
          'email': emailVal,
          'weight': data['weight'] ?? 75.0,
          'weightUnit': (data['weight_unit'] ?? 'KG').toString().toUpperCase(),
          'height': data['height'] ?? 175.0,
          'heightUnit': (data['height_unit'] ?? 'CM').toString().toUpperCase(),
          'gender': data['gender'] ?? 'Erkek',
          'age': data['age'] ?? 25,
          'favoriteActivity': data['favorite_activity'] ?? 'Running',
          'fitnessLevel': data['fitness_level'] ?? 'Beginner',
          'goal': data['goal'] ?? 'Improve fitness',
          'location': data['location'] ?? localLocation,
          'latitude': localLat,
          'longitude': localLon,
          'protein': 130,
          'carbs': 235,
          'fat': 60,
        };
      } else {
        // Backend unavailable — use cached values
        _profileData['name']  = cachedName;
        _profileData['email'] = cachedEmail;
        if (localPhone.isNotEmpty)  _profileData['phone']  = localPhone;
        if (localAvatar.isNotEmpty) _profileData['avatar'] = localAvatar;
        _profileData['location']  = localLocation;
        _profileData['latitude']  = localLat;
        _profileData['longitude'] = localLon;
      }
    } catch (e) {
      debugPrint("Error fetching profile, using mock/cache: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateProfile({
    required String name,
    required String phone,
    required String email,
    required double weight,
    required String weightUnit,
    required double height,
    required String heightUnit,
    required String gender,
    required int age,
    String? avatar,
  }) async {
    _profileData['name'] = name;
    _profileData['phone'] = phone;
    _profileData['email'] = email;
    _profileData['weight'] = weight;
    _profileData['weightUnit'] = weightUnit;
    _profileData['height'] = height;
    _profileData['heightUnit'] = heightUnit;
    _profileData['gender'] = gender;
    _profileData['age'] = age;
    if (avatar != null) {
      _profileData['avatar'] = avatar;
    }
    notifyListeners();

    // 1. Persist locally so values survive restarts
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('full_name', name);
      await prefs.setString('email', email);
      await prefs.setString('phone', phone);
      await prefs.setString('gender', gender);
      await prefs.setDouble('weight', weight);
      await prefs.setString('weight_unit', weightUnit);
      await prefs.setDouble('height', height);
      await prefs.setString('height_unit', heightUnit);
      await prefs.setInt('age', age);
      if (avatar != null) {
        await prefs.setString('avatar', avatar);
      }
    } catch (e) {
      debugPrint("Error caching updated profile locally: $e");
    }

    // 2. Sync display name to Firebase Auth
    try {
      final user = Firebase.apps.isNotEmpty ? FirebaseAuth.instance.currentUser : null;
      if (user != null) {
        await user.updateDisplayName(name);
      }
    } catch (e) {
      debugPrint("Error updating Firebase displayName: $e");
    }

    // 3. Save back to backend
    ApiService.saveOnboarding(
      fullName: name,
      gender: gender,
      favoriteActivity: _profileData['favoriteActivity'] ?? 'Running',
      age: age,
      weight: weight,
      weightUnit: weightUnit.toLowerCase(),
      height: height,
      heightUnit: heightUnit.toLowerCase(),
      fitnessLevel: _profileData['fitnessLevel'] ?? 'Beginner',
      goal: _profileData['goal'] ?? 'Improve fitness',
    );
  }

  void updateLocation(String location, {double? latitude, double? longitude}) async {
    _profileData['location'] = location;
    if (latitude != null) _profileData['latitude'] = latitude;
    if (longitude != null) _profileData['longitude'] = longitude;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('location', location);
      if (latitude != null) await prefs.setDouble('location_latitude', latitude);
      if (longitude != null) await prefs.setDouble('location_longitude', longitude);
    } catch (e) {
      debugPrint("Error caching updated location: $e");
    }
  }

  void clearProfile() {
    _profileData = {
      'name': '',
      'membership': 'Basic member',
      'phone': '',
      'avatar': AppAssets.avatar,
      'email': '',
      'weight': 75.0,
      'weightUnit': 'KG',
      'height': 175.0,
      'heightUnit': 'CM',
      'gender': 'Erkek',
      'age': 25,
      'location': 'Almatı',
      'latitude': 43.2389,
      'longitude': 76.8897,
      'favoriteActivity': 'Running',
      'fitnessLevel': 'Beginner',
      'goal': 'Improve fitness',
      'protein': 130,
      'carbs': 235,
      'fat': 60,
    };
    notifyListeners();
  }

  void updateWeight(double newWeight) {
    _profileData['weight'] = newWeight;
    notifyListeners();
  }
}
