import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final _repository = AuthRepository();
  bool _isLoading = false;
  String? _currentUser;

  bool get isLoading => _isLoading;
  String? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.login(email, password);
      if (success) {
        _currentUser = 'Damir';
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.signUp(name, email, password);
      if (success) {
        _currentUser = name;
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
