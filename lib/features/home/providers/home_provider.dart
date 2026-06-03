import 'package:flutter/material.dart';
import '../data/home_repository.dart';

class HomeProvider extends ChangeNotifier {
  final _repository = HomeRepository();
  String _selectedGoal = 'Lose Weight';

  String get selectedGoal => _selectedGoal;
  List<String> get goals => _repository.getGoals();

  void selectGoal(String goal) {
    _selectedGoal = goal;
    notifyListeners();
  }
}
