import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService extends ChangeNotifier {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal() {
    _loadFromPrefs();
  }

  final List<Map<String, dynamic>> _favoriteProducts = [];

  List<Map<String, dynamic>> get favoriteProducts => _favoriteProducts;

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('favorites_products_json') ?? [];
      _favoriteProducts.clear();
      for (var item in saved) {
        _favoriteProducts.add(jsonDecode(item) as Map<String, dynamic>);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _favoriteProducts.map((p) => jsonEncode(p)).toList();
      await prefs.setStringList('favorites_products_json', list);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  bool isFavorite(Map<String, dynamic> product) {
    return _favoriteProducts.any((p) => p['name'] == product['name']);
  }

  void toggleFavorite(Map<String, dynamic> product) {
    if (isFavorite(product)) {
      _favoriteProducts.removeWhere((p) => p['name'] == product['name']);
    } else {
      _favoriteProducts.add(Map<String, dynamic>.from(product));
    }
    _saveToPrefs();
    notifyListeners();
  }

  void addFavorite(Map<String, dynamic> product) {
    if (!isFavorite(product)) {
      _favoriteProducts.add(Map<String, dynamic>.from(product));
      _saveToPrefs();
      notifyListeners();
    }
  }

  void removeFavorite(Map<String, dynamic> product) {
    _favoriteProducts.removeWhere((p) => p['name'] == product['name']);
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> initializeFromProducts(List<Map<String, dynamic>> products) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('favorites_products_json')) {
      return;
    }
    _favoriteProducts.clear();
    for (var product in products) {
      if (product['isFavorite'] == true) {
        // format price if not formatted yet
        final uiProduct = Map<String, dynamic>.from(product);
        final rawPrice = uiProduct['price'];
        if (rawPrice != null && rawPrice is num) {
          uiProduct['price'] = '${rawPrice.toStringAsFixed(0)} TL';
        }
        _favoriteProducts.add(uiProduct);
      }
    }
    await _saveToPrefs();
    notifyListeners();
  }
}
