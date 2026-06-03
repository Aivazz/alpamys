// lib/features/training/data/training_repository.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../core/services/api_service.dart';

class TrainingRepository {
  // Получение токена Firebase (аналог приватного метода ApiService)
  Future<String?> _getIdToken() async {
    try {
      if (Firebase.apps.isEmpty) return 'mock-firebase-token';
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) return await user.getIdToken();
    } catch (e) {
      debugPrint('Error getting token: $e');
    }
    return 'mock-firebase-token';
  }

  // Получение сгенерированного плана тренировок с Go-сервера
  Future<List<Map<String, dynamic>>> getRemoteWorkoutPlan() async {
    try {
      final token = await _getIdToken();
      final url = '${ApiService.baseUrl}/user/workout-plan';

      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(decoded);
      }
      throw Exception('Plan yükleme hatası: ${res.body}');
    } catch (e) {
      debugPrint('Backend unreachable, using fallback workout plan: $e');
      // Offline-First fallback — локальные данные
      return [
        {
          'title': 'Tüm Vücut (Full Body) Adaptasyon',
          'level': 'Başlangıç',
          'duration': '60 dk',
          'days': 'Haftada 3 Gün',
          'desc': 'Kas adaptasyonunu sağlamak için temel birleşik hareketler.',
          'image':
              'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500&auto=format&fit=crop&q=80',
          'exercises': [
            {
              'name': 'Barbell Squat',
              'sets': '4 Set x 10 Tekrar',
              'desc': 'Bacak ve kalça gelişimi.',
              'duration': '6 dk',
            },
            {
              'name': 'Bench Press',
              'sets': '4 Set x 10 Tekrar',
              'desc': 'Göğüs ve omuz itiş gücü.',
              'duration': '6 dk',
            },
            {
              'name': 'Barbell Row',
              'sets': '4 Set x 8 Tekrar',
              'desc': 'Sırt ve çekiş kuvveti.',
              'duration': '5 dk',
            },
          ],
        },
      ];
    }
  }
}
