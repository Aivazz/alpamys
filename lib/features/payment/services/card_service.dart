import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the last-4 digits, cardholder name and expiry stored on device.
class SavedCard {
  final String last4;
  final String cardholderName;
  final String expiry; // "MM/YY"

  const SavedCard({
    required this.last4,
    required this.cardholderName,
    required this.expiry,
  });

  String get maskedNumber => '••••  ••••  ••••  $last4';
}

class CardService extends ChangeNotifier {
  static final CardService _instance = CardService._internal();
  factory CardService() => _instance;
  CardService._internal();

  SavedCard? _savedCard;
  SavedCard? get savedCard => _savedCard;
  bool get hasCard => _savedCard != null;

  /// Call once at startup (e.g. in initState of root widget).
  Future<void> loadCard() async {
    final prefs = await SharedPreferences.getInstance();
    final last4 = prefs.getString('card_last4');
    final name = prefs.getString('card_name');
    final expiry = prefs.getString('card_expiry');
    if (last4 != null && name != null && expiry != null) {
      _savedCard = SavedCard(last4: last4, cardholderName: name, expiry: expiry);
      notifyListeners();
    }
  }

  Future<void> saveCard({
    required String last4,
    required String cardholderName,
    required String expiry,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('card_last4', last4);
    await prefs.setString('card_name', cardholderName);
    await prefs.setString('card_expiry', expiry);
    _savedCard = SavedCard(last4: last4, cardholderName: cardholderName, expiry: expiry);
    notifyListeners();
  }

  Future<void> clearCard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('card_last4');
    await prefs.remove('card_name');
    await prefs.remove('card_expiry');
    _savedCard = null;
    notifyListeners();
  }
}
