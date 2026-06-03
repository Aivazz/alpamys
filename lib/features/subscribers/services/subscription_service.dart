import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class SubscriptionService extends ChangeNotifier {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  bool _hasActivePass = false;
  bool get hasActivePass => _hasActivePass;

  Set<String> _subscribedGymIds = {};
  Set<String> get subscribedGymIds => _subscribedGymIds;

  String _getUserPrefix() {
    try {
      if (Firebase.apps.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          return 'user_${user.uid}_';
        }
      }
    } catch (_) {}
    return 'user_anonymous_';
  }

  Future<void> loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _getUserPrefix();
    _hasActivePass = prefs.getBool('${prefix}alpamys_pass_active') ?? false;
    final gymIdsList = prefs.getStringList('${prefix}subscribed_gym_ids') ?? [];
    _subscribedGymIds = gymIdsList.toSet();
    notifyListeners();
  }

  Future<void> activatePass() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _getUserPrefix();
    await prefs.setBool('${prefix}alpamys_pass_active', true);
    _hasActivePass = true;
    notifyListeners();
  }

  Future<void> deactivatePass() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _getUserPrefix();
    await prefs.setBool('${prefix}alpamys_pass_active', false);
    _hasActivePass = false;
    notifyListeners();
  }

  Future<void> subscribeToGym(String gymId) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _getUserPrefix();
    _subscribedGymIds.add(gymId);
    await prefs.setStringList('${prefix}subscribed_gym_ids', _subscribedGymIds.toList());
    notifyListeners();
  }

  Future<void> unsubscribeFromGym(String gymId) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _getUserPrefix();
    _subscribedGymIds.remove(gymId);
    await prefs.setStringList('${prefix}subscribed_gym_ids', _subscribedGymIds.toList());
    notifyListeners();
  }

  bool isSubscribedToGym(String gymId) {
    return _subscribedGymIds.contains(gymId);
  }

  void clearCache() {
    _hasActivePass = false;
    _subscribedGymIds = {};
    notifyListeners();
  }
}
