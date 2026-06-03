import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GymVisit {
  final String gymId;
  final String gymName;
  final String gymImage;
  final DateTime visitedAt;

  GymVisit({
    required this.gymId,
    required this.gymName,
    required this.gymImage,
    required this.visitedAt,
  });

  Map<String, dynamic> toJson() => {
        'gymId': gymId,
        'gymName': gymName,
        'gymImage': gymImage,
        'visitedAt': visitedAt.toIso8601String(),
      };

  factory GymVisit.fromJson(Map<String, dynamic> json) => GymVisit(
        gymId: json['gymId'] as String,
        gymName: json['gymName'] as String,
        gymImage: json['gymImage'] as String? ?? '',
        visitedAt: DateTime.parse(json['visitedAt'] as String),
      );
}

class GymVisitService extends ChangeNotifier {
  static final GymVisitService _instance = GymVisitService._internal();
  factory GymVisitService() => _instance;
  GymVisitService._internal();

  List<GymVisit> _visits = [];
  List<GymVisit> get visits => List.unmodifiable(_visits);

  static const String _key = 'gym_visit_history_v1';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _visits = raw
        .map((e) => GymVisit.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
    _visits.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
    notifyListeners();
  }

  Future<void> recordVisit({
    required String gymId,
    required String gymName,
    required String gymImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final visit = GymVisit(
      gymId: gymId,
      gymName: gymName,
      gymImage: gymImage,
      visitedAt: DateTime.now(),
    );
    // Keep max 20 visits, no duplicate on same day
    _visits.removeWhere((v) =>
        v.gymId == gymId &&
        v.visitedAt.year == visit.visitedAt.year &&
        v.visitedAt.month == visit.visitedAt.month &&
        v.visitedAt.day == visit.visitedAt.day);
    _visits.insert(0, visit);
    if (_visits.length > 20) _visits = _visits.sublist(0, 20);
    await prefs.setStringList(_key, _visits.map((e) => jsonEncode(e.toJson())).toList());
    notifyListeners();
  }
}
