import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService extends ChangeNotifier {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  bool _hasActivePass = false;
  bool get hasActivePass => _hasActivePass;

  Set<String> _subscribedGymIds = {};
  Set<String> get subscribedGymIds => _subscribedGymIds;

  Future<void> loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    _hasActivePass = prefs.getBool('alpamys_pass_active') ?? false;
    final gymIdsList = prefs.getStringList('subscribed_gym_ids') ?? [];
    _subscribedGymIds = gymIdsList.toSet();
    notifyListeners();
  }

  Future<void> activatePass() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alpamys_pass_active', true);
    _hasActivePass = true;
    notifyListeners();
  }

  Future<void> deactivatePass() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alpamys_pass_active', false);
    _hasActivePass = false;
    notifyListeners();
  }

  Future<void> subscribeToGym(String gymId) async {
    final prefs = await SharedPreferences.getInstance();
    _subscribedGymIds.add(gymId);
    await prefs.setStringList('subscribed_gym_ids', _subscribedGymIds.toList());
    notifyListeners();
  }

  Future<void> unsubscribeFromGym(String gymId) async {
    final prefs = await SharedPreferences.getInstance();
    _subscribedGymIds.remove(gymId);
    await prefs.setStringList('subscribed_gym_ids', _subscribedGymIds.toList());
    notifyListeners();
  }

  bool isSubscribedToGym(String gymId) {
    return _subscribedGymIds.contains(gymId);
  }
}
